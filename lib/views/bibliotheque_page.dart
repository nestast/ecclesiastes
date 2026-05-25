import 'package:flutter/material.dart';
import 'package:ecclesiaste/utils/constants.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/utils/user_access.dart';

class BibliothequePage extends StatefulWidget {
  const BibliothequePage({super.key});

  @override
  State<BibliothequePage> createState() => _BibliothequePageState();
}

class _BibliothequePageState extends State<BibliothequePage> {
  String _selectedFilter = 'Toutes';
  String _selectedType = 'Tous';
  List<Map<String, dynamic>> _docs = [];
  bool _isLoading = true;

  static const List<String> _typesDocument = [
    'Livre',
    'Lettre',
    'Document',
    'Manuel',
    'Circulaire',
  ];

  static const Map<String, IconData> _iconesType = {
    'Livre': Icons.menu_book,
    'Lettre': Icons.mail,
    'Document': Icons.description,
    'Manuel': Icons.auto_stories,
    'Circulaire': Icons.campaign,
  };

  static const Map<String, Color> _couleursType = {
    'Livre': Colors.brown,
    'Lettre': Colors.indigo,
    'Document': Colors.blueGrey,
    'Manuel': Colors.teal,
    'Circulaire': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    setState(() => _isLoading = true);
    final niveau = UserAccessProfile.bibliothequeNiveau;
    final entiteId = AuthService.currentEntiteId;
    final commission = UserAccessProfile.commissionFilter;

    final data = await DatabaseHelper.instance.getBibliotheque(
      entiteId: niveau == 'communaute' ? entiteId : null,
      commission: commission,
      niveau: niveau == 'champ' ? null : niveau,
    );

    if (!mounted) return;
    setState(() {
      _docs = data;
      _isLoading = false;
    });
  }

  Future<void> _addDocumentDialog() async {
    final titleController = TextEditingController();
    String comm = AppConstants.commissions.first;
    String typeDoc = 'Document';

    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter à la Bibliothèque'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: typeDoc,
                  decoration: const InputDecoration(labelText: 'Type de document'),
                  items: _typesDocument.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => typeDoc = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: comm,
                  decoration: const InputDecoration(labelText: 'Commission'),
                  items: AppConstants.commissions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => comm = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                final nav = Navigator.of(dialogContext);
                await DatabaseHelper.instance.insertDocument({
                  'titre': titleController.text.trim(),
                  'type_document': typeDoc,
                  'commission': comm,
                  'entite_id': AuthService.currentEntiteId,
                  'niveau': UserAccessProfile.bibliothequeNiveau,
                  'auteur_id': AuthService.currentUser?['id'],
                });

                if (!mounted) return;
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Document ajouté avec succès')),
                );
                _loadDocs();
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerSuppression(int id, String titre) async {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le document ?'),
        content: Text('"$titre" sera définitivement supprimé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              await DatabaseHelper.instance.deleteDocument(id);
              if (!mounted) return;
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Document supprimé')),
              );
              _loadDocs();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = _docs.where((d) {
      final matchCommission = _selectedFilter == 'Toutes' || d['commission'] == _selectedFilter;
      final matchType = _selectedType == 'Tous' || d['type_document'] == _selectedType;
      return matchCommission && matchType;
    }).toList();

    final canAdd = UserAccessProfile.canAddDocument;
    final canDelete = UserAccessProfile.canDeleteDocument;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents & Manuels'),
        actions: [
          if (canAdd)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Ajouter un document',
              onPressed: _addDocumentDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildTypeBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDocs.isEmpty
                    ? const Center(child: Text('Aucun document disponible.'))
                    : ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final d = filteredDocs[index];
                          final type = d['type_document']?.toString() ?? 'Document';
                          final icon = _iconesType[type] ?? Icons.description;
                          final color = _couleursType[type] ?? Colors.blueGrey;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: ListTile(
                              leading: Icon(icon, color: color),
                              title: Text(d['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${d['commission'] ?? ''}  •  $type'),
                              trailing: canDelete
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      onPressed: () => _confirmerSuppression(
                                        d['id'] as int,
                                        d['titre']?.toString() ?? '',
                                      ),
                                    )
                                  : const Icon(Icons.download_for_offline, color: Colors.blue, size: 20),
                              onTap: () async {
                                await Future.delayed(const Duration(milliseconds: 500));
                                if (!mounted) return;
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(content: Text('Téléchargement du document...')),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('Toutes'),
          ...AppConstants.commissions.map((c) => _filterChip(c)),
        ],
      ),
    );
  }

  Widget _buildTypeBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _typeChip('Tous'),
          ..._typesDocument.map((t) => _typeChip(t)),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 11)),
        selectedColor: Colors.purple,
        onSelected: (val) {
          if (val) setState(() => _selectedFilter = label);
        },
      ),
    );
  }

  Widget _typeChip(String label) {
    final isSelected = _selectedType == label;
    final color = _couleursType[label] ?? Colors.blueGrey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : color, fontSize: 11, fontWeight: FontWeight.w500)),
        selectedColor: color,
        onSelected: (val) {
          if (val) setState(() => _selectedType = label);
        },
      ),
    );
  }
}