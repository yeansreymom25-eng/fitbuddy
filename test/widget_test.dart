import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('onboarding opens Firebase auth screens with validation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FitBuddyApp());

    expect(
      find.text('Healthy You, Better Tomorrow', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Get Start'), findsOneWidget);

    await tester.tap(find.text('Get Start'));
    await tester.pumpAndSettle();

    expect(find.text('Track Everything', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Improve Your Health', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back !'), findsOneWidget);
    expect(find.text('Forgot Password'), findsOneWidget);

    await tester.tap(find.text('Forgot Password'));
    await tester.pumpAndSettle();

    expect(find.text('Send Reset Link'), findsOneWidget);

    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email address.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'fit@example.com');
    await tester.tap(find.text('Forgot Password'));
    await tester.pumpAndSettle();

    expect(find.text('fit@example.com'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Please complete all signup fields.'), findsOneWidget);
  });
}
