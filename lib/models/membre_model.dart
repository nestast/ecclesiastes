class MembreModel {
  String id;
  String nom;
  String poste;
  String commission;
  String entiteId; // ID de la communauté ou du district

  MembreModel({
    required this.id,
    required this.nom,
    required this.poste,
    required this.commission,
    required this.entiteId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'poste': poste,
      'commission': commission,
      'entite_id': entiteId,
    };
  }
}