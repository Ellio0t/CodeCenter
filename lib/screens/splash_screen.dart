import 'package:flutter/material.dart';
import '../config/app_config.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Interactive Background: Black for Dark Mode, White for Light Mode
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black 
          : Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Centered Logo (Smiley)
          // 1. Centered Logo (Smiley)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The Glow
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppConfig.shared.primaryColor.withOpacity(0.6),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  AppConfig.shared.logoImage, // Dynamic Logo
                  width: 135, 
                  height: 135,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          // 2. Bottom Text/Logo "from Elliot"
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'from',
                  style: TextStyle(
                    color: Colors.grey, // Grey color for 'from'
                    fontSize: 11, // Reduced by ~30% (16 * 0.7 = 11.2)
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 0), // Minimal spacing to keep them close but not overlapping
                // Elliot Logo
                Image.asset(
                  AppConfig.shared.elliotLogoImage,
                  height: 30, // Adjusted height
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
