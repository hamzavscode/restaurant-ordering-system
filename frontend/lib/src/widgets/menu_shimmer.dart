import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A shimmer loading placeholder that mimics the menu grid layout.
/// Shows animated placeholder cards while data is being fetched.
class MenuShimmer extends StatefulWidget {
  const MenuShimmer({super.key});

  @override
  State<MenuShimmer> createState() => _MenuShimmerState();
}

class _MenuShimmerState extends State<MenuShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Shimmer Search Bar
              _shimmerBox(height: 50, borderRadius: 14),
              const SizedBox(height: 16),
              // Shimmer Category Tabs
              SizedBox(
                height: 40,
                child: Row(
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _shimmerBox(
                          width: 80, height: 36, borderRadius: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Shimmer Grid (2x3)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => _shimmerCard(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          _shimmerBox(height: 120, borderRadius: 16, topOnly: true),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(height: 14, width: 100, borderRadius: 6),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerBox(height: 14, width: 50, borderRadius: 6),
                    _shimmerBox(
                        height: 32, width: 32, borderRadius: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    double? width,
    double height = 50,
    double borderRadius = 12,
    bool topOnly = false,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            borderRadius: topOnly
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.textMuted.withOpacity(0.08),
                AppTheme.textMuted.withOpacity(0.15),
                AppTheme.textMuted.withOpacity(0.08),
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
