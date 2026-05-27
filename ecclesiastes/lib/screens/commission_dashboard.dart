import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../event_provider.dart';
import '../models/models.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/role_specific_widgets.dart';

class CommissionDashboard extends StatefulWidget {
  const CommissionDashboard({Key? key}) : super(key: key);

  @override
  State<CommissionDashboard> createState() => _CommissionDashboardState();
}

class _CommissionDashboardState extends State<CommissionDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EventProvider>().loadEvents();
    });
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
              child: const Icon(Icons.groups, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ecclesiastes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Responsable Commission',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade100)),
              ],
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => eventProvider.loadEvents(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil du responsable de commission
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
                            'Commission: ${currentUser.ministry ?? 'Jeunesse'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${currentUser.community} - KSO',
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

              // Statistiques de la commission
              const Text(
                'Statistiques de la Commission',
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
                    title: 'Membres',
                    value: '42',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  DashboardCard(
                    title: 'Actifs',
                    value: '38',
                    icon: Icons.verified,
                    color: Colors.green,
                  ),
                  DashboardCard(
                    title: 'Activités',
                    value: '8',
                    icon: Icons.event,
                    color: Colors.orange,
                  ),
                  DashboardCard(
                    title: 'Taux Activ.',
                    value: '90%',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Info Commission
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Commission Jeunesse KSO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Responsable', 'Mère Françoise'),
                    _buildInfoRow('Suppléant', 'Père Jean-Marc'),
                    _buildInfoRow('Créée le', '15 Janvier 2020'),
                    _buildInfoRow('Statut', 'Active'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Responsable et suppléant
              const Text(
                'Leadership',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ResponsibleCard(
                title: 'Responsable Commission',
                responsibleName: 'Mère Françoise Kila',
                deputyName: 'Père Jean-Marc Okoyo',
                percentage: '85% Actif',
                status: 'Actif',
                icon: Icons.star,
                color: Colors.amber,
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // Membres de la commission
              const Text(
                'Membres de la Commission',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...[
                ('Fr. Pierre', 'Coordonnateur', true),
                ('Mère Ève', 'Secrétaire', true),
                ('Diacre Paul', 'Trésorier', true),
                ('Ministre Jean', 'Membre', true),
                ('Sœur Marie', 'Membre', false),
              ].map((member) => Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                          child: Text(
                            member.$1[0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                member.$2,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: member.$3
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            member.$3 ? 'Actif' : 'Inactif',
                            style: TextStyle(
                              fontSize: 10,
                              color: member.$3 ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),

              // Activités récentes
              const Text(
                'Activités Récentes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...[
                ('Réunion Commission', '15 Avril 2026', '32 présents'),
                ('Activité Jeunesse', '12 Avril 2026', '28 présents'),
                ('Formation Membres', '05 Avril 2026', '25 présents'),
              ].map((activity) => ReportSection(
                    title: activity.$1,
                    icon: Icons.event_note,
                    value: activity.$3,
                    subtitle: activity.$2,
                    backgroundColor: Colors.blue.shade50,
                    iconColor: const Color(0xFF1E3A8A),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }
}
