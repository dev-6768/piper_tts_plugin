enum PiperVoicePack {
  amy(
    modelUrl:
        "https://huggingface.co/sansoft2402/piper-tts-voices-pdfly/resolve/main/en_US-amy-medium.onnx?download=true",
    jsonUrl:
        "https://dev-6768.github.io/models/model_json_files/amy_voice_model_json.json",
  ),

  john(
    modelUrl:
        "https://huggingface.co/sansoft2402/piper-tts-voices-pdfly/resolve/main/en_US-john-medium.onnx?download=true",
    jsonUrl:
        "https://dev-6768.github.io/models/model_json_files/john_voice_model_json.json",
  ),

  kristin(
    modelUrl:
        "https://huggingface.co/sansoft2402/piper-tts-voices-pdfly/resolve/main/en_US-kristin-medium.onnx?download=true",
    jsonUrl:
        "https://dev-6768.github.io/models/model_json_files/kristin_voice_model_json.json",
  ),

  norman(
    modelUrl:
        "https://huggingface.co/sansoft2402/piper-tts-voices-pdfly/resolve/main/en_US-norman-medium.onnx?download=true",
    jsonUrl:
        "https://dev-6768.github.io/models/model_json_files/norman_voice_model_json.json",
  ),

  rohan(
    modelUrl:
        "https://huggingface.co/sansoft2402/piper-tts-voices-pdfly/resolve/main/hi_IN-rohan-medium.onnx?download=true",
    jsonUrl:
        "https://dev-6768.github.io/models/model_json_files/rohan_voice_model_json.json",
  );

  final String modelUrl;
  final String jsonUrl;

  const PiperVoicePack({
    required this.modelUrl,
    required this.jsonUrl,
  });

  /// SharedPrefs keys
  String get modelPrefKey => "piper_voice_${name}_d14c45738e2e_b1facb04985d_model";
  String get jsonPrefKey => "piper_voice_${name}_d14c45738e2e_b1facb04985d_json";
}
