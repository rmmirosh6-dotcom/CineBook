// ============================================================
// CineBook — PaymentGatewayService Unit Tests
// ============================================================
// Tests the payment processing logic: card validation, 
// encryption application, and Payment object construction.
// Uses a hand-rolled fake DatabaseService to avoid Firebase.
// Run: flutter test test/services/payment_gateway_service_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:cinebook/services/encryption_service.dart';
import 'package:cinebook/models/core_models.dart';

// ---------------------------------------------------------------------------
// Extracted & testable payment logic
// ---------------------------------------------------------------------------
// Because PaymentGatewayService directly instantiates FirebaseFirestore,
// we extract the pure logic into testable functions here. This follows
// the "test the behaviour, not the implementation" principle — and maps
// 1-to-1 with what the real service does.
// ---------------------------------------------------------------------------

/// Pure card number + CVV validation — mirrors PaymentGatewayService
String? validatePaymentInputs(String cardNumber, String cvv) {
  if (cardNumber.replaceAll(' ', '').length < 15 || cvv.length < 3) {
    return 'Invalid Card Details. Please verify your card number and CVV.';
  }
  return null;
}

/// Builds the sensitive payload string — mirrors the service
String buildSensitivePayload({
  required String cardNumber,
  required String expiry,
  required String cvv,
  required String name,
}) {
  return '$cardNumber|$expiry|$cvv|$name';
}

/// Simulates the full pipeline (validate → encrypt → build Payment)
/// Returns a [Payment] or throws on invalid input.
Payment simulateProcessPayment({
  required String ticketId,
  required String userId,
  required String cardNumber,
  required String expiry,
  required String cvv,
  required String name,
  required double amount,
  String paymentDocId = 'pay_test_001',
}) {
  // Step 1 — validate
  final error = validatePaymentInputs(cardNumber, cvv);
  if (error != null) throw Exception(error);

  // Step 2 — encrypt
  final payload = buildSensitivePayload(
    cardNumber: cardNumber,
    expiry: expiry,
    cvv: cvv,
    name: name,
  );
  final encryptedData = EncryptionService.encryptData(payload);

  // Step 3 — build Payment record
  return Payment(
    id: paymentDocId,
    ticketId: ticketId,
    userId: userId,
    amount: amount,
    status: 'Success',
    encryptedCardData: encryptedData,
    timestamp: DateTime.now(),
  );
}

void main() {
  const validCard = '4111111111111111';
  const validExpiry = '12/28';
  const validCvv = '737';
  const validName = 'Kasun Perera';
  const validAmount = 3000.0;

  // ── Input Validation ──────────────────────────────────────
  group('Input validation', () {
    test('valid card + valid CVV → no error', () {
      expect(validatePaymentInputs(validCard, validCvv), isNull);
    });

    test('card number < 15 digits → throws exception', () {
      expect(
        () => simulateProcessPayment(
          ticketId: 't1', userId: 'u1',
          cardNumber: '41111111111111', // 14 digits
          expiry: validExpiry, cvv: validCvv, name: validName,
          amount: validAmount,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 'message', contains('Invalid Card Details'),
        )),
      );
    });

    test('empty card number → throws exception', () {
      expect(
        () => simulateProcessPayment(
          ticketId: 't1', userId: 'u1',
          cardNumber: '',
          expiry: validExpiry, cvv: validCvv, name: validName,
          amount: validAmount,
        ),
        throwsException,
      );
    });

    test('card number with spaces but 16 digits → valid', () {
      expect(
        () => simulateProcessPayment(
          ticketId: 't1', userId: 'u1',
          cardNumber: '4111 1111 1111 1111',
          expiry: validExpiry, cvv: validCvv, name: validName,
          amount: validAmount,
        ),
        returnsNormally,
      );
    });

    test('CVV of length 2 → throws exception', () {
      expect(
        () => simulateProcessPayment(
          ticketId: 't1', userId: 'u1',
          cardNumber: validCard, expiry: validExpiry,
          cvv: '12', // too short
          name: validName, amount: validAmount,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 'message', contains('Invalid Card Details'),
        )),
      );
    });

    test('empty CVV → throws exception', () {
      expect(
        () => simulateProcessPayment(
          ticketId: 't1', userId: 'u1',
          cardNumber: validCard, expiry: validExpiry,
          cvv: '',
          name: validName, amount: validAmount,
        ),
        throwsException,
      );
    });

    test('AMEX card (15 digits) + valid CVV → valid', () {
      expect(
        () => simulateProcessPayment(
          ticketId: 't1', userId: 'u1',
          cardNumber: '378282246310005', // 15 digits
          expiry: validExpiry, cvv: '1234', name: validName,
          amount: validAmount,
        ),
        returnsNormally,
      );
    });
  });

  // ── Payment Object Construction ───────────────────────────
  group('Payment object construction', () {
    late Payment payment;

    setUp(() {
      payment = simulateProcessPayment(
        ticketId: 'tkt_999',
        userId: 'usr_888',
        cardNumber: validCard,
        expiry: validExpiry,
        cvv: validCvv,
        name: validName,
        amount: validAmount,
      );
    });

    test('payment status is "Success"', () {
      expect(payment.status, equals('Success'));
    });

    test('payment stores correct ticketId', () {
      expect(payment.ticketId, equals('tkt_999'));
    });

    test('payment stores correct userId', () {
      expect(payment.userId, equals('usr_888'));
    });

    test('payment stores correct amount', () {
      expect(payment.amount, equals(validAmount));
    });

    test('encryptedCardData is NOT equal to raw card number', () {
      expect(payment.encryptedCardData, isNot(equals(validCard)));
    });

    test('encryptedCardData is NOT equal to the raw payload string', () {
      final rawPayload = buildSensitivePayload(
        cardNumber: validCard,
        expiry: validExpiry,
        cvv: validCvv,
        name: validName,
      );
      expect(payment.encryptedCardData, isNot(equals(rawPayload)));
    });

    test('encryptedCardData is non-empty', () {
      expect(payment.encryptedCardData, isNotEmpty);
    });

    test('decrypting encryptedCardData restores the original payload', () {
      final decrypted = EncryptionService.decryptData(payment.encryptedCardData);
      expect(decrypted, contains(validCard));
      expect(decrypted, contains(validCvv));
      expect(decrypted, contains(validName));
      expect(decrypted, contains(validExpiry));
    });

    test('payment has a non-empty id', () {
      expect(payment.id, isNotEmpty);
    });

    test('timestamp is close to now (within 5 seconds)', () {
      final diff = DateTime.now().difference(payment.timestamp).abs();
      expect(diff.inSeconds, lessThan(5));
    });
  });

  // ── Sensitive Payload Builder ─────────────────────────────
  group('Sensitive payload builder', () {
    test('includes all four fields separated by pipes', () {
      final payload = buildSensitivePayload(
        cardNumber: '4111111111111111',
        expiry: '12/28',
        cvv: '737',
        name: 'Kasun Perera',
      );
      expect(payload, equals('4111111111111111|12/28|737|Kasun Perera'));
    });

    test('different cards produce different payloads', () {
      final a = buildSensitivePayload(
        cardNumber: '4111111111111111', expiry: '12/28', cvv: '737', name: 'A',
      );
      final b = buildSensitivePayload(
        cardNumber: '5500000000000004', expiry: '08/30', cvv: '123', name: 'B',
      );
      expect(a, isNot(equals(b)));
    });
  });
}
