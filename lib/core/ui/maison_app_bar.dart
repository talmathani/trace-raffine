import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'maison_back_button.dart';

class MaisonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const MaisonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(77);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 76,
      backgroundColor: AppTheme.obsidian,
      foregroundColor: AppTheme.warmIvory,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading:
          leading ??
          (Navigator.canPop(context)
              ? MaisonBackButton(onPressed: () => Navigator.pop(context))
              : null),
      actions: actions,
      titleSpacing: 8,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: AppTheme.fontArabic,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppTheme.warmIvory,
          height: 1,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppTheme.divider),
      ),
    );
  }
}
