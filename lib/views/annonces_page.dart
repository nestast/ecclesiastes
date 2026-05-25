import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:intl/intl.dart';

class AnnoncesPage extends StatefulWidget {
  const AnnoncesPage({super.key});

  @override
  State<AnnoncesPage> createState() => _AnnoncesPageState();
}

class _AnnoncesPageState extends State<AnnoncesPage> {
  List<Map<String, dynamic>> _annonces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnonces();
  }

  void _fetchAnnonces() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAnnoncesRecent();
    if (mounted) {
      setState(() {
        _annonces = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Annonces Officielles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnnonces,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _annonces.isEmpty
              ? const Center(child: Text("Aucune annonce pour le moment."))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _annonces.length,
                  itemBuilder: (context, index) {
                    final annonce = _annonces[index];
                    final bool isUrgent = annonce['type_annonce'] == 'URGENT';

                    return Card(
                      elevation: isUrgent ? 4 : 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: isUrgent 
                          ? const BorderSide(color: Colors.redAccent, width: 2)
                          : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: isUrgent ? Colors.red : Colors.blueGrey,
                          child: Icon(
                            isUrgent ? Icons.priority_high : Icons.notifications_none,
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            if (isUrgent)
                              const Text("🚨 ", style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                annonce['titre'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              annonce['contenu'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Par: ${annonce['auteur'] ?? 'Administration'}",
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(annonce['date_publication'])),
                                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _showAnnonceDetail(annonce),
                      ),
                    );
                  },
                ),
      floatingActionButton: AuthService.isResponsable()
          ? FloatingActionButton.extended(
              onPressed: _showAddAnnonceDialog,
              label: const Text("Publier"),
              icon: const Icon(Icons.edit_note),
              backgroundColor: Colors.blueAccent,
            )
          : null,
    );
  }

  void _showAnnonceDetail(Map<String, dynamic> annonce) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(25),
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(annonce['titre'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            Text(annonce['contenu'], style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 30),
            Text("Date: ${annonce['date_publication']}", style: const TextStyle(color: Colors.grey)),
            Text("Auteur: ${annonce['auteur']}", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showAddAnnonceDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String typeAnnonce = 'COMMUNIQUE';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle Annonce"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Titre")),
              const SizedBox(height: 10),
              TextField(controller: contentController, maxLines: 4, decoration: const InputDecoration(labelText: "Contenu")),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: typeAnnonce,
                items: const [
                  DropdownMenuItem(value: 'COMMUNIQUE', child: Text("Communiqué")),
                  DropdownMenuItem(value: 'URGENT', child: Text("⚠️ Urgent / Lettre")),
                ],
                onChanged: (v) => typeAnnonce = v!,
                decoration: const InputDecoration(labelText: "Priorité"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                final nav = Navigator.of(context);
                await DatabaseHelper.instance.insertAnnonce({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'titre': titleController.text,
                  'contenu': contentController.text,
                  'date_publication': DateTime.now().toIso8601String(),
                  'type_annonce': typeAnnonce,
                  'auteur': AuthService.currentUser?['nom_complet'] ?? 'Responsable',
                });
                if (!mounted) return;
                nav.pop();
                _fetchAnnonces();
              }
            },
            child: const Text("Publier"),
          ),
        ],
      ),
    );
  }
}