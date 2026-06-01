import 'package:flutter/material.dart';

/// Widgets spécifiques aux différents rôles
class ResponsibleCard extends StatelessWidget {
  final String? name;
  final String? role;
  final String? title;
  final String? responsibleName;
  final String? deputyName;
  final String? percentage;
  final String? status;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const ResponsibleCard({
    this.name,
    this.role,
    this.title,
    this.responsibleName,
    this.deputyName,
    this.percentage,
    this.status,
    this.icon,
    this.color,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 28, color: color ?? Colors.blue),
                const SizedBox(height: 12),
              ],
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              if (responsibleName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Responsable: $responsibleName',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              if (deputyName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Suppléant: $deputyName',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              if (percentage != null) ...[
                const SizedBox(height: 8),
                Text(
                  percentage!,
                  style: const TextStyle(fontSize: 12, color: Colors.amber),
                ),
              ],
              if (status != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'Actif' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status!,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
              if (name != null && role != null) ...[
                const SizedBox(height: 8),
                Text(name!, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(role!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FinancialStatsCard extends StatelessWidget {
  final String? label;
  final String? amount;
  final Color color;
  final dynamic offeringFC;
  final dynamic offeringUSD;
  final String? receiptNumber;

  const FinancialStatsCard({
    this.label,
    this.amount,
    this.color = Colors.green,
    this.offeringFC,
    this.offeringUSD,
    this.receiptNumber,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null && amount != null) ...[
              Text(label!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(amount!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
            if (offeringFC != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Offrandes (FC)', style: TextStyle(fontSize: 12)),
                  Text(
                    offeringFC.toString(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            if (offeringUSD != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Offrandes (USD)', style: TextStyle(fontSize: 12)),
                  Text(
                    '\$${offeringUSD.toString()}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            if (receiptNumber != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('N° Reçu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    receiptNumber!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EntityTile extends StatelessWidget {
  final String name;
  final String? type;
  final int? memberCount;
  final String? responsibleName;
  final String? deputyName;
  final String? status;
  final VoidCallback? onTap;

  const EntityTile({
    required this.name,
    this.type,
    this.memberCount,
    this.responsibleName,
    this.deputyName,
    this.status,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (type != null) Text(type!),
            if (memberCount != null)
              Text('$memberCount membres'),
            if (responsibleName != null)
              Text('Responsable: $responsibleName'),
            if (deputyName != null)
              Text('Suppléant: $deputyName'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'inactive' ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status == 'inactive' ? 'Inactif' : 'Actif',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class ReportSection extends StatelessWidget {
  final String title;
  final List<Widget>? children;
  final IconData? icon;
  final String? value;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? iconColor;

  const ReportSection({
    required this.title,
    this.children,
    this.icon,
    this.value,
    this.subtitle,
    this.backgroundColor,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (children != null && children!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children!,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
            ),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 12),
            Text(
              value!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
