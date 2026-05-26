import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/firebase_service.dart';
import 'package:sqflite/sqflite.dart';

class CloudSyncService {
  CloudSyncService._();

  static Future<void> pushAll() async {
    if (!FirebaseService.isReady) return;
    final firestore = FirebaseService.firestore;
    final db = await DatabaseHelper.instance.database;

    final rapports = await db.query('rapports');
    final transmissions = await db.query('rapport_transmissions');
    final history = await db.query('rapport_history');

    final batch = firestore.batch();
    for (final r in rapports) {
      final id = (r['group_id']?.toString().isNotEmpty ?? false) ? r['group_id'].toString() : r['id'].toString();
      final ref = firestore.collection('rapports').doc(id);
      batch.set(ref, _normalize(r), SetOptions(merge: true));
    }
    for (final t in transmissions) {
      final ref = firestore.collection('rapport_transmissions').doc(t['id'].toString());
      batch.set(ref, _normalize(t), SetOptions(merge: true));
    }
    for (final h in history) {
      final ref = firestore.collection('rapport_history').doc(h['id'].toString());
      batch.set(ref, _normalize(h), SetOptions(merge: true));
    }
    await batch.commit();
  }

  static Future<void> pullAll() async {
    if (!FirebaseService.isReady) return;
    final firestore = FirebaseService.firestore;
    final db = await DatabaseHelper.instance.database;

    final rapportsSnap = await firestore.collection('rapports').get();
    final transmissionsSnap = await firestore.collection('rapport_transmissions').get();
    final historySnap = await firestore.collection('rapport_history').get();

    await db.transaction((txn) async {
      for (final d in rapportsSnap.docs) {
        final data = Map<String, dynamic>.from(d.data());
        final mapped = _toLocalRapport(data, docId: d.id);
        await txn.insert('rapports', mapped, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final d in transmissionsSnap.docs) {
        final data = Map<String, dynamic>.from(d.data());
        final mapped = _toLocalTransmission(data, docId: d.id);
        await txn.insert('rapport_transmissions', mapped, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final d in historySnap.docs) {
        final data = Map<String, dynamic>.from(d.data());
        final mapped = _toLocalHistory(data, docId: d.id);
        await txn.insert('rapport_history', mapped, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Map<String, dynamic> _toLocalRapport(Map<String, dynamic> data, {required String docId}) {
    final out = <String, dynamic>{};
    out['id'] = (data['id'] ?? docId).toString();
    out['group_id'] = (data['group_id'] ?? docId).toString();
    out['entite_id'] = data['entite_id']?.toString();
    out['commission'] = (data['commission'] ?? '').toString();
    out['date_activite'] = (data['date_activite'] ?? '').toString();
    out['offrande_usd'] = double.tryParse(data['offrande_usd']?.toString() ?? '') ?? 0.0;
    out['offrande_fc'] = double.tryParse(data['offrande_fc']?.toString() ?? '') ?? 0.0;
    out['numero_recu'] = (data['numero_recu'] ?? '').toString();
    if (data['taches_json'] != null) {
      out['taches_json'] = data['taches_json'].toString();
    } else if (data['taches'] != null) {
      out['taches_json'] = jsonEncode(data['taches']);
    }
    out['statut'] = int.tryParse(data['statut']?.toString() ?? '') ?? 0;
    out['created_by'] = data['created_by']?.toString();
    out['created_at'] = data['created_at']?.toString();
    out['updated_at'] = data['updated_at']?.toString();
    out['remote_id'] = data['remote_id']?.toString();
    out['version'] = int.tryParse(data['version']?.toString() ?? '') ?? 1;
    return out;
  }

  static Map<String, dynamic> _toLocalTransmission(Map<String, dynamic> data, {required String docId}) {
    return {
      'id': (data['id'] ?? docId).toString(),
      'rapport_id': (data['rapport_id'] ?? '').toString(),
      'dest_entite_id': (data['dest_entite_id'] ?? '').toString(),
      'dest_commission': data['dest_commission']?.toString(),
      'statut': int.tryParse(data['statut']?.toString() ?? '') ?? 0,
      'created_at': data['created_at']?.toString(),
      'sent_at': data['sent_at']?.toString(),
      'received_at': data['received_at']?.toString(),
      'remote_id': data['remote_id']?.toString(),
      'version': int.tryParse(data['version']?.toString() ?? '') ?? 1,
    };
  }

  static Map<String, dynamic> _toLocalHistory(Map<String, dynamic> data, {required String docId}) {
    final out = <String, dynamic>{};
    out['id'] = (data['id'] ?? docId).toString();
    out['rapport_id'] = (data['rapport_id'] ?? '').toString();
    out['action'] = (data['action'] ?? '').toString();
    out['actor_id'] = data['actor_id']?.toString();
    out['from_entite_id'] = data['from_entite_id']?.toString();
    out['to_entite_id'] = data['to_entite_id']?.toString();
    if (data['data_json'] != null) {
      out['data_json'] = data['data_json'].toString();
    } else if (data['data'] != null) {
      out['data_json'] = jsonEncode(data['data']);
    }
    out['created_at'] = data['created_at']?.toString();
    out['remote_id'] = data['remote_id']?.toString();
    out['version'] = int.tryParse(data['version']?.toString() ?? '') ?? 1;
    return out;
  }

  static Map<String, dynamic> _normalize(Map<String, Object?> row) {
    final out = <String, dynamic>{};
    for (final e in row.entries) {
      final k = e.key;
      final v = e.value;
      if (v is num || v is bool) {
        out[k] = v;
      } else if (v == null) {
        out[k] = null;
      } else {
        out[k] = v.toString();
      }
    }
    if (out.containsKey('taches_json') && out['taches_json'] is String) {
      final s = out['taches_json'] as String;
      try {
        out['taches'] = jsonDecode(s);
      } catch (_) {}
    }
    if (out.containsKey('data_json') && out['data_json'] is String) {
      final s = out['data_json'] as String;
      try {
        out['data'] = jsonDecode(s);
      } catch (_) {}
    }
    return out;
  }
}
