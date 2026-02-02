import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui'; // Added for Glassmorphism
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart'; 
import '../screens/faq_screen.dart';
import '../screens/claim_code_screen.dart';
import '../screens/prime_offer_screen.dart';
import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../config/app_config.dart'; // Added

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch \$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (AppConfig.shared.isWinit) {
       return Drawer(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: (Theme.of(context).drawerTheme.backgroundColor ?? const Color(0xFFF2F2F2))
                      .withOpacity(0.85),
                ),
              ),
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                     decoration: BoxDecoration(
                       color: Colors.transparent,
                     ),
                     margin: EdgeInsets.zero,
                     child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Image.asset(
                                AppConfig.shared.drawerImage,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                   Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    // Determine Title and Action based on Auth State
                    final isGuest = user == null || user.isAnonymous;
                    final title = isGuest ? 'LOGIN' : 'PROFILE';
                    
                    return ListTile(
                      leading: isGuest ? Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FaIcon(
                          FontAwesomeIcons.arrowRightToBracket,
                          color: Color(0xFF00C853),
                          size: 22,
                        ),
                      ) : null,
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xFF00C853), // Reverted to Green
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, 
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE0E0E0) : const Color(0xFF424242),
                          ),
                          const SizedBox(width: 8),
                          // Theme Switch (Preserved)
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: themeProvider.isDarkMode,
                              activeColor: AppConfig.shared.primaryColor,
                              onChanged: (bool value) {
                                themeProvider.toggleTheme(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      visualDensity: const VisualDensity(vertical: -2),
                      dense: true,
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        if (isGuest) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        }
                      },
                    );
                  },
                ),
                
                const Divider(height: 1, thickness: 1, color: Colors.black12),
                
                _buildSectionHeader('BONUS POINTS'),
                _buildMenuItem(
                  context,
                  title: 'CLAIM',
                  subtitle: 'Find the latest active code',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ClaimCodeScreen()),
                    );
                  },
                ),
                
                const Divider(height: 1, thickness: 1, color: Colors.black12),
    
                _buildSectionHeader('DISCOVER MORE'),
                _buildMenuItem(
                  context,
                  title: 'SWAGGER', 
                  subtitle: 'Swagbucks Codes',
                  onTap: () => _launchUrl('https://www.swagbuckscodes.net'),
                ),
                _buildMenuItem(
                  context,
                  title: 'POINT', 
                  subtitle: 'MyPoints Codes',
                  onTap: () => _launchUrl('https://www.pointperk.net'),
                ),
                _buildMenuItem(
                  context,
                  title: 'CODBLOX', 
                  subtitle: 'Roblox Codes',
                  onTap: () => _launchUrl('https://www.robloxcodes.net/'),
                ),
    
                const Divider(height: 1, thickness: 1, color: Colors.black12),
    
                ListTile(
                  title: Text(
                    'PRIME',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: AppConfig.shared.primaryColor, // Green Text
                      shadows: [
                        Shadow(
                          color: AppConfig.shared.primaryColor.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                        Shadow(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppConfig.shared.primaryColor.withOpacity(0.4) 
                              : Colors.yellow.withOpacity(0.4),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  subtitle: const Text(
                    'More codes no ADs',
                     style: TextStyle(
                      fontSize: 13, // Standard size
                      color: Colors.grey, // Standard color
                      fontWeight: FontWeight.w300, // Standard weight
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                    ),
                    child: const Text("PRO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  dense: true,
                  onTap: () {
                     Navigator.pop(context);
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrimeOfferScreen()),
                    );
                  },
                ),
    
    
                
                const Divider(height: 1, thickness: 1, color: Colors.black12),
                
                _buildMenuItem(
                   context,
                   title: 'SETTINGS',
                   subtitle: 'Notifications & Preferences',
                   onTap: () {
                     Navigator.pop(context);
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => const SettingsScreen()),
                     );
                   },
                 ),
    
    
    
                const Divider(height: 1, thickness: 1, color: Colors.black12),
                
                // Sign Out / About Row
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red), // Added Icon back
                  title: const Text(
                    'SIGN OUT',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 19, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.grey),
                    tooltip: 'About',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutScreen()),
                      );
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  dense: true,
                  onTap: () async {
                     Navigator.pop(context);
                     await AuthService().signOut();
                  },
                ),
                ],
              ),
            ],
          ),
       );
    }

    return Drawer(
      backgroundColor: Colors.transparent, // Important for glass effect
      child: Stack(
        children: [
           // 1. Blur Effect
           BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: (Theme.of(context).drawerTheme.backgroundColor ?? const Color(0xFFF2F2F2))
                  .withOpacity(0.85), // Semi-transparent
            ),
          ),
          
          // 2. Content
          ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Image.asset(
                            AppConfig.shared.drawerImage, // Dynamic Image
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Padding/Divider handling to match look
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                // Determine Title and Action based on Auth State
                final isGuest = user == null || user.isAnonymous;
                final title = isGuest ? 'LOGIN' : 'PROFILE';
                final icon = isGuest ? Icons.login : Icons.person_outline;
                
                return ListTile(
                  leading: isGuest ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: FaIcon(
                      FontAwesomeIcons.arrowRightToBracket,
                      color: Color(0xFF00C853),
                      size: 22,
                    ),
                  ) : null,
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      color: Color(0xFF00C853), // Reverted to Green
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, 
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE0E0E0) : const Color(0xFF424242),
                      ),
                      const SizedBox(width: 8),
                      // Theme Switch (Preserved)
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: themeProvider.isDarkMode,
                          activeColor: AppConfig.shared.primaryColor,
                          onChanged: (bool value) {
                            themeProvider.toggleTheme(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  visualDensity: const VisualDensity(vertical: -2),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    if (isGuest) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    }
                  },
                );
              },
            ),
            
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            
            _buildSectionHeader('BONUS POINTS'),
            _buildMenuItem(
              context,
              title: 'CLAIM',
              subtitle: 'Find the latest active code',
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClaimCodeScreen()),
                );
              },
            ),
            
            const Divider(height: 1, thickness: 1, color: Colors.black12),

            _buildSectionHeader('DISCOVER MORE'),
            _buildMenuItem(
              context,
              title: 'SWAGGER', 
              subtitle: 'Swagbucks Codes',
              onTap: () => _launchUrl('https://www.swagbuckscodes.net'),
            ),
            _buildMenuItem(
              context,
              title: 'POINT', 
              subtitle: 'MyPoints Codes',
              onTap: () => _launchUrl('https://www.pointperk.net'),
            ),
            _buildMenuItem(
              context,
              title: 'CODBLOX', 
              subtitle: 'Roblox Codes',
              onTap: () => _launchUrl('https://www.robloxcodes.net/'),
            ),

            const Divider(height: 1, thickness: 1, color: Colors.black12),

            ListTile(
              title: Text(
                'PRIME',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppConfig.shared.primaryColor, // Green Text
                  shadows: [
                    Shadow(
                      color: AppConfig.shared.primaryColor.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                    Shadow(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppConfig.shared.primaryColor.withOpacity(0.4) 
                          : Colors.yellow.withOpacity(0.4),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              subtitle: const Text(
                'More codes no ADs',
                 style: TextStyle(
                  fontSize: 13, // Standard size
                  color: Colors.grey, // Standard color
                  fontWeight: FontWeight.w300, // Standard weight
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.withOpacity(0.5)),
                ),
                child: const Text("PRO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              dense: true,
              onTap: () {
                 Navigator.pop(context);
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrimeOfferScreen()),
                );
              },
            ),


            
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            
            _buildMenuItem(
               context,
               title: 'SETTINGS',
               subtitle: 'Notifications & Preferences',
               onTap: () {
                 Navigator.pop(context);
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const SettingsScreen()),
                 );
               },
             ),



            const Divider(height: 1, thickness: 1, color: Colors.black12),
            
            // Sign Out / About Row
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red), // Added Icon back
              title: const Text(
                'SIGN OUT',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 19, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.grey),
                tooltip: 'About',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              dense: true,
              onTap: () async {
                 Navigator.pop(context);
                 await AuthService().signOut();
              },
            ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required String title, String? subtitle, VoidCallback? onTap, double fontSize = 19}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFE0E0E0) : const Color(0xFF424242),
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.w300,
        ),
      ) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      visualDensity: const VisualDensity(vertical: -2), // Compact
      dense: true,
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 5),
      child: Text(
        title,
        style: TextStyle(
          color: AppConfig.shared.primaryColor,
          fontSize: 15,
          fontWeight: FontWeight.bold, 
        ),
      ),
    );
  }
}


