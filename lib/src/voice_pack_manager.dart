import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:piper_tts_plugin/enums/piper_voice_pack.dart';
import 'package:piper_tts_plugin/src/piper_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class PiperVoicePackManager {
  static Future<PiperVoicePaths> getFiles(PiperVoicePack pack) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedModel = prefs.getString(pack.modelPrefKey);
      final savedJson = prefs.getString(pack.jsonPrefKey);

      if (savedModel != null &&
          File(savedModel).existsSync() &&
          savedJson != null &&
          File(savedJson).existsSync()) {
        return PiperVoicePaths(savedModel, savedJson);
      }

      // fresh download
      final uuidGen = Uuid();
      final uniqueId = uuidGen.v4();
      uniqueId.replaceAll("-", "_");

      final modelPath =
          await _download(pack.modelUrl, "${pack.name}_piper_voice_model_${uniqueId}_model.onnx");

      final jsonPath =
          await _download(pack.jsonUrl, "${pack.name}_piper_voice_model_${uniqueId}_config.json");

      await prefs.setString(pack.modelPrefKey, modelPath);
      await prefs.setString(pack.jsonPrefKey, jsonPath);

      return PiperVoicePaths(modelPath, jsonPath);
    }

    catch(err) {
      throw Exception("Some error occured in getting the model files : $err");
    }
    
  }

  static Future<String> _download(String url, String fileName) async {
    try {
      PiperLogger.instance.info("Please Wait, downloading $url...");
      final dir = await getApplicationSupportDirectory();
      final file = File("${dir.path}/$fileName");

      final response = await http.Client().get(Uri.parse(url));
      await file.writeAsBytes(response.bodyBytes);

      PiperLogger.instance.info("download of $url complete. returning file path.");

      return file.path;
    }

    catch(err) {
      throw Exception("Download Failed. It required consistent internet to download voice model files. Please try again : $err");
    }
    
  }
}

class PiperVoicePaths {
  final String modelPath;
  final String jsonPath;

  PiperVoicePaths(this.modelPath, this.jsonPath);
}
