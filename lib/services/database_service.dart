import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import 'database_helper.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async => DatabaseHelper.instance.database;

  // Opérations sur les utilisateurs (Unifiées avec la table utilisateurs si besoin, 
  // mais ici on garde le mapping vers la table 'users' ou on redirige vers 'utilisateurs')
  // Note: Pour simplifier l'unification, on va utiliser la table 'utilisateurs' de DatabaseHelper
  
  Future<int> insertUser(AppUser user) async {
    final db = await database;
    // Map AppUser to DatabaseHelper's utilisateurs table if necessary, 
    // but for now we keep the 'users' table name to avoid breaking existing logic 
    // and rely on DatabaseHelper to have created it or use 'utilisateurs'
    return db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppUser?> getUser(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AppUser.fromMap(maps.first);
    }
    return null;
  }

  Future<List<AppUser>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return List.generate(maps.length, (i) => AppUser.fromMap(maps[i]));
  }

  Future<List<AppUser>> getUsersByLevel(UserLevel level) async {
    final db = await database;
    final maps = await db.query('users', where: 'level = ?', whereArgs: [level.toString()]);
    return List.generate(maps.length, (i) => AppUser.fromMap(maps[i]));
  }

  Future<int> updateUser(AppUser user) async {
    final db = await database;
    return db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Opérations sur les événements
  Future<int> insertEvent(ChurchEvent event) async {
    final db = await database;
    return db.insert('events', event.toMap());
  }

  Future<ChurchEvent?> getEvent(String id) async {
    final db = await database;
    final maps = await db.query('events', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ChurchEvent.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ChurchEvent>> getAllEvents() async {
    final db = await database;
    final maps = await db.query('events', orderBy: 'startDate DESC');
    return List.generate(maps.length, (i) => ChurchEvent.fromMap(maps[i]));
  }

  Future<List<ChurchEvent>> getEventsByType(EventType type) async {
    final db = await database;
    final maps = await db.query('events', where: 'type = ?', whereArgs: [type.toString()], orderBy: 'startDate DESC');
    return List.generate(maps.length, (i) => ChurchEvent.fromMap(maps[i]));
  }

  Future<List<ChurchEvent>> getEventsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'events',
      where: 'startDate >= ? AND startDate <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startDate ASC',
    );
    return List.generate(maps.length, (i) => ChurchEvent.fromMap(maps[i]));
  }

  Future<int> updateEvent(ChurchEvent event) async {
    final db = await database;
    return db.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
  }

  Future<int> deleteEvent(String id) async {
    final db = await database;
    return db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // Opérations sur les rapports de sacristie
  Future<int> insertSacristyReport(SacristyReport report) async {
    final db = await database;
    return db.insert('sacristy_reports', report.toMap());
  }

  Future<SacristyReport?> getSacristyReport(String id) async {
    final db = await database;
    final maps = await db.query('sacristy_reports', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return SacristyReport.fromMap(maps.first);
    }
    return null;
  }

  Future<List<SacristyReport>> getSacristyReportsByEvent(String eventId) async {
    final db = await database;
    final maps = await db.query('sacristy_reports', where: 'eventId = ?', whereArgs: [eventId]);
    return List.generate(maps.length, (i) => SacristyReport.fromMap(maps[i]));
  }

  Future<int> updateSacristyReport(SacristyReport report) async {
    final db = await database;
    return db.update('sacristy_reports', report.toMap(), where: 'id = ?', whereArgs: [report.id]);
  }

  // Statistiques
  Future<Map<String, dynamic>> getStatisticsByLevel(UserLevel level, String entityName) async {
    final db = await database;
    final maps = await db.query(
      'statistics',
      where: 'level = ? AND entityName = ?',
      whereArgs: [level.toString(), entityName],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return {};
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
