import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/utils/constants.dart';

/// Profils d'accès déterminés au login (rôle + ministère).
///
/// ## Hiérarchie des entités
/// Super Admin → Église Territoriale → Champ Apostolique → District → Communauté
///
/// ## Double subordination des commissions
/// Les responsables de commission ont une double subordination :
/// 1. **Hiérarchique** : ils dépendent du responsable d'entité ou du ministre
/// 2. **Fonctionnelle** : ils reçoivent des directives de la commission au niveau supérieur
///
/// ## Périmètre de visibilité
/// - **Super Admin** : voit tout, crée/modifie/nomme les entités et commissions
/// - **Ministre/Apôtre** : voit tout le champ apostolique
/// - **Responsable d'entité** : voit tout ce qui concerne son entité, concentre les rapports
/// - **Responsable de commission** : voit sa commission, reçoit les directives
/// - **Membre** : voit ses propres données
class UserAccessProfile {
  UserAccessProfile._();

  static const superAdmin = 'SUPER_ADMIN';
  static const ministre = 'MINISTRE';
  static const responsableEntite = 'RESPONSABLE_ENTITE';
  static const responsableCommission = 'RESPONSABLE_COMMISSION';
  static const membre = 'MEMBRE';

  static String get current {
    if (AuthService.isSuperAdmin()) return superAdmin;
    final label = AuthService.currentUser?['role_label']?.toString() ?? '';
    if (label == 'Ministre' || label == 'Apôtre') return ministre;
    if (label == 'Responsable de commission') return responsableCommission;
    if (label.startsWith('Responsable de ')) return responsableEntite;
    return membre;
  }

  static String get displayTitle {
    switch (current) {
      case superAdmin:
        return 'Super Administrateur';
      case ministre:
        return 'Apostolic Administrator';
      case responsableEntite:
        return 'Responsable d\'entité';
      case responsableCommission:
        return 'Responsable de commission';
      default:
        return 'Membre';
    }
  }

  static bool get canManageEntites =>
      current == superAdmin;

  static bool get canManageCommissions =>
      current == superAdmin;

  static bool get canSeeFinances =>
      current == superAdmin || current == ministre || current == responsableEntite;

  static bool get canSeeCommissionsGrid =>
      current == superAdmin || current == ministre || current == responsableEntite || current == responsableCommission;

  static bool get canSeeEntityFilters =>
      current == superAdmin || current == ministre || current == responsableEntite;

  static bool get canSeeDailyReport =>
      current == superAdmin || current == ministre || current == responsableEntite;

  static bool get canManageMembers =>
      current != membre;

  static bool get canValidateInscriptions =>
      current == superAdmin || current == ministre || current == responsableEntite;

  static bool get canConsolidateReports =>
      current == superAdmin || current == ministre || current == responsableEntite;

  static bool get canAccessBibliotheque => true;

  static bool get canAddDocument =>
      current == superAdmin || current == ministre || current == responsableEntite || current == responsableCommission;

  static bool get canDeleteDocument =>
      current == superAdmin || current == ministre || current == responsableEntite;

  static String get bibliothequeNiveau {
    switch (current) {
      case superAdmin:
        return 'eglise_territoriale';
      case ministre:
        return 'champ';
      case responsableEntite:
        return 'district';
      default:
        return 'communaute';
    }
  }

  static bool get showOnlyOwnCommission => current == responsableCommission;

  static String? get commissionFilter {
    if (!showOnlyOwnCommission) return null;
    return AuthService.currentUser?['ministere']?.toString();
  }

  static bool isProcheRetraite(String? dateNaissance) {
    if (dateNaissance == null || dateNaissance.isEmpty) return false;
    final naissance = DateTime.tryParse(dateNaissance);
    if (naissance == null) return false;
    final age = DateTime.now().difference(naissance).inDays ~/ 365;
    return age >= AppConstants.ageRetraite - 2;
  }

  static int? ageActuel(String? dateNaissance) {
    if (dateNaissance == null || dateNaissance.isEmpty) return null;
    final naissance = DateTime.tryParse(dateNaissance);
    if (naissance == null) return null;
    return DateTime.now().difference(naissance).inDays ~/ 365;
  }
}
