import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/dashboard_theme.dart';
import 'package:ecclesiaste/utils/user_access.dart';
import 'package:ecclesiaste/views/annonces_page.dart';
import 'package:ecclesiaste/views/gestion_membres_page.dart';
import 'package:ecclesiaste/views/statistiques_page.dart';
import 'package:ecclesiaste/views/journal_finances_page.dart';
import 'package:ecclesiaste/widgets/dashboard/dashboard_shared.dart';
import 'package:ecclesiaste/widgets/dashboard/entite_hierarchy_pills.dart';

/// Dashboard exclusif SUPER_ADMIN pour gestion des entités
class DashboardSuperAdminPage extends StatefulWidget {
  const DashboardSuperAdminPage({super.key});

  @override
  State<DashboardSuperAdminPage> createState() => _DashboardSuperAdminPageState();
}

class _DashboardSuperAdminPageState extends State<DashboardSuperAdminPage> {
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _pendingValidations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _loading = true);

      // Charger les statistiques globales
      final eglises = await DatabaseHelper.instance.getEglisesTerritoriales();
      final champs = await DatabaseHelper.instance.getChampApostoliques();
      final districts = await DatabaseHelper.instance.getDistricts();
      final communautes = await DatabaseHelper.instance.getCommunautesAvecChemin();
      final membres = await DatabaseHelper.instance.getMembresValides();
      final pending = await DatabaseHelper.instance.getUnvalidatedCount();

      // Utilisateurs récents
      final users = await DatabaseHelper.instance.getUtilisateurs();

      if (mounted) {
        setState(() {
          _stats = {
            'eglises': eglises.length,
            'champs': champs.length,
            'districts': districts.length,
            'communautes': communautes.length,
            'membres': membres.length,
            'attente': pending,
          };
          _recentUsers = users.take(5).toList();
          _pendingValidations = users.where((u) => (u['statut_validation'] ?? 0) == 0).take(10).toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement dashboard admin: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'eglise néo-apostolique',
      subtitle: 'Administration Système',
      showDrawer: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Carte de profil admin
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: DashboardTheme.cardDecoration(
                      color: DashboardTheme.navy.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: DashboardTheme.navy,
                          child: const Icon(Icons.admin_panel_settings,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AuthService.currentUser?['nom_complet']
                                        ?.toString() ??
                                    'Admin',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              const Text('Super Administrateur',
                                  style: TextStyle(fontSize: 13)),
                              const Text('Accès complet — gestion système',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grille de statistiques
                  const Text('Statistiques Globales',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _statCard('Églises Territoriales', _stats['eglises'] ?? 0,
                          Icons.account_balance, Colors.blue),
                      _statCard('Champs Apostoliques', _stats['champs'] ?? 0,
                          Icons.public, Colors.green),
                      _statCard(
                          'Districts', _stats['districts'] ?? 0, Icons.domain, Colors.orange),
                      _statCard('Communautés', _stats['communautes'] ?? 0,
                          Icons.location_city, Colors.purple),
                      _statCard('Membres Actifs', _stats['membres'] ?? 0,
                          Icons.people, Colors.teal),
                      _statCard('En Attente Validation', _stats['attente'] ?? 0,
                          Icons.pending_actions, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Validations en attente
                  if (_pendingValidations.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Inscriptions en Attente',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ValidationInscriptionPage(),
                            ),
                          ),
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._pendingValidations.take(3).map((user) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                (user['nom_complet']?.toString() ?? 'U')[0],
                              ),
                            ),
                            title: Text(
                              user['nom_complet']?.toString() ?? 'N/A',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              user['role_label']?.toString() ?? 'Membre',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _acceptUser(user['id']),
                              child: const Text('Valider'),
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Utilisateurs récents
                  const Text('Derniers Utilisateurs',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ..._recentUsers.map((user) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (user['nom_complet']?.toString() ?? 'U')[0],
                            ),
                          ),
                          title: Text(
                            user['nom_complet']?.toString() ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            user['role']?.toString() ?? 'MEMBRE',
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: DashboardTheme.cardDecoration(
        color: color.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _acceptUser(String userId) async {
    try {
      await DatabaseHelper.instance.validerUtilisateur(userId);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur validé ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}
