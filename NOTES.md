# Notes de modifications (auth + tests)

## Objectif

Vérifier que le flow d’authentification est testable et couvert par des tests unitaires + intégration.

## Constat sur le flow d’auth actuel

- **Splash** (`lib/views/splash/splash_screen.dart`)
  - Redirige vers `DashboardScreen` si `FirebaseAuth.instance.currentUser != null`, sinon vers `AuthScreen`.
- **Écran auth** (`lib/views/auth_screen.dart`)
  - Gère login/signup email+password via Firebase Auth.
  - Crée/met à jour un document utilisateur dans Firestore (`collection('users')`).
  - Supporte Google Sign-In.
- **Service auth Riverpod** (`lib/services/auth_service.dart`)
  - Existe mais n’est pas utilisé par `AuthScreen` actuellement.

## Changements effectués

### 1) Testabilité (injection)

- **`lib/services/auth_service.dart`**
  - `AuthService` accepte maintenant des dépendances injectables: `FirebaseAuth?` et `GoogleSignIn?`.
  - Pourquoi: permettre des **tests unitaires** avec `MockFirebaseAuth` sans Firebase réel.

- **`lib/views/auth_screen.dart`**
  - `AuthScreen` accepte maintenant `FirebaseAuth?`, `FirebaseFirestore?`, `GoogleSignIn?` + `WidgetBuilder? dashboardBuilder`.
  - Pourquoi:
    - Injecter des mocks (`MockFirebaseAuth`, `FakeFirebaseFirestore`).
    - Injecter un dashboard fake pour tester la navigation sans dépendre de `DashboardScreen` (qui charge Firestore etc.).

### 2) Dépendances de tests

- **`pubspec.yaml`**
  - Ajout:
    - `integration_test` (SDK)
    - `mocktail`
    - `firebase_auth_mocks`
    - `fake_cloud_firestore`
  - Pourquoi: mocks stables pour tester auth+firestore en local.

### 3) Nouveaux tests

- **`test/auth_service_test.dart`**
  - Tests unitaires: signup, login, signout.

- **`test/auth_screen_widget_test.dart`**
  - Tests widget:
    - Validation formulaire (champs vides)
    - Inscription: création user Firestore + navigation.

- **`integration_test/auth_flow_test.dart`**
  - Tests d’intégration (UI):
    - Signup -> dashboard
    - Login error (user absent)

## Points à améliorer (non fait ici)

- Harmoniser l’architecture: `AuthScreen` n’utilise pas `AuthService` (duplication de logique).
- Ajouter tests sur:
  - Google Sign-In (plus complexe à mocker, possible via wrapper/facade)
  - Password reset / email verification
  - Cas Firestore en erreur (échec `.set()` / `.get()`)
