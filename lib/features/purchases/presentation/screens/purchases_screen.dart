import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/functions/function_invoker.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';

import '../../domain/entities/purchase.dart';
import '../providers/purchase_providers.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  Future<List<Purchase>> _loadPurchases(WidgetRef ref) async {
    final userId = await CurrentUserService.userId;
    if (userId == null) return [];

    return ref.read(purchaseRepositoryProvider).getPurchases(userId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'مشترياتي'),
      body: FutureBuilder<List<Purchase>>(
        future: _loadPurchases(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _PurchasesLoadingState();
          }

          if (snapshot.hasError) {
            return _PurchasesMessageState(
              eyebrow: 'ARCHIVE',
              title: 'تعذر تحميل المشتريات',
              detail: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
            );
          }

          final purchases = snapshot.data ?? [];

          if (purchases.isEmpty) {
            return const _PurchasesMessageState(
              eyebrow: 'ARCHIVE',
              title: 'لا توجد مشتريات حتى الآن',
              detail: 'ستظهر التصاميم المقتناة هنا بعد إتمام عملية الشراء.',
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 56),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];

              return _EditorialPurchaseEntry(index: index, purchase: purchase);
            },
          );
        },
      ),
    );
  }
}

class _EditorialPurchaseEntry extends StatelessWidget {
  final int index;
  final Purchase purchase;

  const _EditorialPurchaseEntry({required this.index, required this.purchase});

  Future<void> _download(BuildContext context) async {
    final userId = await CurrentUserService.userId;
    if (userId == null || userId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول لتنزيل التصميم.')),
        );
      }
      return;
    }

    try {
      final result = await FunctionInvoker.create().getPurchasedFile(
        userId: userId,
        productId: purchase.productId,
      );
      if (result['success'] != true) {
        throw StateError(
          result['error']?.toString() ?? 'تعذر تجهيز ملف التصميم.',
        );
      }

      final rawUrl = result['downloadUrl']?.toString().trim() ?? '';
      final uri = Uri.tryParse(rawUrl);
      if (uri == null || !uri.hasScheme) {
        throw StateError('رابط التنزيل غير صالح.');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw StateError('تعذر فتح رابط التنزيل.');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تنزيل ملف التصميم: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sequence = (index + 1).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sequence,
                style: const TextStyle(
                  fontFamily: AppTheme.fontEditorial,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.softRose,
                  height: 1,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'ARCHIVE',
                  style: TextStyle(
                    fontFamily: AppTheme.fontTechnical,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.6,
                    color: AppTheme.mutedIvory.withValues(alpha: 0.62),
                    height: 1,
                  ),
                ),
              ),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.softRose,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'DESIGN',
            style: TextStyle(
              fontFamily: AppTheme.fontTechnical,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppTheme.mutedIvory.withValues(alpha: 0.48),
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            purchase.productId,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: AppTheme.fontTechnical,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: AppTheme.warmIvory,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الطلب',
                      style: TextStyle(
                        fontFamily: AppTheme.fontArabic,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.mutedIvory.withValues(alpha: 0.62),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      purchase.orderId,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontTechnical,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'ACQUIRED',
                style: TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                  color: AppTheme.softRose.withValues(alpha: 0.72),
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          EditorialButton(
            onPressed: () => _download(context),
            label: 'تنزيل ملف التصميم',
            icon: const Icon(Icons.download_rounded),
            variant: EditorialButtonVariant.secondary,
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: AppTheme.divider),
        ],
      ),
    );
  }
}

class _PurchasesLoadingState extends StatelessWidget {
  const _PurchasesLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ARCHIVE',
              style: TextStyle(
                fontFamily: AppTheme.fontTechnical,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: AppTheme.softRose.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 54,
              height: 1,
              color: AppTheme.softRose.withValues(alpha: 0.58),
            ),
            const SizedBox(height: 16),
            const Text(
              'جاري تحميل المشتريات',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedIvory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchasesMessageState extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String detail;

  const _PurchasesMessageState({
    required this.eyebrow,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              eyebrow,
              style: TextStyle(
                fontFamily: AppTheme.fontTechnical,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: AppTheme.softRose.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.secondaryText,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
