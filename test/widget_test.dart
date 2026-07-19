// Basic smoke test — verifies the app boots and renders its initial route
// without throwing, using flutter_test's WidgetTester utility.

import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_connect/main.dart';

void main() {
  testWidgets('App boots and renders the initial route', (WidgetTester tester) async {
    await tester.pumpWidget(const ExcelerateApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
