import 'package:flutter/material.dart';
import '../models/report_base.dart';
import '../services/report_service.dart';

class InteractiveReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  
  List<ReportBase> _allReports = [];
  List<ReportBase> _filteredReports = [];
  ReportBase? _selectedReport;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ReportBase> get allReports => _allReports;
  List<ReportBase> get filteredReports => _filteredReports;
  ReportBase? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  InteractiveReportProvider() {
    _loadAllReports();
  }

  Future<void> reloadReports() async {
    await _loadAllReports();
  }

  Future<void> _loadAllReports() async {
    _setLoading(true);
    try {
      _allReports = await _reportService.getAllReports();
      _filteredReports = List.from(_allReports);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des rapports: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<String> createReport(ReportBase report) async {
    _setLoading(true);
    try {
      final id = await _reportService.createReport(report);
      await _loadAllReports();
      _error = null;
      return id;
    } catch (e) {
      _error = 'Erreur lors de la création du rapport: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReport(ReportBase report) async {
    _setLoading(true);
    try {
      await _reportService.updateReport(report);
      await _loadAllReports();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du rapport: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReport(String reportId) async {
    _setLoading(true);
    try {
      await _reportService.deleteReport(reportId);
      await _loadAllReports();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la suppression du rapport: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectReport(String reportId) async {
    try {
      _selectedReport = await _reportService.getReport(reportId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la sélection du rapport: $e';
      notifyListeners();
    }
  }

  void searchReports(String query) {
    if (query.isEmpty) {
      _filteredReports = List.from(_allReports);
    } else {
      _filteredReports = _allReports
          .where((report) =>
              report.title.toLowerCase().contains(query.toLowerCase()) ||
              report.author.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByType(String? type) {
    if (type == null || type == 'all') {
      _filteredReports = List.from(_allReports);
    } else {
      _filteredReports = _allReports
          .where((report) => report.type.name == type)
          .toList();
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _error = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _reportService.close();
    super.dispose();
  }
}
