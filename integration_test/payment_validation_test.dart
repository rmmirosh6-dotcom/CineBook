import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cinebook/views/payment_screen.dart';
import 'package:cinebook/models/core_models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Payment Validation Testing', () {
    testWidgets('verify virtual card fields catch invalid inputs',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentScreen(
            checkoutData: {
              'movieId': '1',
              'cinemaName': 'Test Cinema',
              'totalPrice': 2000.0,
              'selectedSeats': const ['A1', 'A2'],
              'showtime': Showtime(
                id: '1',
                time: '10:00 AM',
                format: '2D',
                price: 1000.0,
                availableSeats: 50,
              ),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final payButton = find.text('Pay LKR 2000.00');
      expect(payButton, findsOneWidget);

      await tester.tap(payButton);
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsWidgets);
    });
  });
}
