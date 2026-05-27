import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _sessionKey = 'session_data';

  static Future<void> saveSession({
    required String userId,
    required String role,
    required String entiteId,
  }) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'user_id': userId,
        'role': role,
        'entite_id': entiteId,
      }),
    );
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return decoded;
  }

  static Future<bool> hasSession() async {
    final value = await _storage.read(key: _sessionKey);
    return value != null && value.isNotEmpty;
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }

  static Future<void> saveValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getValue(String key) async {
    return _storage.read(key: key);
  }
}
