import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/pdf_service.dart';
import 'package:ecclesiaste/utils/user_access.dart';
import 'package:ecclesiaste/views/report_form_page.dart';

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  List<Map<String, dynamic>> _inbox = [];
  List<Map<String, dynamic>> _outbox = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final entiteId = AuthService.currentEntiteId;
    final ministere = AuthService.currentUser?['ministere']?.toString();
    final inbox = entiteId.isEmpty
        ? <Map<String, dynamic>>[]
        : await DatabaseHelper.instance.getRapportsRecus(
            destEntiteId: entiteId,
            destCommission: UserAccessProfile.current == UserAccessProfile.responsableCommission ? ministere : null,
          );
    final outbox = await DatabaseHelper.instance.getRapportsEmis(
      entiteId: entiteId.isNotEmpty ? entiteId : null,
      commission: ministere,
    );
    if (!mounted) return;
    setState(() {
      _inbox = inbox;
      _outbox = outbox;
      _isLoading = false;
    });
  }

  Future<void> _transmettreOutbox(String id) async {
    final actorId = AuthService.currentUser?['id']?.toString() ?? '';
    if (actorId.isEmpty) return;
    await DatabaseHelper.instance.transmettreRapport(rapportId: id, actorId: actorId);
    await _load();
  }

  Future<void> _transmettreInbox(String id) async {
    final actorId = AuthService.currentUser?['id']?.toString() ?? '';
    final fromEntiteId = AuthService.currentEntiteId;
    if (actorId.isEmpty || fromEntiteId.isEmpty) return;
    await DatabaseHelper.instance.transmettreRapportDepuis(
      rapportId: id,
      fromEntiteId: fromEntiteId,
      actorId: actorId,
    );
    await _load();
  }

  String _statutLabel(dynamic s) {
    final v = int.tryParse(s?.toString() ?? '') ?? 0;
    switch (v) {
      case 1:
        return 'Soumis';
      case 2:
        return 'Transmis';
      case 3:
        return 'Validé';
      default:
        return 'Brouillon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Rapports"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Reçus'),
              Tab(text: 'Émis'),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _inbox.isEmpty
                      ? _buildEmptyState('Aucun rapport reçu.')
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _inbox.length,
                          itemBuilder: (context, index) => _buildInboxTile(_inbox[index]),
                        ),
                  _outbox.isEmpty
                      ? _buildEmptyState('Aucun rapport émis.')
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _outbox.length,
                          itemBuilder: (context, index) => _buildOutboxTile(_outbox[index]),
                        ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportFormPage()));
            if (mounted) _load();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildInboxTile(Map<String, dynamic> r) {
    final statut = int.tryParse(r['statut']?.toString() ?? '') ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text("${r['commission']} - ${r['numero_recu']}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${_statutLabel(statut)} • ${r['date_activite']?.toString().substring(0, 10) ?? ''}"),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (statut >= 2)
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                onPressed: () => PdfService.generateReportPdf(r),
              ),
            ElevatedButton(
              onPressed: () => _transmettreInbox(r['id']?.toString() ?? ''),
              child: const Text('Transmettre'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutboxTile(Map<String, dynamic> r) {
    final statut = int.tryParse(r['statut']?.toString() ?? '') ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text("${r['commission']} - ${r['numero_recu']}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${_statutLabel(statut)} • ${r['date_activite']?.toString().substring(0, 10) ?? ''}"),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (statut >= 2)
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                onPressed: () => PdfService.generateReportPdf(r),
              ),
            if (statut == 1)
              ElevatedButton(
                onPressed: () => _transmettreOutbox(r['id']?.toString() ?? ''),
                child: const Text('Transmettre'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
