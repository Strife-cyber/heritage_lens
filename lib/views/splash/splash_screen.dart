import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_screen.dart';
import '../dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});  // CONSTRUCTEUR SIMPLE

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Attendre 2 secondes pour l'écran splash
    await Future.delayed(const Duration(seconds: 2));
    
    // Vérifier si l'utilisateur est déjà connecté
    final user = FirebaseAuth.instance.currentUser;
    
    if (!mounted) return;
    
    // Naviguer vers l'écran approprié
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.camera_enhance,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Heritage Lens',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Revivez l\'histoire en réalité augmentée',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}