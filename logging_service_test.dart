import 'package:flutter_test/flutter_test.dart';
import 'package:ecclesiaste/services/logging_service.dart';

void main() {
  group('LoggingService Tests', () {
    test('debug logging should work', () {
      expect(() => LoggingService.debug('Test debug message'), returnsNormally);
    });

    test('info logging should work', () {
      expect(() => LoggingService.info('Test info message'), returnsNormally);
    });

    test('warning logging should work', () {
      expect(() => LoggingService.warning('Test warning message'), returnsNormally);
    });

    test('error logging should work', () {
      expect(() => LoggingService.error('Test error message'), returnsNormally);
    });

    test('logAuth should format auth messages', () {
      expect(
        () => LoggingService.logAuth('login', userId: 'user123', message: 'Test login'),
        returnsNormally,
      );
    });

    test('logDatabase should format database messages', () {
      expect(
        () => LoggingService.logDatabase('SELECT', table: 'users', message: 'Query executed'),
        returnsNormally,
      );
    });

    test('logService should format service messages', () {
      expect(
        () => LoggingService.logService('AuthService', 'login', message: 'Auth called'),
        returnsNormally,
      );
    });
  });
}
