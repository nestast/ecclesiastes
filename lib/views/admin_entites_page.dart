import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/entite_types.dart';

class AdminEntitesPage extends StatefulWidget {
  const AdminEntitesPage({super.key});

  @override
  State<AdminEntitesPage> createState() => _AdminEntitesPageState();
}

class _AdminEntitesPageState extends State<AdminEntitesPage> {
  final _nameController = TextEditingController();
  String _selectedType = EntiteTypes.communaute;
  String? _selectedParentId;
  List<Map<String, dynamic>> _parents = [];

  @override
  void initState() {
    super.initState();
    _loadParents();
  }

  Future<void> _loadParents() async {
    final data = await DatabaseHelper.instance.getAllEntites();
    if (mounted) setState(() => _parents = data);
  }

  List<Map<String, dynamic>> _parentsEligibles(String type) {
    final parentType = _parentTypeFor(type);
    if (parentType == null) return [];
    return _parents.where((p) => EntiteTypes.normalize(p['type']?.toString()) == parentType).toList();
  }

  String? _parentTypeFor(String type) {
    switch (EntiteTypes.normalize(type)) {
      case EntiteTypes.egliseTerritoriale:
        return null;
      case EntiteTypes.champApostolique:
        return EntiteTypes.egliseTerritoriale;
      case EntiteTypes.district:
        return EntiteTypes.champApostolique;
      case EntiteTypes.communaute:
        return EntiteTypes.district;
      default:
        return null;
    }
  }

  void _addEntiteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final parents = _parentsEligibles(_selectedType);
          return AlertDialog(
            title: const Text("Nouvelle entité"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: "Type d'entité"),
                  items: EntiteTypes.typesConfigurables
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(EntiteTypes.label(t)),
                          ))
                      .toList(),
                  onChanged: (v) => setDialogState(() {
                    _selectedType = v!;
                    _selectedParentId = null;
                  }),
                ),
                if (parents.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedParentId,
                    decoration: InputDecoration(
                      labelText: "Entité parente (${EntiteTypes.label(_parentTypeFor(_selectedType)!)})",
                    ),
                    items: parents
                        .map((p) => DropdownMenuItem(
                              value: p['id'].toString(),
                              child: Text(p['nom']?.toString() ?? ''),
                            ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => _selectedParentId = v),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Annuler")),
              ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.trim().isEmpty) return;
                  final needsParent = _parentTypeFor(_selectedType) != null;
                  if (needsParent && _selectedParentId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sélectionnez l'entité parente.")),
                    );
                    return;
                  }
                  await DatabaseHelper.instance.insertEntite(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    nom: _nameController.text.trim(),
                    type: _selectedType,
                    parentId: _selectedParentId,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Entité créée")),
                  );
                  _loadParents();
                  _nameController.clear();
                },
                child: const Text("Créer"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuration hiérarchique")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntiteDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hiérarchie : Église territoriale → Champ apostolique → District → Communauté",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Appuyez sur + pour ajouter une entité. Le parent proposé dépend du type choisi.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _parents.length,
                itemBuilder: (_, i) {
                  final e = _parents[i];
                  final type = EntiteTypes.normalize(e['type']?.toString());
                  return ListTile(
                    leading: const Icon(Icons.account_tree),
                    title: Text(e['nom']?.toString() ?? ''),
                    subtitle: Text(EntiteTypes.label(type)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
