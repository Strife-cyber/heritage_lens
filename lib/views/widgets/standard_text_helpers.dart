import 'package:flutter/material.dart';
import 'package:heritage_lens/core/app_theme.dart';

/// **Système de Typographie de l'Application**
///
/// Cette classe centralise tous les styles de texte pour garantir une cohérence visuelle.
///
/// ### Polices utilisées :
/// - **Titres** : `Alike` (Sérif, classique)
/// - **Corps & Boutons** : `Inria Serif` (Sérif, lisible)
///
/// ### Palette stricte :
/// - Noir (`Colors.black`)
/// - Blanc (`Colors.white`)
/// - Gris Secondaire (`#909090`)
class AppText {
  // Empêche l'instanciation de la classe utilitaire
  AppText._();

  // --- Constantes de couleurs internes ---
  static const Color _primaryColor = Colors.black;
  static const Color _secondaryColor = Color(0xFF909090);
  static const Color _inverseColor = Colors.white;

  // ---------------------------------------------------------------------------
  // TITRES (Font: Alike)
  // ---------------------------------------------------------------------------

  /// Titre XL - **32px** - *Alike*
  ///
  /// Utilisé pour : En-têtes principaux, noms de sections majeurs.
  static TextStyle titleXL({
    Color color = _primaryColor,
    FontWeight weight = FontWeight.w600,
    double? height,
  }) =>
      TextStyle(
        fontFamily: FontFamily.alike.font,
        fontSize: 32,
        fontWeight: weight,
        color: color,
        height: height,
      );

  /// Titre L - **26px** - *Alike*
  ///
  /// Utilisé pour : Sous-titres, cartes principales.
  static TextStyle titleL({
    Color color = _primaryColor,
    FontWeight weight = FontWeight.w600,
    double? height,
  }) =>
      TextStyle(
        fontFamily: FontFamily.alike.font,
        fontSize: 26,
        fontWeight: weight,
        color: color,
        height: height,
      );

  /// Titre M - **22px** - *Alike*
  ///
  /// Utilisé pour : Titres de paragraphes, éléments de liste importants.
  static TextStyle titleM({
    Color color = _primaryColor,
    FontWeight weight = FontWeight.w600,
    double? height,
  }) =>
      TextStyle(
        fontFamily: FontFamily.alike.font,
        fontSize: 22,
        fontWeight: weight,
        color: color,
        height: height,
      );

  // ---------------------------------------------------------------------------
  // CORPS DE TEXTE (Font: Inria Serif)
  // ---------------------------------------------------------------------------

  /// Body L - **18px** - *Inria Serif Regular*
  ///
  /// Utilisé pour : Texte de lecture principal, articles.
  static TextStyle bodyL({
    Color color = _primaryColor,
    FontWeight weight = FontWeight.w400,
    double? height = 1.4, // Légère hauteur de ligne pour la lisibilité
  }) =>
      TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontSize: 18,
        fontWeight: weight,
        color: color,
        height: height,
      );

  /// Body M - **16px** - *Inria Serif Regular*
  ///
  /// Utilisé pour : Champs de saisie, descriptions courtes.
  static TextStyle bodyM({
    Color color = _primaryColor,
    FontWeight weight = FontWeight.w400,
    double? height,
  }) =>
      TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontSize: 16,
        fontWeight: weight,
        color: color,
        height: height,
      );

  /// Body S - **14px** - *Inria Serif Regular*
  ///
  /// **Couleur par défaut : Gris #909090**
  ///
  /// Utilisé pour : Mentions légales, hints, placeholders, textes secondaires.
  static TextStyle bodyS({
    Color color = _secondaryColor,
    FontWeight weight = FontWeight.w400,
    double? height,
  }) =>
      TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontSize: 14,
        fontWeight: weight,
        color: color,
        height: height,
      );

  // ---------------------------------------------------------------------------
  // INTERACTIF & EMPHASE (Font: Inria Serif Bold)
  // ---------------------------------------------------------------------------

  /// Button Text - **16px** - *Inria Serif Bold*
  ///
  /// **Couleur par défaut : Blanc**
  ///
  /// Utilisé pour : Texte à l'intérieur des boutons pleins (CTA).
  static TextStyle button({
    Color color = _inverseColor,
    double? height,
  }) =>
      TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  /// Emphasis - **Taille Custom** - *Inria Serif Bold*
  ///
  /// Utilisé pour : Mettre un mot en gras au milieu d'une phrase, liens.
  static TextStyle emphasis({
    double size = 16,
    Color color = _primaryColor,
    double? height,
  }) =>
      TextStyle(
        fontFamily: FontFamily.inriaSerif.font,
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
        height: height,
      );
}