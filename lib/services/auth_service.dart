import 'package:logger/logger.dart';

final logger = Logger();

class AuthService {
  static Map<String, dynamic>? currentUser;
  static String? _filterCommunauteId;
  static String? _currentEntiteId;

  static Future<bool> login(String username, String password) async {
    try {
      // TODO: Implement actual authentication
      logger.i('Attempting login for user: $username');
      return false;
    } catch (e) {
      logger.e('Login error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      currentUser = null;
      _filterCommunauteId = null;
      _currentEntiteId = null;
      logger.i('User logged out');
    } catch (e) {
      logger.e('Logout error: $e');
    }
  }

  static bool get isAuthenticated => currentUser != null;

  static String? get userId => currentUser?['user_id'] as String?;

  static String? get username => currentUser?['username'] as String?;

  static String? get role => currentUser?['role'] as String?;

  static String? get filterCommunauteId => _filterCommunauteId ?? currentUser?['communaute_id'] as String?;

  static String? get currentEntiteId => _currentEntiteId ?? currentUser?['entite_id'] as String?;

  static void setFilterCommunauteId(String? id) {
    _filterCommunauteId = id;
  }

  static void setCurrentEntiteId(String? id) {
    _currentEntiteId = id;
  }

  static bool isSuperAdmin() {
    final role = currentUser?['role']?.toString().toLowerCase() ?? '';
    return role.contains('admin') || role.contains('apostle');
  }

  static bool isResponsable() {
    final role = currentUser?['role']?.toString().toLowerCase() ?? '';
    return role.contains('responsable') || role.contains('responsable_entite');
  }
}