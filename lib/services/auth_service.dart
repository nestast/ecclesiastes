import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/password_utils.dart';
import 'package:ecclesiaste/utils/secure_storage_helper.dart';
import 'package:ecclesiaste/services/logging_service.dart';

class AuthService {
  static Map<String, dynamic>? currentUser;
  static String? filterCommunauteId;

  static String get currentEntiteId => currentUser?['entite_id']?.toString() ?? '';

  static bool isSuperAdmin() => currentUser?['role'] == 'SUPER_ADMIN';

  static bool isResponsable() {
    final label = currentUser?['role_label']?.toString() ?? '';
    return isSuperAdmin() || label.contains('Responsable') || label == 'Apôtre' || label == 'Ministre';
  }

  static Future<bool> login({
    required String identifiant,
    required String password,
    required String communauteId,
    String? ministere,
    String? roleLabel,
  }) async {
    final user = await DatabaseHelper.instance.getUtilisateurByIdentifiant(identifiant);
    if (user == null) return false;

    if (verifyPassword(password, user['mot_de_passe_hash'])) {
      currentUser = Map<String, dynamic>.from(user);
      if (ministere != null) currentUser!['ministere'] = ministere;
      if (roleLabel != null) currentUser!['role_label'] = roleLabel;
      
      await SecureStorageHelper.saveSession(currentUser!);
      LoggingService.logAuth('login', userId: currentUser!['id'], message: 'User logged in');
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    currentUser = null;
    filterCommunauteId = null;
    await SecureStorageHelper.clearSession();
  }
}
