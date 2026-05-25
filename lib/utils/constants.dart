class AppConstants {
  static const String appName = "Ecclesiaste";
  static const String masterAdminName = "Nestor Mbuyi Kankolongo";

  // Les 12 commissions officielles de KSO
  static const List<String> commissions = [
    "Commission d’Ecodim",
    "Commission d’Econfi",
    "Commission de la Jeunesse",
    "Commission des papas",
    "Commission des mamans",
    "Commission des aînés",
    "Commission musique",
    "Commission presse, médias et sonorisation",
    "Commission des Joseph d’arimathee",
    "Commission sécurité et protocole",
    "Commission médicale",
    "Commission construction",
  ];

  // Données du comité (Modèle CLJ KSO)
  static const List<String> rolesConnexion = [
    'Ministre',
    'Apôtre',
    'Responsable de district',
    'Responsable de communauté',
    'Responsable de commission',
    'Secrétaire',
    'Trésorier',
    'Diacre',
    'Membre',
  ];

  /// 12 commissions KSO avec métadonnées pour le tableau de bord.
  static const List<Map<String, dynamic>> commissionsDashboard = [
    {'id': 1, 'nom': 'Ecodim', 'court': 'Ecodim (1.)', 'section': 'local', 'icon': 0xe318, 'responsable': 'Mère Françoise', 'pct': 85, 'statut': 'Actif'},
    {'id': 2, 'nom': 'Econfi', 'court': 'Econfi (2.)', 'section': 'local', 'icon': 0xe80c, 'responsable': 'P. Kabongo', 'pct': 80, 'statut': 'In-progress'},
    {'id': 3, 'nom': 'Jeunesse', 'court': 'Jeunesse (3.)', 'section': 'local', 'icon': 0xe7ef, 'responsable': 'Fr. Mbuyi', 'pct': 92, 'statut': 'Actif'},
    {'id': 4, 'nom': 'Papas', 'court': 'Papas (4.)', 'section': 'local', 'icon': 0xe7fd, 'responsable': 'P. Tshilombo', 'pct': 70, 'statut': 'In-progress'},
    {'id': 5, 'nom': 'Mamans', 'court': 'Mamans (5.)', 'section': 'local', 'icon': 0xe87e, 'responsable': 'Sr. Ngandu', 'pct': 88, 'statut': 'Actif'},
    {'id': 6, 'nom': 'Aînés', 'court': 'Aînés (6.)', 'section': 'local', 'icon': 0xe8d3, 'responsable': 'P. Kikaba', 'pct': 75, 'statut': 'Actif'},
    {'id': 7, 'nom': 'Musique', 'court': 'Musique (7.)', 'section': 'tech', 'icon': 0xe405, 'responsable': 'Fr. Kavunga', 'pct': 90, 'statut': 'Actif'},
    {'id': 8, 'nom': 'Presse & Sono', 'court': 'Presse & Sono (8.)', 'section': 'tech', 'icon': 0xe04f, 'responsable': 'P. Makiese', 'pct': 65, 'statut': 'In-progress'},
    {'id': 9, 'nom': "Joseph d'Arimathée", 'court': "Joseph d'Arimathée (9.)", 'section': 'tech', 'icon': 0xe869, 'responsable': 'Sr. Mayuba', 'pct': 78, 'statut': 'Actif'},
    {'id': 10, 'nom': 'Sécurité', 'court': 'Sécurité (10.)', 'section': 'tech', 'icon': 0xe32a, 'responsable': 'Fr. Anderson', 'pct': 82, 'statut': 'Actif'},
    {'id': 11, 'nom': 'Médicale', 'court': 'Médicale (11.)', 'section': 'tech', 'icon': 0xe3f3, 'responsable': 'Dr. Ilunga', 'pct': 95, 'statut': 'Actif'},
    {'id': 12, 'nom': 'Construction', 'court': 'Construction (12.)', 'section': 'tech', 'icon': 0xe869, 'responsable': 'P. Didier', 'pct': 60, 'statut': 'In-progress'},
  ];

  static const List<Map<String, String>> comiteMembres = [
    {"poste": "Coordonnateur", "nom": "P. Didier KUYINDAMA"},
    {"poste": "Rapporteur", "nom": "Sr. Bénédicte MAYUBA"},
    {"poste": "Chargé de l'enseignement", "nom": "P. Faki MAKIESE"},
    {"poste": "Chargée des questions féminines", "nom": "Sr. Walburge TOMONE"},
    {"poste": "Chargé de Programmation & Eval.", "nom": "P. Christian KIKABA"},
    {"poste": "Chargé des relations publiques", "nom": "Fr. Anderson KAVUNGA"},
    {"poste": "Chargée des finances & patrimoine", "nom": "Sr. Belle NGANDU"},
  ];

  static const int ageRetraite = 65;

  static const List<String> typesOrdination = [
    'Ordination',
    'Mandatement',
    'Nomination',
  ];

  static const List<String> droitsMinistres = [
    'Consentement préalable avant toute ordination, mandatement ou nomination',
    'Droit à l\'information pour accomplir leurs tâches',
    'Participation aux réunions et services divins ministériels',
    'Protection et sollicitude en cas de conflits liés à l\'activité',
    'Pastorale personnelle pour le ministre et sa famille',
    'Droit d\'être entendu avant toute décision les concernant',
    'Droit à la retraite à 65 ans ou de manière anticipée',
    'Droit de résigner leur ministère',
  ];

  static const List<String> devoirsMinistres = [
    'Communion avec l\'apostolat, ne pas agir par leurs propres ressources',
    'Annoncer l\'Évangile dans sa pureté, respecter la doctrine du Catéchisme',
    'Conformité des actes et paroles à la foi, en public comme en privé',
    'Loyauté, impartialité, désintéressement et conduite exemplaire',
    'Confidentialité absolue sur les entretiens pastoraux et réunions',
    'Protection contre les violences sexuelles, signalement immédiat',
    'Retenue politique : ne pas influencer les convictions politiques des membres',
  ];
}