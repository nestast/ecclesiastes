import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/views/saisie_programme_page.dart';
import 'package:intl/intl.dart';

class CalendrierPage extends StatefulWidget {
  const CalendrierPage({super.key});

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendrierPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _eventsToday = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  void _loadData() async {
    final db = DatabaseHelper.instance;
    final allEvents = await db.getEvenements();
    final allAnnivs = await db.getAnniversairesDuJour();

    if (mounted) {
      setState(() {
        // Filtrer les événements pour le jour sélectionné
        final dayKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
        _eventsToday = allEvents.where((e) {
          final date = (e['date_evenement'] ?? e['date_debut'] ?? '').toString();
          return date.startsWith(dayKey);
        }).toList();

        // Ajouter les anniversaires s'ils correspondent au jour sélectionné
        for (var a in allAnnivs) {
          String dateAnniv = a['date_naissance'] ?? '';
          if (dateAnniv.contains(DateFormat('MM-dd').format(_selectedDay!))) {
            _eventsToday.add({
              'titre': "🎂 Anniversaire : ${a['nom']} ${a['prenom']}",
              'type': 'ANNIVERSAIRE',
              'description': 'Souhaitons un joyeux anniversaire !'
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendrier & Programmes")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadData();
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
            ),
          ),
          const Divider(),
          Expanded(
            child: _eventsToday.isEmpty
                ? const Center(child: Text("Aucun programme pour ce jour."))
                : ListView.builder(
                    itemCount: _eventsToday.length,
                    itemBuilder: (context, index) {
                      final item = _eventsToday[index];
                      bool isAnniv = item['type'] == 'ANNIVERSAIRE';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: ListTile(
                          leading: Icon(
                            isAnniv ? Icons.cake : Icons.event_available,
                            color: isAnniv ? Colors.pink : Colors.blue,
                          ),
                          title: Text(item['titre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item['description'] ?? ''),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: AuthService.isResponsable()
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SaisieProgrammePage()),
                ).then((_) => _loadData());
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
