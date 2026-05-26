import 'dart:convert';

import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/constants.dart';
import 'package:ecclesiaste/utils/user_access.dart';
import 'package:ecclesiaste/utils/password_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StructuredReportFormPage extends StatefulWidget {
  const StructuredReportFormPage({super.key});

  @override
  State<StructuredReportFormPage> createState() => _StructuredReportFormPageState();
}

class _StructuredReportFormPageState extends State<StructuredReportFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titreController = TextEditingController();
  final _presidentController = TextEditingController();
  final _secretaireController = TextEditingController();
  final _presentsController = TextEditingController();
  final _absentsController = TextEditingController();
  final _discussionsController = TextEditingController();
  final _decisionsController = TextEditingController();
  final _actionsController = TextEditingController();
  final _montantController = TextEditingController();
  final _pieceController = TextEditingController();

  List<Map<String, dynamic>> _entites = [];
  List<Map<String, dynamic>> _evenements = [];

  String _typeRapport = 'REUNION';
  String? _entiteId;
  String? _commission;
  String _devise = 'FC';
  DateTime _date = DateTime.now();
  TimeOfDay? _heureDebut;
  TimeOfDay? _heureFin;
  String _validationMode = 'EMPREINTE';
  String? _evenementId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _commission = AuthService.currentUser?['ministere']?.toString();
    _entiteId = AuthService.currentEntiteId.isNotEmpty ? AuthService.currentEntiteId : null;
    _loadEntites();
  }

  Future<void> _loadEntites() async {
    final data = await DatabaseHelper.instance.getEntitesAvecChemin();
    if (!mounted) return;
    setState(() => _entites = data);
    await _loadEvenements();
  }

  Future<void> _loadEvenements() async {
    final entite = _entiteId ?? AuthService.currentEntiteId;
    if (entite.isEmpty) return;
    final list = await DatabaseHelper.instance.getEvenements(entiteId: entite);
    if (!mounted) return;
    setState(() {
      _evenements = list;
      if (_evenementId != null && !_evenements.any((e) => e['id']?.toString() == _evenementId)) {
        _evenementId = null;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _pickTimeDebut() async {
    final picked = await showTimePicker(context: context, initialTime: _heureDebut ?? TimeOfDay.now());
    if (picked == null) return;
    setState(() => _heureDebut = picked);
  }

  Future<void> _pickTimeFin() async {
    final picked = await showTimePicker(context: context, initialTime: _heureFin ?? TimeOfDay.now());
    if (picked == null) return;
    setState(() => _heureFin = picked);
  }

  String _formatTime(TimeOfDay? t) => t == null ? '' : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _typeLabel(String v) {
    switch (v) {
      case 'SERVICE_DIVIN':
        return 'Service divin';
      case 'REPETITION':
        return 'Répétition';
      case 'VISITE':
        return 'Visite';
      case 'REUNION':
      default:
        return 'Réunion';
    }
  }

  Future<bool> _checkPasswordValidation() async {
    final identifiant = AuthService.currentUser?['identifiant']?.toString();
    if (identifiant == null || identifiant.isEmpty) return false;
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Validation'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Valider')),
        ],
      ),
    );
    if (ok != true) return false;
    final user = await DatabaseHelper.instance.getUtilisateurByIdentifiant(identifiant);
    if (user == null) return false;
    final hash = user['mot_de_passe_hash']?.toString() ?? '';
    return verifyPassword(controller.text, hash);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_entiteId == null || _entiteId!.isEmpty) return;
    if (_commission == null || _commission!.isEmpty) return;

    setState(() => _loading = true);
    try {
      if (_validationMode == 'PASSWORD') {
        final ok = await _checkPasswordValidation();
        if (!ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Validation échouée.')));
          }
          return;
        }
      }

      final montant = double.tryParse(_montantController.text.trim()) ?? 0.0;
      final finance = {
        'montant': montant,
        'devise': _devise,
        'piece': _pieceController.text.trim(),
      };

      final payload = {
        'type': _typeRapport,
        'entite_id': _entiteId,
        'commission': _commission,
        'titre': _titreController.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(_date),
        'heure_debut': _formatTime(_heureDebut),
        'heure_fin': _formatTime(_heureFin),
        'president': _presidentController.text.trim(),
        'secretaire': _secretaireController.text.trim(),
        'presents': _presentsController.text.trim(),
        'absents_justifies': _absentsController.text.trim(),
        'discussions': _discussionsController.text.trim(),
        'decisions': _decisionsController.text.trim(),
        'actions': _actionsController.text.trim(),
        'finances': finance,
        'validation_mode': _validationMode,
        if (_evenementId != null) 'evenement_id': _evenementId,
      };

      await DatabaseHelper.instance.insertRapport({
        'entite_id': _entiteId,
        'commission': _commission,
        'type_rapport': _typeRapport,
        'titre': _titreController.text.trim(),
        'payload_json': jsonEncode(payload),
        'date_activite': DateTime(_date.year, _date.month, _date.day).toIso8601String(),
        'offrande_fc': _devise == 'FC' ? montant : 0.0,
        'offrande_usd': _devise == 'USD' ? montant : 0.0,
        'numero_recu': _pieceController.text.trim().isNotEmpty ? _pieceController.text.trim() : 'N/A',
        'taches_json': null,
        'statut': 1,
        'created_by': AuthService.currentUser?['id'],
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rapport enregistré.')));
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPickEntite = UserAccessProfile.canSeeEntityFilters || AuthService.isSuperAdmin();
    final entiteItems = _entites
        .map((e) => DropdownMenuItem<String>(
              value: e['id']?.toString(),
              child: Text(e['chemin']?.toString() ?? '', overflow: TextOverflow.ellipsis),
            ))
        .toList();

    final eventItems = [
      const DropdownMenuItem<String>(value: null, child: Text('Aucun')),
      ..._evenements.map((e) {
        final date = e['date_evenement']?.toString() ?? '';
        final label = '${e['titre'] ?? ''}${date.isNotEmpty ? ' • $date' : ''}';
        return DropdownMenuItem<String>(value: e['id']?.toString(), child: Text(label, overflow: TextOverflow.ellipsis));
      }),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Rapport • ${_typeLabel(_typeRapport)}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _typeRapport,
              items: const [
                DropdownMenuItem(value: 'REUNION', child: Text('Réunion')),
                DropdownMenuItem(value: 'SERVICE_DIVIN', child: Text('Service divin')),
                DropdownMenuItem(value: 'REPETITION', child: Text('Répétition')),
                DropdownMenuItem(value: 'VISITE', child: Text('Visite')),
              ],
              onChanged: (v) => setState(() => _typeRapport = v ?? 'REUNION'),
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _entiteId,
              items: entiteItems,
              onChanged: canPickEntite
                  ? (v) async {
                      setState(() => _entiteId = v);
                      await _loadEvenements();
                    }
                  : null,
              decoration: const InputDecoration(labelText: 'Hiérarchie (entité)', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _commission,
              items: AppConstants.commissions
                  .map((c) => DropdownMenuItem<String>(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _commission = v),
              decoration: const InputDecoration(labelText: 'Commission', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _evenementId,
              items: eventItems,
              onChanged: (v) => setState(() => _evenementId = v),
              decoration: const InputDecoration(labelText: 'Lier à un programme (optionnel)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Objet / Titre', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                      child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: _pickTimeDebut,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Heure début', border: OutlineInputBorder()),
                      child: Text(_formatTime(_heureDebut)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: _pickTimeFin,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Heure fin', border: OutlineInputBorder()),
                      child: Text(_formatTime(_heureFin)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _presidentController,
              decoration: const InputDecoration(labelText: 'Président de séance', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _secretaireController,
              decoration: const InputDecoration(labelText: 'Secrétaire', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _presentsController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Liste des présents', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _absentsController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Absents justifiés', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _discussionsController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Résumé des discussions', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _decisionsController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Décisions prises', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _actionsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Actions à entreprendre', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _montantController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Dépenses (si applicable)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    value: _devise,
                    items: const [
                      DropdownMenuItem(value: 'FC', child: Text('FC')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    ],
                    onChanged: (v) => setState(() => _devise = v ?? 'FC'),
                    decoration: const InputDecoration(labelText: 'Devise', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pieceController,
              decoration: const InputDecoration(labelText: 'Numéro de pièce comptable', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                RadioListTile<String>(
                  value: 'EMPREINTE',
                  groupValue: _validationMode,
                  onChanged: (v) => setState(() => _validationMode = v ?? 'EMPREINTE'),
                  title: const Text('Par empreinte digitale'),
                ),
                RadioListTile<String>(
                  value: 'PASSWORD',
                  groupValue: _validationMode,
                  onChanged: (v) => setState(() => _validationMode = v ?? 'PASSWORD'),
                  title: const Text('Par identifiant & mot de passe'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Valider le rapport'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titreController.dispose();
    _presidentController.dispose();
    _secretaireController.dispose();
    _presentsController.dispose();
    _absentsController.dispose();
    _discussionsController.dispose();
    _decisionsController.dispose();
    _actionsController.dispose();
    _montantController.dispose();
    _pieceController.dispose();
    super.dispose();
  }
}

