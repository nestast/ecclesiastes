import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../models/report_base.dart';
import '../models/meeting_report.dart';
import '../models/visit_report.dart';
import '../models/divine_service_report.dart';

final logger = Logger();

class PDFExportService {
  static Future<String?> exportReportToPDF(ReportBase report) async {
    try {
      final pdf = pw.Document();
      final pageTheme = pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
      );

      pdf.addPage(
        pw.Page(
          pageTheme: pageTheme,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(report),
                pw.SizedBox(height: 20),
                _buildMetadataSection(report),
                pw.SizedBox(height: 20),
                _buildContentSection(report),
                if (report.audioSegments.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildAudioSection(report),
                ],
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final pdfPath =
          '${directory.path}/reports_pdf/${report.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final pdfDir = Directory('${directory.path}/reports_pdf');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      return pdfPath;
    } catch (e) {
      logger.e('Erreur lors de l\'export PDF: $e');
      return null;
    }
  }

  static pw.Widget _buildHeader(ReportBase report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          report.type.label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1976D2'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          report.title,
          style: const pw.TextStyle(fontSize: 18),
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Auteur: ${report.author}',
          style: const pw.TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  static pw.Widget _buildMetadataSection(ReportBase report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildMetadataRow(
            'Date de création',
            report.createdAt.toLocal().toString().split('.')[0],
          ),
          pw.SizedBox(height: 8),
          _buildMetadataRow(
            'Statut',
            report.isCompleted ? 'Complété' : 'En cours',
          ),
          if (report.audioSegments.isNotEmpty)
            pw.SizedBox(height: 8),
          if (report.audioSegments.isNotEmpty)
            _buildMetadataRow(
              'Enregistrements',
              '${report.audioSegments.length} fichier(s)',
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetadataRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
      ],
    );
  }

  static pw.Widget _buildContentSection(ReportBase report) {
    if (report is MeetingReport) {
      return _buildMeetingContent(report);
    } else if (report is VisitReport) {
      return _buildVisitContent(report);
    } else if (report is DivineServiceReport) {
      return _buildDivineServiceContent(report);
    }
    return pw.SizedBox();
  }

  static pw.Widget _buildMeetingContent(MeetingReport meeting) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Détails de la Réunion',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        if (meeting.hierarchy != null)
          _buildContentRow('Hiérarchie', meeting.hierarchy!),
        if (meeting.meetingType != null)
          _buildContentRow('Type', meeting.meetingType!),
        if (meeting.meetingDate != null)
          _buildContentRow(
            'Date',
            meeting.meetingDate!.toLocal().toString().split(' ')[0],
          ),
        if (meeting.president != null)
          _buildContentRow('Président', meeting.president!),
        pw.SizedBox(height: 12),
        _buildContentRow('Participants', '${meeting.presentees.length}'),
        if (meeting.discussionPoints.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            'Points de Discussion',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...meeting.discussionPoints.asMap().entries.map(
            (e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${e.key + 1}. ${e.value['point']}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('Décision: ${e.value['decision']}'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildVisitContent(VisitReport visit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Détails de la Visite',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        if (visit.location != null)
          _buildContentRow('Lieu', visit.location!),
        if (visit.visitDate != null)
          _buildContentRow(
            'Date',
            visit.visitDate!.toLocal().toString().split(' ')[0],
          ),
        if (visit.observations != null)
          _buildContentRow('Observations', visit.observations!),
        if (visit.findings != null)
          _buildContentRow('Constatations', visit.findings!),
      ],
    );
  }

  static pw.Widget _buildDivineServiceContent(DivineServiceReport service) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Détails du Service',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        if (service.serviceDate != null)
          _buildContentRow(
            'Date',
            service.serviceDate!.toLocal().toString().split(' ')[0],
          ),
        _buildContentRow('Participants', '${service.attendance}'),
        if (service.theme != null)
          _buildContentRow('Thème', service.theme!),
        if (service.speakers.isNotEmpty)
          _buildContentRow('Orateurs', service.speakers.join(', ')),
      ],
    );
  }

  static pw.Widget _buildContentRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Widget _buildAudioSection(ReportBase report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Enregistrements Audio',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        ...report.audioSegments.asMap().entries.map(
          (e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              children: [
                pw.Text('${e.key + 1}. ${e.value.section}'),
                pw.Spacer(),
                pw.Text('${e.value.duration.inSeconds}s'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
