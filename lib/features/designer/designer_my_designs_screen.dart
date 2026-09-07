import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/ui/appwrite_image.dart';
import '../auth/domain/entities/auth_user.dart';
import '../auth/domain/repositories/auth_repository.dart';
import 'designer_design_details_screen.dart';
import 'domain/models/designer_design_model.dart';
import 'domain/repositories/designer_design_repository.dart';

class DesignerMyDesignsScreen extends StatelessWidget {
  const DesignerMyDesignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = context.read<AuthRepository>();
    final AuthUser? currentUser = authRepository.currentUser;

    if (currentUser == null) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Text(
              'تعذر تحديد المصمم',
              style: TextStyle(fontFamily: 'Cairo', color: AppTheme.mutedIvory),
            ),
          ),
        ),
      );
    }

    final DesignerDesignRepository repository = context
        .read<DesignerDesignRepository>();

    return StreamBuilder<List<DesignerDesignModel>>(
      stream: repository.watchDesignerDesigns(designerId: currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'خطأ في تحميل التصاميم: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
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
                    fontFamily: 'Cairo',
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
                    fontFamily: 'Cairo',
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

            return Card(
              color: AppTheme.burgundyBlack,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppTheme.divider),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
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
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.warmIvory,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              design.category,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
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
                              fontFamily: 'CormorantGaramond',
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
                                fontFamily: 'Cairo',
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
    );
  }

  Widget _buildStatusBadge(DesignerDesignStatus status) {
    final String label;
    final Color color;
    final Color bgColor;

    switch (status) {
      case DesignerDesignStatus.approved:
        label = 'معتمد';
        color = const Color(0xFF4CAF50);
        bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.15);
        break;

      case DesignerDesignStatus.published:
        label = 'منشور';
        color = const Color(0xFF4CAF50);
        bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.15);
        break;

      case DesignerDesignStatus.rejected:
        label = 'مرفوض';
        color = const Color(0xFFE57373);
        bgColor = const Color(0xFFE57373).withValues(alpha: 0.15);
        break;

      case DesignerDesignStatus.pending:
        label = 'قيد المراجعة';
        color = const Color(0xFFFFB74D);
        bgColor = const Color(0xFFFFB74D).withValues(alpha: 0.15);
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
          fontFamily: 'Cairo',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
