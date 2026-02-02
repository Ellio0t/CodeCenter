import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/app_config.dart';
import '../widgets/header_actions.dart';
import 'contact_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  double _buttonScale = 1.0;
  String _versionInfo = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _versionInfo = 'VERSION ${info.version} / ${info.buildNumber}';
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch \$url');
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.shared;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''), // Empty title for cleaner look
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: buildHeaderActions(
          context,
          colorOverride: isDark ? Colors.white : Colors.white, // Always white on new bg
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900, // Matching CustomHeader
          shadows: [
            Shadow(
              offset: Offset(0, 2),
              blurRadius: 4,
              color: Colors.black26,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFF121212), Color.lerp(Colors.black, config.primaryColor, 0.15)!] // Carbon Black with Faint Glow
                  : [config.primaryColor, config.primaryColor.withOpacity(0.8)], // App Color
              ),
            ),
          ),
          
          // 2. Main Content Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glass Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2), 
                          width: 1
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                            // App Logo with Glow
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                config.logoImage,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // App Name
                            Text(
                              config.appName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Version Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _versionInfo,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Description
                            Text(
                              'Your ultimate tool for discovering active reward codes. We monitor multiple platforms to bring you the latest verified codes, helping you earn faster and easier.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Developer Button (Gradient Pill)
                            GestureDetector(
                                onTapDown: (_) => setState(() => _buttonScale = 0.94),
                                onTapUp: (_) => setState(() => _buttonScale = 1.0),
                                onTapCancel: () => setState(() => _buttonScale = 1.0),
                                onTap: () => _launchUrl('https://play.google.com/store/apps/dev?id=6965493081418698979&pli=1'),
                                child: AnimatedScale(
                                  scale: _buttonScale,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.easeInOut,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.white, Colors.grey[100]!],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.rocket_launch_rounded, color: config.primaryColor, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "MORE APPS",
                                          style: TextStyle(
                                            color: config.primaryColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Footer Links (Simple Text Row - Reverted to Clean Style)
                    // Updated to navigate to new Screens
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFooterLink('Privacy Policy', () => _navigateTo(const PrivacyPolicyScreen())),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 1,
                          height: 12,
                          color: Colors.white54,
                        ),
                         _buildFooterLink('Terms', () => _navigateTo(const TermsScreen())),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 1,
                          height: 12,
                          color: Colors.white54,
                        ),
                        _buildFooterLink('Contact', () => _navigateTo(const ContactScreen())),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Designed by El|iot',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8), // Brighter/Clearer
                        fontSize: 14, // Slightly larger (was 12)
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
