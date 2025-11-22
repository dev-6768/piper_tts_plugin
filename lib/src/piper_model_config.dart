import 'package:piper_tts_plugin/src/piper_logger.dart';

class PiperModelConfig {
  final Map<String, dynamic> json;
  PiperModelConfig(this.json);

  Map<String, List<int>> phonemeIdMap() {
    try {
      return (json['phoneme_id_map'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, List<int>.from(v)));
    }

    catch(err) {
      PiperLogger.instance.error("Some error occured in PiperTtsPlugin : ${err.toString()}");
      throw Exception("Some error occured : $err");
    }
    
  }   

  String espeakVoice() {
    try {
      return json["espeak"]["voice"];
    }

    catch(err) {
      PiperLogger.instance.error("Some error occured in PiperTtsPlugin : ${err.toString()}");
      throw Exception("Some error occured : $err");
    }
  }

  List<double> getScale() {
    //defaults to norman scale.
    try {
      final inference = json["inference"];
      final noiseScale = double.tryParse("${inference["noise_scale"] ?? "0.667"}") ;
      final lengthScale = double.tryParse("${inference["length_scale"] ?? "1"}");
      final noiseW = double.tryParse("${inference["noise_w"] ?? "0.8"}");

      return [lengthScale ?? 1, noiseScale ?? 0.667, noiseW ?? 0.8];
    }
    
    catch(err) {
      PiperLogger.instance.error("Some error occured in PiperTtsPlugin : ${err.toString()}");
      throw Exception("Some error occured : $err");
    }

  } 
}
