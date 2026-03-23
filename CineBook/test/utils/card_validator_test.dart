// ============================================================
// CineBook — Card Validation Logic Unit Tests
// ============================================================
// Tests the same validation rules used in PaymentScreen's form
// validators, as pure logic (no Firebase, no widgets).
// Run: flutter test test/utils/card_validator_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Replicated validators — same rules as in payment_screen.dart
// Keeping them here as pure functions makes them trivially easy to test.
// ---------------------------------------------------------------------------

String? validateCardNumber(String? val) {
  if (val == null || val.replaceAll(' ', '').length < 15) {
    return 'Please enter a valid 16-digit card number';
  }
  return null;
}

String? validateCvv(String? val) {
  if (val == null || val.length < 3) return 'Invalid CVV';
  return null;
}

final _expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');

String? validateExpiry(String? val) {
  if (val == null || !_expiryRegex.hasMatch(val)) return 'Invalid Expiry';
  return null;
}

String? validateName(String? val) {
  if (val == null || val.trim().isEmpty) {
    return 'Please enter the exact name on card';
  }
  return null;
}

// Internal helper: mirrors PaymentGatewayService card check
bool isCardNumberValidForGateway(String cardNumber) {
  return cardNumber.replaceAll(' ', '').length >= 15;
}

bool isCvvValidForGateway(String cvv) {
  return cvv.length >= 3;
}

void main() {
  // ── Card Number ───────────────────────────────────────────
  group('Card Number Validation', () {
    test('null input → invalid', () {
      expect(validateCardNumber(null), isNotNull);
    });

    test('empty string → invalid', () {
      expect(validateCardNumber(''), isNotNull);
    });

    test('14 digits (< 15) → invalid', () {
      expect(validateCardNumber('41111111111111'), isNotNull);
    });

    test('15 digits (AMEX length) → valid', () {
      expect(validateCardNumber('378282246310005'), isNull);
    });

    test('16 digits (Visa/MC) → valid', () {
      expect(validateCardNumber('4111111111111111'), isNull);
    });

    test('16 digits with spaces → valid', () {
      expect(validateCardNumber('4111 1111 1111 1111'), isNull);
    });

    test('19 digits (long card) → valid', () {
      expect(validateCardNumber('4111111111111111111'), isNull);
    });

    test('letters only → invalid', () {
      expect(validateCardNumber('ABCDEFGHIJKLMNO'), isNotNull);
    });
  });

  // ── CVV ───────────────────────────────────────────────────
  group('CVV Validation', () {
    test('null → invalid', () {
      expect(validateCvv(null), isNotNull);
    });

    test('empty → invalid', () {
      expect(validateCvv(''), isNotNull);
    });

    test('1 digit → invalid', () {
      expect(validateCvv('1'), isNotNull);
    });

    test('2 digits → invalid', () {
      expect(validateCvv('12'), isNotNull);
    });

    test('3 digits → valid', () {
      expect(validateCvv('123'), isNull);
    });

    test('4 digits (AMEX CVV) → valid', () {
      expect(validateCvv('1234'), isNull);
    });

    test('alphabetical input of length >= 3 → structurally valid (length only)', () {
      // Validator only checks length, not numeric content
      expect(validateCvv('abc'), isNull);
    });
  });

  // ── Expiry ────────────────────────────────────────────────
  group('Expiry Date Validation', () {
    test('null → invalid', () {
      expect(validateExpiry(null), isNotNull);
    });

    test('empty → invalid', () {
      expect(validateExpiry(''), isNotNull);
    });

    test('valid MM/YY format "09/26" → valid', () {
      expect(validateExpiry('09/26'), isNull);
    });

    test('valid MM/YY format "12/29" → valid', () {
      expect(validateExpiry('12/29'), isNull);
    });

    test('valid "01/25" → valid', () {
      expect(validateExpiry('01/25'), isNull);
    });

    test('invalid month "13/25" → invalid', () {
      expect(validateExpiry('13/25'), isNotNull);
    });

    test('invalid month "00/25" → invalid', () {
      expect(validateExpiry('00/25'), isNotNull);
    });

    test('single-digit month "9/26" → invalid', () {
      expect(validateExpiry('9/26'), isNotNull);
    });

    test('alphabetical "ab/cd" → invalid', () {
      expect(validateExpiry('ab/cd'), isNotNull);
    });

    test('wrong format "2026/09" → invalid', () {
      expect(validateExpiry('2026/09'), isNotNull);
    });

    test('MMYY without slash "0926" → invalid', () {
      expect(validateExpiry('0926'), isNotNull);
    });
  });

  // ── Cardholder Name ───────────────────────────────────────
  group('Cardholder Name Validation', () {
    test('null → invalid', () {
      expect(validateName(null), isNotNull);
    });

    test('empty string → invalid', () {
      expect(validateName(''), isNotNull);
    });

    test('whitespace only → invalid', () {
      expect(validateName('   '), isNotNull);
    });

    test('normal name → valid', () {
      expect(validateName('Kasun Perera'), isNull);
    });

    test('single-word name → valid', () {
      expect(validateName('Kasun'), isNull);
    });

    test('name with numbers → valid (no restriction)', () {
      expect(validateName('John Doe 2'), isNull);
    });
  });

  // ── Gateway-level Validation (mirrors PaymentGatewayService) ─
  group('Gateway Card Number Check', () {
    test('card number with 14 stripped digits → rejected', () {
      expect(isCardNumberValidForGateway('41111111111111'), isFalse);
    });

    test('card number with 15 stripped digits → accepted', () {
      expect(isCardNumberValidForGateway('378282246310005'), isTrue);
    });

    test('card number with spaces → stripped to 16 digits → accepted', () {
      expect(isCardNumberValidForGateway('4111 1111 1111 1111'), isTrue);
    });
  });

  group('Gateway CVV Check', () {
    test('CVV of length 2 → rejected', () {
      expect(isCvvValidForGateway('12'), isFalse);
    });

    test('CVV of length 3 → accepted', () {
      expect(isCvvValidForGateway('123'), isTrue);
    });

    test('CVV of length 4 → accepted', () {
      expect(isCvvValidForGateway('9999'), isTrue);
    });
  });
}
