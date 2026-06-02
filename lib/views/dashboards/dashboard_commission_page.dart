import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/constants.dart';
import 'package:ecclesiaste/utils/dashboard_theme.dart';
import 'package:ecclesiaste/views/calendrier_page.dart';
import 'package:ecclesiaste/views/gestion_membres_page.dart';
import 'package:ecclesiaste/widgets/dashboard/dashboard_shared.dart';

class DashboardCommissionPage extends StatefulWidget {
  const DashboardCommissionPage({super.key});

  @override
  State<DashboardCommissionPage> createState() => _DashboardCommissionPageState();
}

class _DashboardCommissionPageState extends State<DashboardCommissionPage> {
  Map<String, dynamic>? _commissionData;
  List<Map<String, dynamic>> _annonces = [];
  int _membresCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ministere = AuthService.currentUser?['ministere']?.toString() ?? '';
    Map<String, dynamic>? comm;
    for (final c in AppConstants.commissionsDashboard) {
      if (ministere.toLowerCase().contains(c['nom'].toString().toLowerCase()) ||
          c['nom'].toString().toLowerCase().contains(ministere.toLowerCase().split(' ').last)) {
        comm = c;
        break;
      }
    }
    comm ??= AppConstants.commissionsDashboard.first;

    final membres = await DatabaseHelper.instance.getMembresValides(
      communauteId: AuthService.filterCommunauteId,
      commission: ministere.isNotEmpty ? ministere : null,
    );
    final annonces = await DatabaseHelper.instance.getAnnoncesRecent();

    if (mounted) {
      setState(() {
        _commissionData = comm;
        _membresCount = membres.length;
        _annonces = annonces;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final comm = _commissionData;
    final ministere = user?['ministere']?.toString() ?? 'Commission';

    return DashboardScaffold(
      title: 'Ma commission',
      subtitle: ministere,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (comm != null)
                      SizedBox(
                        height: 200,
                        child: CommissionCard(data: comm),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: DashboardTheme.cardDecoration(color: DashboardTheme.navy),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comm?['court']?.toString() ?? ministere,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Responsable : ${comm?['responsable'] ?? user?['nom_complet']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$_membresCount membres actifs dans votre périmètre',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('À la Une', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    AlaUneCarousel(items: _annonces),
                    const SizedBox(height: 24),
                    _buildProgressSection(comm),
                    const SizedBox(height: 24),
                    const Text('Actions commission', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _action(Icons.groups, 'Gérer les membres de la commission', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GestionMembresPage(
                            commissionName: ministere,
                            entiteId: AuthService.currentEntiteId,
                          ),
                        ),
                      );
                    }),
                    _action(Icons.event, 'Programmes & réunions', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendrierPage()));
                    }),
                    _action(Icons.assessment, 'Rapports d\'activité interactifs', () {
                      Navigator.pushNamed(context, '/reports');
                    }),
                    _action(Icons.assignment, 'Rapport commission (version simplifiée)', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rapport commission — à compléter')),
                      );
                    }),
                  ],
                ),
              ),
            ),
      bottomBar: DashboardFooterBar(
        leftText: 'Commission : ${comm?['statut'] ?? 'Actif'}',
        rightText: '${comm?['pct'] ?? 0}% objectifs',
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: DashboardTheme.blue),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProgressSection(Map<String, dynamic>? comm) {
    final pct = (comm?['pct'] as int? ?? 0).toDouble();
    final remaining = 100.0 - pct;
    final color = pct >= 80 ? Colors.green : (pct >= 60 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DashboardTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progression des objectifs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$pct%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: PieChart(
              PieChartData(
                startDegreeOffset: 270,
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: color,
                    value: pct,
                    title: '',
                    radius: 25,
                  ),
                  PieChartSectionData(
                    color: Colors.grey.shade200,
                    value: remaining,
                    title: '',
                    radius: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Objectifs du trimestre en cours',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
