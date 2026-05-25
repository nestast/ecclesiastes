class ReportModel {
  final String id;
  final String commission;
  final DateTime date;
  final double amountUsd;
  final String receiptNumber;
  int statut; // 0: Brouillon, 1: Soumis (RC), 2: Visé (RC), 3: Validé (RD)

  ReportModel({
    required this.id,
    required this.commission,
    required this.date,
    required this.amountUsd,
    required this.receiptNumber,
    this.statut = 0,
  });
}
