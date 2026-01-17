import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:heritage_lens/views/auth_screen.dart';

class _FakeDashboard extends StatelessWidget {
  const _FakeDashboard();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('DASHBOARD'));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Auth flow: signup -> dashboard', (tester) async {
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          auth: auth,
          firestore: firestore,
          dashboardBuilder: (_) => const _FakeDashboard(),
        ),
      ),
    );

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jean');
    await tester.enterText(find.byType(TextFormField).at(1), 'jean@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');

    final submitButton = find.byType(ElevatedButton);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);

    final users = await firestore.collection('users').get();
    expect(users.docs.length, 1);
  });

  testWidgets('Auth flow: login erreur si user absent', (tester) async {
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(
          auth: auth,
          firestore: firestore,
          dashboardBuilder: (_) => const _FakeDashboard(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'absent@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    final submitButton = find.byType(ElevatedButton);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Aucun utilisateur trouvé avec cet email'), findsOneWidget);
  });
}
