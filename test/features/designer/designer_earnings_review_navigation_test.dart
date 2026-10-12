import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/features/designer/designer_earnings_screen.dart';
import 'package:trace_raffine/features/designer/designer_review_status_screen.dart';
import 'package:trace_raffine/features/designer/domain/models/designer_design_model.dart';
import 'package:trace_raffine/features/designer/presentation/providers/designer_dashboard_providers.dart';
import 'package:trace_raffine/features/orders/domain/entities/order.dart';

void main() {
  testWidgets('earnings screen exposes review status without a duplicate main tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          designerEarningsOrdersProvider.overrideWith((ref) async => <Order>[]),
          designerEarningsFinancialsProvider.overrideWith(
            (ref) async => <String, dynamic>{'success': true, 'sales': []},
          ),
          designerDesignsProvider.overrideWith(
            (ref) => Stream<List<DesignerDesignModel>>.value(
              <DesignerDesignModel>[],
            ),
          ),
        ],
        child: const MaterialApp(home: DesignerEarningsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byTooltip('حالة المراجعة'), findsOneWidget);

    await tester.tap(find.byTooltip('حالة المراجعة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DesignerReviewStatusScreen), findsOneWidget);
  });
}
