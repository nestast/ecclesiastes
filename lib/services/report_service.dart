import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/report_base.dart';
import '../models/meeting_report.dart';
import '../models/visit_report.dart';
import '../models/divine_service_report.dart';
import '../models/report_type.dart';

class ReportService {
  static Database? _database;
  static const String tableName = 'reports';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ecclesiastes_reports.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
  }

  Future<String> createReport(ReportBase report) async {
    final db = await database;
    await db.insert(
      tableName,
      {
        'id': report.id,
        'type': report.type.name,
        'title': report.title,
        'author': report.author,
        'data': jsonEncode(report.toJson()),
        'createdAt': report.createdAt.toIso8601String(),
        'isCompleted': report.isCompleted ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return report.id;
  }

  Future<ReportBase?> getReport(String id) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return _parseReport(result.first);
  }

  Future<List<ReportBase>> getAllReports({String? typeFilter}) async {
    final db = await database;
    List<Map<String, dynamic>> result;

    if (typeFilter != null) {
      result = await db.query(
        tableName,
        where: 'type = ?',
        whereArgs: [typeFilter],
        orderBy: 'createdAt DESC',
      );
    } else {
      result = await db.query(tableName, orderBy: 'createdAt DESC');
    }

    return result.map((r) => _parseReport(r)).toList();
  }

  Future<void> updateReport(ReportBase report) async {
    final db = await database;
    await db.update(
      tableName,
      {
        'data': jsonEncode(report.toJson()),
        'updatedAt': DateTime.now().toIso8601String(),
        'isCompleted': report.isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<void> deleteReport(String id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getReportCount({String? typeFilter}) async {
    final db = await database;
    final result = typeFilter != null
        ? await db.rawQuery(
            'SELECT COUNT(*) as count FROM $tableName WHERE type = ?',
            [typeFilter],
          )
        : await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  ReportBase _parseReport(Map<String, dynamic> record) {
    final type = ReportType.values.firstWhere(
      (e) => e.name == record['type'],
      orElse: () => ReportType.other,
    );
    final data = jsonDecode(record['data']) as Map<String, dynamic>;

    switch (type) {
      case ReportType.meeting:
        return MeetingReport.fromJson(data);
      case ReportType.visit:
        return VisitReport.fromJson(data);
      case ReportType.divineService:
        return DivineServiceReport.fromJson(data);
      default:
        throw Exception('Unknown report type: $type');
    }
  }

  Future<void> close() async {
    await _database?.close();
  }
}
