// Basic smoke test — verifies the app boots and renders its initial route
// without throwing, using flutter_test's WidgetTester utility.

import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_connect/core/theme/app_palette.dart';
import 'package:excelerate_connect/core/theme/app_theme.dart';
import 'package:excelerate_connect/main.dart';

void main() {
  testWidgets('App boots and renders the initial route', (WidgetTester tester) async {
    await tester.pumpWidget(const ExcelerateApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  test('Light and dark themes both register a distinct AppPalette', () {
    final light = AppTheme.light.extension<AppPalette>();
    final dark = AppTheme.dark.extension<AppPalette>();

    expect(light, isNotNull);
    expect(dark, isNotNull);
    expect(light, isNot(equals(dark)));
    expect(light!.background, isNot(equals(dark!.background)));
  });
}
