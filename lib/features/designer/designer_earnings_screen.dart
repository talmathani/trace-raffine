import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:trace_raffine/core/appwrite/appwrite_service.dart';
import 'package:trace_raffine/core/functions/function_invoker.dart';
import '../orders/domain/entities/order.dart';
import 'domain/models/designer_design_model.dart';
import 'presentation/providers/designer_dashboard_providers.dart';

final designerEarningsFinancialsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = await AppwriteService.account.get();
  final result = await FunctionInvoker.create().listDesignerFinancials(userId: user.$id);
  if (result['success'] != true) {
    throw StateError(result['error']?.toString() ?? 'تعذر تحميل البيانات المالية.');
  }
  return result;
});

final designerEarningsOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final user = await AppwriteService.account.get();
  final result = await ref.watch(designerEarningsFinancialsProvider.future);
  if (result['success'] != true) {
    throw StateError(result['error']?.toString() ?? 'تعذر تحميل مبيعات المصمم.');
  }
  final rawSales = result['sales'];
  if (rawSales is! List) return const <Order>[];
  return rawSales.whereType<Map>().map((sale) {
    return Order.fromJson({
      r'$id': sale['orderId'],
      'user_id': user.$id,
      'design_id': sale['productId'],
      'designer_id': user.$id,
      'total_amount': sale['grossAmount'] ?? 0,
      'currency': sale['currency'],
      'payment_status': 'paid',
      'order_status': sale['status'] == 'settled' ? 'completed' : 'pending',
      'created_at': sale['createdAt'],
    });
  }).toList(growable: false);
});

class DesignerEarningsScreen extends ConsumerWidget {
  const DesignerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(designerEarningsOrdersProvider);
    final designsAsync = ref.watch(designerDesignsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const MaisonAppBar(title: 'أرباح المصمم'),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(designerEarningsOrdersProvider);
            ref.invalidate(designerDesignsProvider);
            await ref.read(designerEarningsOrdersProvider.future);
          },
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsiveContentMaxWidth,
              ),
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(context.responsiveHorizontalPadding),
                  children: [
                    const SizedBox(height: 100),
                    _MessageCard(
                      icon: Icons.cloud_off_outlined,
                      title: 'تعذر تحميل الأرباح',
                      message: error.toString().replaceFirst('Bad state: ', ''),
                    ),
                  ],
                ),
                data: (orders) => _EarningsOverview(
                  orders: orders,
                  designsAsync: designsAsync,
                  financials: ref.watch(designerEarningsFinancialsProvider),
                  onFinancialAction: () => ref.invalidate(designerEarningsFinancialsProvider),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }








}

class _EarningsOverview extends StatelessWidget {
  const _EarningsOverview({
    required this.orders,
    required this.designsAsync,
    required this.financials,
    required this.onFinancialAction,
  });

  final List<Order> orders;
  final AsyncValue<List<DesignerDesignModel>> designsAsync;
  final AsyncValue<Map<String, dynamic>> financials;
  final VoidCallback onFinancialAction;

