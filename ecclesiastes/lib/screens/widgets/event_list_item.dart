import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';

class EventListItem extends StatelessWidget {
  final ChurchEvent event;
  final VoidCallback? onTap;

  const EventListItem({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(event.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getEventTypeIcon(event.type),
                    color: _getEventTypeColor(event.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(event.startDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(event.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusLabel(event.status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(event.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${event.actualMembers}/${event.expectedMembers}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${event.offering.toStringAsFixed(0)} ${event.offeringCurrency}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEventTypeIcon(EventType type) {
    const icons = {
      EventType.divinService: Icons.church,
      EventType.baptism: Icons.water,
      EventType.sealed: Icons.verified,
      EventType.confirmation: Icons.check_circle,
      EventType.ordination: Icons.star,
      EventType.funeral: Icons.favorite,
      EventType.ecodim: Icons.school,
      EventType.youthActivity: Icons.sports_soccer,
      EventType.meeting: Icons.group,
      EventType.retreat: Icons.hiking,
    };
    return icons[type] ?? Icons.event;
  }

  Color _getEventTypeColor(EventType type) {
    const colors = {
      EventType.divinService: Color(0xFF2196F3),
      EventType.baptism: Color(0xFF00BCD4),
      EventType.sealed: Color(0xFF4CAF50),
      EventType.confirmation: Color(0xFF8BC34A),
      EventType.ordination: Color(0xFFFFC107),
      EventType.funeral: Color(0xFFF44336),
      EventType.ecodim: Color(0xFF9C27B0),
      EventType.youthActivity: Color(0xFFFF5722),
      EventType.meeting: Color(0xFF3F51B5),
      EventType.retreat: Color(0xFF009688),
    };
    return colors[type] ?? Colors.grey;
  }

  Color _getStatusColor(String status) {
    const colors = {
      'planned': Color(0xFF2196F3),
      'ongoing': Color(0xFFFFC107),
      'completed': Color(0xFF4CAF50),
    };
    return colors[status] ?? Colors.grey;
  }

  String _getStatusLabel(String status) {
    const labels = {
      'planned': 'Planifié',
      'ongoing': 'En cours',
      'completed': 'Terminé',
    };
    return labels[status] ?? 'Inconnu';
  }
}
