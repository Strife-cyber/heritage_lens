import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firebase Configuration Validation', () {
    late Map<String, dynamic> firebaseConfig;

    setUpAll(() {
      // Load firebase.json
      final file = File('firebase.json');
      expect(file.existsSync(), isTrue,
          reason: 'firebase.json should exist in project root');

      final content = file.readAsStringSync();
      firebaseConfig = jsonDecode(content) as Map<String, dynamic>;
    });

    test('firebase.json is valid JSON', () {
      expect(firebaseConfig, isNotNull);
      expect(firebaseConfig, isA<Map<String, dynamic>>());
    });

    test('firebase.json contains flutter configuration', () {
      expect(firebaseConfig.containsKey('flutter'), isTrue);
      expect(firebaseConfig['flutter'], isA<Map<String, dynamic>>());
    });

    test('flutter configuration contains platforms', () {
      final flutterConfig =
          firebaseConfig['flutter'] as Map<String, dynamic>;
      expect(flutterConfig.containsKey('platforms'), isTrue);
      expect(flutterConfig['platforms'], isA<Map<String, dynamic>>());
    });

    test('android platform is configured', () {
      final platforms = firebaseConfig['flutter']['platforms']
          as Map<String, dynamic>;
      expect(platforms.containsKey('android'), isTrue);

      final android = platforms['android'] as Map<String, dynamic>;
      expect(android.containsKey('default'), isTrue);
    });

    test('android configuration has required fields', () {
      final android = firebaseConfig['flutter']['platforms']['android']
          ['default'] as Map<String, dynamic>;

      expect(android.containsKey('projectId'), isTrue);
      expect(android.containsKey('appId'), isTrue);
      expect(android.containsKey('fileOutput'), isTrue);

      expect(android['projectId'], equals('hlens-4ded9'));
      expect(android['appId'],
          equals('1:702114339280:android:e8ea17e5de5866982c41d5'));
      expect(android['fileOutput'], equals('android/app/google-services.json'));
    });

    test('dart platform configuration exists', () {
      final platforms = firebaseConfig['flutter']['platforms']
          as Map<String, dynamic>;
      expect(platforms.containsKey('dart'), isTrue);

      final dart = platforms['dart'] as Map<String, dynamic>;
      expect(dart.containsKey('lib/firebase_options.dart'), isTrue);
    });

    test('dart configuration has project ID', () {
      final dartConfig = firebaseConfig['flutter']['platforms']['dart']
          ['lib/firebase_options.dart'] as Map<String, dynamic>;

      expect(dartConfig.containsKey('projectId'), isTrue);
      expect(dartConfig['projectId'], equals('hlens-4ded9'));
    });

    test('dart configuration includes android and web configurations', () {
      final dartConfig = firebaseConfig['flutter']['platforms']['dart']
          ['lib/firebase_options.dart'] as Map<String, dynamic>;

      expect(dartConfig.containsKey('configurations'), isTrue);
      final configurations =
          dartConfig['configurations'] as Map<String, dynamic>;

      expect(configurations.containsKey('android'), isTrue);
      expect(configurations.containsKey('web'), isTrue);

      expect(configurations['android'],
          equals('1:702114339280:android:e8ea17e5de5866982c41d5'));
      expect(configurations['web'],
          equals('1:702114339280:web:cb2200351f3027ed2c41d5'));
    });

    test('iOS and macOS configurations are removed', () {
      final dartConfig = firebaseConfig['flutter']['platforms']['dart']
          ['lib/firebase_options.dart'] as Map<String, dynamic>;
      final configurations =
          dartConfig['configurations'] as Map<String, dynamic>;

      // These should NOT be present in the new configuration
      expect(configurations.containsKey('ios'), isFalse);
      expect(configurations.containsKey('macos'), isFalse);
      expect(configurations.containsKey('windows'), isFalse);
    });

    test('project ID is consistent across configurations', () {
      final androidProjectId = firebaseConfig['flutter']['platforms']
          ['android']['default']['projectId'] as String;
      final dartProjectId = firebaseConfig['flutter']['platforms']['dart']
          ['lib/firebase_options.dart']['projectId'] as String;

      expect(androidProjectId, equals(dartProjectId));
      expect(androidProjectId, equals('hlens-4ded9'));
    });

    test('app IDs follow expected format', () {
      final androidAppId = firebaseConfig['flutter']['platforms']['android']
          ['default']['appId'] as String;

      // Format: number:number:platform:hash
      final appIdPattern = RegExp(r'^\d+:\d+:\w+:[a-f0-9]+$');
      expect(appIdPattern.hasMatch(androidAppId), isTrue);
    });

    test('file output path is valid', () {
      final fileOutput = firebaseConfig['flutter']['platforms']['android']
          ['default']['fileOutput'] as String;

      expect(fileOutput.endsWith('google-services.json'), isTrue);
      expect(fileOutput.contains('android/app/'), isTrue);
    });
  });

  group('Google Services Configuration Validation', () {
    late Map<String, dynamic> googleServicesConfig;

    setUpAll(() {
      // Load android/app/google-services.json
      final file = File('android/app/google-services.json');
      expect(file.existsSync(), isTrue,
          reason: 'google-services.json should exist in android/app/');

      final content = file.readAsStringSync();
      googleServicesConfig = jsonDecode(content) as Map<String, dynamic>;
    });

    test('google-services.json is valid JSON', () {
      expect(googleServicesConfig, isNotNull);
      expect(googleServicesConfig, isA<Map<String, dynamic>>());
    });

    test('contains project_info section', () {
      expect(googleServicesConfig.containsKey('project_info'), isTrue);
      final projectInfo =
          googleServicesConfig['project_info'] as Map<String, dynamic>;

      expect(projectInfo.containsKey('project_number'), isTrue);
      expect(projectInfo.containsKey('project_id'), isTrue);
      expect(projectInfo.containsKey('storage_bucket'), isTrue);
    });

    test('project info has correct values', () {
      final projectInfo =
          googleServicesConfig['project_info'] as Map<String, dynamic>;

      expect(projectInfo['project_number'], equals('702114339280'));
      expect(projectInfo['project_id'], equals('hlens-4ded9'));
      expect(projectInfo['storage_bucket'], equals('hlens-4ded9.appspot.com'));
    });

    test('contains client section', () {
      expect(googleServicesConfig.containsKey('client'), isTrue);
      final client = googleServicesConfig['client'] as List<dynamic>;

      expect(client, isNotEmpty);
      expect(client.length, equals(1));
    });

    test('client has correct package name', () {
      final client = googleServicesConfig['client'] as List<dynamic>;
      final clientInfo = client[0] as Map<String, dynamic>;

      expect(clientInfo.containsKey('client_info'), isTrue);
      final clientInfoDetails =
          clientInfo['client_info'] as Map<String, dynamic>;

      expect(clientInfoDetails.containsKey('android_client_info'), isTrue);
      final androidInfo = clientInfoDetails['android_client_info']
          as Map<String, dynamic>;

      expect(androidInfo['package_name'], equals('com.example.heritage_lens'));
    });

    test('oauth_client array is empty', () {
      final client = googleServicesConfig['client'] as List<dynamic>;
      final clientInfo = client[0] as Map<String, dynamic>;

      expect(clientInfo.containsKey('oauth_client'), isTrue);
      final oauthClient = clientInfo['oauth_client'] as List<dynamic>;

      expect(oauthClient, isEmpty,
          reason: 'OAuth clients should be removed as per the diff');
    });

    test('api_key is present', () {
      final client = googleServicesConfig['client'] as List<dynamic>;
      final clientInfo = client[0] as Map<String, dynamic>;

      expect(clientInfo.containsKey('api_key'), isTrue);
      final apiKey = clientInfo['api_key'] as List<dynamic>;

      expect(apiKey, isNotEmpty);
      expect(apiKey.length, equals(1));

      final apiKeyInfo = apiKey[0] as Map<String, dynamic>;
      expect(apiKeyInfo.containsKey('current_key'), isTrue);
      expect(apiKeyInfo['current_key'],
          equals('AIzaSyAuQ7xxX_5sabOi2CexSOE2DMgniLEOwvQ'));
    });

    test('services section exists', () {
      final client = googleServicesConfig['client'] as List<dynamic>;
      final clientInfo = client[0] as Map<String, dynamic>;

      expect(clientInfo.containsKey('services'), isTrue);
      final services = clientInfo['services'] as Map<String, dynamic>;

      expect(services.containsKey('appinvite_service'), isTrue);
    });

    test('other_platform_oauth_client is empty', () {
      final client = googleServicesConfig['client'] as List<dynamic>;
      final clientInfo = client[0] as Map<String, dynamic>;
      final services = clientInfo['services'] as Map<String, dynamic>;
      final appinvite =
          services['appinvite_service'] as Map<String, dynamic>;

      expect(appinvite.containsKey('other_platform_oauth_client'), isTrue);
      final otherPlatformOAuth =
          appinvite['other_platform_oauth_client'] as List<dynamic>;

      expect(otherPlatformOAuth, isEmpty,
          reason:
              'Other platform OAuth clients should be removed as per the diff');
    });

    test('configuration_version is present', () {
      expect(googleServicesConfig.containsKey('configuration_version'), isTrue);
      expect(googleServicesConfig['configuration_version'], equals('1'));
    });

    test('API key format is valid', () {
      final client = googleServicesConfig['client'] as List<dynamic>;
      final clientInfo = client[0] as Map<String, dynamic>;
      final apiKey = clientInfo['api_key'] as List<dynamic>;
      final apiKeyInfo = apiKey[0] as Map<String, dynamic>;
      final currentKey = apiKeyInfo['current_key'] as String;

      // API keys typically start with "AIza" and are 39 characters long
      expect(currentKey.startsWith('AIza'), isTrue);
      expect(currentKey.length, equals(39));
    });
  });

  group('Configuration File Integrity', () {
    test('firebase.json file is readable', () {
      final file = File('firebase.json');
      expect(() => file.readAsStringSync(), returnsNormally);
    });

    test('google-services.json file is readable', () {
      final file = File('android/app/google-services.json');
      expect(() => file.readAsStringSync(), returnsNormally);
    });

    test('firebase.json is not empty', () {
      final file = File('firebase.json');
      final content = file.readAsStringSync();
      expect(content.trim(), isNotEmpty);
      expect(content.length, greaterThan(10));
    });

    test('google-services.json is not empty', () {
      final file = File('android/app/google-services.json');
      final content = file.readAsStringSync();
      expect(content.trim(), isNotEmpty);
      expect(content.length, greaterThan(10));
    });
  });

  group('Edge Cases and Error Handling', () {
    test('firebase.json handles missing optional fields gracefully', () {
      final file = File('firebase.json');
      final content = file.readAsStringSync();
      final config = jsonDecode(content);

      // Should not throw even if accessing deep nested optional fields
      expect(() {
        final _ = config['flutter']?['platforms']?['nonexistent'];
      }, returnsNormally);
    });

    test('project IDs are non-empty strings', () {
      final firebaseFile = File('firebase.json');
      final firebaseConfig =
          jsonDecode(firebaseFile.readAsStringSync()) as Map<String, dynamic>;

      final projectId = firebaseConfig['flutter']['platforms']['android']
          ['default']['projectId'] as String;

      expect(projectId, isNotEmpty);
      expect(projectId.trim(), equals(projectId),
          reason: 'Project ID should not have leading/trailing whitespace');
    });

    test('app IDs are non-empty strings', () {
      final firebaseFile = File('firebase.json');
      final firebaseConfig =
          jsonDecode(firebaseFile.readAsStringSync()) as Map<String, dynamic>;

      final appId = firebaseConfig['flutter']['platforms']['android']
          ['default']['appId'] as String;

      expect(appId, isNotEmpty);
      expect(appId.contains(':'), isTrue,
          reason: 'App ID should contain colons in the expected format');
    });
  });
}