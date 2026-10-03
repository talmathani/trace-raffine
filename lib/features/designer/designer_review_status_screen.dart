import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'presentation/providers/designer_dashboard_providers.dart';
import 'domain/models/designer_design_model.dart';

class DesignerReviewStatusScreen extends ConsumerWidget {
  const DesignerReviewStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(designerDesignsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: MaisonAppBar(title: 'حالة المراجعة'),
        body: designsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.softRose),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'تعذر تحميل حالات المراجعة: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontArabic,
                  color: AppTheme.softRose,
                ),
              ),
            ),
          ),
          data: (designs) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsiveContentMaxWidth,
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.responsiveHorizontalPadding,
                  context.isCompact ? 16 : 24,
                  context.responsiveHorizontalPadding,
                  40,
                ),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildOverview(designs),
                  const SizedBox(height: 20),
                  _buildSectionTitle(),
                  const SizedBox(height: 12),
                  _buildStatusCard(
                    icon: Icons.pending_actions_rounded,
                    title: 'قيد المراجعة',
                    description:
                        'التصاميم التي أُرسلت للمراجعة ولم يصدر بشأنها قرار بعد.',
                    color: AppTheme.softRose,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'مقبول',
                    description:
                        'التصاميم التي تم اعتمادها وأصبحت مؤهلة للظهور في المنصة.',
                    color: AppTheme.softRose,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusCard(
                    icon: Icons.cancel_outlined,
                    title: 'مرفوض',
                    description: 'التصاميم التي لم تستوفِ متطلبات المنصة.',
                    color: AppTheme.softRose,
                  ),
                  const SizedBox(height: 24),
                  _buildCurrentState(designs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppTheme.deepBurgundy, AppTheme.burgundyBlack],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Row(
        children: [
          Icon(Icons.fact_check_rounded, color: AppTheme.softRose, size: 34),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متابعة التصاميم',
                  style: TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'تابع حالة التصاميم التي أرسلتها للمراجعة واعرف آخر تحديث عليها.',
                  style: TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 12,
                    color: AppTheme.mutedIvory,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(List<DesignerDesignModel> designs) {
    final pending = designs
        .where((design) => design.status == DesignerDesignStatus.pending)
        .length;
    final approved = designs
        .where(
          (design) =>
              design.status == DesignerDesignStatus.approved ||
              design.status == DesignerDesignStatus.published,
        )
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewItem(
              icon: Icons.upload_file_rounded,
              value: designs.length.toString(),
              label: 'إجمالي التصاميم',
            ),
          ),
          const _OverviewDivider(),
          Expanded(
            child: _OverviewItem(
              icon: Icons.pending_actions_rounded,
              value: pending.toString(),
              label: 'قيد المراجعة',
            ),
          ),
          const _OverviewDivider(),
          Expanded(
            child: _OverviewItem(
              icon: Icons.check_circle_outline_rounded,
              value: approved.toString(),
              label: 'مقبولة',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Row(
      children: [
        Icon(Icons.filter_list_rounded, color: AppTheme.softRose, size: 21),
        SizedBox(width: 9),
        Text(
          'حالات المراجعة',
          style: TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return MaisonSurface(
      padding: const EdgeInsets.all(18),
      radius: AppTheme.editorialPanelRadius,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.deepBurgundy,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 12,
                    color: AppTheme.mutedIvory,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentState(List<DesignerDesignModel> designs) {
    if (designs.isEmpty) {
      return MaisonSurface(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
        radius: AppTheme.editorialPanelRadius,
        color: AppTheme.deepBurgundy,
        child: const Column(
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              color: AppTheme.softRose,
              size: 44,
            ),
            SizedBox(height: 14),
            Text(
              'لا توجد مراجعات حالية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'عند إرسال تصميم جديد سيظهر هنا مع حالته وتفاصيل آخر تحديث.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 12,
                color: AppTheme.mutedIvory,
                height: 1.8,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: designs.map(_buildDesignEntry).toList(growable: false),
    );
  }

  Widget _buildDesignEntry(DesignerDesignModel design) {
    final status = switch (design.status) {
      DesignerDesignStatus.pending => (
        'قيد المراجعة',
        Icons.pending_actions_rounded,
      ),
      DesignerDesignStatus.approved => (
        'مقبول',
        Icons.check_circle_outline_rounded,
      ),
      DesignerDesignStatus.published => ('منشور', Icons.public_rounded),
      DesignerDesignStatus.rejected => ('مرفوض', Icons.cancel_outlined),
    };

    return MaisonSurface(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      radius: AppTheme.editorialListRadius,
      child: Row(
        children: [
          Icon(status.$2, color: AppTheme.softRose, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  design.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  status.$1,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 12,
                    color: AppTheme.softRose,
                  ),
                ),
              ],
            ),
          ),
          Text(
            design.price.toStringAsFixed(2),
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: AppTheme.fontTechnical,
              fontSize: 14,
              color: AppTheme.mutedIvory,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.softRose, size: 22),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppTheme.fontTechnical,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: 10,
            color: AppTheme.mutedIvory,
          ),
        ),
      ],
    );
  }
}

class _OverviewDivider extends StatelessWidget {
  const _OverviewDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 55, color: AppTheme.divider);
  }
}
