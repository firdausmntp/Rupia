// Basic Flutter widget test for Rupia app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rupia/main.dart';

void main() {
  testWidgets('Rupia app launches correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: RupiaApp(),
      ),
    );

    // Verify app loads (may show splash screen or home)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
