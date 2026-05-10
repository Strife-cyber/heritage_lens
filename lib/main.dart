// lib/main.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:heritage_lens/views/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:heritage_lens/core/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heritage_lens/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> _requestCameraPermissionOnStartup() async {
  if (!Platform.isAndroid) return;

  final status = await Permission.camera.status;
  if (status.isGranted) return;

  // Requests permission early so Unity's first camera init doesn't fail.
  await Permission.camera.request();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Warning: Could not initialize Firebase: $e');
  }

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env file is optional, but log the warning
    debugPrint('Warning: Could not load .env file: $e');
  }

  await _requestCameraPermissionOnStartup();

  runApp(const ProviderScope(child: HeritageLens()));
}

class HeritageLens extends ConsumerWidget {
  const HeritageLens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Heritage Lens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Home(),
    );
  }
}