  @override
  Widget build(BuildContext context) {
    final completed = orders.where(_earningsOrderCompleted).toList(growable: false);
    final pending = orders.where((order) => !_earningsOrderCompleted(order)).toList(growable: false);
    final totalSales = orders.fold<double>(0, (sum, order) => sum + order.totalAmount);
    final earnings = completed.fold<double>(0, (sum, order) => sum + order.totalAmount);
    final pendingAmount = pending.fold<double>(0, (sum, order) => sum + order.totalAmount);
    final currency = _earningsCurrency(orders);
    final titles = <String, String>{
      for (final design in designsAsync.valueOrNull ?? const [])
        design.id: design.title.isEmpty ? 'تصميم بلا عنوان' : design.title,
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.responsiveHorizontalPadding,
        context.isCompact ? 16 : 24,
        context.responsiveHorizontalPadding,
        40,
      ),
      children: [
        _EarningsHero(amount: earnings, currency: currency, count: completed.length),
        const SizedBox(height: 12),
        financials.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (data) => _FinancialLayerCard(
            data: data,
            currency: currency,
            onChanged: onFinancialAction,
          ),
        ),
        const SizedBox(height: 16),
        _EarningsSummary(
          totalSales: totalSales,
          earnings: earnings,
          pending: pendingAmount,
          currency: currency,
        ),
        const SizedBox(height: 24),
        const _EarningsSectionTitle(
          title: 'الأداء الشهري',
          subtitle: 'المبيعات المكتملة خلال آخر ستة أشهر',
        ),
        const SizedBox(height: 12),
        _EarningsBars(values: _earningsMonthly(completed)),
        const SizedBox(height: 24),
        const _EarningsSectionTitle(
          title: 'الأرباح حسب التصميم',
          subtitle: 'أكثر التصاميم تحقيقاً للمبيعات',
        ),
        const SizedBox(height: 12),
        _EarningsDesigns(
          orders: completed,
          titles: titles,
          currency: currency,
        ),
        const SizedBox(height: 24),
        const _EarningsSectionTitle(
          title: 'آخر العمليات',
          subtitle: 'الطلبات المرتبطة بمبيعات تصاميمك',
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const _MessageCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'لا توجد أرباح مسجلة بعد',
            message: 'ستظهر المبيعات هنا بعد إتمام أول طلب مرتبط بتصميمك.',
          )
        else
          ...orders.take(10).map(
            (order) => _EarningsTransaction(
              order: order,
              title: titles[order.designId] ?? 'تصميم',
              currency: currency,
            ),
          ),
        const SizedBox(height: 24),
        const _EarningsSettlementNotice(),
      ],
    );
  }
}

class _FinancialLayerCard extends StatelessWidget {
  const _FinancialLayerCard({
    required this.data,
    required this.currency,
    required this.onChanged,
  });

  final Map<String, dynamic> data;
  final String currency;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final configured = data['configured'] == true;
    final gross = (data['grossSales'] as num?)?.toDouble() ?? 0;
    final settled = (data['settledEarnings'] as num?)?.toDouble() ?? 0;
    final available = (data['availableBalance'] as num?)?.toDouble() ?? 0;
    final pending = (data['pendingSales'] as num?)?.toDouble() ?? 0;
    final rate = (data['commissionRate'] as num?)?.toDouble();

    return MaisonSurface(
      padding: const EdgeInsets.all(18),
      radius: AppTheme.editorialPanelRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الطبقة المالية الفعلية', style: TextStyle(fontFamily: AppTheme.fontArabic, fontWeight: FontWeight.w700, color: AppTheme.warmIvory)),
          const SizedBox(height: 12),
          _financialLine('إجمالي المبيعات', gross, currency),
          if (configured) ...[
            const SizedBox(height: 6),
            _financialLine('صافي أرباح المصمم', settled, currency),
            const SizedBox(height: 6),
            _financialLine('الرصيد القابل للسحب', available, currency, strong: true),
            if (rate != null) ...[
              const SizedBox(height: 6),
              Text('عمولة المنصة: ${rate.toStringAsFixed(2)}%', style: const TextStyle(fontFamily: AppTheme.fontArabic, fontSize: 11, color: AppTheme.mutedIvory)),
            ],
          ] else ...[
            const SizedBox(height: 8),
            Text('التسوية المالية لم تُضبط بعد؛ لا يتم افتراض نسبة عمولة.', style: const TextStyle(fontFamily: AppTheme.fontArabic, fontSize: 11, height: 1.6, color: AppTheme.softRose)),
          ],
          if (pending > 0) ...[
            const SizedBox(height: 6),
            Text('مبيعات بانتظار التسوية: ${_earningsMoney(pending)} $currency', style: const TextStyle(fontFamily: AppTheme.fontArabic, fontSize: 11, color: AppTheme.mutedIvory)),
          ],
          if (configured && available > 0 && data['minimumWithdrawal'] is num) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDesignerWithdrawalDialog(
                  context,
                  available: available,
                  minimum: (data['minimumWithdrawal'] as num).toDouble(),
                  currency: currency,
                  onChanged: onChanged,
                ),
                icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                label: const Text('طلب سحب الأرباح'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _financialLine(String label, double value, String currency, {bool strong = false}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(fontFamily: AppTheme.fontArabic, fontSize: 12, color: strong ? AppTheme.warmIvory : AppTheme.mutedIvory, fontWeight: strong ? FontWeight.w700 : FontWeight.w500))),
        Text('${_earningsMoney(value)} $currency', textDirection: TextDirection.ltr, style: TextStyle(fontFamily: AppTheme.fontArabic, fontSize: 13, color: AppTheme.warmIvory, fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
      ],
    );
  }
}

