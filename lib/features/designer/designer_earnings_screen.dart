import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'domain/models/designer_design_model.dart';
import 'presentation/providers/designer_dashboard_providers.dart';
import 'designer_notifications_screen.dart';
import 'designer_review_status_screen.dart';

class DesignerEarningsScreen extends ConsumerWidget {
  const DesignerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(designerDesignsProvider);
    final stats = ref.watch(designerDashboardStatsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: MaisonAppBar(
          title: 'استوديو المصمم',
          actions: [
            IconButton(
              tooltip: 'الإشعارات',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DesignerNotificationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              tooltip: 'حالة المراجعة',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DesignerReviewStatusScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.fact_check_outlined),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => ref.invalidate(designerDesignsProvider),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsiveContentMaxWidth,
              ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  context.responsiveHorizontalPadding,
                  context.isCompact ? 16 : 24,
                  context.responsiveHorizontalPadding,
                  40,
                ),
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 18),
                  _buildStats(stats),
                  const SizedBox(height: 24),
                  _buildDesignStatusSection(designsAsync, stats),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.deepBurgundy,
            AppTheme.primaryBurgundy,
            AppTheme.burgundyBlack,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مساحة عمل المصمم',
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 13,
              color: AppTheme.mutedIvory,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'ATELIER',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: AppTheme.fontEditorial,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'DESIGN · REVIEW · STATUS',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.softRose,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(DesignerDashboardStats stats) {
    final cards = [
      _SummaryCard(
        icon: Icons.design_services_outlined,
        title: 'إجمالي التصاميم',
        value: '${stats.total}',
      ),
      _SummaryCard(
        icon: Icons.pending_actions_outlined,
        title: 'قيد المراجعة',
        value: '${stats.pending}',
      ),
    ];

    return contextResponsiveWrap(cards);
  }

  Widget contextResponsiveWrap(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.compact) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                children[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDesignStatusSection(
    AsyncValue<List<DesignerDesignModel>> designsAsync,
    DesignerDashboardStats stats,
  ) {
    return designsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _MessageCard(
        icon: Icons.cloud_off_outlined,
        title: 'تعذر تحميل بيانات التصاميم',
        message: 'تحقق من اتصال Appwrite ثم اسحب الشاشة لإعادة المحاولة.',
      ),
      data: (designs) {
        if (designs.isEmpty) {
          return const _MessageCard(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد تصاميم بعد',
            message: 'ستظهر حالات تصاميمك هنا بعد رفع أول تصميم.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة التصاميم',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
              ),
            ),
            const SizedBox(height: 12),
            ...designs.take(10).map(_DesignStatusTile.new),
            if (stats.rejected > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'لديك ${stats.rejected} تصميم مرفوض يحتاج إلى مراجعة.',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    color: AppTheme.softRose,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MaisonSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.softRose, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 11,
              color: AppTheme.mutedIvory,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignStatusTile extends StatelessWidget {
  const _DesignStatusTile(this.design);

  final DesignerDesignModel design;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (design.status) {
      DesignerDesignStatus.approved => (
        'معتمد',
        AppTheme.statusSuccess,
        Icons.check_circle_outline,
      ),
      DesignerDesignStatus.published => (
        'منشور',
        AppTheme.statusSuccess,
        Icons.storefront_outlined,
      ),
      DesignerDesignStatus.rejected => (
        'مرفوض',
        AppTheme.statusRejected,
        Icons.cancel_outlined,
      ),
      DesignerDesignStatus.pending => (
        'قيد المراجعة',
        AppTheme.softRose,
        Icons.pending_actions_outlined,
      ),
    };

    return MaisonSurface(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: AppTheme.editorialListRadius,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              design.title.isEmpty ? 'تصميم بلا عنوان' : design.title,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.warmIvory,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaisonSurface(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      radius: AppTheme.editorialPanelRadius,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.softRose, size: 44),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 12,
              color: AppTheme.mutedIvory,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
