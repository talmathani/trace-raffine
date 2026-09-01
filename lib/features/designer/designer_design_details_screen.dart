import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/ui/appwrite_image.dart';
import 'domain/models/designer_design_model.dart';

class DesignerDesignDetailsScreen extends StatelessWidget {
  const DesignerDesignDetailsScreen({super.key, required this.design});

  final DesignerDesignModel design;

  @override
  Widget build(BuildContext context) {
    final status = _statusConfiguration(design.status);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل التصميم')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildImage()),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(status, compact: !isWide),
                          const SizedBox(height: 18),
                          _buildTechnicalDetails(),
                          if (_hasValue(design.description)) ...[
                            const SizedBox(height: 18),
                            _buildDescription(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImage(compact: !isWide),
                  const SizedBox(height: 18),
                  _buildHeader(status, compact: !isWide),
                  const SizedBox(height: 18),
                  _buildTechnicalDetails(),
                  if (_hasValue(design.description)) ...[
                    const SizedBox(height: 18),
                    _buildDescription(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage({bool compact = false}) {
    final imageUrl = design.designImageUrl?.trim();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: compact ? 260 : 420,
        maxHeight: compact ? 460 : 720,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.divider),
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? const Center(
              child: Icon(
                Icons.image_outlined,
                color: AppTheme.softRose,
                size: 64,
              ),
            )
          : InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(24),
              child: AppwriteImage(
                imageSource: imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
    );
  }

  Widget _buildHeader(_StatusConfiguration status, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            design.title.isEmpty ? 'بدون عنوان' : design.title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: compact ? 19 : 21,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            design.category,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppTheme.mutedIvory,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _Badge(
                icon: status.icon,
                label: status.label,
                color: status.color,
              ),
              Text(
                design.price.toStringAsFixed(2),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: compact ? 17 : 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.softRose,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.softRose,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'بيانات التنفيذ',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmIvory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.insert_drive_file_outlined,
            title: 'صيغة الملف',
            value: design.fileExtension.toUpperCase(),
          ),
          if (_hasValue(design.stitchDetails))
            _DetailRow(
              icon: Icons.route_rounded,
              title: 'الغرز',
              value: design.stitchDetails!,
            ),
          if (_hasValue(design.beadDetails))
            _DetailRow(
              icon: Icons.circle_outlined,
              title: 'الخرز',
              value: design.beadDetails!,
            ),
          if (_hasValue(design.sequinDetails))
            _DetailRow(
              icon: Icons.stars_rounded,
              title: 'الترتر',
              value: design.sequinDetails!,
            ),
          if (_hasValue(design.additionalDetails))
            _DetailRow(
              icon: Icons.notes_rounded,
              title: 'ملاحظات',
              value: design.additionalDetails!,
            ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الوصف',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            design.description!,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppTheme.mutedIvory,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  _StatusConfiguration _statusConfiguration(DesignerDesignStatus status) {
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
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.softRose, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.mutedIvory,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppTheme.warmIvory,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
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
