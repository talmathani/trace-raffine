import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';

import 'domain/entities/order.dart';
import 'presentation/providers/order_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  Future<List<Order>> _loadOrders(WidgetRef ref) async {
    final userId = await CurrentUserService.userId;
    if (userId == null) return [];

    return ref.read(orderRepositoryProvider).getOrders(userId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'الطلبات'),
      body: FutureBuilder<List<Order>>(
        future: _loadOrders(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _OrdersLoadingState();
          }

          if (snapshot.hasError) {
            return _OrdersMessageState(
              eyebrow: 'ORDERS',
              title: 'تعذر تحميل الطلبات',
              detail: '${snapshot.error}',
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const _OrdersMessageState(
              eyebrow: 'ARCHIVE',
              title: 'لا توجد طلبات حتى الآن',
              detail: 'ستظهر طلباتك هنا عند إتمام أول عملية.',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsiveContentMaxWidth,
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  context.responsiveHorizontalPadding,
                  context.isCompact ? 22 : 34,
                  context.responsiveHorizontalPadding,
                  56,
                ),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  return _EditorialOrderEntry(index: index, order: order);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EditorialOrderEntry extends StatelessWidget {
  final int index;
  final Order order;

  const _EditorialOrderEntry({required this.index, required this.order});

  @override
  Widget build(BuildContext context) {
    final sequence = (index + 1).toString().padLeft(2, '0');
    final orderId = order.id ?? 'غير معروف';
    final amount = '\$${order.totalAmount.toStringAsFixed(2)}';

    return Padding(
      padding: EdgeInsets.only(bottom: index == 0 ? 28 : 0),
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
                  'ORDER',
                  style: TextStyle(
                    fontFamily: AppTheme.fontTechnical,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.4,
                    color: AppTheme.mutedIvory.withValues(alpha: 0.62),
                    height: 1,
                  ),
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warmIvory,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            orderId,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: AppTheme.fontTechnical,
              fontSize: 25,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: AppTheme.warmIvory,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحالة',
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
                      order.orderStatus,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontArabic,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.softRose,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'TOTAL',
                style: TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                  color: AppTheme.mutedIvory.withValues(alpha: 0.48),
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: AppTheme.divider),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _OrdersLoadingState extends StatelessWidget {
  const _OrdersLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ORDERS',
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
              'جاري تحميل الطلبات',
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

class _OrdersMessageState extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String detail;

  const _OrdersMessageState({
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
