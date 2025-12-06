import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  
  // Instances Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // CONNEXION avec Firebase
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential.user != null && mounted) {
          // OPTIONNEL : Récupérer le UserModel depuis Firestore
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();
            
            if (userDoc.exists) {
              final userModel = UserModel.fromMap(userDoc.data()!);
              print('✅ Utilisateur connecté: ${userModel.displayName}');
            }
          } catch (e) {
            print('⚠️ Impossible de récupérer le user: $e');
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else {
        // INSCRIPTION avec Firebase
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Mettre à jour le nom d'affichage dans Firebase Auth
        if (_nameController.text.isNotEmpty) {
          await userCredential.user!.updateDisplayName(
            _nameController.text.trim(),
          );
        }

        if (userCredential.user != null && mounted) {
          // CRÉER LE USERMODEL
          final userModel = UserModel(
            uid: userCredential.user!.uid,
            email: _emailController.text.trim(),
            displayName: _nameController.text.trim(),
            createdAt: DateTime.now(),
            spaces: const [], // Liste vide au départ
          );

          // SAUVEGARDER DANS FIRESTORE
          try {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set(userModel.toMap());
            
            print('✅ Utilisateur créé dans Firestore');
          } catch (e) {
            print('❌ Erreur Firestore: $e');
          }

          // Naviguer vers le dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase
      String errorMessage = 'Une erreur est survenue';
      
      if (e.code == 'user-not-found') {
        errorMessage = 'Aucun utilisateur trouvé avec cet email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mot de passe incorrect';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Cet email est déjà utilisé';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email invalide';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Le mot de passe doit contenir au moins 6 caractères';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Trop de tentatives. Réessayez plus tard';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une erreur est survenue')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Fonction pour Google Sign-In (optionnel)
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => isLoading = true);
      
      // Désactivé pour l'instant - à implémenter si besoin
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentification Google non implémentée'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isLogin)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    alignment: Alignment.centerLeft,
                    onPressed: () => setState(() => isLogin = true),
                  ),
                const SizedBox(height: 40),
                Text(
                  isLogin ? 'Se Connecter' : 'Créer un Compte',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin
                      ? 'Bon retour parmi nous'
                      : 'Dites nous en plus sur vous',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                if (!isLogin) ...[
                  const Text(
                    "Nom D'utilisateur",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre nom...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (!isLogin && (value == null || value.isEmpty)) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Entrez votre email...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Mot de Passe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Entrez votre mot de passe...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                if (!isLogin) ...[
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _handleGoogleSignIn,
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin ? "Vous n'avez pas de compte ? " : 'Vous avez déjà un compte ? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isLogin ? 'Créer un compte' : 'Se connecter',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isLogin ? 'Se Connecter' : 'Soumettre',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}