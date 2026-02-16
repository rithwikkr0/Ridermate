import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate_app/main.dart';

void main() {
  group('RiderMateApp Widget Tests', () {
    testWidgets('should display app title', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Verify the app title
      expect(find.text('RiderMate'), findsOneWidget);
    });

    testWidgets('should display points', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Verify points are displayed
      expect(find.textContaining('pts'), findsOneWidget);
    });

    testWidgets('should have Today tab selected by default', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Verify Today tab is visible
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Memories'), findsOneWidget);
    });

    testWidgets('should display START RIDE button', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Verify START RIDE button is present
      expect(find.text('🚀 START RIDE'), findsOneWidget);
    });

    testWidgets('should display referral code', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Verify referral code section is present
      expect(find.text('📱 Referral Code'), findsOneWidget);
      expect(find.text('RIDER2025XYZ'), findsOneWidget);
    });
  });

  group('Tab Navigation Tests', () {
    testWidgets('should switch to History tab when tapped', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Tap on History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Verify History content is displayed
      expect(find.text('Recent Rides'), findsOneWidget);
    });

    testWidgets('should switch to Friends tab when tapped', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Tap on Friends tab
      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();

      // Verify Friends content is displayed
      expect(find.text('Friends on Map'), findsOneWidget);
      expect(find.text('Friends List'), findsOneWidget);
    });

    testWidgets('should switch to Memories tab when tapped', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Tap on Memories tab
      await tester.tap(find.text('Memories'));
      await tester.pumpAndSettle();

      // Verify Memories content is displayed
      expect(find.text('Location Memories'), findsOneWidget);
    });
  });

  group('Ride Screen Navigation Tests', () {
    testWidgets('should navigate to RideScreen when START RIDE is tapped', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Tap START RIDE button
      await tester.tap(find.text('🚀 START RIDE'));
      await tester.pumpAndSettle();

      // Verify RideScreen is displayed
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
    });

    testWidgets('should display SOS button on RideScreen', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Navigate to RideScreen
      await tester.tap(find.text('🚀 START RIDE'));
      await tester.pumpAndSettle();

      // Verify SOS button is present
      expect(find.byIcon(Icons.sos), findsOneWidget);
    });
  });

  group('HomeScreen Content Tests', () {
    testWidgets('should display ride history items', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Switch to History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Verify ride history items are displayed
      expect(find.text('Route 1'), findsOneWidget);
      expect(find.text('Route 2'), findsOneWidget);
      expect(find.text('Route 3'), findsOneWidget);
    });

    testWidgets('should display friends list', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Switch to Friends tab
      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();

      // Verify friends are displayed
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Jordan'), findsOneWidget);
      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('Casey'), findsOneWidget);
    });

    testWidgets('should display memories with privacy indicators', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(RiderMateApp());

      // Switch to Memories tab
      await tester.tap(find.text('Memories'));
      await tester.pumpAndSettle();

      // Verify memories are displayed
      expect(find.text('Sunset View'), findsOneWidget);
      expect(find.text('City Center'), findsOneWidget);
      expect(find.text('Park Trail'), findsOneWidget);
    });
  });
}
