import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/entite_scope_service.dart';
import 'package:ecclesiaste/services/session_service.dart';
import 'package:ecclesiaste/utils/password_utils.dart';
import 'package:ecclesiaste/utils/entite_types.dart';

class AuthService {
  static Map<String, dynamic>? currentUser;

  /// Initialise l'authentification en restaurant la session persistée
  static Future<void> initializeAuth() async {
    final savedSession = await SessionService.restoreSession();
    if (savedSession != null) {
      currentUser = savedSession;
      debugPrint('✓ Session restaurée pour ${savedSession['nom_complet']}');
    }
  }

  static Future<bool> login({
    required String identifiant,
    required String password,
    required String communauteId,
    String? ministere,
    String? roleLabel,
  }) async {
    // ✅ Validation stricte des paramètres
    if (identifiant.isEmpty || password.isEmpty || communauteId.isEmpty) {
      throw Exception('Identifiant, mot de passe et communauté sont requis.');
    }

    final user = await DatabaseHelper.instance.getUtilisateurByIdentifiant(identifiant);
    if (user == null) {
      throw Exception('Identifiant ou mot de passe incorrect.');
    }

    // ✅ Vérification du mot de passe
    if (!verifyPassword(password, user['mot_de_passe_hash'] as String)) {
      throw Exception('Identifiant ou mot de passe incorrect.');
    }

    final role = user['role'] as String;

    // ✅ Vérifications spécifiques pour non-SUPER_ADMIN
    if (role != 'SUPER_ADMIN') {
      final userEntite = user['entite_id']?.toString();

      // NOUVEAU : Vérifier que l'utilisateur est assigné à une entité
      if (userEntite == null || userEntite.isEmpty) {
        throw Exception('Compte non assigné à une entité. Contactez un administrateur.');
      }

      // ✅ Vérifier que la communauté sélectionnée correspond
      if (userEntite != communauteId) {
        throw Exception('La communauté sélectionnée ne correspond pas à votre inscription.');
      }

      // ✅ Vérifier role_label et ministere si enregistrés
      final regRole = user['role_label']?.toString();
      final regMin = user['ministere']?.toString();

      if (regRole != null && regRole.isNotEmpty && regRole != roleLabel) {
        throw Exception('Le rôle sélectionné ne correspond pas à votre inscription.');
      }
      if (regMin != null && regMin.isNotEmpty && regMin != ministere) {
        throw Exception('Le ministère sélectionné ne correspond pas à votre inscription.');
      }

      // ✅ Vérifier le statut de validation et la deadline de 3 jours
      final int status = user['statut_validation'] != null
          ? int.tryParse(user['statut_validation'].toString()) ?? 0
          : 0;

      final dateInscStr = user['date_inscription']?.toString();
      if (dateInscStr != null && dateInscStr.isNotEmpty) {
        final dateInsc = DateTime.tryParse(dateInscStr);
        if (dateInsc != null) {
          final diffHours = DateTime.now().difference(dateInsc).inHours;

          // ✅ Utiliser les heures pour plus de précision (3 jours = 72h)
          if (status == 0 && diffHours >= 72) {
            // Supprimer l'inscription expirée
            await DatabaseHelper.instance.supprimerUtilisateur(user['id'] as String);
            throw Exception('Votre demande d\'inscription a expiré (délai de 3 jours dépassé). Veuillez vous réinscrire.');
          }
        }
      }

      // ✅ Si le compte est encore en attente de validation
      if (status == 0) {
        final dateInsc = dateInscStr != null ? DateTime.tryParse(dateInscStr) : null;
        final remainingHours = dateInsc != null
            ? (72 - DateTime.now().difference(dateInsc).inHours)
            : 72;
        final remainingDays = (remainingHours / 24).ceil();

        throw Exception(
          'Compte en attente de validation par le responsable de votre entité.\n'
          'Délai restant : $remainingDays jour(s).',
        );
      }
    }

    // ✅ Créer l'objet session utilisateur
    currentUser = {
      'id': user['id'],
      'nom_complet': user['nom_complet'],
      'role': role,
      'entite_id': communauteId,
      'type_entite': EntiteTypes.normalize(user['type_entite']?.toString()) == EntiteTypes.communaute
          ? EntiteTypes.communaute
          : (user['type_entite'] ?? EntiteTypes.communaute),
      if (ministere != null) 'ministere': ministere,
      if (roleLabel != null) 'role_label': roleLabel,
      'login_time': DateTime.now().toIso8601String(), // Timestamp de connexion
    };

    // ✅ Persister la session
    try {
      await SessionService.saveSession(currentUser!);
      debugPrint('✓ Session utilisateur sauvegardée');
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la sauvegarde de session: $e');
      // On continue même si la sauvegarde échoue
    }

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

  /// Déconnexion sécurisée avec nettoyage complet
  static Future<void> logout() async {
    currentUser = null;
    EntiteScopeService.clear();
    
    // ✅ Nettoyer la session persistée
    try {
      await SessionService.clearSession();
      debugPrint('✓ Session déconnectée et nettoyée');
    } catch (e) {
      debugPrint('⚠️ Erreur lors du nettoyage de session: $e');
    }
  }

  static String get currentEntiteId => currentUser?['entite_id']?.toString() ?? '';

  static String? get filterCommunauteId {
    final scoped = EntiteScopeService.communauteId;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    if (isSuperAdmin()) return null;
    return currentEntiteId.isNotEmpty ? currentEntiteId : null;
  }

  /// Obtient les informations de l'utilisateur connecté
  static Map<String, dynamic>? get userInfo => currentUser != null ? Map.from(currentUser!) : null;
}
