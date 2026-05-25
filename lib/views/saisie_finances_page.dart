import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/auth_service.dart';
class SaisieFinancesPage extends StatefulWidget {
  const SaisieFinancesPage({super.key});

  @override
  State<SaisieFinancesPage> createState() => _SaisieFinancesPageState();
}

class _SaisieFinancesPageState extends State<SaisieFinancesPage> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _recuController = TextEditingController();
  
  String _typeOffrande = 'OFFRANDE NORMALE';
  String _devise = 'USD';
  DateTime _selectedDate = DateTime.now();

  final List<String> _types = [
    'OFFRANDE NORMALE',
    'DIME',
    'ACTION DE GRACE',
    'CONSTRUCTION',
    'OEUVRE DE CHARITE',
    'AUTRE'
  ];

  final List<String> _devisesList = ['USD', 'FC', 'EUR'];

  void _enregistrer() async {
    if (_formKey.currentState!.validate()) {
      final entiteId = AuthService.currentUser?['entite_id'] ?? 'COMM_01';
      final financeData = {
        'type_offrande': _typeOffrande,
        'montant': double.parse(_montantController.text),
        'devise': _devise,
        'numero_recu': _recuController.text.trim().isEmpty ? 'N/A' : _recuController.text.trim(),
        'date_saisie': _selectedDate.toIso8601String().split('T').first,
        'entite_id': entiteId,
      };

      await DatabaseHelper.instance.insertFinances(financeData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opération financière enregistrée avec succès !")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saisie des Finances")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Type d'offrande
              DropdownButtonFormField<String>(
                initialValue: _typeOffrande,
                decoration: const InputDecoration(
                  labelText: "Type d'Offrande",
                  border: OutlineInputBorder(),
                ),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _typeOffrande = v!),
              ),
              const SizedBox(height: 20),

              // Montant
              TextFormField(
                controller: _montantController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Montant",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? "Veuillez entrer un montant" : null,
              ),
              const SizedBox(height: 20),

              // Devise
              DropdownButtonFormField<String>(
                initialValue: _devise,
                decoration: const InputDecoration(
                  labelText: "Devise",
                  border: OutlineInputBorder(),
                ),
                items: _devisesList.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _devise = v!),
              ),
              const SizedBox(height: 20),

              // Numéro de reçu (Obligatoire selon vos specs)
              TextFormField(
                controller: _recuController,
                decoration: const InputDecoration(
                  labelText: "Numéro du Reçu",
                  prefixIcon: Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? "Le numéro du reçu est obligatoire" : null,
              ),
              const SizedBox(height: 20),

              // Date de l'opération
              ListTile(
                title: Text("Date: ${_selectedDate.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _enregistrer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text("VALIDER L'ENREGISTREMENT"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montantController.dispose();
    _recuController.dispose();
    super.dispose();
  }
}