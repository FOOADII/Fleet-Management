import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Navigate to onboarding after animation
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.onboarding);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CustomPaint(
                  painter: BlobPainter(),
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              const Text(
                'DDU Fleet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Smart Fleet Management',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the blob shape logo
class BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width * 0.7,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.8,
      size.width * 0.3,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.5,
      size.width * 0.3,
      size.height * 0.4,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
