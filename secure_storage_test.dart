import 'package:flutter_test/flutter_test.dart';
import 'package:ecclesiaste/utils/secure_storage_helper.dart';

void main() {
  group('SecureStorageHelper Tests', () {
    tearDown(() async {
      await SecureStorageHelper.clearSession();
    });

    test('saveSession should save user data', () async {
      await SecureStorageHelper.saveSession(
        userId: 'user123',
        role: 'ADMIN',
        entiteId: 'entite456',
      );

      final hasSession = await SecureStorageHelper.hasSession();
      expect(hasSession, true);
    });

    test('getSession should retrieve saved session', () async {
      await SecureStorageHelper.saveSession(
        userId: 'user123',
        role: 'ADMIN',
        entiteId: 'entite456',
      );

      final session = await SecureStorageHelper.getSession();
      expect(session, isNotNull);
      expect(session?['user_id'], 'user123');
      expect(session?['role'], 'ADMIN');
      expect(session?['entite_id'], 'entite456');
    });

    test('hasSession should return false when no session exists', () async {
      final hasSession = await SecureStorageHelper.hasSession();
      expect(hasSession, false);
    });

    test('clearSession should remove session', () async {
      await SecureStorageHelper.saveSession(
        userId: 'user123',
        role: 'ADMIN',
        entiteId: 'entite456',
      );

      await SecureStorageHelper.clearSession();
      final hasSession = await SecureStorageHelper.hasSession();
      expect(hasSession, false);
    });

    test('saveValue and getValue should work for custom values', () async {
      await SecureStorageHelper.saveValue('custom_key', 'custom_value');
      final value = await SecureStorageHelper.getValue('custom_key');
      expect(value, 'custom_value');
    });
  });
}
