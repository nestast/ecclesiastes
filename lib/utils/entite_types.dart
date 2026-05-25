/// Hiérarchie officielle : Église territoriale → Champ apostolique → District → Communauté.
class EntiteTypes {
  EntiteTypes._();

  static const String egliseTerritoriale = 'EGLISE_TERRITORIALE';
  static const String champApostolique = 'CHAMP_APOSTOLIQUE';
  static const String district = 'DISTRICT';
  static const String communaute = 'COMMUNAUTE';

  /// Racine de navigation (écran initial hiérarchie).
  static const String racine = 'RACINE';

  static const List<String> hierarchie = [
    egliseTerritoriale,
    champApostolique,
    district,
    communaute,
  ];

  static const List<String> typesConfigurables = hierarchie;

  static String label(String type) {
    switch (normalize(type)) {
      case egliseTerritoriale:
        return 'Église territoriale';
      case champApostolique:
        return 'Champ apostolique';
      case district:
        return 'District';
      case communaute:
        return 'Communauté';
      default:
        return type;
    }
  }

  /// Type des enfants directs pour un parent donné.
  static String? enfantDe(String typeParent) {
    switch (normalize(typeParent)) {
      case racine:
        return egliseTerritoriale;
      case egliseTerritoriale:
        return champApostolique;
      case champApostolique:
        return district;
      case district:
        return communaute;
      default:
        return null;
    }
  }

  /// Convertit les anciens codes (CHAMP, TERRITOIRE) vers le nouveau modèle.
  static String normalize(String? type) {
    if (type == null || type.isEmpty) return type ?? '';
    switch (type.toUpperCase()) {
      case 'TERRITOIRE':
      case 'EGLISE':
        return egliseTerritoriale;
      case 'CHAMP':
        return champApostolique;
      case 'DISTRICT':
        return district;
      case 'COMMUNAUTE':
        return communaute;
      case 'RACINE':
        return racine;
      default:
        return type.toUpperCase();
    }
  }

  static bool peutNaviguerVersEnfants(String type) => type != communaute;
}
