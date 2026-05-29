import 'package:uuid/uuid.dart';

class AudioSegment {
  final String id;
  final String filePath;
  final String? transcription;
  final Duration duration;
  final DateTime createdAt;
  final String section;
  bool isProcessed;

  AudioSegment({
    String? id,
    required this.filePath,
    this.transcription,
    required this.duration,
    required this.section,
    DateTime? createdAt,
    this.isProcessed = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'transcription': transcription,
      'duration': duration.inSeconds,
      'section': section,
      'createdAt': createdAt.toIso8601String(),
      'isProcessed': isProcessed,
    };
  }

  factory AudioSegment.fromJson(Map<String, dynamic> json) {
    return AudioSegment(
      id: json['id'],
      filePath: json['filePath'],
      transcription: json['transcription'],
      duration: Duration(seconds: json['duration'] ?? 0),
      section: json['section'],
      createdAt: DateTime.parse(json['createdAt']),
      isProcessed: json['isProcessed'] ?? false,
    );
  }
}
