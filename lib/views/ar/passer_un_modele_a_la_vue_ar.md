# Passer un modèle à la vue AR (ArView)

Ce document explique comment passer l'URL d'un modèle 3D à l'`ArView` lorsqu'un utilisateur y navigue depuis un autre écran (comme le `DetailScreen`).

## Le Concept
Étant donné que le moteur Unity met un instant à initialiser son environnement lorsque l'`ArView` s'ouvre, vous ne pouvez pas envoyer le message en même temps que la navigation se produit.

Au lieu de cela, le constructeur de notre `ArView` prend un `UnityOutgoingMessage` préconfiguré, appelé `modelUrlMessage`. La vue conserve ce message et attend strictement que la fonction de rappel `onUnityCreated` d'Unity se déclenche. Une fois que le moteur natif signale qu'il est réveillé et à l'écoute, le message est instantanément envoyé via la passerelle pour instancier le modèle.

## Implémentation étape par étape

### Étape 1 : Créer la charge utile (Payload)
Dans votre écran d'origine (par exemple, à l'intérieur de la méthode `_viewInAR` de `details_screen.dart`), vous devez d'abord construire le `UnityOutgoingMessage`.

Vous devez le configurer pour cibler le `ModelBridge` (défini dans votre `unity_service.dart`) afin qu'Unity sache acheminer ces données vers le script de chargement du modèle.

```dart
import 'package:heritage_lens/services/unity_service.dart';

// Construire la charge utile du message contenant l'URL du modèle
final modelMessage = UnityOutgoingMessage(
  bridge: UnityBridgeTarget.model,     // Cible le GameObject 'ModelBridge'
  type: UnityMessageType.modelUrl,     // Cible la méthode 'OnModelUrl'
  payload: UnityStringPayload('https://example.com/models/mon_artefact_3d.glb'),
);
```

### Étape 2 : Naviguer vers l'`ArView`
Une fois votre message regroupé, utilisez la navigation standard de Flutter (comme `Navigator.push`) pour ouvrir l'`ArView`, en passant le message regroupé directement dans le constructeur.

```dart
import 'package:flutter/material.dart';
import 'package:heritage_lens/views/ar/ar_view.dart';

Future<void> _viewInAR() async {
  // 1. Préparer la charge utile (Payload)
  final modelMessage = UnityOutgoingMessage(
    bridge: UnityBridgeTarget.model,
    type: UnityMessageType.modelUrl,
    payload: UnityStringPayload('https://super-modeles.com/vase_antique.glb'), // Remplacer par le chemin réel du modèle
  );

  // 2. Naviguer et passer la charge utile
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ArView(
        modelUrlMessage: modelMessage,
        onMessageReceived: (message) {
          debugPrint("Message reçu en retour depuis Unity : $message");
        },
      ),
    ),
  );
}
```

### Comment l'`ArView` gère cela automatiquement
Vous n'avez besoin d'écrire aucune logique supplémentaire dans l'`ArView` car elle gère cela naturellement. Ci-dessous, un extrait de ce qui se passe en interne dans `ar_view.dart` :

```dart
UnityWidget(
  onUnityCreated: (controller) {
    _unityService = UnityService(unityController: controller);
    
    // Une fois le contrôleur initialisé, envoyer le message s'il existe !
    if (widget.modelUrlMessage != null) {
      _unityService.send(widget.modelUrlMessage!);
    }
  },
  // ...
)
```

En suivant exactement ce modèle, vous garantissez pratiquement que l'URL de votre modèle atteindra Unity au moment précis où Unity est prêt à télécharger et à faire apparaître le modèle.
