import 'package:flutter/material.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';

class ManagerDirectNotice extends StatelessWidget {
  const ManagerDirectNotice({
    super.key,
    required this.role,
    required this.unreadCount,
    required this.onOpen,
    required this.onDismiss,
  });

  final String role;
  final int unreadCount;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;

  bool get isDesigner => role == 'designer';

  @override
  Widget build(BuildContext context) {
    final countLabel = unreadCount > 1
        ? 'لديك $unreadCount رسائل جديدة من إدارة TRACÉ RAFFINÉ.'
        : 'لديك رسالة خاصة من إدارة TRACÉ RAFFINÉ.';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          decoration: BoxDecoration(
            color: AppTheme.burgundyBlack,
            borderRadius: BorderRadius.circular(AppTheme.radiusEditorial),
            border: Border.all(color: AppTheme.divider),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MaisonMark(isDesigner: isDesigner),
                const SizedBox(width: 14),
                Expanded(
                  child: _NoticeCopy(
                    isDesigner: isDesigner,
                    countLabel: countLabel,
                    onOpen: onOpen,
                  ),
                ),
                IconButton(
                  tooltip: 'إغلاق',
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded, size: 19),
                  color: AppTheme.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaisonMark extends StatelessWidget {
  const _MaisonMark({required this.isDesigner});
  final bool isDesigner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.deepBurgundy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.roseBurgundy),
      ),
      child: Text(
        isDesigner ? 'DR' : 'TR',
        style: const TextStyle(
          fontFamily: AppTheme.fontEditorial,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.softRose,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NoticeCopy extends StatelessWidget {
  const _NoticeCopy({
    required this.isDesigner,
    required this.countLabel,
    required this.onOpen,
  });

  final bool isDesigner;
  final String countLabel;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRACÉ RAFFINÉ',
          style: const TextStyle(
            fontFamily: AppTheme.fontEditorial,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppTheme.warmIvory,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isDesigner
              ? 'MESSAGE DE LA MAISON · DESIGNER'
              : 'MESSAGE DE LA MAISON',
          style: const TextStyle(
            fontFamily: AppTheme.fontTechnical,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppTheme.softRose,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          isDesigner ? 'رسالة جديدة، مصممنا' : 'رسالة جديدة إليك',
          style: AppTheme.arabicTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(countLabel, style: AppTheme.arabicBody.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: onOpen,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('فتح المحادثة →'),
          ),
        ),
      ],
    );
  }
}
