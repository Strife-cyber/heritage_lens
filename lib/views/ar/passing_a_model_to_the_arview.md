# Passing a Model URL to the ArView

This document explains how to pass a 3D model asset URL to the `ArView` when a user navigates from another screen (like the `DetailScreen`).

## The Concept
Because the Unity engine takes a moment to initialize its environment when the `ArView` is opened, you cannot send the message simultaneously as navigation occurs. 

Instead, our `ArView` constructor takes a pre-configured `UnityOutgoingMessage` called `modelUrlMessage`. The view holds onto this message and strictly waits for Unity's `onUnityCreated` callback to fire. Once the native engine signals that it is awake and listening, the message is instantly fired across the bridge to instantiate the model.

## Step-by-Step Implementation

### Step 1: Create the Payload
In your origin screen (for example, inside the `_viewInAR` method of `details_screen.dart`), you first need to construct the `UnityOutgoingMessage`.

You must configure it to target the `ModelBridge` (which your `unity_service.dart` defines) so Unity knows to route this data to the model-loading script.

```dart
import 'package:heritage_lens/services/unity_service.dart';

// Construct the message payload carrying the model's URL
final modelMessage = UnityOutgoingMessage(
  bridge: UnityBridgeTarget.model,     // Targets the 'ModelBridge' GameObject
  type: UnityMessageType.modelUrl,     // Targets the 'OnModelUrl' method
  payload: UnityStringPayload('https://example.com/models/my_3d_artifact.glb'),
);
```

### Step 2: Navigate to the `ArView`
With your message bundled, use standard Flutter navigation (like `Navigator.push`) to open the `ArView`, passing the bundled message directly into the constructor.

```dart
import 'package:flutter/material.dart';
import 'package:heritage_lens/views/ar/ar_view.dart';

Future<void> _viewInAR() async {
  // 1. Prepare the payload
  final modelMessage = UnityOutgoingMessage(
    bridge: UnityBridgeTarget.model,
    type: UnityMessageType.modelUrl,
    payload: UnityStringPayload('https://awesome-models.com/antique_vase.glb'), // Replace with actual model path
  );

  // 2. Navigate and pass the payload
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ArView(
        modelUrlMessage: modelMessage,
        onMessageReceived: (message) {
          debugPrint("Received a message back from Unity: $message");
        },
      ),
    ),
  );
}
```

### How the `ArView` automatically handles it
You don't need to write any further logic in the `ArView` because it naturally catches this. Below is a snippet of what happens internally within `ar_view.dart`:

```dart
UnityWidget(
  onUnityCreated: (controller) {
    _unityService = UnityService(unityController: controller);
    
    // Once the controller finishes initializing, fire the message if one exists!
    if (widget.modelUrlMessage != null) {
      _unityService.send(widget.modelUrlMessage!);
    }
  },
  // ...
)
```

By following this exact pattern, you practically guarantee that your model's URL reaches Unity at the exact moment that Unity is ready to download and spawn the model.
