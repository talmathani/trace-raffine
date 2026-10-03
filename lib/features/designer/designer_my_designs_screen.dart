import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';

import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/appwrite_image.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import '../auth/domain/entities/auth_user.dart';
import '../auth/domain/repositories/auth_repository.dart';
import 'designer_design_details_screen.dart';
import 'domain/models/designer_design_model.dart';
import 'domain/repositories/designer_design_repository.dart';

class DesignerMyDesignsScreen extends StatefulWidget {
  const DesignerMyDesignsScreen({super.key});

  @override
  State<DesignerMyDesignsScreen> createState() =>
      _DesignerMyDesignsScreenState();
}

class _DesignerMyDesignsScreenState extends State<DesignerMyDesignsScreen> {
  Stream<List<DesignerDesignModel>>? _designsStream;

  @override
  void initState() {
    super.initState();
    final AuthRepository authRepository = context.read<AuthRepository>();
    final AuthUser? currentUser = authRepository.currentUser;
    if (currentUser != null) {
      _designsStream = context
          .read<DesignerDesignRepository>()
          .watchDesignerDesigns(designerId: currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_designsStream == null) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Text(
              'تعذر تحديد المصمم',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.mutedIvory,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'مكتبتي'),
      body: StreamBuilder<List<DesignerDesignModel>>(
        stream: _designsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'خطأ في تحميل التصاميم: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    color: AppTheme.softRose,
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBurgundy),
            );
          }

          final List<DesignerDesignModel> designs =
              snapshot.data ?? const <DesignerDesignModel>[];

          if (designs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.design_services_outlined,
                    size: 56,
                    color: AppTheme.softRose,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد تصاميم مرفوعة بعد',
                    style: TextStyle(
                      fontFamily: AppTheme.fontArabic,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmIvory,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'يمكنك رفع أول تصميم لك من تبويب "رفع تصميم".',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontArabic,
                      fontSize: 12,
                      color: AppTheme.mutedIvory,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            itemCount: designs.length,
            itemBuilder: (context, index) {
              final DesignerDesignModel design = designs[index];

              return MaisonSurface(
                margin: const EdgeInsets.only(bottom: 12),
                radius: AppTheme.editorialListRadius,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppTheme.editorialListRadius,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DesignerDesignDetailsScreen(design: design),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.deepBurgundy,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AppwriteImage(
                            imageSource: design.designImageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                design.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontArabic,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.warmIvory,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                design.category,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontArabic,
                                  fontSize: 11,
                                  color: AppTheme.mutedIvory,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildStatusBadge(design.status),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${design.price.toStringAsFixed(2)} \$',
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontEditorial,
                                color: AppTheme.softRose,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.deepBurgundy,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                design.fileExtension.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontArabic,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.warmIvory,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(DesignerDesignStatus status) {
    final String label;
    final Color color;
    final Color bgColor;

    switch (status) {
      case DesignerDesignStatus.approved:
        label = 'معتمد';
        color = AppTheme.softRose;
        bgColor = AppTheme.softRose.withValues(alpha: 0.15);
        break;

      case DesignerDesignStatus.published:
        label = 'منشور';
        color = AppTheme.softRose;
        bgColor = AppTheme.softRose.withValues(alpha: 0.15);
        break;

      case DesignerDesignStatus.rejected:
        label = 'مرفوض';
        color = AppTheme.roseBurgundy;
        bgColor = AppTheme.roseBurgundy.withValues(alpha: 0.15);
        break;

      case DesignerDesignStatus.pending:
        label = 'قيد المراجعة';
        color = AppTheme.mutedIvory;
        bgColor = AppTheme.mutedIvory.withValues(alpha: 0.15);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontArabic,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
