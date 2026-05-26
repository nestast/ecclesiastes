import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/entite_types.dart';

/// Périmètre actif du tableau de bord (champ / district / communauté sélectionnés).
class EntiteScopeService {
  EntiteScopeService._();

  static String? champId;
  static String? districtId;
  static String? communauteId;

  static String? get filterCommunauteId {
    if (communauteId != null && communauteId!.isNotEmpty) return communauteId;
    return AuthService.filterCommunauteId;
  }

  static void setScope({
    String? champ,
    String? district,
    String? communaute,
  }) {
    champId = champ;
    districtId = district;
    communauteId = communaute;
  }

  static void clear() {
    champId = null;
    districtId = null;
    communauteId = null;
  }

  /// Libellé pill : « Champ (Kinshasa Sud-Ouest) »
  static String pillLabel(String niveau, String nom) => '$niveau ($nom)';

  /// Initialise le scope depuis la communauté de session (login).
  static Future<void> initFromSession() async {
    final sessionEntite = AuthService.currentEntiteId;
    if (sessionEntite.isEmpty) {
      await initDefaultForAdmin();
      return;
    }
    await initFromEntite(sessionEntite);
  }

  static Future<void> initFromEntite(String entiteId) async {
    final chain = await DatabaseHelper.instance.getChaineAncestres(entiteId);
    if (chain.isEmpty) return;

    final currentType = EntiteTypes.normalize(chain.last['type']?.toString());
    String? champ;
    String? district;
    String? communaute;

    for (final e in chain) {
      final t = EntiteTypes.normalize(e['type']?.toString());
      if (t == EntiteTypes.champApostolique) champ = e['id']?.toString();
      if (t == EntiteTypes.district) district = e['id']?.toString();
    }

    if (currentType == EntiteTypes.communaute) communaute = entiteId;
    setScope(champ: champ, district: district, communaute: communaute);
  }

  static Future<void> initFromCommunaute(String communauteIdParam) async {
    await initFromEntite(communauteIdParam);
  }

  /// Super-admin / ministre : premier champ + premier district + première communauté.
  static Future<void> initDefaultForAdmin() async {
    final champs = await DatabaseHelper.instance.getEntitesByType(EntiteTypes.champApostolique);
    if (champs.isEmpty) return;
    final champ = champs.first['id'].toString();
    final districts = await DatabaseHelper.instance.getSubEntites(champ, EntiteTypes.district);
    if (districts.isEmpty) {
      setScope(champ: champ);
      return;
    }
    final district = districts.first['id'].toString();
    final comms = await DatabaseHelper.instance.getSubEntites(district, EntiteTypes.communaute);
    setScope(
      champ: champ,
      district: district,
      communaute: comms.isNotEmpty ? comms.first['id'].toString() : null,
    );
  }
}
