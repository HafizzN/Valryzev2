// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:portal_mobile/main.dart';

void main() {
  testWidgets('App renders LoginScreen when not logged in', (WidgetTester tester) async {
    // Build our app and trigger a frame with isLoggedIn as false
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that the login screen title and subtitle are displayed
    expect(find.text('SMART HR PORTAL'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
  });
}
