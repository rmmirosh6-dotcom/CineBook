// ============================================================
// CineBook — Encryption Service Unit Tests
// ============================================================
// Tests the XOR+Base64 EncryptionService for correctness,
// edge cases, and encrypt/decrypt round-trip integrity.
// Run: flutter test test/services/encryption_service_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:cinebook/services/encryption_service.dart';

void main() {
  group('EncryptionService', () {
    // ── Basic sanity ──────────────────────────────────────────
    group('encryptData', () {
      test('returns a non-empty result for a normal input', () {
        final result = EncryptionService.encryptData('hello');
        expect(result, isNotEmpty);
      });

      test('returns empty string when given empty input', () {
        final result = EncryptionService.encryptData('');
        expect(result, equals(''));
      });

      test('encrypted output is NOT equal to the plaintext', () {
        const plainText = '4111111111111111|12/28|123|John Doe';
        final encrypted = EncryptionService.encryptData(plainText);
        expect(encrypted, isNot(equals(plainText)));
      });

      test('encrypted output is valid Base64', () {
        final result = EncryptionService.encryptData('test-card-data');
        // Base64 chars: A-Z a-z 0-9 + / =
        final base64Regex = RegExp(r'^[A-Za-z0-9+/=]+$');
        expect(base64Regex.hasMatch(result), isTrue,
            reason: 'Output should be valid Base64: $result');
      });

      test('encrypts a full card payload string correctly', () {
        const payload = '4532015112830366|09/26|737|Kasun Perera';
        final result = EncryptionService.encryptData(payload);
        expect(result, isNotEmpty);
        expect(result, isNot(equals(payload)));
      });

      test('same input always produces same output (deterministic)', () {
        const input = 'stable-payload';
        expect(
          EncryptionService.encryptData(input),
          equals(EncryptionService.encryptData(input)),
        );
      });

      test('different inputs produce different outputs', () {
        final a = EncryptionService.encryptData('card1|12/25|111|Alice');
        final b = EncryptionService.encryptData('card2|11/26|222|Bob');
        expect(a, isNot(equals(b)));
      });
    });

    // ── Decrypt ───────────────────────────────────────────────
    group('decryptData', () {
      test('returns empty string for empty input', () {
        expect(EncryptionService.decryptData(''), equals(''));
      });

      test('returns "Decryption Error" for invalid Base64 input', () {
        expect(
          EncryptionService.decryptData('!!!not_valid_base64!!!'),
          equals('Decryption Error'),
        );
      });
    });

    // ── Round-trip ────────────────────────────────────────────
    group('encrypt → decrypt round-trip', () {
      test('restores simple string correctly', () {
        const original = 'hello world';
        final encrypted = EncryptionService.encryptData(original);
        final decrypted = EncryptionService.decryptData(encrypted);
        expect(decrypted, equals(original));
      });

      test('restores full card payload correctly', () {
        const payload = '4532015112830366|09/26|737|Kasun Perera';
        final roundTripped = EncryptionService.decryptData(
          EncryptionService.encryptData(payload),
        );
        expect(roundTripped, equals(payload));
      });

      test('handles special characters in payload', () {
        const payload = 'Name: O\'Brien | Card: 5500-0000-0000-0004';
        final roundTripped = EncryptionService.decryptData(
          EncryptionService.encryptData(payload),
        );
        expect(roundTripped, equals(payload));
      });

      test('handles long payload without data loss', () {
        final longPayload =
            '4111111111111111|12/28|999|${List.filled(100, 'X').join()}';
        final roundTripped = EncryptionService.decryptData(
          EncryptionService.encryptData(longPayload),
        );
        expect(roundTripped, equals(longPayload));
      });
    });
  });
}
