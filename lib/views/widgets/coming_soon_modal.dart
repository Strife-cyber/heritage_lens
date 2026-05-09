import 'package:flutter/material.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';

void showComingSoonModal(BuildContext context) {
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
                // Illustration
                SizedBox(
                  key: const ValueKey('coming-soon'),
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/images/coming_soon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  "C'est Pour Bientôt !",
                  style: AppText.titleM(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Cette partie n'est pas encore prête mais nous faisons tout pour que ce soit le cas",
                  style: AppText.bodyMG(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Daccord button
                SizedBox(
                  width: double.infinity,
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
                      'Daccord',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
