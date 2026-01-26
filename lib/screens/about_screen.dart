import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_header.dart';
import '../widgets/header_actions.dart';

import 'package:package_info_plus/package_info_plus.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Use theme background (Carbon in Dark Mode)

      body: Column(
        children: [
          CustomHeader(
            title: 'About',
            actions: buildHeaderActions(context),
          ),
          Expanded(
            child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text( // Removing const to allow dynamic style
              _versionInfo,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30),
            // Logo Replacement
            Image.asset(
              'images/logo.png',
              width: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 15),
            Text( // Removing const
              'El|iot',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 60),
            // Interactive Developer Button
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
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4EDDA),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF10D34E), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "DEVELOPER'S PAGE (AD)",
                    style: TextStyle(
                      color: Color(0xFF10D34E),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'WinIt Code is your ultimate tool for discovering active reward codes. We monitor multiple platforms to bring you the latest verified codes for InboxDollars, Swagbucks, and more, helping you earn faster and easier.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 80),
            // Footer Links
            TextButton(
              onPressed: () => _launchUrl('https://winitcode.com/p/privacy-policy.html'),
              child: Text(
                'Terms & Conditions',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.black45,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _launchUrl('mailto:barrioselliot@hotmail.com?subject=WinIt%20App%20Inquiry'),
              child: Text(
                'Contact Developer',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.black45,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
          ),
        ),
        ],
      ),
    );
  }
}
