import 'package:flutter/material.dart';
import '../models/models.dart';

class EventListItem extends StatelessWidget {
  final String? title;
  final String? description;
  final DateTime? date;
  final ChurchEvent? event;
  final VoidCallback? onTap;

  const EventListItem({
    this.title,
    this.description,
    this.date,
    this.event,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? event?.title ?? 'Événement';
    final displayDescription = description ?? event?.description ?? '';
    final displayDate = date ?? event?.startDate ?? DateTime.now();

    return ListTile(
      onTap: onTap,
      title: Text(displayTitle),
      subtitle: Text(displayDescription),
      trailing: Text(
        '${displayDate.day}/${displayDate.month}/${displayDate.year}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
