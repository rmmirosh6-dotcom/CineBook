import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cinebook/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('verify login validation and guest bypass', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the Guest login option
      final guestButton = find.text('Continue as Guest');
      expect(guestButton, findsOneWidget);

      // We won't test hard Firebase login here directly to prevent leaking credentials in test scripts,
      // but we will test that validation appears
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Validating that there is error handling shown (either a SnackBar or inline text)
        expect(find.byType(SnackBar), findsWidgets);
      }
    });
  });
}
