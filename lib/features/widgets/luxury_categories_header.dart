import 'dart:math';

import 'package:flutter/material.dart';

class LuxuryCategoriesHeader extends StatefulWidget {
  const LuxuryCategoriesHeader({
    super.key,
    this.height = 82,
    this.backgroundColor = const Color(0xFF0B0B0B),
  });

  final double height;
  final Color backgroundColor;

  @override
  State<LuxuryCategoriesHeader> createState() => _LuxuryCategoriesHeaderState();
}

class _LuxuryCategoriesHeaderState extends State<LuxuryCategoriesHeader> {
  static const List<String> _luxuryPhrases = [
    'PRECISION · CRAFTSMANSHIP · DIGITAL ART',
    'TRACÉ RAFFINÉ · THE ART OF DIGITAL EMBROIDERY',
    'WHERE CRAFT BECOMES DIGITAL ART',
    'HAUTE COUTURE · EMBROIDERY · DESIGN',
    'ENGINEERED FOR CRAFT · CREATED FOR ART',
    'DIGITAL PRECISION · TIMELESS CRAFT',
  ];

  static const List<String> _categories = [
    'فساتين السهرة والهوت كوتور',
    'تصاميم الساري الهندي',
    'العبايات والبوالطوهات',
    'الجلابيات والمخاور',
    'تصاميم موزعة',
    'تصاميم الحواشي',
    'الشعارات واللوغوهات',
    'جديد الأسبوع',
    'تطريزات المناسبات',
    'تطريزات الزفاف',
    'تصاميم الأطفال',
    'التطريز الملكي',
    'الزخارف الشرقية',
    'النقوش الهندسية',
    'مختارات المصممين',
  ];

  late final List<String> _shuffledCategories;

  @override
  void initState() {
    super.initState();

    _shuffledCategories = List<String>.from(_categories)..shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: const Border(
          top: BorderSide(color: Color(0x339B5268), width: 1),
          bottom: BorderSide(color: Color(0x339B5268), width: 1),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: _LuxuryMarquee(
              velocity: 24,
              direction: AxisDirection.left,
              child: _buildPhraseItems(),
            ),
          ),
          Expanded(
            child: _LuxuryMarquee(
              velocity: 34,
              direction: AxisDirection.right,
              child: _buildCategoryItems(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseItems() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final phrase in _luxuryPhrases) ...[
          _LuxuryPhrase(text: phrase),
          const _LuxurySeparator(),
        ],
      ],
    );
  }

  Widget _buildCategoryItems() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final category in _shuffledCategories) ...[
          _LuxuryCategory(text: category),
          const _LuxurySeparator(),
        ],
      ],
    );
  }
}

class _LuxuryMarquee extends StatefulWidget {
  const _LuxuryMarquee({
    required this.child,
    required this.velocity,
    required this.direction,
  });

  final Widget child;
  final double velocity;
  final AxisDirection direction;

  @override
  State<_LuxuryMarquee> createState() => _LuxuryMarqueeState();
}

class _LuxuryMarqueeState extends State<_LuxuryMarquee> {
  final ScrollController _scrollController = ScrollController();

  bool _running = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMarquee();
    });
  }

  Future<void> _startMarquee() async {
    if (!mounted || _running) {
      return;
    }

    _running = true;

    while (mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted || !_scrollController.hasClients) {
        continue;
      }

      final maxExtent = _scrollController.position.maxScrollExtent;

      if (maxExtent <= 0) {
        continue;
      }

      final durationMs = max(
        5000,
        ((maxExtent / widget.velocity) * 1000).round(),
      );

      if (widget.direction == AxisDirection.right) {
        _scrollController.jumpTo(maxExtent);
      }

      await _scrollController.animateTo(
        widget.direction == AxisDirection.left ? maxExtent : 0.0,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      if (!mounted || !_scrollController.hasClients) {
        continue;
      }

      if (widget.direction == AxisDirection.left) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(maxExtent);
      }
    }

    _running = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repeatedContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [widget.child, widget.child],
    );

    return ClipRect(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: repeatedContent,
        ),
      ),
    );
  }
}

class _LuxuryPhrase extends StatelessWidget {
  const _LuxuryPhrase({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: const TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD9A0B1),
          letterSpacing: 2.2,
        ),
      ),
    );
  }
}

class _LuxuryCategory extends StatelessWidget {
  const _LuxuryCategory({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE8DFD8),
          height: 1.2,
        ),
      ),
    );
  }
}

class _LuxurySeparator extends StatelessWidget {
  const _LuxurySeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '✦',
        style: TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: 10,
          color: Color(0x669B5268),
        ),
      ),
    );
  }
}
