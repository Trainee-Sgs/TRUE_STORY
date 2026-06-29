import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double scale = (w / 360).clamp(0.8, 1.4);
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 72 * scale + bottomPadding,
      padding: EdgeInsets.only(
        top: 4 * scale,
        bottom: bottomPadding + 6 * scale,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF7C348D),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('assets/images/nav_home.png', 'Home', 0, scale),
          _buildNavItem('assets/images/nav_category.png', 'Category', 1, scale),
          _buildNavItem('assets/images/nav_profile.png', 'For You', 2, scale),
          _buildNavItem('assets/images/nav_settings.png', 'Settings', 3, scale),
        ],
      ),
    );
  }

  Widget _buildNavItem(String imagePath, String label, int index, double scale) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80 * scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 40 * scale : 36 * scale,
              height: isSelected ? 40 * scale : 36 * scale,
              decoration: isSelected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color.fromARGB(255, 133, 129, 129),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    )
                  : const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
              child: isSelected
                  ? Padding(
                      padding: EdgeInsets.all(10 * scale),
                      child: Image.asset(
                        imagePath,
                        width: 20 * scale,
                        height: 20 * scale,
                        color: const Color(0xFF7C348D),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(8 * scale),
                      child: Image.asset(
                        imagePath,
                        width: 20 * scale,
                        height: 20 * scale,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: isSelected ? 2 * scale : 4 * scale),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11 * scale,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  FadePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        );
}
