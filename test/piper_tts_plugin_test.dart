import 'package:flutter_test/flutter_test.dart';
import 'package:piper_tts_plugin/piper_tts_plugin.dart';
import 'package:piper_tts_plugin/piper_tts_plugin_platform_interface.dart';
import 'package:piper_tts_plugin/piper_tts_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPiperTtsPluginPlatform
    with MockPlatformInterfaceMixin
    implements PiperTtsPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PiperTtsPluginPlatform initialPlatform = PiperTtsPluginPlatform.instance;

  test('$MethodChannelPiperTtsPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPiperTtsPlugin>());
  });

  test('getPlatformVersion', () async {
    PiperTtsPlugin piperTtsPlugin = PiperTtsPlugin();
    MockPiperTtsPluginPlatform fakePlatform = MockPiperTtsPluginPlatform();
    PiperTtsPluginPlatform.instance = fakePlatform;

    expect(await piperTtsPlugin.getPlatformVersion(), '42');
  });
}
