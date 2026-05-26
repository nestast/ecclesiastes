import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/entite_scope_service.dart';
import 'package:ecclesiaste/utils/password_utils.dart';
import 'package:ecclesiaste/utils/entite_types.dart';

class AuthService {
  static Map<String, dynamic>? currentUser;

  static Future<bool> login({
    required String identifiant,
    required String password,
    required String communauteId,
    String? ministere,
    String? roleLabel,
  }) async {
    final user = await DatabaseHelper.instance.getUtilisateurByIdentifiant(identifiant);
    if (user == null) return false;
    if (!verifyPassword(password, user['mot_de_passe_hash'] as String)) return false;

    final role = user['role'] as String;

    if (role != 'SUPER_ADMIN') {
      final userEntite = user['entite_id']?.toString();
      if (userEntite != null &&
          userEntite.isNotEmpty &&
          userEntite != communauteId) {
        throw Exception("La communauté sélectionnée ne correspond pas à celle de votre inscription.");
      }

      // Check registered role_label and ministere if present in user record
      final regRole = user['role_label']?.toString();
      final regMin = user['ministere']?.toString();
      if (regRole != null && regRole.isNotEmpty && regRole != roleLabel) {
        throw Exception("Le rôle sélectionné ne correspond pas à votre inscription.");
      }
      if (regMin != null && regMin.isNotEmpty && regMin != ministere) {
        throw Exception("Le ministère sélectionné ne correspond pas à votre inscription.");
      }

      // Check validation status and 3-day deadline
      final int status = user['statut_validation'] != null 
          ? int.tryParse(user['statut_validation'].toString()) ?? 0 
          : 0;

      final dateInscStr = user['date_inscription']?.toString();
      if (dateInscStr != null && dateInscStr.isNotEmpty) {
        final dateInsc = DateTime.tryParse(dateInscStr);
        if (dateInsc != null) {
          final diffDays = DateTime.now().difference(dateInsc).inDays;
          if (status == 0 && diffDays >= 3) {
            // Delete expired registration
            await DatabaseHelper.instance.supprimerUtilisateur(user['id'] as String);
            throw Exception("Votre demande d'inscription a expiré (délai de 3 jours dépassé). Veuillez vous réinscrire.");
          }
        }
      }

      if (status == 0) {
        final dateInsc = dateInscStr != null ? DateTime.tryParse(dateInscStr) : null;
        final remainingDays = dateInsc != null ? (3 - DateTime.now().difference(dateInsc).inDays) : 3;
        throw Exception("Compte en attente de validation par le responsable de votre entité. (Délai restant : $remainingDays jour(s))");
      }
    }

    currentUser = {
      'id': user['id'],
      'identifiant': user['identifiant'],
      'nom_complet': user['nom_complet'],
      'role': role,
      'entite_id': communauteId,
      'type_entite': EntiteTypes.normalize(user['type_entite']?.toString()) == EntiteTypes.communaute
          ? EntiteTypes.communaute
          : (user['type_entite'] ?? EntiteTypes.communaute),
      if (ministere != null) 'ministere': ministere,
      if (roleLabel != null) 'role_label': roleLabel,
    };
    return true;
  }

  static bool isSuperAdmin() => currentUser?['role'] == 'SUPER_ADMIN';

  static bool isResponsable() {
    final role = currentUser?['role'];
    return role == 'RESPONSABLE' || role == 'SUPER_ADMIN';
  }

  static bool isEgliseTerritorialeAdmin() =>
      EntiteTypes.normalize(currentUser?['type_entite']?.toString()) == EntiteTypes.egliseTerritoriale;

  static bool isChampApostoliqueAdmin() =>
      EntiteTypes.normalize(currentUser?['type_entite']?.toString()) == EntiteTypes.champApostolique;

  static bool isDistrictAdmin() =>
      EntiteTypes.normalize(currentUser?['type_entite']?.toString()) == EntiteTypes.district;

  static bool isCommunauteAdmin() =>
      EntiteTypes.normalize(currentUser?['type_entite']?.toString()) == EntiteTypes.communaute;

  static void logout() {
    currentUser = null;
    EntiteScopeService.clear();
  }

  static String get currentEntiteId => currentUser?['entite_id']?.toString() ?? '';

  static String? get filterCommunauteId {
    final scoped = EntiteScopeService.communauteId;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    if (isSuperAdmin()) return null;
    return currentEntiteId.isNotEmpty ? currentEntiteId : null;
  }
}
