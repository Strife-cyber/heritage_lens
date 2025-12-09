import 'package:flutter/material.dart';
import 'package:heritage_lens/core/app_theme.dart';

/// Un champ de texte (TextField) personnalisé au design minimaliste et monochrome.
///
/// Ce widget a été conçu pour respecter une charte graphique stricte :
/// **Noir, Blanc et Gris (#909090) uniquement**.
///
/// ### Fonctionnalités principales :
/// 1. **Libellé Flottant (Floating Label)** : Le texte du label est à l'intérieur
///    quand le champ est vide, et monte se placer **sur la bordure** (au niveau du trait)
///    lorsque le champ est focus ou rempli.
/// 2. **Mode Optionnel** : Peut ajouter automatiquement la mention "(Optionnel)" au label.
/// 3. **Gestion du Focus** : La bordure et l'icône passent au noir strict lors du focus.
///
/// ### Exemples d'utilisation :
///
/// **1. Utilisation simple avec icône :**
/// ```dart
/// StandardTextField(
///   label: "Adresse Email",
///   controller: emailController,
///   icon: Icons.email_outlined,
/// )
/// ```
///
/// **2. Champ optionnel avec placeholder :**
/// ```dart
/// StandardTextField(
///   label: "Numéro de téléphone",
///   controller: phoneController,
///   isOptional: true, // Affiche "Numéro de téléphone (Optionnel)"
///   placeholder: "ex: +33 6 12 34 56 78",
/// )
/// ```
///
/// **3. Mot de passe (texte masqué) :**
/// ```dart
/// StandardTextField(
///   label: "Mot de passe",
///   controller: passwordController,
///   icon: Icons.lock_outline,
///   obscureText: true,
/// )
/// ```
class StandardTextField extends StatefulWidget {
  /// Le texte principal qui décrit le champ (ex: "Nom", "Email").
  /// Ce texte flotte sur la bordure lors de la saisie.
  final String label;

  /// L'icône à afficher au début du champ.
  /// Utiliser des [IconData] standards (ex: `Icons.person`).
  final IconData? icon;

  /// Texte indicatif (hint) qui s'affiche uniquement quand le champ est focus
  /// et vide. Utile pour donner un format attendu.
  final String? placeholder;

  /// Le contrôleur indispensable pour récupérer ou modifier le texte.
  final TextEditingController controller;

  /// Fonction de validation standard de Flutter.
  /// Retourne `null` si tout va bien, ou un message d'erreur `String` sinon.
  final String? Function(String?)? validator;

  /// Si `true`, ajoute automatiquement la mention "(Optionnel)" à la suite du label.
  /// Défaut : `false`.
  final bool isOptional;

  /// Si `true`, masque le texte (pour les mots de passe).
  /// Défaut : `false`.
  final bool obscureText;

  const StandardTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.placeholder,
    this.validator,
    this.isOptional = false,
    this.obscureText = false,
  });

  @override
  State<StandardTextField> createState() => _StandardTextFieldState();
}

class _StandardTextFieldState extends State<StandardTextField> {
  // Définition de la couleur grise spécifique demandée : #909090
  static const Color _customGrey = Color(0xFF909090);

  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Construction du libellé
    final String labelDisplay = widget.isOptional
        ? '${widget.label} (Optionnel)'
        : widget.label;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      validator: widget.validator,
      obscureText: widget.obscureText,
      
      // Curseur noir strict
      cursorColor: Colors.black,
      
      // Style du texte saisi (Noir)
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontFamily: FontFamily.inriaSerif.font
      ),
      
      decoration: InputDecoration(
        // Remplissage (Fond)
        filled: true,
        // Blanc quand focus, Gris très clair (presque blanc) quand inactif pour le fond
        // Note: On garde le fond très clair pour la lisibilité, le gris #909090 est utilisé pour les traits.
        fillColor: _focused ? Colors.white : const Color(0xFFFAFAFA),
        
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        // Gestion de l'icône (Gris #909090 -> Noir)
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                color: _focused ? Colors.black : _customGrey,
                size: 22,
              )
            : null,

        // --- Configuration du Label (Libellé) ---
        labelText: labelDisplay,
        // Le style du label change selon l'état (Gris #909090 -> Noir)
        labelStyle: TextStyle(
          color: _focused ? Colors.black : _customGrey,
          fontFamily: FontFamily.inriaSerif.font,
          fontWeight: _focused ? FontWeight.w600 : FontWeight.normal,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        // --- Configuration du Placeholder (Hint) ---
        hintText: widget.placeholder,
        hintStyle: TextStyle(
          color: _customGrey, // Utilisation de la couleur #909090
          fontSize: 14,
          fontFamily: FontFamily.inriaSerif.font
        ),

        // --- Configuration des Bordures ---
        
        // 1. Bordure au repos (Utilisation de #909090)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _customGrey, 
            width: 1.0,
          ),
        ),

        // 2. Bordure quand on écrit (Noir épais)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),

        // 3. Bordure en cas d'erreur (Noir)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.black, 
            width: 1.2,
          ),
        ),
        
        // 4. Bordure erreur quand focus (Noir épais)
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        
        errorStyle: TextStyle(
          color: Colors.grey, 
          fontWeight: FontWeight.bold,
          fontFamily: FontFamily.inriaSerif.font
        ),
      ),
    );
  }
}