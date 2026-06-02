import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/constants.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  Map<String, int> _commissions = {};
  Map<String, int> _sacrements = {};
  Map<String, int> _retraite = {};
  List<Map<String, dynamic>> _districts = [];
  String? _selectedDistrict;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final districtsData = await DatabaseHelper.instance.getDistricts();
    if (mounted) {
      setState(() => _districts = districtsData);
      _refreshStats();
    }
  }

  Future<void> _refreshStats() async {
    setState(() => _isLoading = true);
    final comm = await DatabaseHelper.instance.getStatsCommissions(districtId: _selectedDistrict);
    final sacr = await DatabaseHelper.instance.getStatsSacrements(districtId: _selectedDistrict);
    final retr = await DatabaseHelper.instance.getStatsRetraite(entiteId: _selectedDistrict);
    if (mounted) {
      setState(() {
        _commissions = comm;
        _sacrements = sacr;
        _retraite = retr;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistiques du Champ")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: DropdownButtonFormField<String?>(
              initialValue: _selectedDistrict,
              decoration: const InputDecoration(labelText: "Filtrer par District", border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text("🌍 Vue Globale (Tout le Champ)")),
                ..._districts.map((d) => DropdownMenuItem(value: d['id'].toString(), child: Text(d['nom']))),
              ],
              onChanged: (val) {
                setState(() => _selectedDistrict = val);
                _refreshStats();
              },
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    Row(
                      children: [
                        _buildStatCard("Baptisés", _sacrements['Baptisés'] ?? 0, Colors.blue),
                        _buildStatCard("Scellés", _sacrements['Scellés'] ?? 0, Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text("RETRAITE DES MINISTRES (${AppConstants.ageRetraite} ans)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const Divider(),
                    Row(
                      children: [
                        _buildStatCard("Total ministres", _retraite['total'] ?? 0, Colors.teal),
                        _buildStatCard("Proches retraite", _retraite['proches_retraite'] ?? 0, Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatCard("Déjà retraités", _retraite['deja_retraites'] ?? 0, Colors.red),
                        _buildStatCard("Âge retraite", AppConstants.ageRetraite, Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text("RÉPARTITION PAR COMMISSION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const Divider(),
                    ..._commissions.entries.map((e) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.group, color: Colors.blue),
                        title: Text(e.key),
                        trailing: CircleAvatar(child: Text(e.value.toString())),
                      ),
                    )),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int val, Color col) {
    return Expanded(
      child: Card(
        color: col,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 5),
              Text(val.toString(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
