// ============================================================
// CineBook — Payment Model Unit Tests
// ============================================================
// Tests the Payment model's toMap() serialization and
// fromMap() deserialization for correctness and edge cases.
// Run: flutter test test/models/payment_model_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:cinebook/models/core_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  final sampleTimestamp = DateTime(2026, 3, 24, 0, 0, 0);

  Payment buildPayment({
    String id = 'pay_001',
    String ticketId = 'tkt_001',
    String userId = 'usr_001',
    double amount = 3000.0,
    String status = 'Success',
    String encryptedCardData = 'encryptedBase64==',
    DateTime? timestamp,
  }) {
    return Payment(
      id: id,
      ticketId: ticketId,
      userId: userId,
      amount: amount,
      status: status,
      encryptedCardData: encryptedCardData,
      timestamp: timestamp ?? sampleTimestamp,
    );
  }

  group('Payment model', () {
    // ── toMap() ───────────────────────────────────────────────
    group('toMap()', () {
      test('contains all required keys', () {
        final map = buildPayment().toMap();
        expect(map.keys, containsAll([
          'ticketId',
          'userId',
          'amount',
          'status',
          'encryptedCardData',
          'timestamp',
        ]));
      });

      test('stores correct ticketId and userId', () {
        final map = buildPayment(ticketId: 'tkt_123', userId: 'usr_456').toMap();
        expect(map['ticketId'], equals('tkt_123'));
        expect(map['userId'], equals('usr_456'));
      });

      test('stores amount as numeric value', () {
        final map = buildPayment(amount: 1500.0).toMap();
        expect(map['amount'], equals(1500.0));
      });

      test('stores status correctly', () {
        final map = buildPayment(status: 'Success').toMap();
        expect(map['status'], equals('Success'));
      });

      test('stores encryptedCardData correctly', () {
        final map = buildPayment(encryptedCardData: 'abc123==').toMap();
        expect(map['encryptedCardData'], equals('abc123=='));
      });

      test('stores timestamp as Firestore Timestamp', () {
        final map = buildPayment().toMap();
        expect(map['timestamp'], isA<Timestamp>());
      });

      test('does NOT store the plain id in map (id is the document key)', () {
        final map = buildPayment(id: 'secret_id').toMap();
        expect(map.containsKey('id'), isFalse);
      });
    });

    // ── fromMap() ─────────────────────────────────────────────
    group('fromMap()', () {
      Map<String, dynamic> sampleMap() => {
        'ticketId': 'tkt_001',
        'userId': 'usr_001',
        'amount': 3000.0,
        'status': 'Success',
        'encryptedCardData': 'encBase64==',
        'timestamp': Timestamp.fromDate(sampleTimestamp),
      };

      test('correctly reconstructs a Payment', () {
        final payment = Payment.fromMap('pay_001', sampleMap());
        expect(payment.id, equals('pay_001'));
        expect(payment.ticketId, equals('tkt_001'));
        expect(payment.userId, equals('usr_001'));
        expect(payment.amount, equals(3000.0));
        expect(payment.status, equals('Success'));
        expect(payment.encryptedCardData, equals('encBase64=='));
      });

      test('amount is parsed as double even when stored as int', () {
        final map = sampleMap()..['amount'] = 1500; // stored as int
        final payment = Payment.fromMap('pay_001', map);
        expect(payment.amount, isA<double>());
        expect(payment.amount, equals(1500.0));
      });

      test('status defaults to "Pending" when missing', () {
        final map = sampleMap()..remove('status');
        final payment = Payment.fromMap('pay_001', map);
        expect(payment.status, equals('Pending'));
      });

      test('encryptedCardData defaults to empty string when missing', () {
        final map = sampleMap()..remove('encryptedCardData');
        final payment = Payment.fromMap('pay_001', map);
        expect(payment.encryptedCardData, equals(''));
      });

      test('timestamp defaults to now when missing (no crash)', () {
        final map = sampleMap()..remove('timestamp');
        expect(() => Payment.fromMap('pay_001', map), returnsNormally);
      });

      test('amount defaults to 0.0 when missing', () {
        final map = sampleMap()..remove('amount');
        final payment = Payment.fromMap('pay_001', map);
        expect(payment.amount, equals(0.0));
      });
    });

    // ── Round-trip ────────────────────────────────────────────
    group('toMap → fromMap round-trip', () {
      test('preserves all fields through serialization', () {
        final original = buildPayment();
        final map = original.toMap();
        final restored = Payment.fromMap(original.id, map);

        expect(restored.id, equals(original.id));
        expect(restored.ticketId, equals(original.ticketId));
        expect(restored.userId, equals(original.userId));
        expect(restored.amount, equals(original.amount));
        expect(restored.status, equals(original.status));
        expect(restored.encryptedCardData, equals(original.encryptedCardData));
      });
    });
  });
}
