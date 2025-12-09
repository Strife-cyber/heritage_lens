import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:heritage_lens/core/app_theme.dart';
import 'package:heritage_lens/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/auth/login_screen.dart';

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
  /*try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env file is optional, but log the warning
    debugPrint('Warning: Could not load .env file: $e');
  }*/
  
  runApp(
    const ProviderScope(
      child: HeritageLens(),
    ),
  );
}

class HeritageLens extends StatelessWidget {
  const HeritageLens({super.key});

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heritage Lens',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: LoginScreen(),
    );
  }
}
