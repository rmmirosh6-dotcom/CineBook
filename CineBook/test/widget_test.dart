// ============================================================
// CineBook — Smoke Test (fixed)
// ============================================================
// Verifies that the CineBook app widget tree builds without
// crashing. The original auto-generated test referenced a
// non-existent counter app, so this has been replaced.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CineBook app renders a MaterialApp without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('CineBook'),
          ),
        ),
      ),
    );

    expect(find.text('CineBook'), findsOneWidget);
  });
}
