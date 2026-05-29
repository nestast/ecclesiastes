import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  String? _currentRecordingPath;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;

  Stream<Duration> get recordingDurationStream => Stream.periodic(
    const Duration(milliseconds: 100),
    (_) => _recordingDuration,
  );

  Future<bool> requestPermission() async {
    final hasPermission = await _recorder.hasPermission();
    return hasPermission;
  }

  Future<String?> startRecording(String section) async {
    try {
      if (await requestPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final audioDir = Directory('${dir.path}/reports_audio');
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
        }

        final fileName = 'report_${section}_${const Uuid().v4()}.m4a';
        _currentRecordingPath = '${audioDir.path}/$fileName';

        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath!,
        );

        _isRecording = true;
        _recordingDuration = Duration.zero;
        
        return _currentRecordingPath;
      }
      return null;
    } catch (e) {
      logger.e('Erreur lors du démarrage de l\'enregistrement: $e');
      return null;
    }
  }

  Future<Duration?> stopRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
        return _recordingDuration;
      }
      return null;
    } catch (e) {
      logger.e('Erreur lors de l\'arrêt de l\'enregistrement: $e');
      return null;
    }
  }

  Future<void> pauseRecording() async {
    if (_isRecording) {
      await _recorder.pause();
    }
  }

  Future<void> resumeRecording() async {
    if (!_isRecording && _currentRecordingPath != null) {
      await _recorder.resume();
      _isRecording = true;
    }
  }

  Future<void> playAudio(String filePath) async {
    try {
      await _player.play(DeviceFileSource(filePath));
    } catch (e) {
      logger.e('Erreur lors de la lecture: $e');
    }
  }

  Future<void> pausePlayback() async {
    await _player.pause();
  }

  Future<void> resumePlayback() async {
    await _player.resume();
  }

  Future<void> stopPlayback() async {
    await _player.stop();
  }

  Stream<Duration?> get playerPositionStream => _player.onPositionChanged;
  
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  Duration? get currentRecordingDuration => _recordingDuration;

  bool get isRecording => _isRecording;

  Future<void> deleteAudio(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      logger.e('Erreur lors de la suppression du fichier audio: $e');
    }
  }

  Future<int?> getAudioDuration(String filePath) async {
    try {
      final duration = await _player.getDuration();
      return duration?.inSeconds;
    } catch (e) {
      logger.e('Erreur lors de l\'obtention de la durée: $e');
      return null;
    }
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
