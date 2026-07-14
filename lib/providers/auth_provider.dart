import 'package:flutter/foundation.dart';
import '../data/services/auth_service.dart';

/// Expose l'etat d'authentification a l'interface (chargement, erreur,
/// utilisateur connecte) et delegue la logique de verification des
/// identifiants a [AuthService].
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  bool isLoading = false;
  String? errorMessage;
  String? currentUsername;

  bool get isAuthenticated => currentUsername != null;

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      errorMessage = 'Informations de connexion invalides';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.login(username, password);

    isLoading = false;

    if (result.isSuccess) {
      currentUsername = result.username;
      errorMessage = null;
      notifyListeners();
      return true;
    }

    errorMessage = result.message;
    notifyListeners();
    return false;
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  void logout() {
    currentUsername = null;
    errorMessage = null;
    notifyListeners();
  }
}
