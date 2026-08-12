import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class DesignerEarningsScreen extends StatelessWidget {
  const DesignerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأرباح'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 18),
            _buildSummary(),
            const SizedBox(height: 24),
            _buildSectionTitle(),
            const SizedBox(height: 12),
            _buildEmptyTransactions(),
          ],
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

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.trending_up_rounded,
            title: 'إجمالي الأرباح',
            value: '0.00 USD',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.shopping_bag_outlined,
            title: 'المبيعات',
            value: '0',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return const Text(
      'آخر العمليات',
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppTheme.warmIvory,
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 44,
      ),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: AppTheme.softRose,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد عمليات مالية بعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'ستظهر المبيعات والأرباح هنا بعد اعتماد التصاميم وبيعها.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
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
          Icon(
            icon,
            color: AppTheme.softRose,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppTheme.mutedIvory,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
        ],
      ),
    );
  }
}
