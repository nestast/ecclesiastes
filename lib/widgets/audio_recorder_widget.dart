import 'package:flutter/material.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(String)? onRecordingComplete;

  const AudioRecorderWidget({
    this.onRecordingComplete,
    Key? key,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  bool isRecording = false;
  String duration = '0:00';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enregistrement audio', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    setState(() {
                      isRecording = !isRecording;
                    });
                  },
                  child: Icon(isRecording ? Icons.stop : Icons.mic),
                ),
                const SizedBox(width: 16),
                Text(
                  duration,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
