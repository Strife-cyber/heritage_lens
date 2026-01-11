import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heritage_lens/views/auth_screen.dart';

class _FakeDashboard extends StatelessWidget {
  const _FakeDashboard();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('DASHBOARD'));
  }
}

void main() {
  testWidgets('AuthScreen: validation empêche la soumission si champs vides',
      (tester) async {
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

    final submitButton = find.byType(ElevatedButton);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Veuillez entrer votre email'), findsOneWidget);
    expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
  });

  testWidgets('AuthScreen: inscription crée un user firestore puis navigue',
      (tester) async {
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

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Jean',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'jean@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'password123',
    );

    final submitButton = find.byType(ElevatedButton);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);

    final usersCollection = await firestore.collection('users').get();
    expect(usersCollection.docs, isNotEmpty);
    expect(usersCollection.docs.first.data()['email'], 'jean@example.com');
  });
}
