import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:heritage_lens/services/auth_service.dart';

class _FakeGoogleSignIn extends Fake implements GoogleSignIn {}

void main() {
  group('AuthService', () {
    test('signUpWithEmailAndPassword crée un utilisateur', () async {
      final auth = MockFirebaseAuth();
      final service = AuthService(auth: auth, googleSignIn: _FakeGoogleSignIn());

      final UserCredential credential =
          await service.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(credential.user, isNotNull);
      expect(credential.user!.email, 'test@example.com');
    });

    test('signInWithEmailAndPassword connecte un utilisateur existant', () async {
      final user = MockUser(
        isAnonymous: false,
        uid: 'uid-1',
        email: 'test@example.com',
      );
      final auth = MockFirebaseAuth(mockUser: user);

      await auth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      await auth.signOut();

      final service = AuthService(auth: auth, googleSignIn: _FakeGoogleSignIn());
      final UserCredential credential =
          await service.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(credential.user, isNotNull);
      expect(credential.user!.email, 'test@example.com');
      expect(service.currentUser?.email, 'test@example.com');
    });

    test('signOut déconnecte l’utilisateur courant', () async {
      final user = MockUser(
        isAnonymous: false,
        uid: 'uid-1',
        email: 'test@example.com',
      );
      final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
      final service = AuthService(auth: auth, googleSignIn: _FakeGoogleSignIn());

      expect(service.currentUser, isNotNull);
      await service.signOut();
      expect(service.currentUser, isNull);
    });
  });
}
