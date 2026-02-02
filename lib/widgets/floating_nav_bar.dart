import 'package:flutter/material.dart';
import '../config/app_config.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, Icons.home_rounded, "Home"),
            _buildNavItem(context, 1, Icons.monetization_on_outlined, "Cashback"),
            _buildNavItem(context, 2, Icons.games_outlined, "Games"),
            _buildNavItem(context, 3, Icons.person_outline, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final primaryColor = AppConfig.shared.primaryColor; // Brand Color

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              )
            : const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
        child: Icon(
          icon,
          color: isSelected ? primaryColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey),
          size: 28,
        ),
      ),
    );
  }
}

