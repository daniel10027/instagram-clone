import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:instagram_clone/data/services/likes_store.dart';
import 'package:instagram_clone/data/services/unsplash_service.dart';
import 'package:instagram_clone/providers/auth_provider.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/login_screen.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  late Directory tempDir;
  late LikesStore likesStore;
  late UnsplashService unsplashService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('login_screen_test');
    Hive.init(tempDir.path);
    likesStore = await LikesStore.open();

    final mockClient = MockHttpClient();
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('[]', 200));
    unsplashService = UnsplashService(accessKey: 'fake-key', client: mockClient);
  });

  tearDown(() async {
    await likesStore.close();
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildTestApp() {
    return MultiProvider(
      providers: [
        Provider<LikesStore>.value(value: likesStore),
        Provider<UnsplashService>.value(value: unsplashService),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  Future<void> enterCredentials(WidgetTester tester, String username, String password) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), username);
    await tester.enterText(fields.at(1), password);
  }

  group('LoginScreen', () {
    testWidgets('muser1/mpassword1 authentifie et navigue vers le feed', (tester) async {
      await tester.pumpWidget(buildTestApp());

      await enterCredentials(tester, 'muser1', 'mpassword1');
      await tester.tap(find.text('Log In'));

      // Etat de chargement pendant la simulation d'appel reseau
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Laisse le delai simule de AuthService s'ecouler puis la navigation se faire
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(FeedScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('muser2/mpassword2 authentifie et navigue vers le feed', (tester) async {
      await tester.pumpWidget(buildTestApp());

      await enterCredentials(tester, 'muser2', 'mpassword2');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(FeedScreen), findsOneWidget);
    });

    testWidgets('muser3/mpassword3 affiche le message de compte bloque', (tester) async {
      await tester.pumpWidget(buildTestApp());

      await enterCredentials(tester, 'muser3', 'mpassword3');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Ce compte a été bloqué.'), findsOneWidget);
      expect(find.byType(FeedScreen), findsNothing);
    });

    testWidgets("une combinaison invalide affiche le message d'erreur generique", (tester) async {
      await tester.pumpWidget(buildTestApp());

      await enterCredentials(tester, 'nimporte-qui', 'mauvais-mdp');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Informations de connexion invalides'), findsOneWidget);
      expect(find.byType(FeedScreen), findsNothing);
    });

    testWidgets('le bouton "Show" bascule la visibilite du mot de passe', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.text('Show'), findsOneWidget);
      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(find.text('Hide'), findsOneWidget);
    });
  });
}
