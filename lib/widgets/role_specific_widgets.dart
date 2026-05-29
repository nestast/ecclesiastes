import 'package:flutter/material.dart';

/// Widgets spécifiques aux différents rôles
class ResponsibleCard extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback? onTap;

  const ResponsibleCard({
    required this.name,
    required this.role,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(role, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class FinancialStatsCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const FinancialStatsCard({
    required this.label,
    required this.amount,
    this.color = Colors.green,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class EntityTile extends StatelessWidget {
  final String name;
  final String type;
  final VoidCallback? onTap;

  const EntityTile({
    required this.name,
    required this.type,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(name),
      subtitle: Text(type),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class ReportSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ReportSection({
    required this.title,
    required this.children,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
