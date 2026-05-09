import 'package:flutter/material.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';

import 'package:flutter_svg/flutter_svg.dart';

void arNotCompatibleModal(BuildContext context, Future<void> Function(BuildContext) moveToArView) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  "Hey !",
                  style: AppText.titleM(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Votre appareil ne supporte pas notre module de réalité augmenté, donc Il y’a quelques étapes a suivre  pour  voir le modèle.",
                  style: AppText.bodySNB().copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "D’abord imprimez notre logo sur une feuille de papier ou afficher le comme image sur un autre appareil. Ensuite  placez la camera devant celui-ci et le modèle s’affichera",
                  style: AppText.bodySNB().copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),

                Text(
                  "Voici le logo :",
                  style: AppText.bodySNB().copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),

                // Illustration
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    key: const ValueKey('full-logo'),
                    width: 200,
                    height: 200,
                    child: SvgPicture.asset(
                      'assets/images/logo-black.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Daccord button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => {
                      moveToArView(dialogContext)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