Future<void> _showDesignerWithdrawalDialog(
  BuildContext context, {
  required double available,
  required double minimum,
  required String currency,
  required VoidCallback onChanged,
}) async {
  final amountController = TextEditingController(text: available.toStringAsFixed(2));
  final methodController = TextEditingController();
  var submitting = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('طلب سحب الأرباح'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(alignment: AlignmentDirectional.centerStart, child: Text('المتاح: ${_earningsMoney(available)} $currency')),
              Align(alignment: AlignmentDirectional.centerStart, child: Text('الحد الأدنى: ${_earningsMoney(minimum)} $currency')),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'مبلغ السحب ($currency)'),
              ),
              const SizedBox(height: 12),
              TextField(controller: methodController, decoration: const InputDecoration(labelText: 'طريقة الدفع', hintText: 'مثال: تحويل بنكي / محفظة')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: submitting ? null : () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: submitting ? null : () async {
              final amount = double.tryParse(amountController.text.trim());
              final method = methodController.text.trim();
              if (amount == null || amount <= 0 || amount < minimum || amount > available || method.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تحقق من المبلغ وطريقة الدفع.')));
                return;
              }
              setState(() => submitting = true);
              try {
                final user = await AppwriteService.account.get();
                final result = await FunctionInvoker.create().requestDesignerWithdrawal(userId: user.$id, amount: amount, method: method, currency: currency);
                if (result['success'] != true) throw StateError(result['error']?.toString() ?? 'تعذر إنشاء طلب السحب.');
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب السحب للمراجعة.')));
                }
                onChanged();
              } catch (error) {
                if (context.mounted) {
                  setState(() => submitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))));
                }
              }
            },
            child: submitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('إرسال الطلب'),
          ),
        ],
      ),
    ),
  );

  amountController.dispose();
  methodController.dispose();
}

class _EarningsHero extends StatelessWidget {
  const _EarningsHero({
    required this.amount,
    required this.currency,
    required this.count,
  });

  final double amount;
  final String currency;
  final int count;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الأرباح المسجلة',
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 13,
              color: AppTheme.mutedIvory,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_earningsMoney(amount)} $currency',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: AppTheme.fontEditorial,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count عملية مكتملة',
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 12,
              color: AppTheme.softRose,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsSummary extends StatelessWidget {
  const _EarningsSummary({
    required this.totalSales,
    required this.earnings,
    required this.pending,
    required this.currency,
  });

  final double totalSales;
  final double earnings;
  final double pending;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        icon: Icons.trending_up_rounded,
        title: 'إجمالي المبيعات',
        value: '${_earningsMoney(totalSales)} $currency',
      ),
      _SummaryCard(
        icon: Icons.payments_outlined,
        title: 'الأرباح المكتملة',
        value: '${_earningsMoney(earnings)} $currency',
      ),
      _SummaryCard(
        icon: Icons.pending_actions_outlined,
        title: 'مبالغ معلقة',
        value: '${_earningsMoney(pending)} $currency',
      ),
    ];

    if (context.isCompact) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            cards[i],
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }
}

class _EarningsSectionTitle extends StatelessWidget {
  const _EarningsSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: 11,
            color: AppTheme.mutedIvory,
          ),
        ),
      ],
    );
  }
}

class _EarningsBars extends StatelessWidget {
  const _EarningsBars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<double>(0, (max, value) => value > max ? value : max);

