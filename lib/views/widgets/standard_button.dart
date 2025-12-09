import 'package:flutter/material.dart';
import 'package:heritage_lens/core/app_theme.dart';

/// Un bouton standardisé au design minimaliste et monochrome.
///
/// Respecte la charte : **Noir et Blanc**, avec des nuances de Gris pour les états d'interaction (clic).
///
/// Ce widget est flexible et peut être utilisé de trois manières principales :
/// 1. **Bouton Primaire (Défaut)** : Fond noir, texte blanc. Pour les actions principales.
/// 2. **Bouton Secondaire (Outline)** : Fond blanc, bordure noire. Pour les actions secondaires (ex: "Annuler").
/// 3. **Bouton Icône** : Via le constructeur nommé `StandardButton.icon`.
///
/// ### Exemples d'utilisation :
///
/// **1. Bouton Primaire avec Texte :**
/// ```dart
/// StandardButton(
///   onPressed: () => print("Submit"),
///   child: const Text("Envoyer"),
/// )
/// ```
///
/// **2. Bouton Secondaire avec Texte et Icône :**
/// ```dart
/// StandardButton(
///   isPrimary: false, // Style "Outline"
///   onPressed: () => Navigator.pop(context),
///   child: Row(
///     mainAxisSize: MainAxisSize.min,
///     children: const [
///       Icon(Icons.arrow_back, size: 20),
///       SizedBox(width: 8),
///       Text("Retour"),
///     ],
///   ),
/// )
/// ```
///
/// **3. Bouton Icône carré :**
/// ```dart
/// StandardButton.icon(
///   icon: Icons.close,
///   onPressed: () => print("Close"),
/// )
/// ```
class StandardButton extends StatelessWidget {
  /// Le contenu du bouton (Texte, Row avec icône, etc.).
  final Widget child;

  /// L'action à effectuer au clic. Si `null`, le bouton est désactivé.
  final VoidCallback? onPressed;

  /// Si `true` (défaut), le bouton est Noir (rempli).
  /// Si `false`, le bouton est Blanc avec une bordure Noire (outline).
  final bool isPrimary;

  /// Padding interne personnalisé.
  final EdgeInsetsGeometry? padding;

  /// Hauteur fixe optionnelle. Par défaut, s'adapte au contenu avec un minimum standard.
  final double? height;

  /// Largeur fixe optionnelle. Par défaut, s'adapte au contenu avec un minimum standard.
  final double? width;

  /// Constructeur standard pour les boutons avec du texte ou du contenu complexe.
  const StandardButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isPrimary = true,
    this.padding,
    this.height,
    this.width
  });

  /// Constructeur nommé pratique pour créer un bouton carré contenant uniquement une icône.
  /// Il ajuste automatiquement le padding pour un rendu centré.
  factory StandardButton.icon({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = true,
    double size = 24.0,
  }) {
    return StandardButton(
      key: key,
      onPressed: onPressed,
      isPrimary: isPrimary,
      // Padding réduit pour les boutons icônes afin qu'ils soient plus carrés
      padding: const EdgeInsets.all(12),
      child: Icon(icon, size: size),
    );
  }

  // Couleurs définies pour le respect de la charte
  static const Color _black = Colors.black;
  static const Color _white = Colors.white;
  // Gris foncé pour l'état "pressé" du bouton primaire
  static const Color _pressedDarkGrey = Color(0xFF333333); 
  // Gris clair pour l'état "pressé" du bouton secondaire (le #909090 demandé précédemment, avec transparence)
  static const Color _pressedLightGreyOverlay = Color(0x33909090); 

  @override
  Widget build(BuildContext context) {
    // Définition du style de base commun
    final ButtonStyle baseStyle = ButtonStyle(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      padding: WidgetStateProperty.all(
        padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      minimumSize: WidgetStateProperty.all(
         Size(width ?? 64, height ?? 56), // Hauteur et Largeur standard similaire aux inputs
      ),
      elevation: WidgetStateProperty.all(0), // Pas d'ombre pour un design plat
      textStyle: WidgetStateProperty.all(
        TextStyle(
          fontFamily: FontFamily.inriaSerif.font,
          fontWeight: FontWeight.w700, 
          fontSize: 16
        ),
      ),
    );

    // Application des styles spécifiques (Primaire vs Secondaire)
    final ButtonStyle finalStyle = isPrimary
        ? baseStyle.copyWith(
            // --- Style Primaire (Fond Noir) ---
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return Colors.grey.shade300;
              if (states.contains(WidgetState.pressed)) return _pressedDarkGrey;
              return _black;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return Colors.grey.shade500;
              return _white;
            }),
            overlayColor: WidgetStateProperty.all(_pressedDarkGrey),
          )
        : baseStyle.copyWith(
            // --- Style Secondaire (Bordure Noire) ---
            backgroundColor: WidgetStateProperty.resolveWith((states) {
               // Fond transparent normalement, mais gris clair au clic
              if (states.contains(WidgetState.pressed)) return _pressedLightGreyOverlay;
              return _white;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return Colors.grey.shade300;
              return _black;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              // Bordure
              if (states.contains(WidgetState.disabled)) return BorderSide(color: Colors.grey.shade300);
              return const BorderSide(color: _black, width: 1.5);
            }),
             overlayColor: WidgetStateProperty.all(_pressedLightGreyOverlay),
          );

    // On utilise ElevatedButton pour les deux styles car il gère bien 
    // les fonds remplis, et on peut le forcer à avoir un fond blanc avec bordure.
    return ElevatedButton(
      onPressed: onPressed,
      style: finalStyle,
      child: child,
    );
  }
}
