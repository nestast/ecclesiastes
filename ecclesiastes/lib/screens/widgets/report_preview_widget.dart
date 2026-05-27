import 'package:flutter/material.dart';
import '../../models/report_base.dart';
import '../../models/meeting_report.dart';
import '../../models/visit_report.dart';
import '../../models/divine_service_report.dart';
import '../../models/report_type.dart';

class ReportPreviewWidget extends StatelessWidget {
  final ReportBase report;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;

  const ReportPreviewWidget({
    Key? key,
    required this.report,
    this.onEdit,
    this.onDelete,
    this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildMetadata(context),
            const SizedBox(height: 20),
            _buildContent(context),
            if (report.audioSegments.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildAudioSection(context),
            ],
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: _getReportTypeColor(report.type),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.type.label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Par: ${report.author}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _metadataRow(context, 'Créé', report.createdAt),
            if (report.updatedAt != null) ...[
              const SizedBox(height: 8),
              _metadataRow(context, 'Modifié', report.updatedAt),
            ],
            const SizedBox(height: 8),
            _metadataRow(context, 'Statut', 
              report.isCompleted ? '✓ Complété' : '⏱ En cours'),
          ],
        ),
      ),
    );
  }

  Widget _metadataRow(BuildContext context, String label, dynamic value) {
    final displayValue = value is DateTime 
        ? value.toLocal().toString().split('.')[0]
        : value.toString();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          displayValue,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (report is MeetingReport) {
      return _buildMeetingContent(context, report as MeetingReport);
    } else if (report is VisitReport) {
      return _buildVisitContent(context, report as VisitReport);
    } else if (report is DivineServiceReport) {
      return _buildDivineServiceContent(context, report as DivineServiceReport);
    }
    return SizedBox.shrink();
  }

  Widget _buildMeetingContent(BuildContext context, MeetingReport meeting) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meeting.hierarchy != null)
              _contentRow(context, 'Hiérarchie', meeting.hierarchy!),
            if (meeting.meetingType != null)
              _contentRow(context, 'Type', meeting.meetingType!),
            if (meeting.meetingDate != null)
              _contentRow(context, 'Date', 
                meeting.meetingDate!.toLocal().toString().split(' ')[0]),
            if (meeting.president != null)
              _contentRow(context, 'Président', meeting.president!),
            if (meeting.secretary != null)
              _contentRow(context, 'Secrétaire', meeting.secretary!),
            const SizedBox(height: 12),
            Text(
              'Participants: ${meeting.presentees.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (meeting.discussionPoints.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Points de Discussion: ${meeting.discussionPoints.length}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: meeting.discussionPoints.length,
                itemBuilder: (context, index) {
                  final point = meeting.discussionPoints[index];
                  return ListTile(
                    dense: true,
                    title: Text(point['point'] ?? ''),
                    subtitle: Text(point['decision'] ?? ''),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisitContent(BuildContext context, VisitReport visit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visit.location != null)
              _contentRow(context, 'Lieu', visit.location!),
            if (visit.visitDate != null)
              _contentRow(context, 'Date', 
                visit.visitDate!.toLocal().toString().split(' ')[0]),
            if (visit.observations != null)
              _contentRow(context, 'Observations', visit.observations!),
            if (visit.findings != null)
              _contentRow(context, 'Constatations', visit.findings!),
          ],
        ),
      ),
    );
  }

  Widget _buildDivineServiceContent(BuildContext context, DivineServiceReport service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.serviceDate != null)
              _contentRow(context, 'Date', 
                service.serviceDate!.toLocal().toString().split(' ')[0]),
            _contentRow(context, 'Participants', service.attendance.toString()),
            if (service.theme != null)
              _contentRow(context, 'Thème', service.theme!),
            if (service.speakers.isNotEmpty)
              _contentRow(context, 'Orateurs', service.speakers.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _contentRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enregistrements Audio (${report.audioSegments.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: report.audioSegments.length,
              itemBuilder: (context, index) {
                final audio = report.audioSegments[index];
                return ListTile(
                  leading: Icon(Icons.audio_file),
                  title: Text(audio.section),
                  subtitle: Text(
                    'Durée: ${audio.duration.inSeconds}s',
                  ),
                  trailing: audio.isProcessed
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (onEdit != null)
          ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
          ),
        if (onExport != null)
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download),
            label: const Text('Exporter'),
          ),
        if (onDelete != null)
          ElevatedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            label: const Text('Supprimer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
      ],
    );
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.meeting:
        return Colors.blue;
      case ReportType.visit:
        return Colors.orange;
      case ReportType.divineService:
        return Colors.purple;
      case ReportType.activity:
        return Colors.green;
      case ReportType.financial:
        return Colors.teal;
      case ReportType.disciplinary:
        return Colors.red;
      case ReportType.other:
        return Colors.grey;
    }
  }
}
