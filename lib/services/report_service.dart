import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../models/report_base.dart';
import '../models/meeting_report.dart';
import '../models/visit_report.dart';
import '../models/divine_service_report.dart';
import '../models/report_type.dart';
import 'database_helper.dart';

class ReportService {
  static const String tableName = 'reports';

  Future<Database?> get database async => DatabaseHelper.instance.database;

  Future<String> createReport(ReportBase report) async {
    final db = await database;
    if (db == null) return report.id;
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
    if (db == null) return null;
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
    if (db == null) return [];
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
    if (db == null) return;
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
    if (db == null) return;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getReportCount({String? typeFilter}) async {
    final db = await database;
    if (db == null) return 0;
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
    // Database closing is handled by DatabaseHelper if necessary
  }
}
