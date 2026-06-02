import 'report_base.dart';
import 'report_type.dart';
import 'audio_segment.dart';

class VisitReport extends ReportBase {
  String? location;
  String? hierarchy;
  String? visitReason;
  DateTime? visitDate;
  List<String> visitedPeople;
  String? observations;
  String? findings;
  List<String> recommendations;
  String? conclusion;

  VisitReport({
    String? id,
    required String title,
    required String author,
    DateTime? createdAt,
    this.location,
    this.hierarchy,
    this.visitReason,
    this.visitDate,
    List<String>? visitedPeople,
    this.observations,
    this.findings,
    List<String>? recommendations,
    this.conclusion,
    List<AudioSegment>? audioSegments,
    Map<String, dynamic>? metadata,
    bool isCompleted = false,
  }) : visitedPeople = visitedPeople ?? [],
      recommendations = recommendations ?? [],
      super(
        id: id,
        type: ReportType.visit,
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
    if (visitDate == null) errors.add('La date de la visite est requise');
    if (location?.isEmpty ?? true) errors.add('Le lieu de la visite est requis');
    if (observations?.isEmpty ?? true) errors.add('Les observations sont requises');
    return errors;
  }

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'location': location,
      'hierarchy': hierarchy,
      'visitReason': visitReason,
      'visitDate': visitDate?.toIso8601String(),
      'visitedPeople': visitedPeople,
      'observations': observations,
      'findings': findings,
      'recommendations': recommendations,
      'conclusion': conclusion,
    });
    return base;
  }

  factory VisitReport.fromJson(Map<String, dynamic> json) {
    return VisitReport(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
      location: json['location'],
      hierarchy: json['hierarchy'],
      visitReason: json['visitReason'],
      visitDate: json['visitDate'] != null ? DateTime.parse(json['visitDate']) : null,
      visitedPeople: List<String>.from(json['visitedPeople'] ?? []),
      observations: json['observations'],
      findings: json['findings'],
      recommendations: List<String>.from(json['recommendations'] ?? []),
      conclusion: json['conclusion'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
