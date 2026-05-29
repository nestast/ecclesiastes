import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/utils/entite_types.dart';
import 'package:intl/intl.dart';

class SaisieProgrammePage extends StatefulWidget {
  const SaisieProgrammePage({super.key});

  @override
  State<SaisieProgrammePage> createState() => _SaisieProgrammePageState();
}

class _SaisieProgrammePageState extends State<SaisieProgrammePage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _dateDebut = DateTime.now();
  String _selectedType = 'CULTE';
  String _selectedNiveau = EntiteTypes.communaute;
  String? _selectedCommission = 'Aucune';

  final List<String> _types = [
    'CULTE', 
    'REUNION', 
    'PROGRAMME_ANNUEL', 
    'JEUNESSE', 
    'MUSIQUE', 
    'ECOLE_DIMANCHE'
  ];
  
  final List<String> _niveaux = EntiteTypes.hierarchie.reversed.toList();

  final List<String> _commissions = [
    'Aucune', 
    'Musique', 
    'Jeunesse', 
    'Ecole du Dimanche', 
    'Technique', 
    'Accueil'
  ];

  Future<void> _choisirDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dateDebut) {
      setState(() {
        _dateDebut = picked;
      });
    }
  }

  void _enregistrerEvenement() async {
    if (_formKey.currentState!.validate()) {
      final eventData = {
        'titre': _titreController.text.trim(),
        'description': _descController.text.trim(),
        'date_evenement': DateFormat('yyyy-MM-dd').format(_dateDebut),
        'type': _selectedType,
        'niveau': _selectedNiveau,
        'commission_liee': _selectedCommission == 'Aucune' ? null : _selectedCommission,
        'auteur_id': AuthService.currentUser?['id'],
        'entite_id': AuthService.currentUser?['entite_id'],
      };

      await DatabaseHelper.instance.insertEvenement(eventData);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Programme publié avec succès")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau Programme"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Détails de l'événement",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: "Titre de l'événement",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description / Détails",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 15),

              // Sélection du Type
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: "Type de programme",
                  border: OutlineInputBorder(),
                ),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 15),

              // Date
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                title: Text("Date prévue : ${DateFormat('dd/MM/yyyy').format(_dateDebut)}"),
                trailing: const Icon(Icons.edit),
                onTap: () => _choisirDate(context),
              ),
              const SizedBox(height: 25),

              const Divider(),
              const SizedBox(height: 10),
              const Text("Visibilité & Commission", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // Niveau de visibilité
              DropdownButtonFormField<String>(
                initialValue: _selectedNiveau,
                decoration: const InputDecoration(
                  labelText: "Niveau de visibilité",
                  border: OutlineInputBorder(),
                  helperText: "Qui pourra voir cet événement ?", // Correction ici
                ),
                items: _niveaux
                    .map((n) => DropdownMenuItem(value: n, child: Text(EntiteTypes.label(n))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedNiveau = v!),
              ),
              const SizedBox(height: 15),

              // Commission spécifique
              DropdownButtonFormField<String>(
                initialValue: _selectedCommission,
                decoration: const InputDecoration(
                  labelText: "Commission liée",
                  border: OutlineInputBorder(),
                ),
                items: _commissions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCommission = v),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _enregistrerEvenement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  child: const Text("PUBLIER LE PROGRAMME", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
