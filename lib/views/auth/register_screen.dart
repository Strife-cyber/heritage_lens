import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:heritage_lens/services/auth_service.dart';
import 'package:heritage_lens/views/widgets/standard_toast.dart';
import 'package:heritage_lens/views/widgets/standard_button.dart';
import 'package:heritage_lens/views/widgets/standard_text_field.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';

import 'login_screen.dart';
import 'widgets/connect_with_google.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> controllers = List.generate(3, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = MediaQuery.of(context).size.height * 0.0075;

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
                  SizedBox(height: spacing * 8), 
                  Icon(Icons.arrow_back),
                  SizedBox(height: spacing * 10),
                  Text("Créer un Compte", style: AppText.titleL()),
                  SizedBox(height: spacing),
                  Text("Dites nous en plus sur vous", style: AppText.bodyM()),
                  SizedBox(height: spacing * 8),
                  Text("Nom d'utilisateur", style: AppText.emphasis()),
                  SizedBox(height: spacing),
                  StandardTextField(
                    label: "Entrez votre nom d'utilisateur",
                    placeholder: "John Doe", 
                    controller: controllers[0]
                  ),
                  SizedBox(height: spacing * 4),
                  Text("Email", style: AppText.emphasis()),
                  SizedBox(height: spacing),
                  StandardTextField(
                    label: "Entrez votre email...", 
                    controller: controllers[1],
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
                  SizedBox(height: spacing * 4),
                  Text("Mot de passe", style: AppText.emphasis()),
                  SizedBox(height: spacing),
                  StandardTextField(
                    label: "Entrez votre mot de passe...", 
                    controller: controllers[2],
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
                  SizedBox(height: spacing * 3),
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
                  SizedBox(height: spacing * 3),
                  ConnectWithGoogleButton(onPressed: _handleGoogleSignIn),
                  SizedBox(height: spacing * 8),
                  Row(
                    children: [
                      Text("Vous avez déja un compte ?", style: AppText.bodyS()),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (_) => LoginScreen())
                        ),
                        child: Text(" Se connecter", style: AppText.emphasis().copyWith(fontSize: 14))
                      )
                    ],
                  ),
                  SizedBox(height: spacing * 4),
                  StandardButton(
                    width: double.infinity,
                    onPressed: _handleRegister,
                    child: Text("Soumettre")
                  ),
                  SizedBox(height: spacing * 3)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  Future<void> _handleRegister() async {
    // A. Validate the Form using the Key
    if (!_formKey.currentState!.validate()) {
      return; // Stop if regex fails
    }

    try {
      // B. Attempt Login
      await ref.read(authServiceProvider).signUpWithEmailAndPassword(
        email: controllers[1].text.trim(),
        password: controllers[2].text.trim(),
      );

      await ref.read(authServiceProvider).updateProfile(
        displayName: controllers[0].text.trim()
      );

      
      if (mounted) {
         StandardToast.show(context, "Creation de compte réussie", type: ToastType.success);
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