    return MaisonSurface(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      radius: AppTheme.editorialPanelRadius,
      child: SizedBox(
        height: 180,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _earningsMoney(values[i]),
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontArabic,
                          fontSize: 9,
                          color: AppTheme.mutedIvory,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FractionallySizedBox(
                        heightFactor: maxValue == 0 ? 0.02 : (values[i] / maxValue).clamp(0.02, 1.0),
                        widthFactor: 0.55,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBurgundy,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.divider),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _earningsMonthLabel(i),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontArabic,
                          fontSize: 9,
                          color: AppTheme.mutedIvory,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EarningsDesigns extends StatelessWidget {
  const _EarningsDesigns({
    required this.orders,
    required this.titles,
    required this.currency,
  });

  final List<Order> orders;
  final Map<String, String> titles;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Order>>{};
    for (final order in orders) {
      final key = order.designId ?? order.id ?? 'unknown';
      grouped.putIfAbsent(key, () => <Order>[]).add(order);
    }

    if (grouped.isEmpty) {
      return const _MessageCard(
        icon: Icons.design_services_outlined,
        title: 'لا توجد مبيعات مكتملة',
        message: 'ستظهر التصاميم هنا بعد تسجيل أول عملية بيع مكتملة.',
      );
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => _earningsSum(b.value).compareTo(_earningsSum(a.value)));

    return Column(
      children: [
        for (final entry in entries.take(10))
          MaisonSurface(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            radius: AppTheme.editorialListRadius,
            child: Row(
              children: [
                const Icon(Icons.design_services_outlined, color: AppTheme.softRose),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titles[entry.key] ?? 'تصميم',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontArabic,
                      color: AppTheme.warmIvory,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_earningsMoney(_earningsSum(entry.value))} $currency',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontArabic,
                        color: AppTheme.warmIvory,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${entry.value.length} مبيعات',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontArabic,
                        fontSize: 10,
                        color: AppTheme.mutedIvory,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EarningsTransaction extends StatelessWidget {
  const _EarningsTransaction({
    required this.order,
    required this.title,
    required this.currency,
  });

  final Order order;
  final String title;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final completed = _earningsOrderCompleted(order);
    final color = completed ? AppTheme.statusSuccess : AppTheme.softRose;

    return MaisonSurface(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: AppTheme.editorialListRadius,
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle_outline : Icons.pending_actions_outlined,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    color: AppTheme.warmIvory,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _earningsDate(order.completedAt ?? order.createdAt),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 10,
                    color: AppTheme.mutedIvory,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_earningsMoney(order.totalAmount)} $currency',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsSettlementNotice extends StatelessWidget {
  const _EarningsSettlementNotice();

  @override
  Widget build(BuildContext context) {
    return MaisonSurface(
      padding: const EdgeInsets.all(18),
      radius: AppTheme.editorialPanelRadius,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_outlined, color: AppTheme.softRose),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'السحب والرصيد القابل للسحب لن يتم احتسابهما قبل إضافة سجل العمولات والتسويات وطلبات السحب. بهذه الطريقة لا نعرض رقماً مالياً غير موثق.',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 11,
                height: 1.7,
                color: AppTheme.mutedIvory,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _earningsOrderCompleted(Order order) {
  final payment = order.paymentStatus.trim().toLowerCase();
  final status = order.orderStatus.trim().toLowerCase();
  const completed = {'paid', 'succeeded', 'success', 'completed', 'complete', 'delivered'};
  return completed.contains(payment) || completed.contains(status);
}

String _earningsCurrency(List<Order> orders) {
  for (final order in orders) {
    final value = order.currency?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return 'USD';
}

double _earningsSum(List<Order> orders) =>
    orders.fold<double>(0, (sum, order) => sum + order.totalAmount);

List<double> _earningsMonthly(List<Order> orders) {
  final now = DateTime.now();
  final values = List<double>.filled(6, 0);
  for (final order in orders) {
    final date = order.completedAt ?? order.createdAt;
    if (date == null) continue;
    final monthIndex = (now.year - date.year) * 12 + now.month - date.month;
    if (monthIndex >= 0 && monthIndex < 6) {
      values[5 - monthIndex] += order.totalAmount;
    }
  }
  return values;
}

String _earningsMonthLabel(int index) {
  final date = DateTime(DateTime.now().year, DateTime.now().month - (5 - index));
  return '${date.month}/';
}

String _earningsMoney(double value) => value.toStringAsFixed(2);

String _earningsDate(DateTime? date) {
  if (date == null) return 'بدون تاريخ';
  return '//';
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
