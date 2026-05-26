import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/dashboard_theme.dart';
import 'package:ecclesiaste/views/annonces_page.dart';
import 'package:ecclesiaste/views/journal_finances_page.dart';
import 'package:ecclesiaste/views/saisie_finances_page.dart';
import 'package:ecclesiaste/views/statistiques_page.dart';
import 'package:ecclesiaste/views/report_list_page.dart';
import 'package:ecclesiaste/services/entite_scope_service.dart';
import 'package:ecclesiaste/utils/entite_types.dart';
import 'package:ecclesiaste/widgets/dashboard/dashboard_shared.dart';
import 'package:ecclesiaste/widgets/dashboard/entite_hierarchy_pills.dart';
import 'package:ecclesiaste/widgets/ena_logo.dart';

class DashboardMinistrePage extends StatefulWidget {
  const DashboardMinistrePage({super.key});

  @override
  State<DashboardMinistrePage> createState() => _DashboardMinistrePageState();
}

class _DashboardMinistrePageState extends State<DashboardMinistrePage> {
  String? _filterDistrictId;
  List<Map<String, dynamic>> _annonces = [];
  double _totalFc = 0;
  double _totalUsd = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await EntiteScopeService.initDefaultForAdmin();
    final annonces = await DatabaseHelper.instance.getAnnoncesRecent();
    final finances = await DatabaseHelper.instance.getJournalFinancier();
    Set<String>? allowedCommunauteIds;
    if (_filterDistrictId != null) {
      final comms = await DatabaseHelper.instance.getSubEntites(
        _filterDistrictId!,
        EntiteTypes.communaute,
      );
      allowedCommunauteIds = comms.map((c) => c['id'].toString()).toSet();
    }
    double fc = 0, usd = 0;
    for (final f in finances) {
      final entiteFin = f['entite_id']?.toString();
      if (allowedCommunauteIds != null &&
          entiteFin != null &&
          !allowedCommunauteIds.contains(entiteFin)) {
        continue;
      }
      final m = (f['montant'] as num?)?.toDouble() ?? 0;
      if (f['devise'] == 'USD') {
        usd += m;
      } else {
        fc += m;
      }
    }
    if (mounted) {
      setState(() {
        _annonces = annonces;
        _totalFc = fc;
        _totalUsd = usd;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final news = [
      {'titre': 'La sainte cène: un repas doctrine'},
      {'titre': 'Ndjili - Encerea au saintes'},
      {'titre': "NACSEA Relief - Aide d'urgence"},
      if (_annonces.isNotEmpty) ..._annonces.take(3).map((a) => {'titre': a['titre']}),
    ];

    return DashboardScaffold(
      title: 'eglise néo-apostolique',
      subtitle: 'Dashboard KSO RDC Ouest',
      showDrawer: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const EnaLogo(size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?['nom_complet']?.toString() ?? 'Apôtre',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              const Text('Profil ministre / direction KSO', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: DashboardTheme.navy,
                        borderRadius: BorderRadius.circular(DashboardTheme.cardRadius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rapport Financier Néo-Apostolique', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _financeStat('Offrandes (FC)', _totalFc.toStringAsFixed(0), true)),
                              Expanded(child: _financeStat('Offrandes (USD)', _totalUsd.toStringAsFixed(0), true)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('N° Reçu : ENA-2026-042', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalFinancesPage())),
                                child: const Text('Journal', style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SaisieFinancesPage())),
                                child: const Text('Saisie', style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatistiquesPage())),
                                child: const Text('Stats', style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportListPage())),
                                child: const Text('Rapports', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('À la Une', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    AlaUneCarousel(items: _annonces.isNotEmpty ? _annonces : [
                      {'titre': "Un sourire fort - Journée de la Femme en Afrique"},
                      {'titre': "NACSEA Relief - Aide d'urgence"},
                    ]),
                    const SizedBox(height: 16),
                    const Text('Filtrer par District (RDC Ouest)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DistrictFilterPills(
                      onDistrictChanged: (districtId) {
                        setState(() => _filterDistrictId = districtId);
                        _load();
                      },
                    ),
                    const SizedBox(height: 8),
                    EntiteHierarchyPills(onScopeChanged: _load),
                    const SizedBox(height: 16),
                    const Text('Actualités Récentes', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: DashboardTheme.cardDecoration(),
                      child: Column(
                        children: news.map((n) {
                          return ListTile(
                            title: Text(n['titre']?.toString() ?? '', style: const TextStyle(fontSize: 14)),
                            trailing: ElevatedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnoncesPage())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DashboardTheme.navy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Text('Lire', style: TextStyle(fontSize: 12)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: DashboardTheme.cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today, color: DashboardTheme.blue),
                              SizedBox(width: 8),
                              Text('Rapport du Jour', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Text('Dimanche 12 Avril 2026', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _dayReport(Icons.people, 'Présences'),
                              _dayReport(Icons.payments, 'Offrandes'),
                              _dayReport(Icons.add_circle_outline, 'Saint Scellé'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _financeStat(String label, String value, bool up) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Row(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            if (up) const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 16),
          ],
        ),
      ],
    );
  }

  Widget _dayReport(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: DashboardTheme.navy, size: 28),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
