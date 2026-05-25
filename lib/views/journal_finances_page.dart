import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:intl/intl.dart';

class JournalFinancesPage extends StatefulWidget {
  const JournalFinancesPage({super.key});

  @override
  State<JournalFinancesPage> createState() => _JournalFinancesPageState();
}

class _JournalFinancesPageState extends State<JournalFinancesPage> {
  List<Map<String, dynamic>> _transactions = [];
  Map<String, double> _totaux = {'USD': 0.0, 'FC': 0.0, 'EUR': 0.0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerTransactions();
  }

  void _chargerTransactions() async {
    setState(() => _isLoading = true);
    
    // Correction : getJournalFinancier s'exécute sans argument selon l'erreur de l'analyseur
    final data = await DatabaseHelper.instance.getJournalFinancier(
      entiteId: AuthService.filterCommunauteId,
    );

    Map<String, double> tempTotaux = {'USD': 0.0, 'FC': 0.0, 'EUR': 0.0};
    for (var item in data) {
      String devise = item['devise'] ?? 'USD';
      double montant = (item['montant'] as num).toDouble();
      if (tempTotaux.containsKey(devise)) {
        tempTotaux[devise] = tempTotaux[devise]! + montant;
      }
    }

    if (mounted) {
      setState(() {
        _transactions = data;
        _totaux = tempTotaux;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Journal des Finances")),
      body: Column(
        children: [
          // En-tête des Offrandes accumulées
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.blueGrey.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _totaux.entries.map((e) => Column(
                children: [
                  Text("Total Offrandes (${e.key})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat("#,##0.00").format(e.value), 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)
                  ),
                ],
              )).toList(),
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _transactions.isEmpty
                  ? const Center(child: Text("Aucune transaction enregistrée."))
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long, color: Colors.teal),
                            title: Text(tx['type_offrande'] ?? 'Offrande'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Numéro du Reçu: ${tx['numero_recu'] ?? 'N/A'}"),
                                Text("Date: ${tx['date_paiement'] ?? ''}"),
                              ],
                            ),
                            trailing: Text(
                              "${tx['montant']} ${tx['devise']}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}