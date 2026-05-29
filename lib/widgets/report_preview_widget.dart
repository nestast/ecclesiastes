import 'package:flutter/material.dart';

class ReportPreviewWidget extends StatelessWidget {
  final String title;
  final String content;
  final DateTime createdAt;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReportPreviewWidget({
    required this.title,
    required this.content,
    required this.createdAt,
    this.onEdit,
    this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Créé le ${createdAt.day}/${createdAt.month}/${createdAt.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(content, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Modifier'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onDelete,
                  child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
