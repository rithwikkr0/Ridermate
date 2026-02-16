// This is a basic Flutter widget test for RiderMate app
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ridermate_app/main.dart';

void main() {
  testWidgets('RiderMate app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(RiderMateApp());

    // Verify that the app title is present
    expect(find.text('RiderMate'), findsOneWidget);

    // Verify that the START RIDE button is present
    expect(find.text('🚀 START RIDE'), findsOneWidget);

    // Verify that points are displayed
    expect(find.text('1250 pts'), findsOneWidget);
  });

  testWidgets('Tab navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(RiderMateApp());

    // Verify initial tab is Today
    expect(find.text('Today'), findsOneWidget);
    
    // Find and tap on History tab
    await tester.tap(find.text('History'));
    await tester.pump();

    // Verify History tab is now active
    // (The tab should still be visible)
    expect(find.text('History'), findsOneWidget);

    // Find and tap on AI Chat tab
    await tester.tap(find.text('AI Chat'));
    await tester.pumpAndSettle();

    // Verify AI Chat interface loaded
    expect(find.text('AI Chat'), findsOneWidget);
  });
}
