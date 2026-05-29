import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/pdf_service.dart'; // Import du service PDF

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // Chargement des données depuis SQFlite
  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('rapports', orderBy: 'date_activite DESC');
    setState(() {
      _reports = data;
      _isLoading = false;
    });
  }

  // Action de validation (Statut 1 -> 3)
  Future<void> _validateReport(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'rapports', 
      {'statut': 3}, 
      where: 'id = ?', 
      whereArgs: [id]
    );
    _loadReports(); // Rafraîchir la liste
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rapport validé avec succès !")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grand Livre des Rapports"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final r = _reports[index];
                    final bool isValidated = r['statut'] == 3;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: isValidated ? Colors.green.shade100 : Colors.amber.shade100,
                          child: Icon(
                            isValidated ? Icons.check_circle : Icons.pending_actions,
                            color: isValidated ? Colors.green : Colors.amber.shade900,
                          ),
                        ),
                        title: Text(
                          "${r['commission']} - ${r['numero_recu']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Montant : ${r['offrande_usd']} USD"),
                            Text(
                              "Date : ${r['date_activite'].toString().substring(0, 10)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Bouton PDF (Visible seulement si validé)
                            if (isValidated)
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                tooltip: "Générer PDF",
                                onPressed: () => PdfService.generateReportPdf(r),
                              ),
                            
                            // Bouton de Validation ou Badge
                            isValidated
                                ? const Icon(Icons.verified, color: Colors.blue)
                                : ElevatedButton(
                                    onPressed: () => _validateReport(r['id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    child: const Text("Valider"),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Aucun rapport trouvé dans la base locale.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
