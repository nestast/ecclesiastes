import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/admin_service.dart';
import 'package:uuid/uuid.dart';

class GestionMembresPage extends StatefulWidget {
  final String commissionName;
  final String entiteId;

  const GestionMembresPage({
    super.key, 
    required this.commissionName, 
    required this.entiteId
  });

  @override
  State<GestionMembresPage> createState() => _GestionMembresPageState();
}

class _GestionMembresPageState extends State<GestionMembresPage> {
  List<Map<String, dynamic>> _membres = [];
  bool _isLoading = true;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // Charge les membres confirmés de cette commission pour cette entité
  void _refresh() async {
    setState(() => _isLoading = true);
    try {
      final data = await AdminService.getMembresByCommission(widget.commissionName);
      // Filtrage local par entité pour plus de précision
      setState(() {
        _membres = data
            .where((m) => (m['communaute_id'] ?? m['entite_id'])?.toString() == widget.entiteId)
            .toList();
      });
    } catch (e) {
      debugPrint("Erreur de chargement : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Affiche le formulaire d'ajout ou de modification
  void _showForm(Map<String, dynamic>? membre) {
    final isEditing = membre != null;
    final nomController = TextEditingController(text: membre?['nom']);
    final prenomController = TextEditingController(text: membre?['prenom']);
    final posteController = TextEditingController(text: membre?['poste'] ?? 'Membre');
    final telController = TextEditingController(text: membre?['telephone']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? "Modifier Responsable" : "Ajouter Responsable",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(controller: nomController, decoration: const InputDecoration(labelText: "Nom")),
              TextField(controller: prenomController, decoration: const InputDecoration(labelText: "Prénom")),
              TextField(controller: posteController, decoration: const InputDecoration(labelText: "Poste (ex: Responsable, Adjoint)")),
              TextField(controller: telController, decoration: const InputDecoration(labelText: "Téléphone"), keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45)
                ),
                onPressed: () async {
                  if (nomController.text.isNotEmpty) {
                    final data = {
                      'id': isEditing ? membre['id'] : _uuid.v4(),
                      'nom': nomController.text,
                      'prenom': prenomController.text,
                      'poste': posteController.text,
                      'telephone': telController.text,
                      'commission': widget.commissionName,
                      'entite_id': widget.entiteId,
                      'statut': 1, // Membre déjà confirmé car ajouté par l'admin
                      'date_inscription': isEditing ? membre['date_inscription'] : DateTime.now().toIso8601String(),
                    };
                    
                    await AdminService.saveMembre(data);
                    if (mounted) Navigator.pop(context);
                    _refresh();
                  }
                },
                child: Text(isEditing ? "Mettre à jour" : "Enregistrer"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.commissionName, style: const TextStyle(fontSize: 16)),
            const Text("Membres & Responsables", style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _membres.isEmpty
              ? const Center(child: Text("Aucun membre dans cette commission"))
              : ListView.builder(
                  itemCount: _membres.length,
                  itemBuilder: (context, index) {
                    final m = _membres[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey[100],
                          child: Text(m['nom'][0], style: TextStyle(color: Colors.blueGrey[900])),
                        ),
                        title: Text("${m['nom']} ${m['prenom'] ?? ''}"),
                        subtitle: Text("${m['poste']} • ${m['telephone'] ?? 'Pas de tél.'}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showForm(m),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Supprimer ?"),
                                    content: const Text("Voulez-vous retirer ce membre de la commission ?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Supprimer")),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await AdminService.deleteMembre(m['id']);
                                  _refresh();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        backgroundColor: Colors.orange[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
