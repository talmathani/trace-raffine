import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';

void main() {
  testWidgets('TRACÉ RAFFINÉ theme works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: AppTheme.obsidian,
          body: Center(
            child: Text(
              'TRACÉ RAFFINÉ',
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 16,
                letterSpacing: 3,
                color: AppTheme.warmIvory,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('TRACÉ RAFFINÉ'), findsOneWidget);
  });
}
