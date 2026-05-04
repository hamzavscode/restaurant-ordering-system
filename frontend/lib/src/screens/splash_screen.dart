import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Splash Screen - The first screen users see when opening the app.
/// Displays the restaurant logo, brand name, and tagline with animations,
/// then navigates to the Login screen after a short delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller (1.5 seconds duration)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade-in animation for the whole content
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Scale animation for the logo circle
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Slide-up animation for the bottom tagline
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Start the animation
    _controller.forward();

    // Navigate to Register after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/register');
      }
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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // ─── Top spacer ───
              const Spacer(flex: 3),

              // ─── Logo Circle with Icon ───
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.08),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 55,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ─── Brand Name ───
              Text(
                'Modern Hospitality',
                style: AppTheme.headingLarge,
              ),

              // ─── Bottom spacer ───
              const Spacer(flex: 3),

              // ─── Tagline at Bottom ───
              SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Text(
                      'Delivering Taste to Your Table',
                      style: AppTheme.subtitle,
                    ),
                    const SizedBox(height: 12),

                    // ─── Page Indicator Dots ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(AppTheme.primary),
                        const SizedBox(width: 6),
                        _buildDot(AppTheme.primaryLight),
                        const SizedBox(width: 6),
                        _buildDot(AppTheme.primaryFaded),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single indicator dot
  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
