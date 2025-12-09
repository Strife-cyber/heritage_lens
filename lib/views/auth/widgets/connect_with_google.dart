import 'package:flutter/material.dart';
import 'package:heritage_lens/core/app_theme.dart';

/// Un bouton spécifique "Connect with Google" au design strictement monochrome.
///
/// Respecte la charte : **Fond Blanc, Texte Noir, Bordure Noire, Icône Noire**.
///
/// ### Configuration requise :
/// Vous devez ajouter l'image dans votre `pubspec.yaml` :
/// ```yaml
/// assets:
///   - assets/google-logo.png
/// ```
class ConnectWithGoogleButton extends StatelessWidget {
  /// L'action à effectuer au clic (ex: lancer le processus d'authentification OAuth).
  final VoidCallback? onPressed;

  /// Padding interne optionnel.
  final EdgeInsetsGeometry? padding;

  const ConnectWithGoogleButton({
    super.key,
    required this.onPressed,
    this.padding,
  });

  // Définition des couleurs strictes
  static const Color _black = Colors.black;
  static const Color _white = Colors.white;
  // Un gris très léger pour l'effet de survol/clic
  static const Color _pressedOverlay = Color(0x1A000000); // Noir à 10% d'opacité

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // --- Style Monochrome Strict ---
        
        // Fond Blanc
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return _white;
        }),
        
        // Couleur de premier plan (Texte) : Noir
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.grey.shade400;
          return _black;
        }),
        
        // Bordure Noire fine
        side: WidgetStateProperty.resolveWith((states) {
           if (states.contains(WidgetState.disabled)) {
             return BorderSide(color: Colors.grey.shade300);
           }
          return const BorderSide(color: _black, width: 1.2);
        }),
        
        // Effet de survol gris clair
        overlayColor: WidgetStateProperty.all(_pressedOverlay),
        
        // Pas d'ombre (design plat)
        elevation: WidgetStateProperty.all(0),
        
        // Forme arrondie
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        
        // Hauteur standard (56px)
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
        padding: WidgetStateProperty.all(
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      // Utilisation d'une Row pour aligner l'icône et le texte
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          // --- LOGO GOOGLE (ASSET) ---
          Image.asset(
            'assets/icons/google-logo.png', // Chemin de l'asset
            height: 24,
            width: 24,
          ),
                    
          // --- TEXTE ---
          Text(
            "Connect with Google",
            style: TextStyle(
              color: _black, // Force le noir strict
              fontSize: 16,
              fontFamily: FontFamily.inriaSerif.font,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 16), // Espace entre l'icône et le texte
        ],
      ),
    );
  }
}