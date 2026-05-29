import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';

class TransfertMembrePage extends StatefulWidget {
  const TransfertMembrePage({super.key});

  @override
  State<TransfertMembrePage> createState() => _TransfertMembrePageState();
}

class _TransfertMembrePageState extends State<TransfertMembrePage> {
  List<Map<String, dynamic>> _membres = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembres();
  }

  void _loadMembres() async {
    final entiteId = AuthService.filterCommunauteId;
    final data = await DatabaseHelper.instance.getMembresValides(communauteId: entiteId);
    if (mounted) {
      setState(() {
        _membres = data;
        _isLoading = false;
      });
    }
  }

  void _confirmerTransfert(String membreId, String nomMembre, String commOrigine) {
    final districtController = TextEditingController();
    final communauteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Transférer $nomMembre"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: districtController,
              decoration: const InputDecoration(labelText: "ID du nouveau District"),
            ),
            TextField(
              controller: communauteController,
              decoration: const InputDecoration(labelText: "ID de la nouvelle Communauté"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (districtController.text.isEmpty || communauteController.text.isEmpty) return;

              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);
              await DatabaseHelper.instance.transfererMembre(
                membreId,
                districtController.text.trim(),
                communauteController.text.trim(),
                commOrigine,
              );

              if (!mounted) return;
              nav.pop();
              _loadMembres();

              messenger.showSnackBar(
                const SnackBar(content: Text("Transfert réussi avec succès.")),
              );
            },
            child: const Text("Transférer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestion des Transferts")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _membres.isEmpty
              ? const Center(child: Text("Aucun membre disponible pour le transfert."))
              : ListView.builder(
                  itemCount: _membres.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final m = _membres[index];
                    final nomComplet = "${m['nom']} ${m['prenom'] ?? ''}".trim();
                    final commOrigine = m['communaute_id'] ?? 'Inconnue';
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(nomComplet),
                        subtitle: Text("Communauté actuelle : $commOrigine"),
                        trailing: IconButton(
                          icon: const Icon(Icons.swap_horiz, color: Colors.blue),
                          onPressed: () => _confirmerTransfert(m['id'], nomComplet, commOrigine),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
