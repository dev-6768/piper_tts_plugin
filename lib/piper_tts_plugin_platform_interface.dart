import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'piper_tts_plugin_method_channel.dart';

abstract class PiperTtsPluginPlatform extends PlatformInterface {
  /// Constructs a PiperTtsPluginPlatform.
  PiperTtsPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static PiperTtsPluginPlatform _instance = MethodChannelPiperTtsPlugin();

  /// The default instance of [PiperTtsPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelPiperTtsPlugin].
  static PiperTtsPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PiperTtsPluginPlatform] when
  /// they register themselves.
  static set instance(PiperTtsPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
