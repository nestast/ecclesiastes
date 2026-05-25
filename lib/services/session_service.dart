import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service de gestion des sessions utilisateur avec persistance
class SessionService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  
  /// Sauvegarde la session utilisateur dans SharedPreferences
  static Future<void> saveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
    // Enregistrer aussi l'heure de connexion
    await prefs.setInt('session_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Restaure la session utilisateur depuis SharedPreferences
  static Future<Map<String, dynamic>?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    
    if (data == null) return null;
    
    try {
      final user = jsonDecode(data) as Map<String, dynamic>;
      
      // Vérifier si la session n'a pas expiré (optionnel : 24 heures)
      final timestamp = prefs.getInt('session_timestamp');
      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final diffHours = (now - timestamp) ~/ (1000 * 60 * 60);
        
        if (diffHours > 24) {
          // Session expirée
          await clearSession();
          return null;
        }
      }
      
      return user;
    } catch (e) {
      debugPrint('Erreur lors de la restauration de session: $e');
      return null;
    }
  }
  
  /// Efface complètement la session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove('session_timestamp');
  }
  
  /// Vérifie si une session existe et est valide
  static Future<bool> isSessionValid() async {
    final session = await restoreSession();
    return session != null;
  }
}
