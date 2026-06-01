// Example of how to integrate the Reports System into your main app
// This is a reference implementation - adapt as needed for your app

import 'package:flutter/material.dart';
import 'views/report_list_screen.dart';
import 'views/create_report_screen.dart';

void main() {
  runApp(const EcclesiastesApp());
}

class EcclesiastesApp extends StatelessWidget {
  const EcclesiastesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecclesiastes - Rapports Interactifs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/reports': (context) => const ReportListScreen(),
        '/create-report': (context) => const CreateReportScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecclesiastes'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Card(
                elevation: 4,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🙏 Bienvenue',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gestion des Rapports Interactifs avec Audio',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Actions Rapides',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // New Report Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-report');
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('Créer un Nouveau Rapport'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // View Reports Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/reports');
                },
                icon: const Icon(Icons.list),
                label: const Text('Voir Tous les Rapports'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Features Section
              Text(
                'Fonctionnalités',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildFeatureCard(
                context,
                '🎵 Enregistrement Audio',
                'Enregistrez directement vos rapports avec audio intégré',
              ),
              const SizedBox(height: 8),

              _buildFeatureCard(
                context,
                '📝 Formulaires Interactifs',
                'Formulaires adaptés à chaque type de rapport',
              ),
              const SizedBox(height: 8),

              _buildFeatureCard(
                context,
                '🔍 Recherche & Filtrage',
                'Trouvez rapidement vos rapports par titre, auteur ou type',
              ),
              const SizedBox(height: 8),

              _buildFeatureCard(
                context,
                '📄 Export PDF',
                'Exportez vos rapports en PDF formaté professionnellement',
              ),
              const SizedBox(height: 8),

              _buildFeatureCard(
                context,
                '📊 Types Multiples',
                'Réunions, Visites, Services Divins, et bien plus',
              ),
              const SizedBox(height: 24),

              // Statistics Section
              Text(
                'Statistiques',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildStatsGrid(context),
              const SizedBox(height: 24),

              // Info Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Système complet de gestion des rapports pour l\'Église Néo-Apostolique RDC Ouest',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildStatCard(context, '7', 'Types\nde Rapport'),
        _buildStatCard(context, '∞', 'Rapports\nPossibles'),
        _buildStatCard(context, '🔒', 'Sécurisé'),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Card(
      color: Colors.blue.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
