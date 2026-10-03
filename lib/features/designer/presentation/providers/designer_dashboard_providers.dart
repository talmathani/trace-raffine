import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/appwrite/appwrite_service.dart';
import 'package:trace_raffine/core/di/app_dependencies.dart';
import '../../domain/models/designer_design_model.dart';

final designerDesignsProvider =
    StreamProvider.autoDispose<List<DesignerDesignModel>>((ref) async* {
      final user = await AppwriteService.account.get();
      final repository = ref.watch(designerDesignRepositoryProvider);
      yield* repository.watchDesignerDesigns(designerId: user.$id);
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
          .where((design) => design.status == DesignerDesignStatus.rejected)
          .length,
    );
  }
}
