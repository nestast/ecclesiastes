import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/utils/dashboard_theme.dart';
import 'package:ecclesiaste/views/login_page.dart';

class DashboardScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottomBar;
  final bool showDrawer;
  final List<Widget>? actions;

  const DashboardScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.bottomBar,
    this.showDrawer = true,
    this.actions,
  });

  void _logout(BuildContext context) {
    AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardTheme.background,
      appBar: AppBar(
        backgroundColor: DashboardTheme.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: subtitle != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
                ],
              )
            : Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          ...?actions,
          if (showDrawer)
            IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: showDrawer ? const DashboardDrawer() : null,
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }
}

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?['nom_complet'] ?? ''),
            accountEmail: Text(user?['role_label']?.toString() ?? user?['role']?.toString() ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: DashboardTheme.blue,
              child: Text(
                (user?['nom_complet'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            decoration: const BoxDecoration(color: DashboardTheme.navy),
          ),
          const ListTile(leading: Icon(Icons.dashboard), title: Text('Tableau de bord')),
          const ListTile(leading: Icon(Icons.person), title: Text('Mon profil')),
          const ListTile(leading: Icon(Icons.help_outline), title: Text('Aide')),
        ],
      ),
    );
  }
}

class EntityPillRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const EntityPillRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? DashboardTheme.blue : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: DashboardTheme.blue),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected ? Colors.white : DashboardTheme.navy,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryPillRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryPillRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return EntityPillRow(labels: labels, selectedIndex: selectedIndex, onSelected: onSelected);
  }
}

class AlaUneCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const AlaUneCarousel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        decoration: DashboardTheme.cardDecoration(),
        child: const Text('Aucune actualité pour le moment', style: TextStyle(color: Colors.grey)),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          return Container(
            width: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [DashboardTheme.navy, DashboardTheme.blue.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item['titre']?.toString() ?? 'Actualité',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      icon: const Icon(Icons.menu_book, size: 16),
                      label: const Text('Lire', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      icon: const Icon(Icons.headphones, size: 16),
                      label: const Text('Écouter', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

IconData commissionIcon(String nom) {
  final n = nom.toLowerCase();
  if (n.contains('ecodim') || n.contains('jeunesse')) return Icons.child_care;
  if (n.contains('musique')) return Icons.music_note;
  if (n.contains('presse') || n.contains('sono')) return Icons.mic;
  if (n.contains('médic') || n.contains('medic')) return Icons.medical_services;
  if (n.contains('sécur') || n.contains('secur')) return Icons.security;
  if (n.contains('construction')) return Icons.construction;
  if (n.contains('maman')) return Icons.female;
  if (n.contains('papa')) return Icons.male;
  if (n.contains('aîn') || n.contains('ain')) return Icons.elderly;
  return Icons.groups;
}

class CommissionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const CommissionCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = data['pct'] as int? ?? 0;
    final statut = data['statut']?.toString() ?? 'Actif';
    final dotColor = pct >= 80 ? Colors.green : (pct >= 60 ? Colors.amber : Colors.orange);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(commissionIcon(data['nom']?.toString() ?? ''), color: DashboardTheme.blue, size: 22),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data['court']?.toString() ?? data['nom']?.toString() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: DashboardTheme.blue.withValues(alpha: 0.15),
                    child: Text(
                      (data['responsable']?.toString() ?? 'R')[0],
                      style: const TextStyle(fontSize: 10, color: DashboardTheme.navy),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data['responsable']?.toString() ?? '',
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('$pct% $statut', style: TextStyle(fontSize: 10, color: dotColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardFooterBar extends StatelessWidget {
  final String leftText;
  final String rightText;

  const DashboardFooterBar({super.key, required this.leftText, required this.rightText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(leftText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          Text(rightText, style: const TextStyle(fontSize: 12, color: DashboardTheme.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
