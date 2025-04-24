import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Real-time Fleet Tracking',
      description:
          'Monitor your entire fleet with live GPS tracking and instant location updates',
      image: 'assets/images/onboarding/tracking.png',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.white],
      ),
      icon: Icons.location_on_rounded,
    ),
    OnboardingPage(
      title: 'Smart Maintenance',
      description:
          'Stay ahead with predictive maintenance alerts and service scheduling',
      image: 'assets/images/onboarding/maintenance.png',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.white],
      ),
      icon: Icons.build_rounded,
    ),
    OnboardingPage(
      title: 'Fuel Analytics',
      description:
          'Track fuel efficiency and costs with detailed analytics and reports',
      image: 'assets/images/onboarding/fuel.png',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.white],
      ),
      icon: Icons.local_gas_station_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _onGetStarted() {
    Get.offAllNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                color: Colors.white,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        // Progress indicator
                        LinearProgressIndicator(
                          value: (index + 1) / _pages.length,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CAF50)),
                        ),
                        const Spacer(),
                        // Icon with animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFE8F5E9), // Light green background
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              page.icon,
                              size: 60,
                              color: const Color(0xFF4CAF50), // Primary green
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Title with animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Description with animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Navigation buttons
                        Padding(
                          padding: const EdgeInsets.only(bottom: 48),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Skip button
                              TextButton(
                                onPressed: _onGetStarted,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              // Page indicators
                              Row(
                                children: List.generate(
                                  _pages.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: _currentPage == index ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: _currentPage == index
                                          ? const Color(0xFF4CAF50)
                                          : Colors.grey[300],
                                    ),
                                  ),
                                ),
                              ),
                              // Next/Get Started button
                              TextButton(
                                onPressed: _currentPage == _pages.length - 1
                                    ? _onGetStarted
                                    : () {
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF4CAF50),
                                ),
                                child: Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Get Started'
                                      : 'Next',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final LinearGradient gradient;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.gradient,
    required this.icon,
  });
}
