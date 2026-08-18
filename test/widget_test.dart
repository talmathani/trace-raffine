import 'package:flutter_test/flutter_test.dart';

import 'package:trace_raffine/app.dart';
import 'package:trace_raffine/features/splash/splash_screen.dart';

void main() {
  testWidgets('TRACÉ RAFFINÉ application starts with splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TRApp());

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
