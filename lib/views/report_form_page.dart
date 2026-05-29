import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/constants.dart';
import 'package:ecclesiaste/utils/task_constants.dart';
import 'dart:convert';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCommission = AppConstants.commissions.first;
  final TextEditingController _usdController = TextEditingController();
  final TextEditingController _fcController = TextEditingController();
  final TextEditingController _receiptController = TextEditingController();
  
  // Stockage des réponses aux tâches
  Map<String, String> _taskResponses = {};

  void _saveReport() async {
    if (_formKey.currentState!.validate()) {
      final db = await DatabaseHelper.instance.database;
      await db.insert('rapports', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'entite_id': 'COM_01', // À lier à la communauté sélectionnée
        'commission': _selectedCommission,
        'date_activite': DateTime.now().toIso8601String(),
        'offrande_usd': double.tryParse(_usdController.text) ?? 0.0,
        'offrande_fc': double.tryParse(_fcController.text) ?? 0.0,
        'numero_recu': _receiptController.text,
        'taches_json': jsonEncode(_taskResponses), // Sauvegarde des tâches en JSON
        'statut': 1,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rapport transmis au Prêtre !")));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> tasks = TaskConstants.commissionTasks[_selectedCommission] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Saisie du Rapport")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Sélection de la Commission (Les 12)
            DropdownButtonFormField<String>(
              initialValue: _selectedCommission,
              items: AppConstants.commissions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) => setState(() {
                _selectedCommission = val!;
                _taskResponses = {}; // Reset des tâches si on change de commission
              }),
              decoration: const InputDecoration(labelText: "Commission", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),

            // Section FINANCES
            const Text("FINANCES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(),
            Row(
              children: [
                Expanded(child: _buildTextField(_usdController, "Offrande USD", Icons.attach_money)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_fcController, "Offrande FC", Icons.money)),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField(_receiptController, "Numéro du Reçu (Obligatoire)", Icons.receipt_long, isRequired: true),
            
            const SizedBox(height: 30),

            // Section TÂCHES SPÉCIFIQUES
            if (tasks.isNotEmpty) ...[
              Text("RAPPORT D'ACTIVITÉ : $_selectedCommission", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              const Divider(),
              ...tasks.map((task) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  decoration: InputDecoration(labelText: task, border: const OutlineInputBorder()),
                  onChanged: (value) => _taskResponses[task] = value,
                ),
              )),
            ],

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveReport,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text("VALIDER ET ENVOYER"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isRequired ? TextInputType.text : TextInputType.number,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: (v) => isRequired && (v == null || v.isEmpty) ? "Champ requis" : null,
    );
  }
}
