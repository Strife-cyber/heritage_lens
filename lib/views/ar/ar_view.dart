import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_unity_widget_2/flutter_unity_widget_2.dart';

import '../../services/unity_service.dart';

class ArView extends StatefulWidget {
  final Function(String)? onMessageReceived;
  final UnityOutgoingMessage? modelUrlMessage;
  final Function(SceneLoaded?)? onSceneLoaded;

  const ArView({super.key, this.modelUrlMessage, this.onMessageReceived, this.onSceneLoaded});

  @override
  State<ArView> createState() => _ArViewState();
}

class _ArViewState extends State<ArView> {
  late UnityService _unityService;
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    // Send model URL to Unity when the view is initialized (Android only)
  }

  @override
  Widget build(BuildContext context) {
    if (_isAndroid) {
      return UnityWidget(
        onUnityCreated: (controller) {
          debugPrint('Unity created on Android: Initializing UnityService');
          _unityService = UnityService(unityController: controller);
          if (widget.modelUrlMessage != null) {
            _unityService.send(widget.modelUrlMessage!);
          }
        },
        onUnityMessage: (message) {
          debugPrint('Unity message received: ${message.toString()}');
          if (widget.onMessageReceived != null) {
            widget.onMessageReceived!(message.toString());
          }
        },
        onUnitySceneLoaded: (sceneInfo) {
          debugPrint('Unity scene loaded: ${sceneInfo?.name}');
          if (widget.onSceneLoaded != null) {
            widget.onSceneLoaded!(sceneInfo);
          }
        },
      );
    }

    return Scaffold(
      body: SafeArea(
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_iphone,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'AR is supported on Android only',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Switch to an Android device to use this feature.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
