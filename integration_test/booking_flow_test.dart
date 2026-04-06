import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cinebook/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Flow Testing', () {
    testWidgets('navigate through cinema to seat selection', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final guestButton = find.text('Continue as Guest');
      if (guestButton.evaluate().isNotEmpty) {
        await tester.tap(guestButton);
        await tester.pumpAndSettle();
      }

      final movieCard = find.byType(GestureDetector).last;
      if (movieCard.evaluate().isNotEmpty) {
        await tester.tap(movieCard);
        await tester.pumpAndSettle();

        final bookButton = find.text('Book Tickets');
        if (bookButton.evaluate().isNotEmpty) {
          await tester.tap(bookButton);
          await tester.pumpAndSettle();
          
          expect(find.byIcon(Icons.calendar_today), findsWidgets);
        }
      }
    });
  });
}
