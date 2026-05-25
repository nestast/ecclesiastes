import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/dashboard_theme.dart';
import 'package:ecclesiaste/utils/user_access.dart';

/// Gestionnaire complet des événements avec CRUD pour toutes les entités
class GestionEvenementsPage extends StatefulWidget {
  const GestionEvenementsPage({super.key});

  @override
  State<GestionEvenementsPage> createState() => _GestionEvenementsPageState();
}

class _GestionEvenementsPageState extends State<GestionEvenementsPage> {
  List<Map<String, dynamic>> _evenements = [];
  bool _loading = true;
  int _selectedTab = 0; // 0: Événements, 1: Calendrier, 2: Annonces

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final entiteId = AuthService.filterCommunauteId;
      final events = await DatabaseHelper.instance.getEvenements(entiteId: entiteId);
      if (mounted) {
        setState(() {
          _evenements = events;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement événements: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddEventDialog(),
    ).then((_) => _loadData());
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (_) => EditEventDialog(event: event),
    ).then((_) => _loadData());
  }

  Future<void> _deleteEvent(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet événement ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final db = await DatabaseHelper.instance.database;
        await db.delete('evenements', where: 'id = ?', whereArgs: [id]);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Événement supprimé ✅')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Événements'),
        elevation: 0,
        actions: [
          if (UserAccessProfile.canManageMembers)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: _showAddEventDialog,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _evenements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('Aucun événement'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _evenements.length,
                    itemBuilder: (ctx, idx) {
                      final event = _evenements[idx];
                      final dateEvent = event['date_evenement']?.toString() ?? '';
                      final titre = event['titre']?.toString() ?? 'Sans titre';
                      final desc = event['description']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.event,
                            color: DashboardTheme.blue,
                          ),
                          title: Text(titre, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                dateEvent,
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (desc.isNotEmpty)
                                Text(
                                  desc.length > 50 ? '${desc.substring(0, 50)}...' : desc,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                child: const Text('Modifier'),
                                onTap: () => _showEditEventDialog(event),
                              ),
                              PopupMenuItem(
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                onTap: () => _deleteEvent(event['id'] as int),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({super.key});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _type = 'Événement';

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_titreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titre obligatoire')),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.insertEvenement({
        'titre': _titreCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'date_evenement': _selectedDate.toIso8601String().split('T').first,
        'type': _type,
        'auteur_id': AuthService.currentUser?['id']?.toString(),
        'entite_id': AuthService.filterCommunauteId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement créé ✅')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un événement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titreCtrl,
              decoration: const InputDecoration(labelText: 'Titre'),
              maxLength: 100,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _type,
              isExpanded: true,
              items: ['Événement', 'Réunion', 'Service', 'Formation', 'Autre']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Sélectionner date'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Créer'),
        ),
      ],
    );
  }
}

class EditEventDialog extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventDialog({super.key, required this.event});

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  late TextEditingController _titreCtrl;
  late TextEditingController _descCtrl;
  late DateTime _selectedDate;
  late String _type;

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController(text: widget.event['titre']?.toString() ?? '');
    _descCtrl = TextEditingController(text: widget.event['description']?.toString() ?? '');
    _type = widget.event['type']?.toString() ?? 'Événement';
    final dateStr = widget.event['date_evenement']?.toString() ?? '';
    _selectedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_titreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titre obligatoire')),
      );
      return;
    }

    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'evenements',
        {
          'titre': _titreCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'date_evenement': _selectedDate.toIso8601String().split('T').first,
          'type': _type,
        },
        where: 'id = ?',
        whereArgs: [widget.event['id']],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement mis à jour ✅')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier événement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titreCtrl,
              decoration: const InputDecoration(labelText: 'Titre'),
              maxLength: 100,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _type,
              isExpanded: true,
              items: ['Événement', 'Réunion', 'Service', 'Formation', 'Autre']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Modifier date'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Mettre à jour'),
        ),
      ],
    );
  }
}
