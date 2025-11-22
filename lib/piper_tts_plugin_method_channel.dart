import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'piper_tts_plugin_platform_interface.dart';

/// An implementation of [PiperTtsPluginPlatform] that uses method channels.
class MethodChannelPiperTtsPlugin extends PiperTtsPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('piper_tts_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
