# Clone de l'Interface Instagram (Flutter)

Projet realise dans le cadre de l'evaluation technique mobile FFK. L'application permet de :

1. S'authentifier via un ecran reproduisant l'interface de connexion Instagram
2. Consulter un feed d'images provenant de l'API Unsplash, avec chargement infini
3. "Liker" des publications, avec persistance des preferences entre les sessions (base de donnees cote client)

> **Avertissement.** Ce projet est un exercice technique a but pedagogique/evaluatif. Il reprend la structure visuelle generale d'un ecran de connexion Instagram (mise en page, champs, bouton) mais ne contient ni le logotype officiel, ni aucune ressource graphique proprietaire de Meta/Instagram : le mot-cle "Instagram" n'est utilise que comme texte de demonstration. Ce n'est pas une application destinee a la publication publique ni affiliee a Meta.

## Sommaire

- [Stack technique](#stack-technique)
- [Choix techniques](#choix-techniques)
- [Configuration d'Unsplash (obligatoire)](#configuration-dunsplash-obligatoire)
- [Installation](#installation)
- [Lancer l'application en local](#lancer-lapplication-en-local)
- [Executer les tests](#executer-les-tests)
- [Construire l'APK de release](#construire-lapk-de-release)
- [Integration continue (CI)](#integration-continue-ci)
- [Scenarios d'authentification](#scenarios-dauthentification)
- [Structure du projet](#structure-du-projet)
- [Limites connues](#limites-connues)

## Stack technique

| Composant                   | Choix                                                     |
| --------------------------- | --------------------------------------------------------- |
| Framework                   | Flutter (Dart)                                            |
| Gestion d'etat              | `provider`                                                |
| Appels reseau               | `http`                                                    |
| Chargement/cache des images | `cached_network_image`                                    |
| Persistance des "likes"     | `hive` / `hive_flutter` (equivalent client-side de Level) |
| Configuration               | `--dart-define` (cle Unsplash injectee a la compilation)  |
| Tests                       | `flutter_test`, `mocktail`                                |
| CI/CD                       | GitHub Actions (analyse, tests, build APK)                |

## Choix techniques

**Flutter** a ete retenu (plutot que React Native) pour son rendu par moteur graphique propre (Skia/Impeller), qui facilite une reproduction fidele et performante d'une interface au pixel pres, ainsi que pour son systeme de widgets declaratif qui se prete naturellement a une architecture en couches claire (services / providers / ecrans / widgets).

**`provider`** comme solution de gestion d'etat : suffisant pour la portee de ce projet (deux ecrans, deux flux d'etat principaux : authentification et feed), largement documente, et facilement testable en injectant des services factices dans l'arbre de widgets pendant les tests.

**Authentification par service dedie (`AuthService`)** plutot qu'un veritable backend : le cahier des charges impose des scenarios d'identifiants fixes. La logique de verification est isolee dans une classe pure (sans dependance Flutter), ce qui la rend testable unitairement sans monter la moindre UI (voir `test/unit/auth_service_test.dart`).

**`hive` / `hive_flutter` comme equivalent a Level** pour la persistance des likes : Hive est une base de donnees cle/valeur embarquee, ecrite en Dart pur (donc sans binding natif specifique a compiler par plateforme, contrairement a une veritable implementation LevelDB), concue specifiquement pour Flutter. Elle offre exactement la garantie demandee par le cahier des charges : une persistance locale, cote client, qui survit aux redemarrages de l'application. Les likes sont stockes par nom d'utilisateur (`lib/data/services/likes_store.dart`), permettant a plusieurs comptes de conserver des preferences distinctes sur le meme appareil.

**Cle Unsplash injectee via `--dart-define`** plutot qu'un fichier `.env` embarque comme asset : cette approche est recommandee par l'equipe Flutter pour les valeurs de configuration determinees a la compilation, et evite un ecueil frequent avec `flutter_dotenv` (`flutter build`/`flutter test` echoue si le fichier `.env` declare comme asset est absent). Voir `lib/core/env.dart`.

**Scroll infini** implemente via un `ScrollController` qui declenche le chargement de la page suivante lorsque l'utilisateur approche du bas de la liste (`lib/screens/feed_screen.dart`), plutot qu'une pagination par boutons, conformement a la demande du cahier des charges.

**Dossiers de plateformes natives (`android/`, `ios/`) non versionnes** : ce depot suit une approche "code first". Les dossiers natifs sont regeneres a la demande via `flutter create .`, une commande officielle et idempotente qui ne touche pas au code Dart existant. Cela evite de verser des centaines de fichiers de boilerplate (Gradle, Xcode) qui n'ont aucune valeur ajoutee pour la relecture du code, et elimine tout risque de conflit de version d'outils (Gradle/AGP/CocoaPods) entre l'environnement d'origine et celui de l'evaluateur. Le pipeline CI regenere ces dossiers automatiquement a chaque execution (voir plus bas).

## Configuration d'Unsplash (obligatoire)

L'application ne peut afficher aucune image sans une cle d'acces Unsplash valide.

### 1. Creer un compte developpeur Unsplash

1. Aller sur [https://unsplash.com/developers](https://unsplash.com/developers)
2. Cliquer sur **Register as a developer**
3. Se connecter avec un compte Unsplash existant, ou en creer un
4. Accepter les conditions d'utilisation de l'API

### 2. Creer une nouvelle application

1. Aller sur [https://unsplash.com/oauth/applications](https://unsplash.com/oauth/applications)
2. Cliquer sur **New Application**
3. Accepter les conditions (API Guidelines et API Terms)
4. Renseigner un nom et une description, par exemple :
   - **Application name** : `Evaluation Technique FFK - Clone Instagram`
   - **Description** : `Application de demonstration pour une evaluation technique mobile`
5. Valider la creation

### 3. Recuperer la cle d'acces (Access Key)

Sur la page de l'application, section **Keys**, copier la valeur du champ **Access Key** (pas la Secret Key, non utilisee ici : l'application ne fait que des requetes en lecture simple, sans authentification OAuth au nom d'un utilisateur).

### 4. Limite de quota (mode Demo)

Par defaut, une application Unsplash est en mode **Demo**, limitee a **50 requetes/heure**, largement suffisant pour ce projet. Le quota restant est visible depuis le tableau de bord de l'application.

### 5. Attribution

Chaque publication du feed affiche le nom de l'auteur, conformement aux [conditions d'utilisation de l'API Unsplash](https://help.unsplash.com/en/articles/2511315-unsplash-api-guidelines) qui imposent de crediter le photographe.

## Installation

Pre-requis :

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.19 ou superieur (le projet est verifie en CI avec Flutter 3.24.5)
- Un emulateur Android/iOS demarre, ou un appareil physique connecte (ou Chrome, pour lancer en mode web de developpement)

```bash
# 1. Cloner le depot puis s'y placer
cd instagram_clone

# 2. Generer les dossiers de plateforme natifs (Android et iOS)
flutter create . --platforms=android,ios --org com.ffk.instagramclone

# 3. Recuperer les dependances
flutter pub get

# 4. Preparer la configuration Unsplash (voir section precedente)
cp dart_define.example.json dart_define.json
# puis editer dart_define.json et y coller votre Access Key
```

## Lancer l'application en local

```bash
flutter run --dart-define-from-file=dart_define.json
```

Alternative sans fichier (utile pour un test rapide en une commande) :

```bash
flutter run --dart-define=UNSPLASH_ACCESS_KEY=votre_access_key
```

## Executer les tests

```bash
flutter test
```

Avec rapport de couverture :

```bash
flutter test --coverage
```

La suite de tests comprend (voir `test/`) :

- **`test/unit/auth_service_test.dart`** : les quatre scenarios d'authentification imposes par le cahier des charges
- **`test/unit/likes_store_test.dart`** : persistance, isolation par utilisateur, et survie des likes a une fermeture/reouverture de la base Hive
- **`test/unit/unsplash_service_test.dart`** : parsing des reponses Unsplash, gestion des erreurs (cle invalide, erreur reseau), calcul de `hasMore`, via un `http.Client` mocke (aucun appel reseau reel)
- **`test/widget/login_screen_test.dart`** : rendu de l'ecran de connexion, les quatre scenarios d'authentification rejoues au niveau interface (saisie, tap, message affiche ou navigation vers le feed), bascule "Show"/"Hide" du mot de passe

## Construire l'APK de release

```bash
flutter build apk --release --dart-define-from-file=dart_define.json
```

L'APK genere se trouve dans `build/app/outputs/flutter-apk/app-release.apk`, installable directement sur un appareil Android (`adb install build/app/outputs/flutter-apk/app-release.apk`).

## Scenarios d'authentification

Conformement au cahier des charges, geres par `lib/data/services/auth_service.dart` :

| Identifiant / Mot de passe | Resultat                                                    |
| -------------------------- | ----------------------------------------------------------- |
| `muser1` / `mpassword1`    | Authentification reussie -> navigation directe vers le feed |
| `muser2` / `mpassword2`    | Authentification reussie -> navigation directe vers le feed |
| `muser3` / `mpassword3`    | Message d'erreur : "Ce compte a été bloqué."                |
| Toute autre combinaison    | Message d'erreur : "Informations de connexion invalides"    |

L'ecran affiche un indicateur de chargement pendant la verification (bouton "Log In"), un message d'erreur anime (`AnimatedSize`) sous le champ mot de passe, et une bascule d'affichage du mot de passe ("Show"/"Hide"), fidele a la maquette fournie.

## Structure du projet

```
.
├── lib/
│   ├── main.dart                        # Point d'entree, initialisation Hive, injection des providers
│   ├── core/
│   │   ├── app_colors.dart              # Palette de couleurs
│   │   ├── app_text_styles.dart         # Styles de texte partages
│   │   └── env.dart                     # Lecture de la cle Unsplash via --dart-define
│   ├── data/
│   │   ├── models/unsplash_photo.dart   # Modele photo (parsing JSON Unsplash)
│   │   └── services/
│   │       ├── auth_service.dart        # Scenarios d'authentification
│   │       ├── unsplash_service.dart    # Client API Unsplash (pagination, gestion d'erreurs)
│   │       └── likes_store.dart         # Persistance des likes (Hive)
│   ├── providers/
│   │   ├── auth_provider.dart           # Etat d'authentification
│   │   └── feed_provider.dart           # Etat du feed (pagination, likes)
│   ├── screens/
│   │   ├── login_screen.dart            # Ecran de connexion
│   │   └── feed_screen.dart             # Ecran du feed (scroll infini)
│   └── widgets/
│       ├── app_wordmark.dart
│       ├── custom_text_field.dart
│       ├── primary_button.dart
│       ├── post_card.dart               # Publication du feed + bouton like
│       └── image_placeholder.dart
├── test/
│   ├── unit/
│   └── widget/
├── .github/workflows/ci.yml
├── dart_define.example.json
├── pubspec.yaml
└── analysis_options.yaml
```

## Limites connues

- Les boutons "Forgotten password?", "Log in with Facebook" et "Sign up." sont presents pour respecter fidelement la maquette, mais restent volontairement inertes (une notification s'affiche au tap) : le cahier des charges ne demande que les quatre scenarios d'authentification par identifiant/mot de passe.
- Les likes sont stockes localement (Hive), propres a l'appareil utilise : ce comportement correspond a la demande explicite d'une "base de donnees cote client".
- La session n'est pas persistee entre deux lancements de l'application (seuls les likes le sont) : ce n'est pas demande par le cahier des charges, qui precise uniquement que la navigation vers le feed doit suivre immediatement une connexion reussie.
- Le quota Unsplash en mode Demo (50 requetes/heure) peut etre atteint lors de tests intensifs du scroll infini ; un message d'erreur explicite s'affiche alors, avec un bouton "Reessayer".
