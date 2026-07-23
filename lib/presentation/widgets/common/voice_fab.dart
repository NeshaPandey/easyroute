// lib/presentation/widgets/common/voice_fab.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/theme/app_theme.dart';

class VoiceFab extends StatefulWidget {
  final Function(String) onVoiceResult;
  const VoiceFab({super.key, required this.onVoiceResult});

  @override
  State<VoiceFab> createState() => _VoiceFabState();
}

class _VoiceFabState extends State<VoiceFab> with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.stop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      _ctrl.stop();
      _ctrl.reset();
      return;
    }

    final available = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          setState(() => _isListening = false);
          _ctrl.stop();
          _ctrl.reset();
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _ctrl.repeat(reverse: true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            widget.onVoiceResult(result.recognizedWords);
          }
        },
        localeId: 'en_IN',
      );
    } else {
      // Show fallback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone not available')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _isListening ? _scale.value : 1.0,
        child: child,
      ),
      child: FloatingActionButton.extended(
        onPressed: _toggle,
        backgroundColor: _isListening ? AppColors.error : AppColors.primary,
        icon: Icon(
          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
        ),
        label: Text(
          _isListening ? 'Listening…' : 'Voice search',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
