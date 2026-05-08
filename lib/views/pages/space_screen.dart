import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/views/widgets/standard_button.dart';
import 'package:heritage_lens/views/widgets/standard_text_field.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  const SpaceScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              Text(
                'Espaces',
                style: AppText.titleXL(),
              ),
              const SizedBox(height: 4),
              Text(
                'Rejoindre un espace partagé grace a un lien',
                style: AppText.bodyMG(),
              ),
              const SizedBox(height: 64),

              Text('Lien d\'invitation', style: AppText.bodyS()),
              const SizedBox(height: 16),
              StandardTextField(
                placeholder: 'Entrez le lien de l\'espace ...', 
                controller: TextEditingController()
              ),
              const SizedBox(height: 24),
              StandardButton(
                width: 50,
                child: Text('Rejoindre'), 
                onPressed: () {},
              ),
              const SizedBox(height: 64),
              Text(
                'C\'est quoi un espace partagé ?',
                style: AppText.titleM(),
              ),
              const SizedBox(height: 24),
              Text(
                "Grace a l’espace partagé, vous pouvez placer des artéfacts sur un emplacement, et les autres pourront le voir a partir de la cameraAR. Un bon lien devrait ressembler a ceci : \n\nHeritageLens/c2f1f0d8-8a5e-4a6d-9f0f-4d6e3a6a86f1 \n\nHeritageLens/a8b6e52d-1e4f-46c7-9b1b-7c9a41f8d9e2",
                style: AppText.bodyMG(),
              ),
            ],
          ),
        )
      ),
    );
  }
}