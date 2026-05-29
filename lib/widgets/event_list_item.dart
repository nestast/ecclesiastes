import 'package:flutter/material.dart';

class EventListItem extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
  final VoidCallback? onTap;

  const EventListItem({
    required this.title,
    required this.description,
    required this.date,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title),
      subtitle: Text(description),
      trailing: Text(
        '${date.day}/${date.month}/${date.year}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
