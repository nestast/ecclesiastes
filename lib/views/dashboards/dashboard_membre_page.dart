import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/dashboard_theme.dart';
import 'package:ecclesiaste/views/annonces_page.dart';
import 'package:ecclesiaste/views/bibliotheque_page.dart';
import 'package:ecclesiaste/views/calendrier_page.dart';
import 'package:ecclesiaste/widgets/dashboard/dashboard_shared.dart';

/// Vue simplifiée : actualités, calendrier, bibliothèque — sans gestion ni finances.
class DashboardMembrePage extends StatefulWidget {
  const DashboardMembrePage({super.key});

  @override
  State<DashboardMembrePage> createState() => _DashboardMembrePageState();
}

class _DashboardMembrePageState extends State<DashboardMembrePage> {
  List<Map<String, dynamic>> _annonces = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final annonces = await DatabaseHelper.instance.getAnnoncesRecent();
    if (mounted) setState(() { _annonces = annonces; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final ministere = user?['ministere']?.toString() ?? '—';

    return DashboardScaffold(
      title: 'Ma communauté',
      subtitle: user?['role_label']?.toString(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: DashboardTheme.cardDecoration(color: DashboardTheme.blue.withValues(alpha: 0.08)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: DashboardTheme.blue,
                          child: Text((user?['nom_complet'] ?? 'M')[0], style: const TextStyle(color: Colors.white, fontSize: 22)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user?['nom_complet']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                              Text('Ministère : $ministere', style: const TextStyle(fontSize: 13)),
                              const Text('Accès membre — consultation', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('À la Une', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  AlaUneCarousel(items: _annonces),
                  const SizedBox(height: 24),
                  const Text('Mes espaces', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _tile(Icons.calendar_month, 'Calendrier & programmes', const CalendrierPage()),
                  _tile(Icons.campaign, 'Annonces & communiqués', const AnnoncesPage()),
                  _tile(Icons.menu_book, 'Bibliothèque spirituelle', const BibliothequePage()),
                ],
              ),
            ),
    );
  }

  Widget _tile(IconData icon, String title, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: DashboardTheme.navy),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
