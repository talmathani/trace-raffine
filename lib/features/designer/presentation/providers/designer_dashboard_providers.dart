import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/appwrite/appwrite_service.dart';
import 'package:trace_raffine/core/di/app_dependencies.dart';
import 'package:trace_raffine/core/functions/function_invoker.dart';
import '../../domain/models/designer_design_model.dart';

final designerDesignsProvider =
    StreamProvider.autoDispose<List<DesignerDesignModel>>((ref) async* {
      final user = await AppwriteService.account.get();
      final repository = ref.watch(designerDesignRepositoryProvider);
      final functionInvoker = FunctionInvoker.create();

      yield* repository
          .watchDesignerDesigns(designerId: user.$id)
          .asyncMap((designs) async {
            try {
              final result = await functionInvoker.listDesignerReviews(
                userId: user.$id,
              );
              if (result['success'] != true || result['reviews'] is! List) {
                return designs;
              }

              final latestStatusByDesign = <String, DesignerDesignStatus>{};
              final latestFeedbackByDesign = <String, String?>{};
              for (final raw in (result['reviews'] as List).whereType<Map>()) {
                final data = raw['data'] is Map
                    ? Map<String, dynamic>.from(raw['data'] as Map)
                    : Map<String, dynamic>.from(raw);
                final designId = data['design_id']?.toString().trim() ?? '';
                final status = data['status']?.toString().trim().toLowerCase();
                if (designId.isEmpty || latestStatusByDesign.containsKey(designId)) {
                  continue;
                }

                final reviewStatus = switch (status) {
                  'needs_revision' => DesignerDesignStatus.needsRevision,
                  'rejected' => DesignerDesignStatus.rejected,
                  'approved' => DesignerDesignStatus.approved,
                  'published' => DesignerDesignStatus.published,
                  _ => null,
                };
                if (reviewStatus == null) continue;

                var feedback = status == 'needs_revision' || status == 'rejected'
                    ? data['feedback']?.toString().trim()
                    : null;
                // Older duplicate review records sometimes contain generated
                // notification text instead of the original admin feedback.
                if (feedback != null &&
                    (feedback.startsWith('مطلوب تعديل على تصميمك') ||
                        feedback.startsWith('تم رفض تصميمك') ||
                        feedback.startsWith('التصميم «'))) {
                  final separator = feedback.lastIndexOf('»: ');
                  if (separator >= 0) {
                    feedback = feedback.substring(separator + 3).trim();
                  }
                }

                latestStatusByDesign[designId] = reviewStatus;
                latestFeedbackByDesign[designId] =
                    feedback == null || feedback.isEmpty ? null : feedback;
              }

              return designs.map((design) {
                final reviewStatus = latestStatusByDesign[design.id];
                if (reviewStatus == null) {
                  return design.withReviewState(
                    reviewStatus: design.status,
                    feedback: design.rejectionReason,
                  );
                }
                return design.withReviewState(
                  reviewStatus: reviewStatus,
                  feedback: latestFeedbackByDesign[design.id],
                );
              }).toList(growable: false);
            } catch (_) {
              // Preserve the design list if review feedback lookup is temporarily unavailable.
              return designs;
            }
          });
    });

final designerDashboardStatsProvider =
    Provider.autoDispose<DesignerDashboardStats>((ref) {
      final designs =
          ref.watch(designerDesignsProvider).valueOrNull ?? const [];
      return DesignerDashboardStats.fromDesigns(designs);
    });

class DesignerDashboardStats {
  const DesignerDashboardStats({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  final int total;
  final int pending;
  final int approved;
  final int rejected;

  factory DesignerDashboardStats.fromDesigns(
    List<DesignerDesignModel> designs,
  ) {
    return DesignerDashboardStats(
      total: designs.length,
      pending: designs
          .where((design) => design.status == DesignerDesignStatus.pending)
          .length,
      approved: designs
          .where((design) => design.status == DesignerDesignStatus.approved)
          .length,
      rejected: designs
          .where((design) => design.status == DesignerDesignStatus.rejected || design.status == DesignerDesignStatus.needsRevision)
          .length,
    );
  }
}
