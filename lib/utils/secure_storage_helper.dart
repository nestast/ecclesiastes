import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'user_session';

  static Future<void> saveSession(Map<String, dynamic> userData) async {
    await _storage.write(key: _sessionKey, value: jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final data = await _storage.read(key: _sessionKey);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> hasSession() async {
    final data = await _storage.read(key: _sessionKey);
    return data != null;
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}
