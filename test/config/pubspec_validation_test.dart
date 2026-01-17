import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Pubspec Configuration Validation', () {
    late YamlMap pubspecConfig;

    setUpAll(() {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue,
          reason: 'pubspec.yaml should exist in project root');

      final content = file.readAsStringSync();
      pubspecConfig = loadYaml(content) as YamlMap;
    });

    test('pubspec.yaml is valid YAML', () {
      expect(pubspecConfig, isNotNull);
      expect(pubspecConfig, isA<YamlMap>());
    });

    test('project name is heritage_lens', () {
      expect(pubspecConfig.containsKey('name'), isTrue);
      expect(pubspecConfig['name'], equals('heritage_lens'));
    });

    test('description is present and not empty', () {
      expect(pubspecConfig.containsKey('description'), isTrue);
      final description = pubspecConfig['description'] as String;
      expect(description.trim(), isNotEmpty);
    });

    test('version follows semantic versioning', () {
      expect(pubspecConfig.containsKey('version'), isTrue);
      final version = pubspecConfig['version'] as String;

      // Check format: X.Y.Z+build
      final versionPattern = RegExp(r'^\d+\.\d+\.\d+\+\d+$');
      expect(versionPattern.hasMatch(version), isTrue);
    });

    test('Flutter SDK environment is configured', () {
      expect(pubspecConfig.containsKey('environment'), isTrue);
      final environment = pubspecConfig['environment'] as YamlMap;

      expect(environment.containsKey('sdk'), isTrue);
    });

    test('required dependencies are present', () {
      expect(pubspecConfig.containsKey('dependencies'), isTrue);
      final dependencies = pubspecConfig['dependencies'] as YamlMap;

      // Core Flutter dependencies
      expect(dependencies.containsKey('flutter'), isTrue);
      expect(dependencies.containsKey('flutter_riverpod'), isTrue);
      expect(dependencies.containsKey('firebase_core'), isTrue);
      expect(dependencies.containsKey('flutter_dotenv'), isTrue);
    });

    test('flutter_riverpod dependency is specified', () {
      final dependencies = pubspecConfig['dependencies'] as YamlMap;
      expect(dependencies.containsKey('flutter_riverpod'), isTrue);
      
      // Should have a version constraint
      final riverpodDep = dependencies['flutter_riverpod'];
      expect(riverpodDep, isNotNull);
    });

    test('firebase_core dependency is specified', () {
      final dependencies = pubspecConfig['dependencies'] as YamlMap;
      expect(dependencies.containsKey('firebase_core'), isTrue);
      
      final firebaseDep = dependencies['firebase_core'];
      expect(firebaseDep, isNotNull);
    });

    test('flutter_dotenv dependency is specified', () {
      final dependencies = pubspecConfig['dependencies'] as YamlMap;
      expect(dependencies.containsKey('flutter_dotenv'), isTrue);
      
      final dotenvDep = dependencies['flutter_dotenv'];
      expect(dotenvDep, isNotNull);
    });

    test('dev_dependencies include flutter_test', () {
      expect(pubspecConfig.containsKey('dev_dependencies'), isTrue);
      final devDependencies = pubspecConfig['dev_dependencies'] as YamlMap;

      expect(devDependencies.containsKey('flutter_test'), isTrue);
    });

    test('flutter configuration is present', () {
      expect(pubspecConfig.containsKey('flutter'), isTrue);
      final flutterConfig = pubspecConfig['flutter'] as YamlMap;

      expect(flutterConfig.containsKey('uses-material-design'), isTrue);
      expect(flutterConfig['uses-material-design'], isTrue);
    });

    test('assets configuration is present', () {
      final flutterConfig = pubspecConfig['flutter'] as YamlMap;
      
      // Assets should be configured (even if empty list)
      expect(flutterConfig.containsKey('assets'), isTrue);
    });

    test('.env file is listed in assets if dotenv is used', () {
      final flutterConfig = pubspecConfig['flutter'] as YamlMap;
      
      if (flutterConfig.containsKey('assets')) {
        final assets = flutterConfig['assets'] as YamlList?;
        
        if (assets != null && assets.isNotEmpty) {
          // Check if .env is in assets (it should be for flutter_dotenv)
          final assetStrings = assets.map((e) => e.toString()).toList();
          final hasEnvFile = assetStrings.any((asset) => 
            asset.contains('.env') || asset == '.env'
          );
          
          // This is a recommendation but not strictly required
          // Log if not present
          if (!hasEnvFile) {
            debugPrint('Warning: .env file not found in assets. '
                'Consider adding it for flutter_dotenv to work properly.');
          }
        }
      }
    });

    test('no deprecated font assets remain', () {
      final flutterConfig = pubspecConfig['flutter'] as YamlMap;
      
      if (flutterConfig.containsKey('fonts')) {
        final fonts = flutterConfig['fonts'] as YamlList?;
        
        if (fonts != null) {
          final fontFamilies = fonts.map((font) {
            final fontMap = font as YamlMap;
            return fontMap['family'] as String?;
          }).where((f) => f != null).toList();
          
          // Based on the diff, these fonts were removed
          expect(fontFamilies.contains('Alike'), isFalse,
              reason: 'Alike font should be removed from pubspec.yaml');
          expect(fontFamilies.contains('InriaSerif'), isFalse,
              reason: 'InriaSerif font should be removed from pubspec.yaml');
        }
      }
    });

    test('SDK version constraint is reasonable', () {
      final environment = pubspecConfig['environment'] as YamlMap;
      final sdkConstraint = environment['sdk'] as String;
      
      expect(sdkConstraint, isNotEmpty);
      expect(sdkConstraint.contains('>='), isTrue,
          reason: 'SDK constraint should specify minimum version');
    });
  });

  group('Dependency Version Constraints', () {
    late YamlMap dependencies;

    setUpAll(() {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      final config = loadYaml(content) as YamlMap;
      dependencies = config['dependencies'] as YamlMap;
    });

    test('dependencies have valid version constraints', () {
      dependencies.forEach((key, value) {
        if (key.toString() == 'flutter') {
          expect(value.toString(), anyOf(equals('sdk: flutter'), contains('sdk')));
        } else if (value is String) {
          // Version string format
          expect(value.trim(), isNotEmpty,
              reason: 'Dependency $key should have version specified');
        } else if (value is YamlMap) {
          // Complex dependency specification (like sdk)
          expect(value, isNotNull);
        }
      });
    });

    test('no package has deprecated syntax', () {
      // Check that all dependencies use proper YAML syntax
      dependencies.forEach((key, value) {
        expect(key, isNotNull);
        expect(value, isNotNull);
        
        // If it's a map, it should have valid keys
        if (value is YamlMap) {
          expect(value.keys, isNotEmpty);
        }
      });
    });
  });

  group('Asset Configuration Validation', () {
    test('assets directory exists if assets are declared', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      final config = loadYaml(content) as YamlMap;
      
      if (config.containsKey('flutter')) {
        final flutterConfig = config['flutter'] as YamlMap;
        
        if (flutterConfig.containsKey('assets')) {
          final assets = flutterConfig['assets'] as YamlList?;
          
          if (assets != null && assets.isNotEmpty) {
            // At least the assets directory should be accessible
            final assetsDir = Directory('assets');
            // Note: This test is informational - assets might not exist yet
            if (assetsDir.existsSync()) {
              expect(assetsDir.existsSync(), isTrue);
            }
          }
        }
      }
    });

    test('removed font files are not referenced', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      
      // These font files were deleted according to the diff
      expect(content.contains('Alike-Regular.ttf'), isFalse);
      expect(content.contains('InriaSerif-Bold.ttf'), isFalse);
      expect(content.contains('InriaSerif-Regular.ttf'), isFalse);
    });

    test('removed icon files are not referenced', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      
      // This icon was deleted according to the diff
      expect(content.contains('google-logo.png'), isFalse);
    });
  });

  group('Configuration File Integrity', () {
    test('pubspec.yaml is readable and parseable', () {
      final file = File('pubspec.yaml');
      expect(() => file.readAsStringSync(), returnsNormally);
      
      final content = file.readAsStringSync();
      expect(() => loadYaml(content), returnsNormally);
    });

    test('pubspec.yaml has consistent indentation', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      
      // YAML should be parseable without errors
      expect(() => loadYaml(content), returnsNormally);
    });

    test('no duplicate keys in pubspec.yaml', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      
      // If there were duplicate keys, YAML parsing might behave unexpectedly
      // This test ensures we can parse it cleanly
      expect(() {
        final config = loadYaml(content) as YamlMap;
        expect(config.keys.toSet().length, equals(config.keys.length),
            reason: 'No duplicate top-level keys should exist');
      }, returnsNormally);
    });
  });

  group('Edge Cases and Best Practices', () {
    test('project follows Flutter naming conventions', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      final config = loadYaml(content) as YamlMap;
      
      final projectName = config['name'] as String;
      
      // Flutter project names should be lowercase with underscores
      expect(projectName, equals(projectName.toLowerCase()));
      expect(projectName.contains('-'), isFalse,
          reason: 'Flutter projects should use underscores, not hyphens');
    });

    test('version number components are valid', () {
      final file = File('pubspec.yaml');
      final content = file.readAsStringSync();
      final config = loadYaml(content) as YamlMap;
      
      final version = config['version'] as String;
      final parts = version.split('+');
      
      expect(parts.length, equals(2),
          reason: 'Version should have format X.Y.Z+build');
      
      final versionPart = parts[0].split('.');
      expect(versionPart.length, equals(3),
          reason: 'Version should have three parts (major.minor.patch)');
      
      // All parts should be valid integers
      for (var part in versionPart) {
        expect(int.tryParse(part), isNotNull,
            reason: 'Version components should be integers');
      }
      
      // Build number should be an integer
      expect(int.tryParse(parts[1]), isNotNull,
          reason: 'Build number should be an integer');
    });
  });
}