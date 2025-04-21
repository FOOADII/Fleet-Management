import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    // Blue part
    paint.color = const Color(0xFF4285F4);
    var path = Path()
      ..moveTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.35)
      ..lineTo(size.width * 0.4, size.height * 0.35)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..lineTo(size.width * 0.8, size.height * 0.65)
      ..close();
    canvas.drawPath(path, paint);

    // Red part
    paint.color = const Color(0xFFEA4335);
    path = Path()
      ..moveTo(size.width * 0.4, size.height * 0.35)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..close();
    canvas.drawPath(path, paint);

    // Yellow part
    paint.color = const Color(0xFFFBBC05);
    path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..lineTo(size.width * 0.25, size.height * 0.8)
      ..lineTo(size.width * 0.1, size.height * 0.65)
      ..close();
    canvas.drawPath(path, paint);

    // Green part
    paint.color = const Color(0xFF34A853);
    path = Path()
      ..moveTo(size.width * 0.4, size.height * 0.65)
      ..lineTo(size.width * 0.25, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.95)
      ..lineTo(size.width * 0.55, size.height * 0.8)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
