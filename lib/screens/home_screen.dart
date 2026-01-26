import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;
import '../models/cashback_code.dart';
import '../models/referral_site.dart';
import '../widgets/app_drawer.dart';
import '../widgets/code_card.dart';
import '../widgets/code_list.dart';
import '../widgets/referral_section.dart';
import '../widgets/ad_placeholder.dart';
import '../services/firestore_service.dart';
import 'about_screen.dart';
import 'rss_feed_screen.dart';
import 'claim_code_screen.dart'; // Added import
import '../widgets/header_actions.dart';

import '../widgets/code_search_delegate.dart';
import '../widgets/prime_banner.dart';
import '../widgets/suggest_site_card.dart';
import '../config/app_config.dart'; // Added

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService = FirestoreService();
  final ValueNotifier<int> _refreshNotifier = ValueNotifier(0); // For refreshing CodeList

  final List<ReferralSite> referralSites = [
    ReferralSite(
      name: 'InboxDollars',
      referralUrl: 'https://www.winitcode.com/',
      logoAssetsPath: 'images/winit-app.png',
    ),
    ReferralSite(
      name: 'MyPoints',
      referralUrl: 'https://www.pointperk.net/',
      logoAssetsPath: 'images/perk-app.png',
    ),
    ReferralSite(
      name: 'Swagbucks',
      referralUrl: 'https://www.swagbuckscodes.net/',
      logoAssetsPath: 'images/swag-app.png',
    ),
    ReferralSite(
      name: 'Roblox',
      referralUrl: 'https://www.robloxcodes.net/',
      logoAssetsPath: 'images/roblox-app.png',
    ),


  ];

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch \$url');
    }
  }



  @override
  Widget build(BuildContext context) {
    final config = AppConfig.shared;
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 140.0,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                ? Theme.of(context).colorScheme.surface // Use dark surface color for Carbon feel
                : config.primaryColor,
              elevation: 0,
              leading: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.bars, 
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.white
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              actions: buildHeaderActions(context),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  children: [
                    // 1. Background Image (Zoomed)
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Theme.of(context).colorScheme.surface 
                          : config.primaryColor,
                        child: Transform.scale(
                          scale: 1.5,
                          child: Opacity(
                            opacity: 0.3,
                            child: Image.asset(
                              'images/inboxdollars.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 2. Content
                    SafeArea(
                      child: Container(
                        padding: const EdgeInsets.only(top: 60, bottom: 10, left: 16, right: 16),
                        child: Column(
                          children: [
                            // Bottom Row: Facebook, Telegram, Twitter
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.facebookF, 
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.white
                                  ),
                                  onPressed: () => _launchUrl('https://www.facebook.com/winitcode/'),
                                ),
                                IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.paperPlane, 
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.white
                                  ),
                                  onPressed: () => _launchUrl('https://t.me/winitcodes'),
                                ),
                                IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.twitter, 
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.white
                                  ),
                                  onPressed: () => _launchUrl('https://twitter.com/WinItCode'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const AdPlaceholder(),
                  
                  // New "CLAIM CODE" Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GestureDetector(
                        onTap: () {
                          print('DEBUG: Navigating to RssFeedScreen with Money Back filter');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RssFeedScreen(filterCategory: 'Money Back')),
                          );
                        },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), // More rounded
                          gradient: LinearGradient(
                            colors: Theme.of(context).brightness == Brightness.dark 
                              ? [ config.primaryColor.withOpacity(0.5), config.primaryColor.withOpacity(0.2) ] // Dynamic Dark
                              : [ config.primaryColor, config.primaryColor.withOpacity(0.8) ], // Dynamic Light
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (Theme.of(context).brightness == Brightness.dark 
                                  ? config.primaryColor.withOpacity(0.2)
                                  : config.primaryColor).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // 1. Background Decorative Icon
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Transform.rotate(
                                angle: -0.2, // Tilted
                                child: Icon(
                                  Icons.monetization_on_rounded, // Changed to dollar icon
                                  size: 150,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                            ),
                            
                            // 2. Content
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20, // Constrain width for thin screens
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'CASHBACK CENTER',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11, // Reduced from 12 (-10%)
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'MONEY BACK', // Uppercase
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Stay updated with the latest offers.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13, // Reduced from 14 (-10%)
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 600.ms).slideX(begin: -0.1, end: 0),

                  if (config.hasCodesFeature)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                 onTap: () {
                                   Navigator.push(
                                     context, 
                                     MaterialPageRoute(builder: (context) => const ClaimCodeScreen())
                                   );
                                 },
                                 child: Row(
                                   children: [
                                     Text(
                                      'RECENT CODES',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: config.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: config.primaryColor,
                                    ),
                                   ],
                                 ),
                                ),
                              IconButton(
                                icon: Icon(Icons.refresh, color: config.primaryColor),
                                onPressed: () {
                                  _refreshNotifier.value++;
                                },
                                tooltip: 'Refresh Codes',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Don\'t miss out on these limited time offers!',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 700.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
                ],
              ),
            ),
            
            // Sliver List of Codes (Limit 5)
            if (config.hasCodesFeature) 
              ValueListenableBuilder<int>(
                valueListenable: _refreshNotifier,
                builder: (context, value, child) {
                  return CodeList(
                    key: ValueKey(value), // Force rebuild on refresh
                    scrollable: false, 
                    useSliver: true, 
                    limit: 5, 
                    showAds: false
                  );
                },
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: const SuggestSiteCard(),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // EARN TO PLAY Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RssFeedScreen(filterCategory: 'Games')),
                        );
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: Theme.of(context).brightness == Brightness.dark 
                              ? [ const Color(0xFF4A148C), const Color(0xFF311B92) ] // Darker Purple for Carbon
                              : [ const Color(0xFF8E2DE2), const Color(0xFF4A00E0) ], 
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (Theme.of(context).brightness == Brightness.dark 
                                  ? const Color(0xFF4A148C) 
                                  : const Color(0xFF8E2DE2)).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background Icon
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Icon(
                                  Icons.games_rounded,
                                  size: 150,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                            ),
                            // Content
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20, // Constrain width for thin screens
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'GAME CENTER',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11, // Reduced from 12 (-10%)
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'EARN TO PLAY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Play games and earn rewards.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13, // Reduced from 14 (-10%)
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 800.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  const AdPlaceholder(),
                  const SizedBox(height: 16),
                  ReferralSection(referralSites: referralSites),
                  const SizedBox(height: 16),
                  const PrimeBanner(),
                  // Removed SizedBox(height: 24)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // Removed top padding
                    child: Column(
                      children: [
                        Text(
                          'FOLLOW US FOR MORE CODES!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: config.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2)),
                              onPressed: () => _launchUrl('https://facebook.com'),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.twitter, color: Color(0xFF1DA1F2)),
                              onPressed: () => _launchUrl('https://twitter.com'),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE4405F)),
                              onPressed: () => _launchUrl('https://instagram.com'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '© 2026 WinIt Codes. All rights reserved.',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
