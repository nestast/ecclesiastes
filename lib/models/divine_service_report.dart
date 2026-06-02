import 'report_base.dart';
import 'report_type.dart';
import 'audio_segment.dart';

class DivineServiceReport extends ReportBase {
  DateTime? serviceDate;
  String? serviceType;
  int attendance;
  List<String> speakers;
  String? theme;
  String? summary;
  List<String> hymns;
  Map<String, String> collections;
  String? nextServiceDate;
  List<String> observations;

  DivineServiceReport({
    String? id,
    required String title,
    required String author,
    DateTime? createdAt,
    this.serviceDate,
    this.serviceType,
    this.attendance = 0,
    List<String>? speakers,
    this.theme,
    this.summary,
    List<String>? hymns,
    Map<String, String>? collections,
    this.nextServiceDate,
    List<String>? observations,
    List<AudioSegment>? audioSegments,
    Map<String, dynamic>? metadata,
    bool isCompleted = false,
  }) : speakers = speakers ?? [],
      hymns = hymns ?? [],
      collections = collections ?? {},
      observations = observations ?? [],
      super(
        id: id,
        type: ReportType.divineService,
        title: title,
        author: author,
        createdAt: createdAt,
        audioSegments: audioSegments,
        metadata: metadata,
        isCompleted: isCompleted,
      );

  @override
  List<String> validate() {
    final errors = <String>[];
    if (title.isEmpty) errors.add('Le titre du rapport est requis');
    if (serviceDate == null) errors.add('La date du service est requise');
    if (attendance < 0) errors.add('Le nombre de participants invalide');
    if (speakers.isEmpty) errors.add('Au moins un orateur est requis');
    return errors;
  }

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'serviceDate': serviceDate?.toIso8601String(),
      'serviceType': serviceType,
      'attendance': attendance,
      'speakers': speakers,
      'theme': theme,
      'summary': summary,
      'hymns': hymns,
      'collections': collections,
      'nextServiceDate': nextServiceDate,
      'observations': observations,
    });
    return base;
  }

  factory DivineServiceReport.fromJson(Map<String, dynamic> json) {
    return DivineServiceReport(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
      serviceDate: json['serviceDate'] != null ? DateTime.parse(json['serviceDate']) : null,
      serviceType: json['serviceType'],
      attendance: json['attendance'] ?? 0,
      speakers: List<String>.from(json['speakers'] ?? []),
      theme: json['theme'],
      summary: json['summary'],
      hymns: List<String>.from(json['hymns'] ?? []),
      collections: Map<String, String>.from(json['collections'] ?? {}),
      nextServiceDate: json['nextServiceDate'],
      observations: List<String>.from(json['observations'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
