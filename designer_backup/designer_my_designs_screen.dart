import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/repositories/auth_repository.dart';
import 'data/repositories/designer_design_repository.dart';
import 'domain/models/designer_design_model.dart';

class DesignerMyDesignsScreen extends StatelessWidget {
  const DesignerMyDesignsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final currentUser = authRepository.currentUser;

    if (currentUser == null) {
      return const _DesignerMyDesignsUnavailable();
    }

    return _DesignerMyDesignsContent(
      designerId: currentUser.id,
    );
  }
}

class _DesignerMyDesignsContent extends StatelessWidget {
  const _DesignerMyDesignsContent({
    required this.designerId,
  });

  final String designerId;

  @override
  Widget build(BuildContext context) {
    final repository = DesignerDesignRepositoryImpl();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تصاميمي'),
        ),
        body: StreamBuilder<List<DesignerDesignModel>>(
          stream: repository.watchDesignerDesigns(
            designerId: designerId,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorState(
                message: snapshot.error.toString(),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.softRose,
                ),
              );
            }

            final designs = snapshot.data ?? const <DesignerDesignModel>[];

            return _DesignsBody(
              designs: designs,
            );
          },
        ),
      ),
    );
  }
}

class _DesignsBody extends StatelessWidget {
  const _DesignsBody({
    required this.designs,
  });

  final List<DesignerDesignModel> designs;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      color: AppTheme.softRose,
      backgroundColor: AppTheme.burgundyBlack,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildOverviewHeader(),
                  const SizedBox(height: 18),
                  _buildStatusSummary(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (designs.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverToBoxAdapter(
                child: _buildEmptyState(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList.separated(
                itemCount: designs.length,
                itemBuilder: (context, index) {
                  return _DesignCard(
                    design: designs[index],
                  );
                },
                separatorBuilder: (_, _) {
                  return const SizedBox(height: 14);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.deepBurgundy,
            AppTheme.burgundyBlack,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.obsidian.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          _HeaderIcon(),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مكتبة تصاميمك',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'من هنا تتابع تصاميمك وحالة كل ملف قبل ظهوره للعملاء.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
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

  Widget _buildStatusSummary() {
    final pendingCount = designs
        .where(
          (design) => design.status == DesignerDesignStatus.pending,
        )
        .length;

    final approvedCount = designs
        .where(
          (design) => design.status == DesignerDesignStatus.approved,
        )
        .length;

    final rejectedCount = designs
        .where(
          (design) => design.status == DesignerDesignStatus.rejected,
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatusSummaryCard(
            icon: Icons.hourglass_top_rounded,
            title: 'قيد المراجعة',
            count: pendingCount,
            color: AppTheme.softRose,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusSummaryCard(
            icon: Icons.verified_rounded,
            title: 'مقبول',
            count: approvedCount,
            color: const Color(0xFF75B798),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusSummaryCard(
            icon: Icons.cancel_outlined,
            title: 'مرفوض',
            count: rejectedCount,
            color: const Color(0xFFD47A7A),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'جميع التصاميم',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
        ),
        Icon(
          Icons.tune_rounded,
          color: AppTheme.softRose,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.design_services_outlined,
            color: AppTheme.softRose,
            size: 52,
          ),
          SizedBox(height: 18),
          Text(
            'لا توجد تصاميم بعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'عند إرسال أول تصميم للمراجعة سيظهر هنا، '
            'وستتمكن من متابعة حالته حتى اعتماده ونشره.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.mutedIvory,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.obsidian.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppTheme.softRose.withValues(alpha: 0.22),
        ),
      ),
      child: const Icon(
        Icons.design_services_rounded,
        color: AppTheme.softRose,
        size: 30,
      ),
    );
  }
}

class _StatusSummaryCard extends StatelessWidget {
  const _StatusSummaryCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 21,
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: AppTheme.mutedIvory,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignCard extends StatelessWidget {
  const _DesignCard({
    required this.design,
  });

  final DesignerDesignModel design;

  @override
  Widget build(BuildContext context) {
    final status = _statusConfiguration(design.status);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppTheme.deepBurgundy,
                      AppTheme.burgundyBlack,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.divider,
                  ),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: AppTheme.softRose,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      design.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warmIvory,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      design.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.mutedIvory,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(
                label: status.label,
                color: status.color,
                icon: status.icon,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: AppTheme.obsidian.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.insert_drive_file_outlined,
                    label: 'الصيغة',
                    value: design.fileExtension.toUpperCase(),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.payments_outlined,
                    label: 'السعر',
                    value: design.price.toStringAsFixed(2),
                  ),
                ),
                if (design.submittedAt != null)
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'الإرسال',
                      value: _formatDate(design.submittedAt!),
                    ),
                  ),
              ],
            ),
          ),
          if (design.status == DesignerDesignStatus.rejected &&
              design.rejectionReason != null &&
              design.rejectionReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFD47A7A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFD47A7A).withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFD47A7A),
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      design.rejectionReason!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.mutedIvory,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusConfiguration _statusConfiguration(
    DesignerDesignStatus status,
  ) {
    switch (status) {
      case DesignerDesignStatus.pending:
        return const _StatusConfiguration(
          label: 'قيد المراجعة',
          color: AppTheme.softRose,
          icon: Icons.hourglass_top_rounded,
        );
      case DesignerDesignStatus.approved:
        return const _StatusConfiguration(
          label: 'مقبول',
          color: Color(0xFF75B798),
          icon: Icons.verified_rounded,
        );
      case DesignerDesignStatus.rejected:
        return const _StatusConfiguration(
          label: 'مرفوض',
          color: Color(0xFFD47A7A),
          icon: Icons.cancel_outlined,
        );
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _StatusConfiguration {
  const _StatusConfiguration({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.softRose,
          size: 17,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 9,
            color: AppTheme.mutedText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.warmIvory,
          ),
        ),
      ],
    );
  }
}

class _DesignerMyDesignsUnavailable extends StatelessWidget {
  const _DesignerMyDesignsUnavailable();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Text(
            'تعذر تحديد المصمم الحالي.',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppTheme.warmIvory,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFD47A7A),
              size: 48,
            ),
            const SizedBox(height: 14),
            const Text(
              'تعذر تحميل التصاميم',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppTheme.mutedIvory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
