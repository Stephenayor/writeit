import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatternPainter extends CustomPainter {
  final bool isDark;

  PatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.grey.shade800 : Colors.grey.shade600)
          .withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw circular segments pattern
    final random = [0.2, 0.5, 0.8, 0.3, 0.6, 0.9, 0.4, 0.7];
    int index = 0;

    for (double x = -50; x < size.width + 50; x += 80) {
      for (double y = -50; y < size.height + 50; y += 80) {
        final radius = 40.0 * random[index % random.length];
        canvas.drawArc(
          Rect.fromCircle(center: Offset(x, y), radius: radius),
          0,
          3.14,
          true,
          paint,
        );
        index++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw a simple abstract logo (circle with segments)
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final startAngle = (i * 3.14 * 2) / 6;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        3.14 / 6,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ButtonLogoPainter extends CustomPainter {
  final bool isDark;

  ButtonLogoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.grey.shade700).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw circular segments (similar to main logo)
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final startAngle = (i * 3.14 * 2) / 6;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        3.14 / 6,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
