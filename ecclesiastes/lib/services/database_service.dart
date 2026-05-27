import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'ecclesiastes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        level TEXT NOT NULL,
        ministry TEXT,
        apostleField TEXT NOT NULL,
        district TEXT NOT NULL,
        community TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Table des événements
    await db.execute('''
      CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        location TEXT NOT NULL,
        apostleField TEXT,
        district TEXT,
        community TEXT,
        officiator TEXT NOT NULL,
        assistants TEXT,
        description TEXT,
        expectedMembers INTEGER DEFAULT 0,
        actualMembers INTEGER DEFAULT 0,
        offering REAL DEFAULT 0,
        offeringCurrency TEXT DEFAULT 'FC',
        status TEXT DEFAULT 'planned',
        createdAt TEXT NOT NULL,
        createdBy TEXT NOT NULL
      )
    ''');

    // Table des rapports de sacristie
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sacristy_reports (
        id TEXT PRIMARY KEY,
        eventId TEXT NOT NULL,
        date TEXT NOT NULL,
        memberCount INTEGER NOT NULL,
        visitorCount INTEGER NOT NULL,
        presentMembers TEXT,
        saintSealed TEXT,
        churchOrder TEXT,
        offeringAmount REAL NOT NULL,
        chaliceOpeners TEXT,
        chaliceClosers TEXT,
        holySceneDistributors TEXT,
        sickList TEXT,
        observations TEXT,
        reporterName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(eventId) REFERENCES events(id)
      )
    ''');

    // Table des statistiques par niveau
    await db.execute('''
      CREATE TABLE IF NOT EXISTS statistics (
        id TEXT PRIMARY KEY,
        level TEXT NOT NULL,
        entityType TEXT NOT NULL,
        entityName TEXT NOT NULL,
        totalMembers INTEGER DEFAULT 0,
        totalVisitors INTEGER DEFAULT 0,
        totalOfferings REAL DEFAULT 0,
        eventsCount INTEGER DEFAULT 0,
        lastUpdated TEXT NOT NULL
      )
    ''');
  }

  // Opérations sur les utilisateurs
  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return db.insert('users', user.toMap());
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
