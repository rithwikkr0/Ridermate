// This is a basic Flutter widget test.
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

    // Verify that the app displays RiderMate title
    expect(find.text('RiderMate'), findsOneWidget);

    // Verify that the START RIDE button is present
    expect(find.text('🚀 START RIDE'), findsOneWidget);

    // Verify that points are displayed
    expect(find.textContaining('pts'), findsOneWidget);
  });
}
