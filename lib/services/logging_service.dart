import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

class LoggingService {
  static void debug(String message) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, stackTrace: stackTrace, error: error);
  }

  static void verbose(String message) {
    _logger.t(message);
  }

  static void logAuth(String location, {String? userId, String? message}) {
    final details = 'Auth [$location] - UserId: $userId - $message';
    _logger.i(details);
  }

  static void logNavigation(String from, String to) {
    _logger.i('Navigation: $from -> $to');
  }

  static void logDatabaseOperation(String operation, String table, {dynamic data}) {
    _logger.i('DB [$operation] on $table: $data');
  }

  static void logValidation(String context, List<String> errors) {
    if (errors.isEmpty) {
      _logger.i('Validation [$context]: OK');
    } else {
      _logger.w('Validation [$context] errors: ${errors.join(", ")}');
    }
  }
}