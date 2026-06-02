import 'package:flutter/material.dart';
import '../models/report_base.dart';
import '../models/meeting_report.dart';
import '../models/visit_report.dart';
import '../models/divine_service_report.dart';

class ReportPreviewWidget extends StatelessWidget {
  final ReportBase report;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;

  const ReportPreviewWidget({
    required this.report,
    this.onEdit,
    this.onDelete,
    this.onExport,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Créé par ${report.author} le ${_formatDate(report.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(report.type.label),
                backgroundColor: Colors.blue.shade50,
              ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: _buildDetails(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter PDF'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Modifier',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    final r = report;
    if (r is MeetingReport) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Objet', r.meetingObject),
          _infoRow('Président', r.president),
          _infoRow('Secrétaire', r.secretary),
          _infoRow('Hiérarchie', r.hierarchy),
        ],
      );
    }
    if (r is VisitReport) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Lieu', r.location),
          _infoRow('Raison', r.visitReason),
          _infoRow('Observations', r.observations),
        ],
      );
    }
    if (r is DivineServiceReport) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Thème', r.theme),
          _infoRow('Résumé', r.summary),
          _infoRow('Présences', r.attendance.toString()),
        ],
      );
    }
    return const Text('Aucun détail spécifique disponible.');
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          Text(value ?? 'Non renseigné', style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
