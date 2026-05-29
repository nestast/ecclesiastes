import 'package:uuid/uuid.dart';
import 'report_type.dart';
import 'audio_segment.dart';

abstract class ReportBase {
  final String id;
  final ReportType type;
  final String title;
  final String author;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<AudioSegment> audioSegments;
  final Map<String, dynamic> metadata;
  bool isCompleted;

  ReportBase({
    String? id,
    required this.type,
    required this.title,
    required this.author,
    DateTime? createdAt,
    this.updatedAt,
    List<AudioSegment>? audioSegments,
    Map<String, dynamic>? metadata,
    this.isCompleted = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        audioSegments = audioSegments ?? [],
        metadata = metadata ?? {};

  void addAudioSegment(AudioSegment segment) {
    audioSegments.add(segment);
  }

  void removeAudioSegment(String segmentId) {
    audioSegments.removeWhere((s) => s.id == segmentId);
  }

  List<String> validate();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'audioSegments': audioSegments.map((a) => a.toJson()).toList(),
      'metadata': metadata,
      'isCompleted': isCompleted,
    };
  }
}
