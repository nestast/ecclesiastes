import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  /// Génère un rapport de visite simple
  static Future<void> generateReportPdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            "Rapport de Visite - ${reportData['date'] ?? ''}",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Génère la fiche administrative complète au format A4
  static Future<void> generateFicheMembre(Map<String, dynamic> m) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start, // Corrigé
              children: [
                // EN-TÊTE
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, // Corrigé
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start, // Corrigé
                      children: [
                        pw.Text("EGLISE NEO-APOSTOLIQUE",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                        pw.Text("CHAMP KIN SUD-OUEST", style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Text("FICHE DE MEMBRE",
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),

                _buildSectionHeader("I. IDENTITÉ DU FIDÈLE"),
                _buildInfoRow("Nom complet", "${m['nom'] ?? ''} ${m['postnom'] ?? ''} ${m['prenom'] ?? ''}"),
                _buildInfoRow("Sexe", "${m['sexe'] ?? ''}"),
                _buildInfoRow("Date de Naissance", "${m['date_naissance'] ?? ''}"),

                _buildSectionHeader("II. VIE SACRAMENTELLE"),
                _buildInfoRow("Date de Baptême", m['date_bapteme'] ?? 'Non renseigné'),
                _buildInfoRow("Date de Scellement", m['date_scellement'] ?? 'Non renseigné'),

                _buildSectionHeader("III. APPARTENANCE"),
                _buildInfoRow("Commission", "${m['commission'] ?? 'Aucune'}"),
                _buildInfoRow("Poste", "${m['poste'] ?? 'Membre'}"),

                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Fait à Kinshasa, le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Génère une petite carte avec QR Code
  static Future<void> generateQRCard(Map<String, dynamic> m) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(86 * PdfPageFormat.mm, 54 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue900, width: 1.5),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start, // Corrigé
              children: [
                pw.Text("EGLISE NEO-APOSTOLIQUE",
                    style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
                pw.Divider(thickness: 0.5),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, // Corrigé
                  children: [
                    pw.Container(
                      width: 40,
                      height: 40,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: m['id']?.toString() ?? 'N/A',
                        drawText: false,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start, // Corrigé
                        children: [
                          pw.Text("${m['nom'] ?? ''} ${m['prenom'] ?? ''}",
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text("ID: ${m['id'] ?? ''}", style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // Fonctions d'aide (Helpers) privées
  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.all(4),
      color: PdfColors.grey200,
      width: double.infinity,
      child: pw.Text(title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 120,
              child: pw.Text("$label :", style: const pw.TextStyle(fontSize: 10))),
          pw.Expanded(
            child: pw.Text(value,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}