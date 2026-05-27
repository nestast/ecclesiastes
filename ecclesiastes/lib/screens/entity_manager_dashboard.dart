import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../event_provider.dart';
import '../models/models.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/role_specific_widgets.dart';

class EntityManagerDashboard extends StatefulWidget {
  const EntityManagerDashboard({Key? key}) : super(key: key);

  @override
  State<EntityManagerDashboard> createState() => _EntityManagerDashboardState();
}

class _EntityManagerDashboardState extends State<EntityManagerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Non authentifié')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.domain, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ecclesiastes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Responsable Entité',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade100)),
              ],
            ),
          ],
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vue d\'ensemble', icon: Icon(Icons.dashboard)),
            Tab(text: 'Structures', icon: Icon(Icons.hub)),
            Tab(text: 'Responsables', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet 1: Vue d'ensemble
          _buildOverviewTab(currentUser, eventProvider),
          // Onglet 2: Structures
          _buildStructuresTab(currentUser),
          // Onglet 3: Responsables
          _buildResponsablesTab(currentUser),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AppUser currentUser, EventProvider eventProvider) {
    return RefreshIndicator(
      onRefresh: () => eventProvider.loadEvents(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil du responsable
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      currentUser.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Responsable ${currentUser.district}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          currentUser.community,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques globales
            const Text(
              'Statistiques de l\'Entité',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                DashboardCard(
                  title: 'Communautés',
                  value: '5',
                  icon: Icons.location_city,
                  color: Colors.blue,
                ),
                DashboardCard(
                  title: 'Commissions',
                  value: '12',
                  icon: Icons.groups,
                  color: Colors.green,
                ),
                DashboardCard(
                  title: 'Membres Actifs',
                  value: '342',
                  icon: Icons.people,
                  color: Colors.orange,
                ),
                DashboardCard(
                  title: 'Événements',
                  value: '24',
                  icon: Icons.event,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Rapport Financier
            const Text(
              'Rapport Financier',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FinancialStatsCard(
              offeringFC: 2450000,
              offeringUSD: 1225,
              receiptNumber: 'ENA-2026-042',
            ),
            const SizedBox(height: 24),

            // Alertes et notifications
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              'Absence d\'un responsable',
              'Le responsable de Jeunesse n\'a pas signalé sa présence',
              Icons.warning,
              Colors.orange,
            ),
            _buildNotificationItem(
              'Rapport manquant',
              'Rapport de sacristie du 20 avril non reçu',
              Icons.error,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuresTab(AppUser currentUser) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hiérarchie des Structures',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Districts
          _buildSectionHeader('Districts', Icons.map),
          const SizedBox(height: 8),
          EntityTile(
            name: 'Kinshasa',
            memberCount: 2300,
            responsibleName: 'Évêque Mika',
            deputyName: 'Diacre Joseph',
            onTap: () {},
          ),
          EntityTile(
            name: 'Kasai',
            memberCount: 1850,
            responsibleName: 'Apôtre Pierre',
            deputyName: 'Évêque Marie',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // Communautés
          _buildSectionHeader('Communautés', Icons.location_city),
          const SizedBox(height: 8),
          EntityTile(
            name: 'KSO - Kindamba',
            memberCount: 680,
            responsibleName: 'Diacre Paul',
            deputyName: 'Fr. Thomas',
            onTap: () {},
          ),
          EntityTile(
            name: 'Goma - Centre',
            memberCount: 450,
            responsibleName: 'Ministre Jean',
            deputyName: 'Mère Ève',
            onTap: () {},
          ),
          EntityTile(
            name: 'Kolwezi - Sud',
            memberCount: 520,
            responsibleName: 'Père Marc',
            status: 'inactive',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildResponsablesTab(AppUser currentUser) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Responsables et Suppléants',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Section Responsables
          const Text(
            'Responsables Actuels',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ResponsibleCard(
            title: 'Responsable Principal',
            responsibleName: 'Évêque Mika Mukendi',
            deputyName: 'Diacre Joseph Okafor',
            percentage: '95% Actif',
            status: 'Actif',
            icon: Icons.star,
            color: Colors.amber,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          ResponsibleCard(
            title: 'Responsable District',
            responsibleName: 'Apôtre Pierre Mondonge',
            deputyName: 'Évêque Marie Ndungu',
            percentage: '88% Actif',
            status: 'Actif',
            icon: Icons.person_pin,
            color: Colors.blue,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          ResponsibleCard(
            title: 'Responsable Communauté',
            responsibleName: 'Diacre Paul Zulu',
            deputyName: 'Fr. Thomas Kabutu',
            percentage: '0% Actif',
            status: 'Inactif',
            icon: Icons.location_on,
            color: Colors.grey,
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // Responsables de Commissions
          const Text(
            'Responsables de Commissions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...['Jeunesse', 'Musique', 'Écodim', 'Médecale'].asMap().entries.map((e) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ResponsibleCard(
                  title: e.value,
                  responsibleName: 'Mère ${e.value}',
                  deputyName: 'Père Support',
                  percentage: '${80 + e.key * 5}% Actif',
                  status: 'Actif',
                  icon: Icons.groups,
                  color: Colors.green,
                  onTap: () {},
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.left(side: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
