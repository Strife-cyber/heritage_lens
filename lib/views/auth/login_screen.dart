import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/services/auth_service.dart';

import 'package:heritage_lens/views/widgets/standard_toast.dart';
import 'package:heritage_lens/views/widgets/standard_button.dart';
import 'package:heritage_lens/views/widgets/standard_text_field.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';

import 'widgets/connect_with_google.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> controllers = List.generate(2, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),
                  Icon(Icons.arrow_back),
                  const SizedBox(height: 80),
                  Text("Se Connecter", style: AppText.titleL()),
                  const SizedBox(height: 8),
                  Text("Ravi de vous revoir, vous nous avez manqué", style: AppText.bodyM()),
                  const SizedBox(height: 64),
                  Text("Email", style: AppText.emphasis()),
                  const SizedBox(height: 8),
                  StandardTextField(
                    label: "Entrez votre email...", 
                    controller: controllers[0],
                    placeholder: "john.doe@gmail.com",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer une adresse e-mail';
                      }
              
                      // Regex robuste mais pas trop permissive
                      final RegExp emailRegExp = RegExp(
                        r"^[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9]+([.-]?[a-zA-Z0-9]+)*\.[a-zA-Z]{2,}$",
                      );
              
                      if (!emailRegExp.hasMatch(value.trim())) {
                        return 'Adresse e-mail invalide';
                      }
              
                      return null; // valide
                    },
                  ),
                  const SizedBox(height: 32),
                  Text("Mot de passe", style: AppText.emphasis()),
                  const SizedBox(height: 8),
                  StandardTextField(
                    label: "Entrez votre mot de passe...", 
                    controller: controllers[1],
                    placeholder: "********",
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
              
                      if (value.trim().length < 8) {
                        return 'Le mot de passe doit contenir au moins 8 caractères';
                      }
              
                      return null; // valide
                    }
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
                        child: Text("ou", style: AppText.bodyS()),
                      ),
                      Expanded(child: Divider())
                    ],
                  ),
                  const SizedBox(height: 24),
                  ConnectWithGoogleButton(onPressed: _handleGoogleSignIn),
                  const SizedBox(height: 64),
                  Row(
                    children: [
                      Text("Vous n'avez pas de compte ?", style: AppText.bodyS()),
                      const SizedBox(width: 8),
                      Text("Créer un compte", style: AppText.emphasis().copyWith(fontSize: 14))
                    ],
                  ),
                  const SizedBox(height: 32),
                  StandardButton(
                    width: double.infinity,
                    onPressed: _handleLogin,
                    child: Text("Soumettre")
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  Future<void> _handleLogin() async {
    // A. Validate the Form using the Key
    if (!_formKey.currentState!.validate()) {
      return; // Stop if regex fails
    }

    try {
      // B. Attempt Login
      await ref.read(authServiceProvider).signInWithEmailAndPassword(
        email: controllers[0].text.trim(),
        password: controllers[1].text.trim(),
      );
      
      if (mounted) {
         StandardToast.show(context, "Connexion réussie", type: ToastType.success);
         // Navigate to Home
      }
    } catch (e) {
      // C. Handle Errors (Wrong password, No internet, etc.)
      if (mounted) {
        StandardToast.show(context, e.toString(), type: ToastType.error);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // Navigation happens in the auth state listener usually
    } catch (e) {
      if (mounted) {
        StandardToast.show(context, "Erreur Google: ${e.toString()}", type: ToastType.error);
      }
    }
  }
}