import 'package:flutter/material.dart';

/// Représente les familles de polices utilisées dans l’application.
///
/// ## Usage recommandé :
///
/// ### Alike  
/// À utiliser pour :  
/// - Les **titres principaux**  
/// - Les **en-têtes de section**  
/// - Les éléments nécessitant une typographie plus marquée et lisible  
///
/// Exemple :  
/// ```dart
/// Text(
///   "Titre de page",
///   style: TextStyle(
///     fontFamily: FontFamily.alike.font,
///     fontSize: 24,
///     fontWeight: FontWeight.w600,
///   ),
/// );
/// ```
///
/// ---
///
/// ### Inria Serif (Regular)  
/// À utiliser pour :  
/// - Le **texte du corps**  
/// - Les paragraphes  
/// - Les descriptions longues  
///
/// Exemple :  
/// ```dart
/// Text(
///   "Ceci est un paragraphe de texte.",
///   style: TextStyle(
///     fontFamily: FontFamily.inriaSerif.font,
///     fontSize: 16,
///     fontWeight: FontWeight.w400, // Regular
///   ),
/// );
/// ```
///
/// ---
///
/// ### Inria Serif (Bold, 700)  
/// À utiliser pour :  
/// - Le **texte des boutons**  
/// - Les éléments nécessitant une emphase forte  
///
/// Exemple :  
/// ```dart
/// Text(
///   "Continuer",
///   style: TextStyle(
///     fontFamily: FontFamily.inriaSerif.font,
///     fontSize: 16,
///     fontWeight: FontWeight.w700, // Bold 700
///   ),
/// );
/// ```
///
/// ---
///
/// Vous pouvez accéder à la police via :  
/// `FontFamily.inriaSerif.font` ou `FontFamily.alike.font`
///
enum FontFamily {
  alike("Alike"),
  inriaSerif("InriaSerif");

  final String font;
  const FontFamily(this.font);
}



/// Thème global de l’application, configuré selon les règles typographiques.
///
/// - Titres : **Alike**
/// - Corps : **Inria Serif Regular**
/// - Boutons : **Inria Serif Bold (700)**
///
/// Couleurs de base :
/// - Blanc : `Colors.white`
/// - Noir : `Colors.black`
/// - Gris : `Color(0xFF909090)`
///
class AppTheme {
  static final Color grey = const Color(0xFF909090);

  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.black,

    // --- Couleurs globales ---
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    ),

    // --- Typographie complète ---
    textTheme: TextTheme(
      // TITRES + HEADINGS (Alike)
      headlineLarge: TextStyle(
        fontFamily: FontFamily.alike.font,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      headlineMedium: TextStyle(
        fontFamily: FontFamily.alike.font,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      headlineSmall: TextStyle(
        fontFamily: FontFamily.alike.font,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),

      // TEXTE DU CORPS (Inria Serif Regular)
      bodyLarge: TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppTheme.grey,
      ),

      // BOUTONS (Inria Serif Bold 700)
      labelLarge: TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),

    // --- Style des boutons ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontFamily: FontFamily.inriaSerif.font,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),

    // --- Style des champs de texte ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F0F0),
      hintStyle: TextStyle(
        color: grey,
        fontFamily: FontFamily.inriaSerif.font,
      ),
      labelStyle: TextStyle(
        color: Colors.black,
        fontFamily: FontFamily.inriaSerif.font,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
