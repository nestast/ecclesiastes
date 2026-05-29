import 'report_base.dart';
import 'report_type.dart';
import 'audio_segment.dart';

class MeetingReport extends ReportBase {
  String? hierarchy;
  String? meetingType;
  String? meetingObject;
  DateTime? meetingDate;
  String? startTime;
  String? endTime;
  String? president;
  String? secretary;
  List<String> presentees;
  List<String> absentes;
  List<Map<String, String>> discussionPoints;
  List<String> actions;
  Map<String, String> finances;

  MeetingReport({
    String? id,
    required String title,
    required String author,
    DateTime? createdAt,
    this.hierarchy,
    this.meetingType,
    this.meetingObject,
    this.meetingDate,
    this.startTime,
    this.endTime,
    this.president,
    this.secretary,
    List<String>? presentees,
    List<String>? absentes,
    List<Map<String, String>>? discussionPoints,
    List<String>? actions,
    Map<String, String>? finances,
    List<AudioSegment>? audioSegments,
    Map<String, dynamic>? metadata,
    bool isCompleted = false,
  ) : presentees = presentees ?? [],
      absentes = absentes ?? [],
      discussionPoints = discussionPoints ?? [],
      actions = actions ?? [],
      finances = finances ?? {},
      super(
        id: id,
        type: ReportType.meeting,
        title: title,
        author: author,
        createdAt: createdAt,
        audioSegments: audioSegments,
        metadata: metadata,
        isCompleted: isCompleted,
      );

  void addDiscussionPoint(String point, String decision) {
    discussionPoints.add({'point': point, 'decision': decision});
  }

  void addAction(String action) {
    actions.add(action);
  }

  void addFinance(String description, String amount) {
    finances[description] = amount;
  }

  @override
  List<String> validate() {
    final errors = <String>[];
    if (title.isEmpty) errors.add('Le titre du rapport est requis');
    if (meetingDate == null) errors.add('La date de la réunion est requise');
    if (presentees.isEmpty && absentes.isEmpty) {
      errors.add('Au moins un participant est requis');
    }
    if (discussionPoints.isEmpty) {
      errors.add('Au moins un point de discussion est requis');
    }
    return errors;
  }

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'hierarchy': hierarchy,
      'meetingType': meetingType,
      'meetingObject': meetingObject,
      'meetingDate': meetingDate?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'president': president,
      'secretary': secretary,
      'presentees': presentees,
      'absentes': absentes,
      'discussionPoints': discussionPoints,
      'actions': actions,
      'finances': finances,
    });
    return base;
  }

  factory MeetingReport.fromJson(Map<String, dynamic> json) {
    return MeetingReport(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
      hierarchy: json['hierarchy'],
      meetingType: json['meetingType'],
      meetingObject: json['meetingObject'],
      meetingDate: json['meetingDate'] != null ? DateTime.parse(json['meetingDate']) : null,
      startTime: json['startTime'],
      endTime: json['endTime'],
      president: json['president'],
      secretary: json['secretary'],
      presentees: List<String>.from(json['presentees'] ?? []),
      absentes: List<String>.from(json['absentes'] ?? []),
      discussionPoints: List<Map<String, String>>.from(
        (json['discussionPoints'] ?? []).map((p) => Map<String, String>.from(p))
      ),
      actions: List<String>.from(json['actions'] ?? []),
      finances: Map<String, String>.from(json['finances'] ?? {}),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
