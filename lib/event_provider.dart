import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class EventProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<ChurchEvent> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChurchEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charger tous les événements
  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await _databaseService.getAllEvents();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur chargement événements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les événements par type
  Future<void> loadEventsByType(EventType type) async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await _databaseService.getEventsByType(type);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur chargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les événements par plage de dates
  Future<void> loadEventsByDateRange(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await _databaseService.getEventsByDateRange(start, end);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur chargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un nouvel événement
  Future<bool> createEvent(ChurchEvent event) async {
    try {
      await _databaseService.insertEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur création: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour un événement
  Future<bool> updateEvent(ChurchEvent event) async {
    try {
      await _databaseService.updateEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur mise à jour: $e';
      notifyListeners();
      return false;
    }
  }

  /// Supprimer un événement
  Future<bool> deleteEvent(String id) async {
    try {
      await _databaseService.deleteEvent(id);
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur suppression: $e';
      notifyListeners();
      return false;
    }
  }

  /// Obtenir les statistiques des événements
  Map<String, dynamic> getEventStatistics() {
    int totalEvents = _events.length;
    int plannedEvents = _events.where((e) => e.status == 'planned').length;
    int completedEvents = _events.where((e) => e.status == 'completed').length;
    double totalOfferings = _events.fold(0.0, (sum, e) => sum + e.offering);
    int totalMembers = _events.fold(0, (sum, e) => sum + e.actualMembers);

    return {
      'totalEvents': totalEvents,
      'plannedEvents': plannedEvents,
      'completedEvents': completedEvents,
      'totalOfferings': totalOfferings,
      'totalMembers': totalMembers,
      'averageMembers': totalEvents > 0 ? totalMembers / totalEvents : 0,
    };
  }

  /// Obtenir les prochains événements
  List<ChurchEvent> getUpcomingEvents({int days = 30}) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));

    return _events
        .where((e) => e.startDate.isAfter(now) && e.startDate.isBefore(future))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  /// Obtenir les événements passés
  List<ChurchEvent> getPastEvents() {
    final now = DateTime.now();
    return _events
        .where((e) => e.startDate.isBefore(now))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }
}

/// Provider pour la gestion des rapports
class ReportProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<SacristyReport> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SacristyReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charger les rapports pour un événement
  Future<void> loadReportsByEvent(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reports = await _databaseService.getSacristyReportsByEvent(eventId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur chargement rapports: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un rapport
  Future<bool> createReport(SacristyReport report) async {
    try {
      await _databaseService.insertSacristyReport(report);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur création rapport: $e';
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour un rapport
  Future<bool> updateReport(SacristyReport report) async {
    try {
      await _databaseService.updateSacristyReport(report);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur mise à jour rapport: $e';
      notifyListeners();
      return false;
    }
  }

  /// Obtenir les statistiques des rapports
  Map<String, dynamic> getReportStatistics() {
    int totalReports = _reports.length;
    int totalMembers = _reports.fold(0, (sum, r) => sum + r.memberCount);
    int totalVisitors = _reports.fold(0, (sum, r) => sum + r.visitorCount);
    double totalOfferings = _reports.fold(0.0, (sum, r) => sum + r.offeringAmount);

    return {
      'totalReports': totalReports,
      'totalMembers': totalMembers,
      'totalVisitors': totalVisitors,
      'totalOfferings': totalOfferings,
      'averageMembersPerReport': totalReports > 0 ? totalMembers / totalReports : 0,
      'averageOfferingPerReport': totalReports > 0 ? totalOfferings / totalReports : 0,
    };
  }
}
