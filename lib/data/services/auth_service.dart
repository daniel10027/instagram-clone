/// Statuts possibles renvoyes par une tentative de connexion.
enum AuthStatus { success, blocked, invalid }

/// Resultat d'une tentative d'authentification : le statut, ainsi que
/// le message a afficher le cas echeant (null en cas de succes).
class AuthResult {
  final AuthStatus status;
  final String? message;
  final String? username;

  const AuthResult._(this.status, this.message, this.username);

  factory AuthResult.success(String username) =>
      AuthResult._(AuthStatus.success, null, username);

  factory AuthResult.blocked() =>
      const AuthResult._(AuthStatus.blocked, 'Ce compte a été bloqué.', null);

  factory AuthResult.invalid() => const AuthResult._(
        AuthStatus.invalid,
        'Informations de connexion invalides',
        null,
      );

  bool get isSuccess => status == AuthStatus.success;
}

/// Service d'authentification. Conformement au cahier des charges de
/// cette evaluation technique, les identifiants sont fixes (aucun
/// backend d'authentification reel n'est requis) :
///
/// - muser1 / mpassword1 -> connexion reussie
/// - muser2 / mpassword2 -> connexion reussie
/// - muser3 / mpassword3 -> compte bloque
/// - toute autre combinaison -> identifiants invalides
class AuthService {
  static const Map<String, String> _validCredentials = {
    'muser1': 'mpassword1',
    'muser2': 'mpassword2',
  };

  static const Map<String, String> _blockedCredentials = {
    'muser3': 'mpassword3',
  };

  /// Simule un appel reseau pour rendre l'experience de connexion
  /// realiste (etat de chargement visible sur le bouton "Log in").
  Future<AuthResult> login(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final normalizedUsername = username.trim();

    if (_blockedCredentials[normalizedUsername] == password) {
      return AuthResult.blocked();
    }

    if (_validCredentials[normalizedUsername] == password) {
      return AuthResult.success(normalizedUsername);
    }

    return AuthResult.invalid();
  }
}
