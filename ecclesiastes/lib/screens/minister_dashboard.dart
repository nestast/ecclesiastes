import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../event_provider.dart';
import '../models/models.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/event_list_item.dart';
import 'widgets/role_specific_widgets.dart';

class MinisterDashboard extends StatefulWidget {
  const MinisterDashboard({Key? key}) : super(key: key);

  @override
  State<MinisterDashboard> createState() => _MinisterDashboardState();
}

class _MinisterDashboardState extends State<MinisterDashboard> {
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

    // Filtrer les événements du ministre
    final ministerEvents = eventProvider.events
        .where((e) =>
            e.officiator == currentUser.name ||
            e.assistants.contains(currentUser.name))
        .toList();

    final upcomingMinisterEvents = ministerEvents
        .where((e) => e.startDate.isAfter(DateTime.now()))
        .toList();

    // Calculer les statistiques
    final totalEventsOfficiated = ministerEvents.where((e) => e.officiator == currentUser.name).length;
    final totalEventsAssisted = ministerEvents.where((e) => e.assistants.contains(currentUser.name)).length;
    final totalMembersServed =
        ministerEvents.fold<int>(0, (sum, e) => sum + e.actualMembers);
    final totalOfferingsCollected =
        ministerEvents.fold<double>(0, (sum, e) => sum + e.offering);

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
              child: const Icon(Icons.church, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ecclesiastes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Dashboard Ministre',
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
              // Profil du ministre
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                                'Ministre / ${currentUser.ministry ?? 'Non spécifié'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '${currentUser.district} - ${currentUser.community}',
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Statistiques du ministre
              const Text(
                'Statistiques Personnelles',
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
                    title: 'Officié',
                    value: totalEventsOfficiated.toString(),
                    icon: Icons.auto_awesome,
                    color: Colors.amber,
                  ),
                  DashboardCard(
                    title: 'Assisté',
                    value: totalEventsAssisted.toString(),
                    icon: Icons.handshake,
                    color: Colors.blue,
                  ),
                  DashboardCard(
                    title: 'Fidèles Servis',
                    value: totalMembersServed.toString(),
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                  DashboardCard(
                    title: 'Offrandes',
                    value: '${totalOfferingsCollected.toStringAsFixed(0)} FC',
                    icon: Icons.monetization_on,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Rapport Financier
              const Text(
                'Rapport du Jour',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FinancialStatsCard(
                offeringFC: totalOfferingsCollected,
                offeringUSD: totalOfferingsCollected * 0.0005,
                receiptNumber: 'ENA-2026-042',
              ),
              const SizedBox(height: 24),

              // Services à venir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Services à Venir',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (upcomingMinisterEvents.length > 5)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/minister-events');
                      },
                      child: const Text('Voir tout'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (eventProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (upcomingMinisterEvents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: const Center(
                    child: Text('Aucun service prévu pour vous'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcomingMinisterEvents.take(5).length,
                  itemBuilder: (context, index) {
                    return EventListItem(
                      event: upcomingMinisterEvents[index],
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Activités récentes
              const Text(
                'Activités Récentes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...ministerEvents.take(3).map((event) => Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.event,
                              color: Color(0xFF1E3A8A), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${event.actualMembers} fidèles',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
