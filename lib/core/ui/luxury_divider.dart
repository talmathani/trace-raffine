import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LuxuryDivider extends StatelessWidget {
  const LuxuryDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
  });

  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: AppTheme.divider,
    );
  }
}
