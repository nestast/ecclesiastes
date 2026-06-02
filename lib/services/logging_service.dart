import 'package:logger/logger.dart';

class LoggingService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );

  static void info(String message) => _logger.i(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) => _logger.e(message, error: error, stackTrace: stackTrace);
  static void warning(String message) => _logger.w(message);

  static void logAuth(String action, {String? userId, required String message}) {
    _logger.i('AUTH [$action]${userId != null ? " (User: $userId)" : ""}: $message');
  }
}
