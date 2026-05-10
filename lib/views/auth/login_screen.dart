import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:heritage_lens/services/auth_service.dart';
import 'package:heritage_lens/views/home.dart';
import 'package:heritage_lens/views/widgets/standard_toast.dart';
import 'package:heritage_lens/views/widgets/standard_button.dart';
import 'package:heritage_lens/views/widgets/standard_text_field.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';

import 'register_screen.dart';
import 'widgets/connect_with_google.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> controllers = List.generate(2, (_) => TextEditingController());
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // If the user is already logged in, skip login and go to Profile.
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser != null) {
      ref.read(homeTabProvider.notifier).state = 2; // Profile tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }

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
                  GestureDetector(
                    onTap: () => {Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()),(Route<dynamic> route) => false)},
                    child: Icon(Icons.arrow_back)
                  ),
                  SizedBox(height: spacing * 10),
                  Text("Se Connecter", style: AppText.titleL()),
                  SizedBox(height: spacing),
                  Text("Ravi de vous revoir, vous nous avez manqué", style: AppText.bodyM()),
                  SizedBox(height: spacing * 8),
                  Text("Email", style: AppText.emphasis()),
                  SizedBox(height: spacing),
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
                  SizedBox(height: spacing * 4),
                  Text("Mot de passe", style: AppText.emphasis()),
                  SizedBox(height: spacing),
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
                  ConnectWithGoogleButton(
                    onPressed: _isSubmitting ? null : _handleGoogleSignIn,
                  ),
                  SizedBox(height: spacing * 8),
                  Row(
                    children: [
                      Text("Vous n'avez pas de compte ?", style: AppText.bodyS().copyWith(color: Colors.grey[500])),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => RegisterScreen())
                        ),
                        child: Text("Créer un compte", style: AppText.emphasis().copyWith(fontSize: 14))
                      )
                    ],
                  ),
                  SizedBox(height: spacing * 4),
                  StandardButton(
                    width: double.infinity,
                    onPressed: _isSubmitting ? () {} : _handleLogin,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Soumettre"),
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

    if (!_isSubmitting) setState(() => _isSubmitting = true);
    try {
      // B. Attempt Login
      await ref.read(authServiceProvider).signInWithEmailAndPassword(
        email: controllers[0].text.trim(),
        password: controllers[1].text.trim(),
      );
      
      if (mounted) {
         StandardToast.show(context, "Connexion réussie", type: ToastType.success);
        // Make sure next Home render lands on Profile tab.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('home_tab_index', 2);
      }
    } catch (e) {
      // C. Handle Errors (Wrong password, No internet, etc.)
      if (mounted) {
        StandardToast.show(context, e.toString(), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      if (!_isSubmitting) setState(() => _isSubmitting = true);
      await ref.read(authServiceProvider).signInWithGoogle();
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('home_tab_index', 2);
      }
    } catch (e) {
      if (mounted) {
        StandardToast.show(context, "Erreur Google: ${e.toString()}", type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}