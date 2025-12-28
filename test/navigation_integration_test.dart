import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Navigation Integration Tests', () {
    testWidgets('MaterialApp has proper navigation setup',
        (WidgetTester tester) async {
      // Create a test app with navigation
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const TestHomePage(),
          ),
        ),
      );

      expect(find.byType(TestHomePage), findsOneWidget);
      expect(navigatorKey.currentState, isNotNull);
    });

    testWidgets('Navigator can push and pop routes',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const TestHomePage(),
          ),
        ),
      );

      // Initial state
      expect(find.byType(TestHomePage), findsOneWidget);

      // Push a new route
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const TestSecondPage()),
      );

      await tester.pumpAndSettle();
      expect(find.byType(TestSecondPage), findsOneWidget);

      // Pop the route
      navigatorKey.currentState?.pop();
      await tester.pumpAndSettle();
      expect(find.byType(TestHomePage), findsOneWidget);
    });

    testWidgets('Navigator handles pushReplacement correctly',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const TestHomePage(),
          ),
        ),
      );

      expect(find.byType(TestHomePage), findsOneWidget);

      // Replace current route
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const TestSecondPage()),
      );

      await tester.pumpAndSettle();
      expect(find.byType(TestSecondPage), findsOneWidget);
      expect(find.byType(TestHomePage), findsNothing);

      // Try to pop - should not go back to TestHomePage
      final canPop = navigatorKey.currentState?.canPop() ?? false;
      expect(canPop, isFalse);
    });

    testWidgets('Navigator works with callbacks similar to splash screen',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      var callbackCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: TestSplashPage(
              onFinished: () {
                callbackCalled = true;
                navigatorKey.currentState?.pushReplacement(
                  MaterialPageRoute(builder: (_) => const TestSecondPage()),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(TestSplashPage), findsOneWidget);

      // Trigger the callback
      final testSplashState =
          tester.state<TestSplashPageState>(find.byType(TestSplashPage));
      testSplashState.triggerCallback();

      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
      expect(find.byType(TestSecondPage), findsOneWidget);
      expect(find.byType(TestSplashPage), findsNothing);
    });

    testWidgets('Multiple navigation operations in sequence',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const TestHomePage(),
          ),
        ),
      );

      // Push first page
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const TestSecondPage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TestSecondPage), findsOneWidget);

      // Push second page
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const TestThirdPage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TestThirdPage), findsOneWidget);

      // Pop back to second page
      navigatorKey.currentState?.pop();
      await tester.pumpAndSettle();
      expect(find.byType(TestSecondPage), findsOneWidget);

      // Pop back to home
      navigatorKey.currentState?.pop();
      await tester.pumpAndSettle();
      expect(find.byType(TestHomePage), findsOneWidget);
    });

    testWidgets('Navigation preserves widget state across routes',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const TestStatefulPage(),
          ),
        ),
      );

      // Find and interact with counter
      expect(find.text('Count: 0'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      // Navigate away
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const TestSecondPage()),
      );
      await tester.pumpAndSettle();

      // Navigate back
      navigatorKey.currentState?.pop();
      await tester.pumpAndSettle();

      // State should be preserved
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('Navigation with named routes style pattern',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            initialRoute: '/',
            routes: {
              '/': (context) => const TestHomePage(),
              '/second': (context) => const TestSecondPage(),
              '/third': (context) => const TestThirdPage(),
            },
          ),
        ),
      );

      expect(find.byType(TestHomePage), findsOneWidget);

      // Navigate using named route
      final BuildContext context = tester.element(find.byType(TestHomePage));
      Navigator.pushNamed(context, '/second');
      await tester.pumpAndSettle();

      expect(find.byType(TestSecondPage), findsOneWidget);
    });

    testWidgets('Navigator handles errors gracefully',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const TestHomePage(),
          ),
        ),
      );

      // Try to pop when can't pop
      final canPop = navigatorKey.currentState?.canPop() ?? false;
      expect(canPop, isFalse);

      // This should not crash
      expect(() => navigatorKey.currentState?.maybePop(), returnsNormally);
    });
  });

  group('MaterialApp Configuration Integration', () {
    testWidgets('Theme is applied correctly to child widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: const TestThemedPage(),
          ),
        ),
      );

      // Get the theme from the context
      final BuildContext context = tester.element(find.byType(TestThemedPage));
      final theme = Theme.of(context);

      expect(theme.colorScheme, isNotNull);
      expect(theme.colorScheme.primary, isNotNull);
    });

    testWidgets('ProviderScope provides Riverpod context',
        (WidgetTester tester) async {
      final testProvider = StateProvider<int>((ref) => 0);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final value = ref.watch(testProvider);
                return Text('Value: $value');
              },
            ),
          ),
        ),
      );

      expect(find.text('Value: 0'), findsOneWidget);
    });

    testWidgets('Multiple ProviderScopes can be nested independently',
        (WidgetTester tester) async {
      final outerProvider = StateProvider<String>((ref) => 'outer');
      final innerProvider = StateProvider<String>((ref) => 'inner');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            outerProvider.overrideWith((ref) => 'outer-value'),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final outer = ref.watch(outerProvider);
                return ProviderScope(
                  overrides: [
                    innerProvider.overrideWith((ref) => 'inner-value'),
                  ],
                  child: Consumer(
                    builder: (context, ref, child) {
                      final inner = ref.watch(innerProvider);
                      return Column(
                        children: [
                          Text('Outer: $outer'),
                          Text('Inner: $inner'),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Outer: outer-value'), findsOneWidget);
      expect(find.text('Inner: inner-value'), findsOneWidget);
    });
  });
}

// Test helper widgets
class TestHomePage extends StatelessWidget {
  const TestHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home Page')),
    );
  }
}

class TestSecondPage extends StatelessWidget {
  const TestSecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Second Page')),
    );
  }
}

class TestThirdPage extends StatelessWidget {
  const TestThirdPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Third Page')),
    );
  }
}

class TestSplashPage extends StatefulWidget {
  final VoidCallback onFinished;

  const TestSplashPage({Key? key, required this.onFinished}) : super(key: key);

  @override
  State<TestSplashPage> createState() => TestSplashPageState();
}

class TestSplashPageState extends State<TestSplashPage> {
  void triggerCallback() {
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Splash Page')),
    );
  }
}

class TestStatefulPage extends StatefulWidget {
  const TestStatefulPage({Key? key}) : super(key: key);

  @override
  State<TestStatefulPage> createState() => _TestStatefulPageState();
}

class _TestStatefulPageState extends State<TestStatefulPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: $_count'),
            ElevatedButton(
              onPressed: () => setState(() => _count++),
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestThemedPage extends StatelessWidget {
  const TestThemedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: const Center(child: Text('Themed Page')),
      ),
    );
  }
}