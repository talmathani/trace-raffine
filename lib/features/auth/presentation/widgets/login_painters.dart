import 'package:flutter/material.dart';

/// راسم شعار TRACÉ RAFFINÉ الفاخر
class TRLogoPainter extends CustomPainter {
  const TRLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'TR',
        style: TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: size.height * 0.82,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2 - 2,
    );

    textPainter.paint(canvas, offset);

    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.88),
      Offset(size.width * 0.82, size.height * 0.88),
      paint..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant TRLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// راسم الخلفية التدرجية والزخارف النباتية لشاشة تسجيل الدخول
class LoginBackgroundPainter extends CustomPainter {
  const LoginBackgroundPainter({
    required this.primary,
    required this.secondary,
    required this.surface,
  });

  final Color primary;
  final Color secondary;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradient = RadialGradient(
      center: const Alignment(-0.55, -0.35),
      radius: 1.15,
      colors: [
        primary.withValues(alpha: 0.24),
        surface.withValues(alpha: 0.98),
      ],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final ornamentPaint = Paint()
      ..color = secondary.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    _drawFloralCorner(canvas, const Offset(-25, 65), 1.0, ornamentPaint);

    _drawFloralCorner(
      canvas,
      Offset(size.width + 25, size.height - 75),
      -1.0,
      ornamentPaint,
    );

    final bottomPaint = Paint()
      ..color = primary.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path()
      ..moveTo(0, size.height - 125)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height - 35,
        size.width * 0.58,
        size.height - 80,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height - 115,
        size.width,
        size.height - 52,
      );

    canvas.drawPath(path, bottomPaint);
  }

  void _drawFloralCorner(
    Canvas canvas,
    Offset origin,
    double direction,
    Paint paint,
  ) {
    final path = Path();

    path.moveTo(origin.dx, origin.dy);
    path.cubicTo(
      origin.dx + direction * 55,
      origin.dy + 35,
      origin.dx + direction * 30,
      origin.dy + 100,
      origin.dx + direction * 85,
      origin.dy + 125,
    );

    path.cubicTo(
      origin.dx + direction * 140,
      origin.dy + 150,
      origin.dx + direction * 120,
      origin.dy + 220,
      origin.dx + direction * 175,
      origin.dy + 235,
    );

    canvas.drawPath(path, paint);

    for (var i = 0; i < 4; i++) {
      final x = origin.dx + direction * (55 + i * 38);
      final y = origin.dy + 55 + i * 48;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 38, height: 18),
        paint,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + direction * 10, y - 12),
          width: 24,
          height: 12,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LoginBackgroundPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.surface != surface;
  }
}
