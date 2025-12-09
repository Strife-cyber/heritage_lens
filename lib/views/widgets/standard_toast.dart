import 'package:flutter/material.dart';

/// Types de notifications disponibles
enum ToastType {
  info,
  success,
  error,
}

/// Un composant "Toast" (Notification flottante) au design monochrome strict.
///
/// Il utilise le système de `SnackBar` de Flutter mais avec un rendu totalement personnalisé.
///
/// ### Différenciation visuelle (sans couleur) :
/// - **Info** : Bordure Grise (#909090), Icône Grise. Aspect léger.
/// - **Succès** : Bordure Noire fine, Icône Check. Aspect validé.
/// - **Erreur** : Bordure Noire ÉPAISSE, Icône Danger. Aspect lourd et urgent.
///
/// ### Exemple d'utilisation :
/// ```dart
/// // Afficher une erreur
/// StandardToast.show(context, "Mot de passe incorrect", type: ToastType.error);
///
/// // Afficher une info
/// StandardToast.show(context, "Sauvegarde effectuée", type: ToastType.success);
/// ```
class StandardToast extends StatelessWidget {
  final String message;
  final ToastType type;

  const StandardToast({
    super.key,
    required this.message,
    this.type = ToastType.info,
  });

  // --- Couleurs & Styles ---
  static const Color _black = Colors.black;
  static const Color _white = Colors.white;
  static const Color _grey = Color(0xFF909090);

  /// Méthode utilitaire statique pour afficher le Toast facilement
  /// sans avoir à instancier manuellement le widget dans l'arbre.
  static void show(BuildContext context, String message, {ToastType type = ToastType.info}) {
    // On enlève les Toasts précédents pour éviter l'empilement
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Fond transparent car notre widget gère son propre fond/ombre
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        // Marge pour le décoller du bas ou des bords
        margin: const EdgeInsets.all(16),
        content: StandardToast(message: message, type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Détermination des propriétés selon le type
    Color borderColor;
    double borderWidth;
    IconData icon;
    Color iconColor;

    switch (type) {
      case ToastType.error:
        borderColor = _black;
        borderWidth = 2.0; // Plus épais pour attirer l'attention
        icon = Icons.error_outline;
        iconColor = _black;
        break;
      case ToastType.success:
        borderColor = _black;
        borderWidth = 1.0;
        icon = Icons.check_circle_outline;
        iconColor = _black;
        break;
      case ToastType.info:
        borderColor = _grey;
        borderWidth = 1.0;
        icon = Icons.info_outline;
        iconColor = _grey; // Plus discret
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        // Ombre légère pour détacher le toast du fond (essentiel en monochrome)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // L'icône indicative
          Icon(icon, color: iconColor, size: 24),
          
          const SizedBox(width: 12),
          
          // Le message
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                // Si vous utilisez AppText, remplacez par : AppText.bodyM()
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Petit bouton fermer (optionnel, mais sympa pour l'UX)
          // On le fait discret (gris) quelle que soit la notification
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: const Icon(Icons.close, color: _grey, size: 18),
          )
        ],
      ),
    );
  }
}