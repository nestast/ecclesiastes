import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../event_provider.dart';
import '../models/models.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/event_list_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

    final stats = eventProvider.getEventStatistics();
    final upcomingEvents = eventProvider.getUpcomingEvents();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE67E22), // Orange du logo
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.church, color: Color(0xFFE67E22)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ecclesiastes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(currentUser.community, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => eventProvider.loadEvents(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil utilisateur
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFE67E22),
                      child: Text(
                        currentUser.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getLevelLabel(currentUser.level),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            currentUser.district,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        authProvider.logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistiques
              const Text(
                'Tableau de bord',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    title: 'Événements',
                    value: stats['totalEvents'].toString(),
                    icon: Icons.event,
                    color: Colors.blue,
                  ),
                  DashboardCard(
                    title: 'Planifiés',
                    value: stats['plannedEvents'].toString(),
                    icon: Icons.calendar_today,
                    color: Colors.amber,
                  ),
                  DashboardCard(
                    title: 'Membres présents',
                    value: stats['totalMembers'].toString(),
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                  DashboardCard(
                    title: 'Offrandes',
                    value: '${stats['totalOfferings']?.toStringAsFixed(0) ?? 0} FC',
                    icon: Icons.monetization_on,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Prochains événements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prochains événements',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/events');
                    },
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (eventProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (upcomingEvents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: const Center(
                    child: Text('Aucun événement prévu'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcomingEvents.take(5).length,
                  itemBuilder: (context, index) {
                    return EventListItem(event: upcomingEvents[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLevelLabel(UserLevel level) {
    const labels = {
      UserLevel.apostle: 'Apôtre',
      UserLevel.bishop: 'Évêque',
      UserLevel.deacon: 'Diacre',
      UserLevel.committeeLead: 'Responsable Commission',
      UserLevel.minister: 'Ministre',
      UserLevel.member: 'Membre',
    };
    return labels[level] ?? 'Inconnu';
  }
}
