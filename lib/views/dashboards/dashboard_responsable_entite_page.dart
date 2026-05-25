import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/entite_scope_service.dart';
import 'package:ecclesiaste/utils/constants.dart';
import 'package:ecclesiaste/utils/dashboard_theme.dart';
import 'package:ecclesiaste/utils/user_access.dart';
import 'package:ecclesiaste/views/annonces_page.dart';
import 'package:ecclesiaste/views/bibliotheque_page.dart';
import 'package:ecclesiaste/views/calendrier_page.dart';
import 'package:ecclesiaste/views/gestion_membres_page.dart';
import 'package:ecclesiaste/views/inscription_membre_page.dart';
import 'package:ecclesiaste/views/validation_inscription_page.dart';
import 'package:ecclesiaste/widgets/dashboard/dashboard_shared.dart';
import 'package:ecclesiaste/widgets/dashboard/entite_hierarchy_pills.dart';

class DashboardResponsableEntitePage extends StatefulWidget {
  const DashboardResponsableEntitePage({super.key});

  @override
  State<DashboardResponsableEntitePage> createState() => _DashboardResponsableEntitePageState();
}

class _DashboardResponsableEntitePageState extends State<DashboardResponsableEntitePage> {
  int _categoryIndex = 0;
  int _pending = 0;
  List<Map<String, dynamic>> _annonces = [];
  Map<String, int> _counts = {'districts': 0, 'communautes': 0, 'champs': 0};
  bool _loading = true;

  final _categories = ['Tout', 'Évènements', 'Calendrier', 'Bibliothèque', 'Programmes'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entiteId = AuthService.filterCommunauteId;
    final pending = await DatabaseHelper.instance.getUnvalidatedCount(communauteId: entiteId);
    final annonces = await DatabaseHelper.instance.getAnnoncesRecent();
    final counts = await DatabaseHelper.instance.getEntiteCounts(
      champId: EntiteScopeService.champId,
    );
    if (mounted) {
      setState(() {
        _pending = pending;
        _annonces = annonces;
        _counts = counts;
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _commissions {
    const all = AppConstants.commissionsDashboard;
    final filter = UserAccessProfile.commissionFilter;
    if (filter == null) return all;
    return all.where((c) => filter.toLowerCase().contains(c['nom'].toString().toLowerCase())).toList();
  }

  String get _footerLeft {
    final champ = EntiteScopeService.champId;
    final d = _counts['districts'] ?? 0;
    final c = _counts['communautes'] ?? 0;
    if (champ != null) {
      return 'Périmètre actif : $d districts / $c communautés';
    }
    return 'KSO : $d districts / $c communautés';
  }

  void _openCategory() {
    switch (_categoryIndex) {
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendrierPage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BibliothequePage()));
        break;
      case 4:
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnoncesPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final local = _commissions.where((c) => c['section'] == 'local').toList();
    final tech = _commissions.where((c) => c['section'] == 'tech').toList();
    final filterEntite = AuthService.filterCommunauteId ?? AuthService.currentEntiteId;

    return DashboardScaffold(
      title: UserAccessProfile.displayTitle,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: DashboardTheme.blue.withValues(alpha: 0.15),
                          child: Text(
                            (user?['nom_complet'] ?? 'R')[0],
                            style: const TextStyle(color: DashboardTheme.navy, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?['nom_complet']?.toString() ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                user?['role_label']?.toString() ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    if (UserAccessProfile.canSeeEntityFilters)
                      EntiteHierarchyPills(onScopeChanged: _load),
                    const SizedBox(height: 20),
                    const Text('À la Une', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    AlaUneCarousel(items: _annonces),
                    const SizedBox(height: 16),
                    CategoryPillRow(
                      labels: _categories,
                      selectedIndex: _categoryIndex,
                      onSelected: (i) {
                        setState(() => _categoryIndex = i);
                        if (i > 0) _openCategory();
                      },
                    ),
                    const SizedBox(height: 20),
                    if (UserAccessProfile.canManageMembers) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _quickAction(Icons.person_add, 'Inscription', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const InscriptionMembrePage()),
                              );
                            }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _quickAction(Icons.verified_user, 'Validations ($_pending)', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ValidationInscriptionPage(
                                    isSuperAdmin: AuthService.isSuperAdmin(),
                                    entiteId: filterEntite,
                                  ),
                                ),
                              ).then((_) => _load());
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (UserAccessProfile.canSeeCommissionsGrid) ...[
                      const Text('Suivi des 12 Commissions Locally', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _commissionGrid(local, filterEntite),
                      const SizedBox(height: 20),
                      const Text('Technique & Soutien', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _commissionGrid(tech, filterEntite),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomBar: DashboardFooterBar(
        leftText: _footerLeft,
        rightText: 'Alertes validations $_pending',
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: DashboardTheme.blue, size: 20),
              const SizedBox(width: 8),
              Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _commissionGrid(List<Map<String, dynamic>> list, String entiteId) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        return CommissionCard(
          data: c,
          onTap: () {
            final nomCourt = c['nom']?.toString() ?? '';
            final fullName = AppConstants.commissions.firstWhere(
              (x) => x.toLowerCase().contains(nomCourt.toLowerCase()),
              orElse: () => AppConstants.commissions.first,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GestionMembresPage(
                  commissionName: fullName,
                  entiteId: entiteId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
