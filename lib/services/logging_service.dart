import 'package:logger/logger.dart';

class LoggingService {
  static final Logger _logger = Logger();

  static void debug(String message, {String? source}) {
    _logger.d(_format(source, message));
  }

  static void info(String message, {String? source}) {
    _logger.i(_format(source, message));
  }

  static void warning(String message, {String? source}) {
    _logger.w(_format(source, message));
  }

  static void error(String message, {String? source, Object? error, StackTrace? stackTrace}) {
    _logger.e(_format(source, message), error: error, stackTrace: stackTrace);
  }

  static void logAuth(String source, {String? userId, required String message}) {
    _logger.i('[$source] userId=$userId $message');
  }

  static void logDatabase(String action, {String? table, required String message}) {
    _logger.i('[database] action=$action table=${table ?? "unknown"} $message');
  }

  static void logService(String service, String action, {required String message}) {
    _logger.i('[$service] action=$action $message');
  }

  static String _format(String? source, String message) {
    if (source == null || source.isEmpty) {
      return message;
    }
    return '[$source] $message';
  }
}
