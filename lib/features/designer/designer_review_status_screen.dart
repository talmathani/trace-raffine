import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:trace_raffine/core/ui/appwrite_image.dart';
import 'package:trace_raffine/core/di/app_dependencies.dart';
import 'presentation/providers/designer_dashboard_providers.dart';
import 'domain/models/designer_design_model.dart';

class DesignerReviewStatusScreen extends ConsumerStatefulWidget {
  const DesignerReviewStatusScreen({super.key});

  @override
  ConsumerState<DesignerReviewStatusScreen> createState() =>
      _DesignerReviewStatusScreenState();
}

class _DesignerReviewStatusScreenState
    extends ConsumerState<DesignerReviewStatusScreen> {
  DesignerDesignStatus? _selectedStatus;
  String? _deletingDesignId;

  @override
  Widget build(BuildContext context) {
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
                  _buildSectionTitle(),
                  const SizedBox(height: 12),
                  _buildStatusCard(
                    icon: Icons.pending_actions_rounded,
                    title: 'قيد المراجعة',
                    description:
                        'التصاميم التي أُرسلت للمراجعة ولم يصدر بشأنها قرار بعد.',
                    color: AppTheme.softRose,
                    status: DesignerDesignStatus.pending,
                    designs: designs,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusCard(
                    icon: Icons.edit_note_rounded,
                    title: 'مطلوب تعديل',
                    description:
                        'التصاميم التي أرسلت الإدارة بشأنها ملاحظات تحتاج إلى تنفيذها.',
                    color: AppTheme.softRose,
                    status: DesignerDesignStatus.needsRevision,
                    designs: designs,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'مقبول',
                    description:
                        'التصاميم التي تم اعتمادها وأصبحت مؤهلة للظهور في المنصة.',
                    color: AppTheme.softRose,
                    status: DesignerDesignStatus.approved,
                    designs: designs,
                  ),
                  const SizedBox(height: 12),
                  _buildStatusCard(
                    icon: Icons.cancel_outlined,
                    title: 'مرفوض',
                    description: 'التصاميم التي لم تستوفِ متطلبات المنصة.',
                    color: AppTheme.softRose,
                    status: DesignerDesignStatus.rejected,
                    designs: designs,
                  ),
                  const SizedBox(height: 24),
                  _buildCurrentState(
                    _selectedStatus == null
                        ? designs
                        : designs.where((design) {
                            if (_selectedStatus ==
                                DesignerDesignStatus.approved) {
                              return design.status ==
                                      DesignerDesignStatus.approved ||
                                  design.status ==
                                      DesignerDesignStatus.published;
                            }
                            return design.status == _selectedStatus;
                          }).toList(growable: false),
                  ),
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
    required DesignerDesignStatus status,
    required List<DesignerDesignModel> designs,
  }) {
    final count = status == DesignerDesignStatus.approved
        ? designs
            .where(
              (design) =>
                  design.status == DesignerDesignStatus.approved ||
                  design.status == DesignerDesignStatus.published,
            )
            .length
        : designs.where((design) => design.status == status).length;
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? null : status;
        });
      },
      child: MaisonSurface(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontArabic,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.warmIvory,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.softRose.withValues(alpha: 0.18)
                            : AppTheme.deepBurgundy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontTechnical,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.softRose,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.mutedIvory,
                      size: 20,
                    ),
                  ],
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
    final managerFeedback = design.rejectionReason?.trim();
    final showManagerFeedback =
        design.status == DesignerDesignStatus.needsRevision ||
        design.status == DesignerDesignStatus.rejected;
    final displayedStatus = switch (design.status) {
      DesignerDesignStatus.pending => 'قيد المراجعة',
      DesignerDesignStatus.approved => 'مقبول',
      DesignerDesignStatus.published => 'منشور',
      DesignerDesignStatus.rejected => 'مرفوض',
      DesignerDesignStatus.needsRevision => 'مطلوب تعديل',
    };
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
      DesignerDesignStatus.needsRevision => (
        'مطلوب تعديل',
        Icons.edit_note_rounded,
      ),
    };

    return MaisonSurface(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      radius: AppTheme.editorialListRadius,
      child: Row(
        children: [
          AppwriteImage(
            imageSource: design.designImageUrl,
            width: 76,
            height: 76,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(14),
            errorWidget: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.deepBurgundy,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.divider),
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppTheme.softRose,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.deepBurgundy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(status.$2, color: AppTheme.softRose, size: 21),
          ),
          const SizedBox(width: 12),
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
                  displayedStatus,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 12,
                    height: 1.6,
                    color: AppTheme.softRose,
                  ),
                ),
                if (showManagerFeedback) ...[
                  const SizedBox(height: 7),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.softRose.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      managerFeedback?.isNotEmpty == true
                          ? 'ملاحظات الإدارة: $managerFeedback'
                          : 'ملاحظات الإدارة: لم تصل الملاحظات لهذا التصميم بعد.',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontArabic,
                        fontSize: 12,
                        height: 1.6,
                        color: AppTheme.warmIvory,
                      ),
                    ),
                  ),
                ],
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
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'حذف التصميم',
            onPressed: _deletingDesignId == design.id
                ? null
                : () => _confirmDeleteDesign(design),
            icon: _deletingDesignId == design.id
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.softRose,
                    ),
                  )
                : const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.softRose,
                    size: 21,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteDesign(DesignerDesignModel design) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.burgundyBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'حذف التصميم؟',
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          content: Text(
            'سيتم حذف «${design.title}» نهائيًا من تصاميمك، ولا يمكن التراجع عن هذا الإجراء.',
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 13,
              height: 1.7,
              color: AppTheme.mutedIvory,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: AppTheme.fontArabic,
                  color: AppTheme.mutedIvory,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.deepBurgundy,
                foregroundColor: AppTheme.softRose,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'حذف نهائيًا',
                style: TextStyle(fontFamily: AppTheme.fontArabic),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingDesignId = design.id);
    try {
      final repository = ref.read(designerDesignRepositoryProvider);
      await repository.deleteDesign(
        designId: design.id,
        imagePath: _extractFileId(design.designImageUrl),
        embroideryPath: design.embroideryFileUrl,
      );

      ref.invalidate(designerDesignsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم حذف التصميم بنجاح.',
              style: TextStyle(fontFamily: AppTheme.fontArabic),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر حذف التصميم: $error',
              style: const TextStyle(fontFamily: AppTheme.fontArabic),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _deletingDesignId = null);
      }
    }
  }

  String? _extractFileId(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return null;
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      return normalized;
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null) return normalized;
    final segments = uri.pathSegments;
    final filesIndex = segments.indexOf('files');
    if (filesIndex >= 0 && filesIndex + 1 < segments.length) {
      return segments[filesIndex + 1];
    }
    return normalized;
  }
}
