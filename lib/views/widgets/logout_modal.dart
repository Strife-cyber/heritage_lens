import 'package:flutter/material.dart';
import 'package:heritage_lens/services/auth_service.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/views/widgets/standard_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showLogoutModal(BuildContext context, WidgetRef ref, bool mounted) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Déconnexion",
                  style: AppText.titleM(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Vous allez être déconnecté.",
                  style: AppText.bodyMG(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Daccord button
                Row(
                  children: [
                     Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _handleLogout(context, ref, mounted, dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Daccord',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

Future<void> _handleLogout(BuildContext context ,WidgetRef ref, bool mounted, BuildContext dialogContext) async {
    try {
      // Attempt Logout
      await ref.read(authServiceProvider).signOut();
      
      if (mounted) {
        StandardToast.show(context, "Deconnexion réussie", type: ToastType.success);
        // Get out of it
        Navigator.of(dialogContext).pop();
        // Make sure next Home render lands on Home tab.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('home_tab_index', 0);
       
      }
    } catch (e) {
      // Handle Errors (Wrong password, No internet, etc.)
      if (mounted) {
        StandardToast.show(context, e.toString(), type: ToastType.error);
      }
    }
  }