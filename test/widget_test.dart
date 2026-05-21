import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('onboarding moves through the three intro pages', (
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
  });
}
