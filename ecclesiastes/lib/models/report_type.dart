enum ReportType {
  meeting('Rapport de Réunion'),
  visit('Rapport de Visite'),
  divineService('Rapport de Service Divin'),
  activity('Rapport d\'Activité'),
  financial('Rapport Financier'),
  disciplinary('Rapport Disciplinaire'),
  other('Autre Rapport');

  final String label;
  const ReportType(this.label);

  String get description {
    switch (this) {
      case ReportType.meeting:
        return 'Documenter une réunion officielle avec discussions et décisions';
      case ReportType.visit:
        return 'Enregistrer une visite pastorale ou administrative';
      case ReportType.divineService:
        return 'Reporter sur un service divin';
      case ReportType.activity:
        return 'Documenter une activité communautaire';
      case ReportType.financial:
        return 'Rapport sur les finances et les offrandes';
      case ReportType.disciplinary:
        return 'Documenter des actions disciplinaires';
      case ReportType.other:
        return 'Type de rapport personnalisé';
    }
  }
}
