
import 'package:piper_tts_plugin/enums/piper_voice_pack.dart';

import 'src/piper_wrapper.dart';
import 'piper_tts_plugin_platform_interface.dart';
import 'dart:io';

class PiperTtsPlugin {
  final _tts = PiperTTS.instance;

  Future<void> loadViaPath({
    required String modelPath,
    required String configPath,
  }) {
    return _tts.load(
      modelPath: modelPath,
      configPath: configPath,
    );
  }

  Future<void> loadViaVoicePack(PiperVoicePack voicePack) {
    return _tts.loadVoice(voicePack);
  }

  Future<File> synthesizeToFile({
    required String text,
    required String outputPath,
  }) {
    return _tts.synthesizeToFile(
      text: text,
      path: outputPath,
    );
  }
  bool get isLoaded => _tts.isLoaded;

  Future<String?> getPlatformVersion() {
    return PiperTtsPluginPlatform.instance.getPlatformVersion();
  }
}
