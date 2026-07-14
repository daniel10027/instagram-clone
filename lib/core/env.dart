/// Configuration fournie a la compilation via `--dart-define`, plutot
/// qu'un fichier `.env` embarque dans les assets de l'application.
///
/// Avantages de cette approche pour ce projet :
/// - aucun fichier secret a versionner ni a garantir present au moment
///   du build (un `.env` manquant ferait echouer `flutter build`/`flutter
///   test` puisqu'il est declare comme asset) ;
/// - approche recommandee par l'equipe Flutter pour les valeurs de
///   configuration determinees a la compilation.
///
/// Utilisation :
///   flutter run --dart-define=UNSPLASH_ACCESS_KEY=votre_cle
///   flutter build apk --release --dart-define=UNSPLASH_ACCESS_KEY=votre_cle
///
/// Voir le README pour la procedure complete de configuration d'Unsplash.
class Env {
  Env._();

  static const String unsplashAccessKey = String.fromEnvironment(
    'UNSPLASH_ACCESS_KEY',
    defaultValue: '',
  );
}
