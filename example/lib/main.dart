import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piper_tts_plugin/piper_tts_plugin.dart';
import 'package:piper_tts_plugin/enums/piper_voice_pack.dart';

void main() {
  runApp(const PiperExampleApp());
}

class PiperExampleApp extends StatelessWidget {
  const PiperExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Piper TTS Example",
      debugShowCheckedModeBanner: false,
      home: const PiperHomePage(),
    );
  }
}

class PiperHomePage extends StatefulWidget {
  const PiperHomePage({super.key});

  @override
  State<PiperHomePage> createState() => _PiperHomePageState();
}

class _PiperHomePageState extends State<PiperHomePage> {
  final PiperTtsPlugin _tts = PiperTtsPlugin();
  final TextEditingController _textController =
      TextEditingController(text: "Hello from Piper TTS!");

  PiperVoicePack _selectedVoice = PiperVoicePack.norman;

  bool _loadingVoice = false;
  bool _synthesizing = false;

  final AudioPlayer _player = AudioPlayer();
  File? _generatedFile;

  // ========================================
  // LOAD SELECTED VOICE MODEL
  // ========================================

  Future<void> _loadVoice() async {
    setState(() => _loadingVoice = true);

    try {
      await _tts.loadViaVoicePack(_selectedVoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${_selectedVoice.name} loaded successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading model: $e")),
        );
      }
    } 
    
    finally {
      if (mounted) setState(() => _loadingVoice = false);
    }
  }

  // ========================================
  // SYNTHESIZE TO WAV FILE
  // ========================================
  Future<void> _synthesize() async {
    setState(() => _synthesizing = true);

    try {
      final dir = await getTemporaryDirectory();
      final out = File("${dir.path}/piper_output.wav");

      final file = await _tts.synthesizeToFile(
        text: _textController.text.trim(),
        outputPath: out.path,
      );

      _generatedFile = file;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Audio generated: ${file.path}")),
        );
      }

      await _player.setFilePath(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error synthesizing: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _synthesizing = false);
    }
  }

  // ========================================
  // PLAYBACK
  // ========================================
  Future<void> _play() async {
    if (_generatedFile == null) return;

    try {
      await _player.play();
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Piper TTS Example")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Choose Voice:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),

              DropdownButton<PiperVoicePack>(
                value: _selectedVoice,
                isExpanded: true,
                items: PiperVoicePack.values
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedVoice = v!),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadingVoice ? null : _loadVoice,
                child: _loadingVoice
                    ? const CircularProgressIndicator()
                    : const Text("Load Voice Model"),
              ),

              const SizedBox(height: 32),
              TextField(
                controller: _textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Enter text to speak",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (_loadingVoice || _synthesizing) ? null : _synthesize,
                child: _synthesizing
                    ? const CircularProgressIndicator()
                    : const Text("Generate WAV"),
              ),

              const SizedBox(height: 24),
              if (_generatedFile != null)
                ElevatedButton(
                  onPressed: _play,
                  child: const Text("Play Audio"),
                ),

              if (_generatedFile == null)
                const Text("No audio generated yet.",
                    style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
