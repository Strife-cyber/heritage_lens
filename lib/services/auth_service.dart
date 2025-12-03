import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance unique du service d'authentification via Riverpod.
final authServiceProvider = Provider<AuthService>((ref) {
  final service = AuthService();
  return service;
});

/// Fournit l'utilisateur actuel authentifié.
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Service responsable des opérations d'authentification Firebase.
class AuthService {
  AuthService()
      : _auth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Obtient l'instance FirebaseAuth.
  FirebaseAuth get auth => _auth;

  /// Obtient l'utilisateur actuellement authentifié.
  User? get currentUser => _auth.currentUser;

  /// Flux des changements d'état d'authentification.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Flux des changements d'utilisateur.
  Stream<User?> get userChanges => _auth.userChanges();

  /// Inscrit un nouvel utilisateur avec email et mot de passe.
  ///
  /// [email] - L'adresse email de l'utilisateur.
  /// [password] - Le mot de passe de l'utilisateur.
  ///
  /// Retourne l'utilisateur créé.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de l\'inscription : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Connecte un utilisateur avec email et mot de passe.
  ///
  /// [email] - L'adresse email de l'utilisateur.
  /// [password] - Le mot de passe de l'utilisateur.
  ///
  /// Retourne les informations d'identification de l'utilisateur.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la connexion : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Connecte un utilisateur de manière anonyme.
  ///
  /// Retourne les informations d'identification de l'utilisateur anonyme.
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la connexion anonyme : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Connecte un utilisateur avec Google.
  ///
  /// Retourne les informations d'identification de l'utilisateur Google.
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Déclenche le flux d'authentification Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        throw StateError('La connexion Google a été annulée.');
      }

      // Obtient les détails d'authentification de la demande
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crée un nouveau credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Une fois connecté, retourne le UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la connexion Google : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Déconnecte l'utilisateur de Google.
  ///
  /// Retourne une Future qui se complète lorsque l'utilisateur est déconnecté de Google.
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la déconnexion Google : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Envoie un email de réinitialisation de mot de passe.
  ///
  /// [email] - L'adresse email de l'utilisateur.
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de l\'envoi de l\'email de réinitialisation : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Envoie un email de vérification.
  ///
  /// Retourne une Future qui se complète lorsque l'email est envoyé.
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('Aucun utilisateur connecté.');
      }
      await user.sendEmailVerification();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de l\'envoi de l\'email de vérification : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Recharge les informations de l'utilisateur actuel.
  ///
  /// Retourne une Future qui se complète lorsque l'utilisateur est rechargé.
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('Aucun utilisateur connecté.');
      }
      await user.reload();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors du rechargement de l\'utilisateur : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Met à jour le profil de l'utilisateur actuel.
  ///
  /// [displayName] - Le nouveau nom d'affichage (optionnel).
  /// [photoURL] - La nouvelle URL de photo (optionnel).
  ///
  /// Retourne une Future qui se complète lorsque le profil est mis à jour.
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('Aucun utilisateur connecté.');
      }
      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      await user.reload();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la mise à jour du profil : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Met à jour le mot de passe de l'utilisateur actuel.
  ///
  /// [newPassword] - Le nouveau mot de passe.
  ///
  /// Retourne une Future qui se complète lorsque le mot de passe est mis à jour.
  Future<void> updatePassword({
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('Aucun utilisateur connecté.');
      }
      await user.updatePassword(newPassword);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la mise à jour du mot de passe : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Supprime le compte de l'utilisateur actuel.
  ///
  /// Retourne une Future qui se complète lorsque le compte est supprimé.
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('Aucun utilisateur connecté.');
      }
      await user.delete();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la suppression du compte : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Déconnecte l'utilisateur actuel.
  ///
  /// Retourne une Future qui se complète lorsque l'utilisateur est déconnecté.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la déconnexion : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Vérifie si l'email est vérifié.
  ///
  /// Retourne true si l'email est vérifié, false sinon.
  bool get isEmailVerified {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Vérifie si un utilisateur est connecté.
  ///
  /// Retourne true si un utilisateur est connecté, false sinon.
  bool get isSignedIn => _auth.currentUser != null;
}

