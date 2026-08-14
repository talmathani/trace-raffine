import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AdministrationNavigation extends StatefulWidget {
  const AdministrationNavigation({super.key});

  @override
  State<AdministrationNavigation> createState() =>
      _AdministrationNavigationState();
}

class _AdministrationNavigationState extends State<AdministrationNavigation> {
  int _currentIndex = 0;

  static const List<_AdminDestination> _destinations = [
    _AdminDestination(
      label: 'الرئيسية',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _AdminDestination(
      label: 'الطلبات',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _AdminDestination(
      label: 'التصاميم',
      icon: Icons.design_services_outlined,
      selectedIcon: Icons.design_services_rounded,
    ),
    _AdminDestination(
      label: 'المصممون',
      icon: Icons.draw_outlined,
      selectedIcon: Icons.draw_rounded,
    ),
    _AdminDestination(
      label: 'العملاء',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
    ),
    _AdminDestination(
      label: 'المراجعات',
      icon: Icons.fact_check_outlined,
      selectedIcon: Icons.fact_check_rounded,
    ),
  ];

  static const List<Widget> _pages = [
    _AdministrationDashboard(),
    _AdminPlaceholder(
      title: 'الطلبات',
      subtitle: 'إدارة الطلبات ومتابعة حالتها.',
      icon: Icons.receipt_long_rounded,
    ),
    _AdminPlaceholder(
      title: 'التصاميم',
      subtitle: 'إدارة ومراجعة مكتبة التصاميم.',
      icon: Icons.design_services_rounded,
    ),
    _AdminPlaceholder(
      title: 'المصممون',
      subtitle: 'إدارة حسابات المصممين ومحتواهم.',
      icon: Icons.draw_rounded,
    ),
    _AdminPlaceholder(
      title: 'العملاء',
      subtitle: 'إدارة حسابات العملاء.',
      icon: Icons.people_rounded,
    ),
    _AdminPlaceholder(
      title: 'المراجعات',
      subtitle: 'مراجعة التصاميم والطلبات المعلقة.',
      icon: Icons.fact_check_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.obsidian,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            if (index == _currentIndex) {
              return;
            }

            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            for (final destination in _destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _AdministrationDashboard extends StatelessWidget {
  const _AdministrationDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(
        title: const Text('مركز الإدارة'),
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 36 : 20,
                  24,
                  isDesktop ? 36 : 20,
                  40,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHero(isDesktop),
                    const SizedBox(height: 22),
                    _buildStatistics(isDesktop),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      title: 'المتابعة اليومية',
                      subtitle: 'المؤشرات الأساسية للمنصة',
                    ),
                    const SizedBox(height: 14),
                    _buildMonitoringGrid(isDesktop),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      title: 'النشاط الأخير',
                      subtitle: 'آخر العمليات التي تحتاج إلى متابعة',
                    ),
                    const SizedBox(height: 14),
                    const _RecentActivityCard(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.deepBurgundy,
            AppTheme.burgundyBlack,
            AppTheme.obsidian,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRACÉ RAFINÉ',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.2,
                    color: AppTheme.warmIvory,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'مركز الإدارة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'إدارة دقيقة لمنصة الحِرفة الرقمية.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppTheme.mutedIvory,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBurgundy,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.roseBurgundy.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Text(
                    'النظام يعمل بشكل طبيعي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warmIvory,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 30),
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.burgundyBlack,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.divider),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 42,
                color: AppTheme.softRose,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatistics(bool isDesktop) {
    final cards = const [
      _StatisticCard(
        title: 'التصاميم',
        value: '0',
        caption: 'إجمالي التصاميم',
        icon: Icons.design_services_rounded,
      ),
      _StatisticCard(
        title: 'الطلبات',
        value: '0',
        caption: 'إجمالي الطلبات',
        icon: Icons.receipt_long_rounded,
      ),
      _StatisticCard(
        title: 'المصممون',
        value: '0',
        caption: 'الحسابات المسجلة',
        icon: Icons.draw_rounded,
      ),
      _StatisticCard(
        title: 'العملاء',
        value: '0',
        caption: 'الحسابات المسجلة',
        icon: Icons.people_rounded,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isDesktop ? 1.55 : 1.35,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppTheme.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildMonitoringGrid(bool isDesktop) {
    final cards = const [
      _MonitoringCard(
        icon: Icons.pending_actions_rounded,
        title: 'طلبات قيد المراجعة',
        value: '0',
      ),
      _MonitoringCard(
        icon: Icons.cloud_upload_rounded,
        title: 'تصاميم بانتظار الاعتماد',
        value: '0',
      ),
      _MonitoringCard(
        icon: Icons.person_add_alt_1_rounded,
        title: 'مصممون جدد',
        value: '0',
      ),
      _MonitoringCard(
        icon: Icons.report_problem_outlined,
        title: 'تنبيهات النظام',
        value: '0',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isDesktop ? 1.65 : 1.4,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppTheme.softRose),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedIvory,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringCard extends StatelessWidget {
  const _MonitoringCard({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.deepBurgundy,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: AppTheme.softRose),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedIvory,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Column(
        children: [
          _ActivityRow(
            icon: Icons.check_circle_outline_rounded,
            title: 'لا توجد عمليات حديثة',
            subtitle: 'ستظهر هنا آخر أنشطة المنصة.',
          ),
          Divider(height: 28),
          _ActivityRow(
            icon: Icons.security_outlined,
            title: 'مركز الإدارة جاهز',
            subtitle: 'يمكن ربط البيانات الفعلية بعد اكتمال الواجهة.',
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppTheme.softRose),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warmIvory,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminPlaceholder extends StatelessWidget {
  const _AdminPlaceholder({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppTheme.softRose),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmIvory,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppTheme.mutedText,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminDestination {
  const _AdminDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
