import 'package:flutter/material.dart';
import 'package:ecclesiaste/utils/user_access.dart';
import 'package:ecclesiaste/views/dashboards/dashboard_commission_page.dart';
import 'package:ecclesiaste/views/dashboards/dashboard_membre_page.dart';
import 'package:ecclesiaste/views/dashboards/dashboard_ministre_page.dart';
import 'package:ecclesiaste/views/dashboards/dashboard_responsable_entite_page.dart';

/// Routeur : affiche le tableau de bord selon le profil de connexion.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    switch (UserAccessProfile.current) {
      case UserAccessProfile.ministre:
        return const DashboardMinistrePage();
      case UserAccessProfile.responsableEntite:
        return const DashboardResponsableEntitePage();
      case UserAccessProfile.responsableCommission:
        return const DashboardCommissionPage();
      case UserAccessProfile.membre:
      default:
        return const DashboardMembrePage();
    }
  }
}
