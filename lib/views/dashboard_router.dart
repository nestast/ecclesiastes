import 'package:flutter/material.dart';
import '../models/models.dart';
import 'minister_dashboard.dart';
import 'entity_manager_dashboard.dart';
import 'commission_dashboard.dart';
import 'member_dashboard.dart';

/// Classe utilitaire pour router vers le bon dashboard selon le rôle
class DashboardRouter {
  static Widget getDashboardForUser(AppUser user) {
    switch (user.level) {
      case UserLevel.apostle:
      case UserLevel.bishop:
        return const EntityManagerDashboard();
      case UserLevel.deacon:
        return const EntityManagerDashboard();
      case UserLevel.committeeLead:
        return const CommissionDashboard();
      case UserLevel.minister:
        return const MinisterDashboard();
      case UserLevel.member:
        return const MemberDashboard();
    }
  }

  /// Retourne un titre lisible pour le dashboard
  static String getDashboardTitle(UserLevel level) {
    const titles = {
      UserLevel.apostle: 'Dashboard Apôtre',
      UserLevel.bishop: 'Dashboard Évêque',
      UserLevel.deacon: 'Dashboard Diacre',
      UserLevel.committeeLead: 'Dashboard Responsable Commission',
      UserLevel.minister: 'Dashboard Ministre',
      UserLevel.member: 'Espace Membre',
    };
    return titles[level] ?? 'Dashboard';
  }

  /// Retourne une icône pour le dashboard
  static IconData getDashboardIcon(UserLevel level) {
    const icons = {
      UserLevel.apostle: Icons.trending_up,
      UserLevel.bishop: Icons.business,
      UserLevel.deacon: Icons.domain,
      UserLevel.committeeLead: Icons.groups,
      UserLevel.minister: Icons.person,
      UserLevel.member: Icons.person_outline,
    };
    return icons[level] ?? Icons.dashboard;
  }

  /// Retourne une couleur pour le dashboard
  static Color getDashboardColor(UserLevel level) {
    const colors = {
      UserLevel.apostle: Color(0xFF8B0000),  // Rouge foncé
      UserLevel.bishop: Color(0xFF1E3A8A),  // Bleu foncé
      UserLevel.deacon: Color(0xFF2D5016),  // Vert foncé
      UserLevel.committeeLead: Color(0xFF5B21B6),  // Violet
      UserLevel.minister: Color(0xFF1E3A8A),  // Bleu
      UserLevel.member: Color(0xFF4B5563),  // Gris bleu
    };
    return colors[level] ?? const Color(0xFF1E3A8A);
  }
}

/// Classe pour gérer la navigation vers le dashboard approprié
class DashboardNavigator {
  static void navigateToDashboard(BuildContext context, AppUser user) {
    Navigator.of(context).pushReplacementNamed(
      _getDashboardRoute(user.level),
    );
  }

  static String _getDashboardRoute(UserLevel level) {
    switch (level) {
      case UserLevel.apostle:
      case UserLevel.bishop:
      case UserLevel.deacon:
        return '/entity-dashboard';
      case UserLevel.committeeLead:
        return '/commission-dashboard';
      case UserLevel.minister:
        return '/minister-dashboard';
      case UserLevel.member:
        return '/member-dashboard';
    }
  }
}
