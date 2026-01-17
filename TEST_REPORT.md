# Rapport de tests — Auth (Heritage Lens)

## Portée

Ces tests vérifient le flow d’authentification **email/password** (signup + login) et la création du document utilisateur dans Firestore.

## Prérequis

- Flutter SDK installé.
- Dépendances installées:

```bash
flutter pub get
```

## Commandes d’exécution

- Tests unitaires + widget:

```bash
flutter test
```

- Tests d’intégration (device/emulator requis):

```bash
flutter test integration_test
```

### Note Windows (desktop)

Si tu exécutes les tests d’intégration sur la cible **Windows (desktop)**, Flutter exige une **toolchain Visual Studio** (C++ Desktop). Sans ça, tu verras l’erreur:

`Unable to find suitable Visual Studio toolchain`

Alternatives simples:

- Exécuter sur **Edge (web)**:

```bash
flutter test -d edge integration_test
```

- Exécuter sur **Android emulator / device** (si installé):

```bash
flutter test -d android integration_test
```

## Suites de tests

### 1) Unit tests

- **Fichier**: `test/auth_service_test.dart`
- **Couvre**:
  - Signup email/password
  - Login email/password
  - Signout

### 2) Widget tests

- **Fichier**: `test/auth_screen_widget_test.dart`
- **Couvre**:
  - Validation UI: soumission avec champs vides
  - Signup UI: création du user et navigation vers dashboard (fake)

### 3) Integration tests

- **Fichier**: `integration_test/auth_flow_test.dart`
- **Couvre**:
  - Signup (UI) -> dashboard
  - Login (UI) user absent -> snackbar erreur

## Résultats attendus

- `flutter test`:
  - Tous les tests passent.
- `flutter test integration_test`:
  - Les scénarios passent sur un device/emulator.

## Notes de fiabilité

- Les tests utilisent `MockFirebaseAuth` et `FakeFirebaseFirestore`, donc **pas besoin de Firebase réel**.
- Les tests de navigation utilisent un `dashboardBuilder` injecté pour éviter les dépendances réseau/Firestore du vrai `DashboardScreen`.
