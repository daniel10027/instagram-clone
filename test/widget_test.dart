import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:instagram_clone/providers/auth_provider.dart';
import 'package:instagram_clone/screens/login_screen.dart';

/// Test de fumee de l'application : verifie que l'ecran de connexion
/// se construit sans erreur et affiche ses elements principaux.
///
/// Ce fichier remplace volontairement le test genere par defaut par
/// `flutter create` (qui reference une classe `MyApp` inexistante dans
/// ce projet). Sa presence ici empeche `flutter create .` d'injecter a
/// nouveau ce test par defaut lors de la regeneration des dossiers de
/// plateforme en CI (voir README, section "Choix techniques").
void main() {
  testWidgets("L'ecran de connexion s'affiche avec ses elements principaux", (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}