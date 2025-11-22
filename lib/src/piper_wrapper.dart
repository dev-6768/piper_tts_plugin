import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:piper_phonemizer_plugin/piper_phonemizer_plugin.dart';
import 'package:piper_tts_plugin/src/piper_logger.dart';
import 'package:piper_tts_plugin/src/piper_model_config.dart';
import 'package:piper_tts_plugin/enums/piper_voice_pack.dart';
import 'package:piper_tts_plugin/src/voice_pack_manager.dart';

class PiperTTS {
  PiperTTS._private(); // private constructor
  static final PiperTTS instance = PiperTTS._private(); // singleton instance

  OrtSession? _session;
  PiperModelConfig? _config;
  Completer<void>? _piperSetupCompleter;
  PiperPhonemizerPlugin phonemizer = PiperPhonemizerPlugin();

  bool get isLoaded => _session != null && _config != null;

  /// ---------------------------------------------------------
  /// LOAD PIPER MODEL + CONFIG + Piper-Phonemizer
  /// ---------------------------------------------------------
  Future<void> load({
    required String modelPath,
    required String configPath,
  }) async {
    if (!File(modelPath).existsSync()) {
      throw Exception("Model not found: $modelPath");
    }
    if (!File(configPath).existsSync()) {
      throw Exception("Config not found: $configPath");
    }

    // Load model config
    _config =
        PiperModelConfig(jsonDecode(await File(configPath).readAsString()));

    // Load ONNX model
    _session = OrtSession.fromFile(
      File(modelPath),
      OrtSessionOptions(),
    );

    await setupPhonemizer();

    PiperLogger.instance.debug("Piper model + config + eSpeak loaded.");
  }

  Future<void> setupPhonemizer() async {
    if(_piperSetupCompleter != null) {
      PiperLogger.instance.debug("⏳ Waiting for existing eSpeak setup to finish...");
      return _piperSetupCompleter!.future;
    }

    _piperSetupCompleter = Completer<void>();

    try {
      PiperLogger.instance.debug("Initialized Phonemizer please wait ..");
      await phonemizer.initialize();
      PiperLogger.instance.debug("Phonemizer initialized successfully.. setting up voice.");
      phonemizer.setVoice(_config!.espeakVoice());
      PiperLogger.instance.debug("Voice found and set up successfully.");


      if (!_piperSetupCompleter!.isCompleted) {
        _piperSetupCompleter!.complete();
      }
    }


    catch (e, st) {
      PiperLogger.instance.error("❌ Failed to initialize eSpeak: $e\n$st");

      if (!_piperSetupCompleter!.isCompleted) {
        _piperSetupCompleter!.completeError(e, st);
      }

      rethrow;
    } 
    
    finally {
      // Reset completer after completion (success or error)
      PiperLogger.instance.debug("Ending eSpeak Initialization.");
      _piperSetupCompleter = null;
    }    
  }


  Future<void> loadVoice(PiperVoicePack pack) async {
    final paths = await PiperVoicePackManager.getFiles(pack);
    
    await load(
      modelPath: paths.modelPath,
      configPath: paths.jsonPath,
    );
  }


  /// ---------------------------------------------------------
  /// PHONEMES (text → piper phonemes via espeak)
  /// ---------------------------------------------------------
  Future<String> textToPhonemes(String text) async {
    final p = phonemizer.getPhonemesString(text);
    PiperLogger.instance.debug("Phonemes: $p");
    return p;
  }

  /// ---------------------------------------------------------
  /// MAP PHONEMES → LIST of int using phoneme_id_map
  /// ---------------------------------------------------------
  List<int> phonemesToIds(String phonemes) {
    if (_config == null) throw Exception("Config missing");

    final map = _config!.phonemeIdMap();
    final ids = <int>[];

    for (final c in phonemes.split('')) {
      if (map.containsKey(c)) {
        ids.add(map[c]!.first);
      }
    }

    return phonemeIdPadding(ids);
  }

  /// ---------------------------------------------------------
  /// ONNX INFERENCE — returns Float32List PCM
  /// ---------------------------------------------------------
  Future<Float32List> synthesizePcm(List<int> ids) async {
    if (_session == null) throw Exception("Model not loaded");

    final input =
        OrtValueTensor.createTensorWithDataList(ids, [1, ids.length]);

    final inputLengths =
        OrtValueTensor.createTensorWithDataList([ids.length], [1]);

    final scales = OrtValueTensor.createTensorWithDataList(
      //getScale() defaults to [1.0, 0.667, 0.8], scale on which usual piper models get trained on
      Float32List.fromList(_config!.getScale()), 
      [3],
    );

    final output = _session!.run(
      OrtRunOptions(),
      {
        "input": input,
        "input_lengths": inputLengths,
        "scales": scales,
      },
    );

    final value = (output.first as OrtValueTensor).value;

    input.release();
    inputLengths.release();
    for (final o in output) {
      o?.release();
    }

    return Float32List.fromList(_flatten(value));
  }

  /// ---------------------------------------------------------
  /// SAVE TO WAV
  /// ---------------------------------------------------------
  Future<File> synthesizeToFile({
    required String text,
    required String path,
  }) async {
    final phon = await textToPhonemes(text);
    final ids = phonemesToIds(phon);
    final pcm = await synthesizePcm(ids);

    final wav = _pcmToWav(pcm, 22050);
    final file = File(path);
    await file.writeAsBytes(wav);

    return file;
  }

  /// ---------------------------------------------------------
  /// UTIL: flatten ONNX nested lists
  /// ---------------------------------------------------------
  

  /// ---------------------------------------------------------
  /// UTIL: PCM float32 → WAV bytes
  /// ---------------------------------------------------------
  List<int> _pcmToWav(Float32List pcm, int sampleRate) {
    final bd = ByteData(44 + pcm.length * 2);
    final dataSize = pcm.length * 2;

    void write(int o, String s) {
      for (int i = 0; i < s.length; i++) {
        bd.setUint8(o + i, s.codeUnitAt(i));
      }
    }

    write(0, 'RIFF');
    bd.setUint32(4, 36 + dataSize, Endian.little);
    write(8, 'WAVE');
    write(12, 'fmt ');
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, 1, Endian.little);
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    write(36, 'data');
    bd.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (final s in pcm) {
      final v = (s * 32767).clamp(-32768, 32767).toInt();
      bd.setInt16(offset, v, Endian.little);
      offset += 2;
    }

    return bd.buffer.asUint8List();
  }


  List<double> _flatten(dynamic x) {
    if (x is List) {
      return x.expand((e) => _flatten(e)).toList();
    }
    if (x is double) return [x];
    return [];
  }

  static List<int> phonemeIdPadding(List<int> phonemeList) {
    final int n = phonemeList.length;
    final int size = 2 * n + 3; // [1, 0, a1, 0, a2, 0, ..., an, 0, 2]
    final List<int> padded = List.filled(size, 0);

    padded[0] = 1;              // Start marker
    padded[size - 1] = 2;       // End marker

    for (int i = 0; i < n; i++) {
      padded[2 * i + 2] = phonemeList[i];
    }

    return padded;
  }
}
