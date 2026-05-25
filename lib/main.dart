import 'package:flutter/material.dart';
import 'package:ecclesiaste/views/login_page.dart';
import 'package:ecclesiaste/views/dashboard_page.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);
  await DatabaseHelper.instance.database;
  await NotificationService.init();

  runApp(const EgliseApp());
}

class EgliseApp extends StatelessWidget {
  const EgliseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eglise',
      debugShowCheckedModeBanner: false,
      
      // Configuration du thème global de l'application
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004A99),
          primary: const Color(0xFF004A99),
          secondary: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // Logique de démarrage :
      // Si une session utilisateur existe dans AuthService, on va au Dashboard.
      // Sinon, on affiche la page de connexion.
      home: AuthService.currentUser != null 
          ? const DashboardPage() 
          : const LoginPage(),

      // Définition des routes nommées pour faciliter la navigation
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}