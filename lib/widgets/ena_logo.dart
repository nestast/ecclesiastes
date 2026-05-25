import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Logo ENA : image fournie si disponible, sinon dessin vectoriel.
class EnaLogo extends StatelessWidget {
  final double size;

  const EnaLogo({super.key, this.size = 120});

  static const _assetPath = 'assets/images/logo_accueil.png';

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        _assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _VectorLogo(size: size),
      ),
    );
  }
}

class _VectorLogo extends StatelessWidget {
  final double size;

  const _VectorLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: _EnaLogoPainter(),
        size: Size(size, size),
      ),
    );
  }
}

class _EnaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final inner = size.width * 0.22;
      final outer = size.width * 0.38;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle), center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle), center.dy + outer * math.sin(angle)),
        Paint()
          ..color = Colors.white
          ..strokeWidth = size.width * 0.025
          ..strokeCap = StrokeCap.round,
      );
    }

    final crossLen = size.width * 0.22;
    final crossW = size.width * 0.07;
    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: crossW, height: crossLen),
        Radius.circular(crossW / 2),
      ),
      crossPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: crossLen, height: crossW),
        Radius.circular(crossW / 2),
      ),
      crossPaint,
    );

    final wavePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;
    final waveY = size.height * 0.72;
    final path = Path();
    path.moveTo(size.width * 0.2, waveY);
    path.quadraticBezierTo(size.width * 0.35, waveY - 8, size.width * 0.5, waveY);
    path.quadraticBezierTo(size.width * 0.65, waveY + 8, size.width * 0.8, waveY);
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
