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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Espaces',
                style: AppText.titleXL(),
              ),
              const SizedBox(height: 4),
              Text(
                'Rejoindre un espace partagé grace a un lien',
                style: AppText.bodyS(),
              ),
              const SizedBox(height: 24),

              Text('Lien d\'invitation', style: AppText.emphasis()),
              const SizedBox(height: 4),
              StandardTextField(
                label: 'Entrez le lien de l\'espace ...', 
                controller: TextEditingController()
              ),
              const SizedBox(height: 4),
              StandardButton(
                child: Text('Rejoindre'), 
                onPressed: () {} //TODO: Implementer la logique de rejoindre un espace
              )
            ],
          ),
        )
      ),
    );
  }
}