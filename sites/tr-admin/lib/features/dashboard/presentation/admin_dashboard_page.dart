import '../../../app/tr_admin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/presentation/admin_auth_controller.dart';
import '../../authentication/presentation/admin_auth_state.dart';

final class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

final class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  bool _redirectScheduled = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(_verifyAccess);
  }

  void _verifyAccess() {
    if (!mounted || _redirectScheduled) {
      return;
    }

    final AdminAuthState authState = ref.read(adminAuthControllerProvider);

    if (!AdminRouteAccess.isAllowed(authState)) {
      _redirectScheduled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      });
    }
  }

  Future<void> _logout() async {
    await ref.read(adminAuthControllerProvider.notifier).logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final AdminAuthState authState = ref.watch(adminAuthControllerProvider);

    if (!AdminRouteAccess.isAllowed(authState)) {
      return const Scaffold(
        backgroundColor: TRAdminTheme.obsidian,
        body: Center(
          child: CircularProgressIndicator(color: TRAdminTheme.roseBurgundy),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TRAdminTheme.obsidian,
      appBar: AppBar(
        backgroundColor: TRAdminTheme.burgundyBlack,
        foregroundColor: TRAdminTheme.mutedIvory,
        elevation: 0,
        titleSpacing: 24,
        title: const Row(
          children: [
            Text(
              'TR',
              style: TextStyle(
                color: TRAdminTheme.roseBurgundy,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'TRACÉ RAFFINÉ',
              style: TextStyle(
                color: TRAdminTheme.mutedIvory,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.4,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: PopupMenuButton<String>(
              tooltip: 'Administrator menu',
              color: TRAdminTheme.deepBurgundy,
              icon: const Icon(
                Icons.account_circle_outlined,
                color: TRAdminTheme.mutedIvory,
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: TRAdminTheme.mutedIvory,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        authState.user?.email ?? 'Administrator',
                        style: const TextStyle(color: TRAdminTheme.mutedIvory),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 850;

            return SingleChildScrollView(
              padding: EdgeInsets.all(compact ? 20 : 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context, authState.user?.email, compact),
                      const SizedBox(height: 28),
                      _buildOverviewGrid(compact),
                      const SizedBox(height: 28),
                      _buildManagementSection(compact),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? email, bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 30),
      decoration: BoxDecoration(
        color: TRAdminTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TRAdminTheme.roseBurgundy.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: TRAdminTheme.obsidian.withValues(alpha: 0.28),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 58 : 68,
            height: compact ? 58 : 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TRAdminTheme.roseBurgundy, width: 1.2),
            ),
            child: const Center(
              child: Text(
                'TR',
                style: TextStyle(
                  color: TRAdminTheme.roseBurgundy,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administration Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: TRAdminTheme.mutedIvory,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email == null || email.isEmpty ? 'Administrator' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TRAdminTheme.softRose,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(bool compact) {
    final cards = [
      _DashboardMetric(
        title: 'Designs',
        value: '0',
        icon: Icons.grid_view_rounded,
      ),
      _DashboardMetric(
        title: 'Orders',
        value: '0',
        icon: Icons.shopping_bag_outlined,
      ),
      _DashboardMetric(
        title: 'Customers',
        value: '0',
        icon: Icons.people_outline_rounded,
      ),
      _DashboardMetric(
        title: 'Designers',
        value: '0',
        icon: Icons.design_services_outlined,
      ),
    ];

    if (compact) {
      return Column(
        children: [
          for (final card in cards) ...[
            _buildMetricCard(card),
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (context, index) {
        return _buildMetricCard(cards[index]);
      },
    );
  }

  Widget _buildMetricCard(_DashboardMetric metric) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TRAdminTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TRAdminTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: TRAdminTheme.roseBurgundy.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metric.icon, color: TRAdminTheme.mutedIvory, size: 23),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.title,
                  style: const TextStyle(
                    color: TRAdminTheme.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  metric.value,
                  style: const TextStyle(
                    color: TRAdminTheme.mutedIvory,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(bool compact) {
    final items = [
      _ManagementItem(
        title: 'Design Management',
        subtitle: 'Review and manage embroidery design files.',
        icon: Icons.grid_view_rounded,
      ),
      _ManagementItem(
        title: 'Order Management',
        subtitle: 'Review orders and fulfillment status.',
        icon: Icons.receipt_long_outlined,
      ),
      _ManagementItem(
        title: 'Customer Management',
        subtitle: 'Manage customer accounts and access.',
        icon: Icons.people_outline_rounded,
      ),
      _ManagementItem(
        title: 'Designer Management',
        subtitle: 'Review designers and marketplace access.',
        icon: Icons.design_services_outlined,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(compact ? 20 : 26),
      decoration: BoxDecoration(
        color: TRAdminTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TRAdminTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Administration',
            style: TextStyle(
              color: TRAdminTheme.mutedIvory,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Core TRACÉ RAFFINÉ platform management.',
            style: TextStyle(color: TRAdminTheme.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 22),
          if (compact)
            Column(
              children: [
                for (final item in items) ...[
                  _buildManagementCard(item),
                  const SizedBox(height: 12),
                ],
              ],
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 2.8,
              ),
              itemBuilder: (context, index) {
                return _buildManagementCard(items[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(_ManagementItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TRAdminTheme.obsidian,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TRAdminTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: TRAdminTheme.roseBurgundy.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(item.icon, color: TRAdminTheme.mutedIvory, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: TRAdminTheme.mutedIvory,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TRAdminTheme.mutedText,
                    fontSize: 11.5,
                    height: 1.35,
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

final class AdminRouteAccess {
  const AdminRouteAccess._();

  static bool isAllowed(AdminAuthState state) {
    return state.status == AdminAuthStatus.authenticated &&
        state.access?.isAdmin == true;
  }
}

final class _DashboardMetric {
  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

final class _ManagementItem {
  const _ManagementItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}











