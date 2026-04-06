import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cinebook/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Movie Browser Testing', () {
    testWidgets('verify toggle and movie card navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final guestButton = find.text('Continue as Guest');
      if (guestButton.evaluate().isNotEmpty) {
        await tester.tap(guestButton);
        await tester.pumpAndSettle();
      }

      expect(find.text('Now Showing'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);

      await tester.tap(find.text('Upcoming'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Now Showing'));
      await tester.pumpAndSettle();

      final inceptionCard = find.text('Inception');
      if (inceptionCard.evaluate().isNotEmpty) {
        await tester.tap(inceptionCard);
        await tester.pumpAndSettle();

        expect(find.text('Book Tickets'), findsOneWidget);
      }
    });
  });
}
