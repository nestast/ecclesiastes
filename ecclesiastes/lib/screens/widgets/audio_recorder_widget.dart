import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/audio_service.dart';

class AudioRecorderWidget extends StatefulWidget {
  final String section;
  final Function(String filePath, Duration duration) onRecordingComplete;
  final VoidCallback? onRecordingStart;

  const AudioRecorderWidget({
    Key? key,
    required this.section,
    required this.onRecordingComplete,
    this.onRecordingStart,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  late AudioService _audioService;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _setupAudioService();
  }

  void _setupAudioService() {
    _audioService.recordingDurationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _recordingDuration = duration;
        });
      }
    });
  }

  Future<void> _startRecording() async {
    widget.onRecordingStart?.call();
    final filePath = await _audioService.startRecording(widget.section);
    if (filePath != null) {
      setState(() {
        _isRecording = true;
        _recordedFilePath = filePath;
        _recordingDuration = Duration.zero;
      });
    }
  }

  Future<void> _stopRecording() async {
    final duration = await _audioService.stopRecording();
    if (duration != null && _recordedFilePath != null) {
      setState(() {
        _isRecording = false;
      });
      widget.onRecordingComplete(_recordedFilePath!, duration);
    }
  }

  Future<void> _pauseRecording() async {
    await _audioService.pauseRecording();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _resumeRecording() async {
    await _audioService.resumeRecording();
    setState(() {
      _isRecording = true;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String hours = twoDigits(duration.inHours);
    return duration.inHours > 0 ? "$hours:$twoDigitMinutes:$twoDigitSeconds" : "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.section,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isRecording)
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isRecording)
                  ElevatedButton.icon(
                    onPressed: _startRecording,
                    icon: const Icon(Icons.mic),
                    label: const Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: _pauseRecording,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _stopRecording,
                    icon: const Icon(Icons.stop),
                    label: const Text('Arrêter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
