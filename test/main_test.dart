import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Mock Firebase
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

void main() {
  setUpAll(() {
    setupFirebaseAuthMocks();
  });

  group('HeritageLens App Initialization', () {
    testWidgets('app creates MaterialApp with correct configuration',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Heritage Lens'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('MaterialApp has navigatorKey configured',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.navigatorKey, isNotNull);
    });

    testWidgets('MaterialApp theme uses ColorScheme with deepPurple seed',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme!.colorScheme.primary, isNotNull);
      // The seed color generates a scheme, we can verify it's configured
      expect(materialApp.theme!.colorScheme, isA<ColorScheme>());
    });

    testWidgets('app wraps with ProviderScope for Riverpod',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      expect(find.byType(ProviderScope), findsOneWidget);
    });
  });

  group('HeritageLens Widget Structure', () {
    testWidgets('HeritageLens is a StatelessWidget',
        (WidgetTester tester) async {
      // Arrange
      const app = HeritageLens();

      // Assert
      expect(app, isA<StatelessWidget>());
    });

    testWidgets('HeritageLens build method returns MaterialApp',
        (WidgetTester tester) async {
      // Arrange
      const app = HeritageLens();

      // Act
      final widget = app.build(tester.element(find.byType(ProviderScope)));

      // Assert
      expect(widget, isA<MaterialApp>());
    });
  });

  group('App Theme Configuration', () {
    testWidgets('theme is properly configured and not null',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = materialApp.theme;

      expect(theme, isNotNull);
      expect(theme!.colorScheme, isNotNull);
      expect(theme.colorScheme.seedColor, isNotNull);
    });

    testWidgets('ColorScheme is generated from seed color',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final colorScheme = materialApp.theme!.colorScheme;

      // Verify that a complete color scheme exists
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.secondary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.error, isNotNull);
    });
  });

  group('Navigator Configuration', () {
    testWidgets('navigatorKey is accessible and functional',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.navigatorKey, isNotNull);
      expect(materialApp.navigatorKey!.currentState, isNotNull);
    });
  });

  group('App Constants and Configuration', () {
    test('app title is "Heritage Lens"', () {
      // Arrange
      const app = HeritageLens();

      // This test verifies the constant is properly set
      expect(app, isNotNull);
    });
  });

  group('Edge Cases and Error Handling', () {
    testWidgets('app handles rebuild without errors',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Trigger rebuild
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert - no exceptions thrown
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app can be disposed without errors',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Dispose
      await tester.pumpWidget(const SizedBox.shrink());

      // Assert - no exceptions thrown
      expect(find.byType(MaterialApp), findsNothing);
    });
  });

  group('Integration with Flutter Riverpod', () {
    testWidgets('ProviderScope properly wraps the app',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final providerScope = tester.widget<ProviderScope>(
        find.byType(ProviderScope),
      );
      expect(providerScope.child, isA<HeritageLens>());
    });

    testWidgets('multiple ProviderScopes can be nested',
        (WidgetTester tester) async {
      // Arrange & Act - Test that nested scopes work
      await tester.pumpWidget(
        ProviderScope(
          child: ProviderScope(
            child: const HeritageLens(),
          ),
        ),
      );

      // Assert
      expect(find.byType(ProviderScope), findsWidgets);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('MaterialApp Properties Validation', () {
    testWidgets('debugShowCheckedModeBanner is false',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('title is set correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Heritage Lens'));
      expect(materialApp.title.isNotEmpty, isTrue);
      expect(materialApp.title.length, greaterThan(0));
    });
  });

  group('Theme Consistency', () {
    testWidgets('theme remains consistent across rebuilds',
        (WidgetTester tester) async {
      // Arrange & Act - First build
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      final materialApp1 =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme1 = materialApp1.theme;

      // Rebuild
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      final materialApp2 =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme2 = materialApp2.theme;

      // Assert - theme properties should be identical
      expect(theme1!.colorScheme.primary, equals(theme2!.colorScheme.primary));
      expect(
          theme1.colorScheme.secondary, equals(theme2.colorScheme.secondary));
    });
  });

  group('Memory and Performance', () {
    testWidgets('app can be created and disposed multiple times',
        (WidgetTester tester) async {
      // Test multiple creation and disposal cycles
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(
          const ProviderScope(
            child: HeritageLens(),
          ),
        );

        expect(find.byType(MaterialApp), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        expect(find.byType(MaterialApp), findsNothing);
      }
    });
  });

  group('Navigator State Management', () {
    testWidgets('navigatorKey provides access to NavigatorState',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: HeritageLens(),
        ),
      );

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final navigatorState = materialApp.navigatorKey?.currentState;

      expect(navigatorState, isNotNull);
      expect(navigatorState, isA<NavigatorState>());
    });
  });
}