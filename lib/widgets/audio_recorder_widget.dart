import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class AudioRecorderWidget extends StatefulWidget {
  final String section;
  final Function(String, Duration)? onRecordingComplete;
  final VoidCallback? onRecordingStart;

  const AudioRecorderWidget({
    required this.section,
    this.onRecordingComplete,
    this.onRecordingStart,
    Key? key,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  Duration _duration = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      _stopTimer();
      final path = await _audioService.stopRecording();
      if (path != null && widget.onRecordingComplete != null) {
        widget.onRecordingComplete!(path.toString(), _duration);
      }
      setState(() {
        _isRecording = false;
      });
    } else {
      final path = await _audioService.startRecording(widget.section);
      if (path != null) {
        widget.onRecordingStart?.call();
        setState(() {
          _isRecording = true;
          _duration = Duration.zero;
        });
        _startTimer();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du démarrage de l\'enregistrement')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.section,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isRecording ? Icons.mic : Icons.mic_none,
                      color: _isRecording ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        color: _isRecording ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Arrêter' : 'Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
