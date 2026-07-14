import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_clone/data/services/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  group('AuthService', () {
    test('muser1/mpassword1 authentifie avec succes', () async {
      final result = await authService.login('muser1', 'mpassword1');

      expect(result.isSuccess, isTrue);
      expect(result.status, AuthStatus.success);
      expect(result.username, 'muser1');
      expect(result.message, isNull);
    });

    test('muser2/mpassword2 authentifie avec succes', () async {
      final result = await authService.login('muser2', 'mpassword2');

      expect(result.isSuccess, isTrue);
      expect(result.status, AuthStatus.success);
      expect(result.username, 'muser2');
    });

    test('muser3/mpassword3 renvoie le message de compte bloque', () async {
      final result = await authService.login('muser3', 'mpassword3');

      expect(result.isSuccess, isFalse);
      expect(result.status, AuthStatus.blocked);
      expect(result.message, 'Ce compte a été bloqué.');
    });

    test('une combinaison inconnue renvoie le message d\'identifiants invalides', () async {
      final result = await authService.login('inconnu', 'mauvais-mdp');

      expect(result.isSuccess, isFalse);
      expect(result.status, AuthStatus.invalid);
      expect(result.message, 'Informations de connexion invalides');
    });

    test('un mot de passe correct mais un username incorrect echoue', () async {
      final result = await authService.login('muser1', 'mpassword2');

      expect(result.isSuccess, isFalse);
      expect(result.status, AuthStatus.invalid);
    });

    test('les espaces autour du username sont ignores', () async {
      final result = await authService.login('  muser1  ', 'mpassword1');

      expect(result.isSuccess, isTrue);
      expect(result.username, 'muser1');
    });
  });
}
