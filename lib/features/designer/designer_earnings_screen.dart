import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import 'domain/models/designer_design_model.dart';
import 'presentation/providers/designer_dashboard_providers.dart';

class DesignerEarningsScreen extends ConsumerWidget {
  const DesignerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(designerDesignsProvider);
    final stats = ref.watch(designerDashboardStatsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة المصمم')),
        body: RefreshIndicator(
          onRefresh: () async => ref.invalidate(designerDesignsProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
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
            'الرصيد المتاح',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.mutedIvory,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '0.00',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 38,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'USD',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'Cairo',
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
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.design_services_outlined,
            title: 'إجمالي التصاميم',
            value: '${stats.total}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.pending_actions_outlined,
            title: 'قيد المراجعة',
            value: '${stats.pending}',
          ),
        ),
      ],
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
                fontFamily: 'Cairo',
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
                    fontFamily: 'Cairo',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.softRose, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppTheme.mutedIvory)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.warmIvory)),
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
      DesignerDesignStatus.approved => ('معتمد', Colors.greenAccent, Icons.check_circle_outline),
      DesignerDesignStatus.published => ('منشور', Colors.greenAccent, Icons.storefront_outlined),
      DesignerDesignStatus.rejected => ('مرفوض', Colors.redAccent, Icons.cancel_outlined),
      DesignerDesignStatus.pending => ('قيد المراجعة', AppTheme.softRose, Icons.pending_actions_outlined),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(design.title.isEmpty ? 'تصميم بلا عنوان' : design.title, style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.warmIvory))),
          Text(label, style: TextStyle(fontFamily: 'Cairo', color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.softRose, size: 44),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.warmIvory)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppTheme.mutedIvory, height: 1.7)),
        ],
      ),
    );
  }
}
