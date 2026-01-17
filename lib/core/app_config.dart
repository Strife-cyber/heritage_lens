import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String? _webClientId;

    /// Get Web Client Id with lazy loading
  static Future<String> get webClientId async {
    _webClientId ??= await _loadEnvValue('GOOGLE_WEB_CLIENT_ID');
    return _webClientId!;
  }

    /// Load environment value with fallback
  static Future<String> _loadEnvValue(String key) async {
    try {
      // Ensure .env is loaded
      if (dotenv.env.isEmpty) {
        await dotenv.load(fileName: "assets/.env");
      }
      return dotenv.env[key] ?? '';
    } catch (e) {
      debugPrint('Warning: Could not load $key from .env file: $e');
      return '';
    }
  }

  static String get webClientIdSync => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
}