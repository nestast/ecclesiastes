import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/models.dart';
import 'services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Vérifier si l'utilisateur était connecté
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _secureStorage.read(key: 'userId');
      if (userId != null) {
        final user = await _databaseService.getUser(userId);
        if (user != null && user.isActive) {
          _currentUser = user;
          _errorMessage = null;
        } else {
          await logout();
        }
      }
    } catch (e) {
      _errorMessage = 'Erreur de vérification: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Connexion utilisateur
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulation: dans une vrai app, vérifier le mot de passe hashé
      final users = await _databaseService.getAllUsers();
      final user = users.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('Utilisateur non trouvé'),
      );

      if (!user.isActive) {
        throw Exception('Compte désactivé');
      }

      _currentUser = user;
      await _secureStorage.write(key: 'userId', value: user.id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur de connexion: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    _currentUser = null;
    await _secureStorage.delete(key: 'userId');
    notifyListeners();
  }

  /// Créer un nouvel utilisateur (admin only)
  Future<bool> createUser(AppUser user) async {
    if (_currentUser?.level != UserLevel.apostle) {
      _errorMessage = 'Accès refusé';
      return false;
    }

    try {
      await _databaseService.insertUser(user);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur création utilisateur: $e';
      return false;
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<bool> updateProfile(AppUser updatedUser) async {
    if (_currentUser == null) {
      _errorMessage = 'Non authentifié';
      return false;
    }

    try {
      await _databaseService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur mise à jour: $e';
      return false;
    }
  }

  /// Vérifier les permissions
  bool canAccessLevel(UserLevel requiredLevel) {
    if (_currentUser == null) return false;

    const levelHierarchy = {
      UserLevel.apostle: 0,
      UserLevel.bishop: 1,
      UserLevel.deacon: 2,
      UserLevel.committeeLead: 3,
      UserLevel.minister: 4,
      UserLevel.member: 5,
    };

    return (levelHierarchy[_currentUser!.level] ?? 99) <= (levelHierarchy[requiredLevel] ?? 99);
  }

  /// Vérifier l'accès par entité
  bool canAccessEntity(EntityLevel entityLevel, String entityName) {
    if (_currentUser == null) return false;

    switch (entityLevel) {
      case EntityLevel.commission:
        return _currentUser!.apostleField == entityName || _currentUser!.level == UserLevel.apostle;
      case EntityLevel.district:
        return _currentUser!.district == entityName || _currentUser!.apostleField == _currentUser!.district;
      case EntityLevel.community:
        return _currentUser!.community == entityName;
    }
  }
}
