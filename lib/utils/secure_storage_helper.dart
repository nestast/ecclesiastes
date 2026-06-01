import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();
  static const String _sessionKey = 'ecclesiaste_session';

  static Future<bool> hasSession() async {
    try {
      final sessionData = await _storage.read(key: _sessionKey);
      return sessionData != null && sessionData.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getSession() async {
    try {
      final sessionData = await _storage.read(key: _sessionKey);
      if (sessionData != null) {
        return jsonDecode(sessionData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveSession(Map<String, dynamic> sessionData) async {
    try {
      await _storage.write(
        key: _sessionKey,
        value: jsonEncode(sessionData),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> clearSession() async {
    try {
      await _storage.delete(key: _sessionKey);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    try {
      await _storage.write(key: key, value: jsonEncode(object));
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final data = await _storage.read(key: key);
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      rethrow;
    }
  }
}