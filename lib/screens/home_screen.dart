import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;
import 'dart:ui'; // Added for Glassmorphism
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService = FirestoreService();
  final ValueNotifier<int> _refreshNotifier = ValueNotifier(0);
  final ScrollController _scrollController = ScrollController();
  double _scrollOpacity = 0.0;

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _refreshNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // Fade in over the first 100 pixels of scroll
    final newOpacity = (offset / 100).clamp(0.0, 1.0);
    if (newOpacity != _scrollOpacity) {
      setState(() {
        _scrollOpacity = newOpacity;
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
    final config = AppConfig.shared;
    // Reduced Winit header height from 70.0 to 60.0 to make it less elongated
    final double headerHeight = config.isWinit ? 60.0 : 56.0;
    // Total height including status bar for the background layer
    final double totalHeaderHeight = MediaQuery.of(context).padding.top + headerHeight;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // 1. SCROLLABLE CONTENT (Layer 0)
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Spacer
              SliverToBoxAdapter(
                child: SizedBox(
                  // Reduced extra spacing from + 16 to + 4
                  height: totalHeaderHeight + 4, 
                ),
              ),
              
              // Helper wrapper
              ...[
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RssFeedScreen(filterCategory: 'Money Back')),
                              );
                            },
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: Theme.of(context).brightness == Brightness.dark 
                                  ? [ config.primaryColor, config.primaryColor.withOpacity(0.7) ]
                                  : [ config.primaryColor, config.primaryColor.withOpacity(0.9) ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: config.primaryColor.withOpacity(0.6),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Gloss Effect
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(0.15),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Icon
                                Positioned(
                                  right: -20,
                                  bottom: -20,
                                  child: Transform.rotate(
                                    angle: -0.2,
                                    child: Icon(
                                      Icons.monetization_on_rounded,
                                      size: 150,
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                ),
                                
                                // Content
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
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
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'MONEY BACK',
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade(duration: 600.ms).slideX(begin: -0.1, end: 0),
                      ),
    
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
                                    iconSize: 30.0,
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
                
                if (config.hasCodesFeature) 
                  ValueListenableBuilder<int>(
                    valueListenable: _refreshNotifier,
                    builder: (context, value, child) {
                      return CodeList(
                        key: ValueKey(value),
                        scrollable: false, 
                        useSliver: true, 
                        limit: 4, 
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
                                  ? [ const Color(0xFF7B1FA2), const Color(0xFF4527A0) ]
                                  : [ const Color(0xFFE040FB), const Color(0xFF651FFF) ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (Theme.of(context).brightness == Brightness.dark 
                                      ? const Color(0xFF7B1FA2) 
                                      : const Color(0xFFE040FB)).withOpacity(0.6),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(0.15),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
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
                                            fontSize: 11,
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade(duration: 800.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                      ),
                      const SizedBox(height: 16),
                      const AdPlaceholder(),
                      const SizedBox(height: 16),
                      ReferralSection(referralSites: referralSites),
                      const SizedBox(height: 16),
                      const PrimeBanner(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                                  icon: const FaIcon(FontAwesomeIcons.telegram, color: Color(0xFF0088cc)),
                                  onPressed: () => _launchUrl('https://telegram.org'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Â© 2026 WinIt Codes. All rights reserved.',
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
            ],
          ),

          // 2. GLASS BACKGROUND (Layer 1 - Animated Blur)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: totalHeaderHeight,
            child: Opacity(
              opacity: _scrollOpacity, // Controlled by scroll
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                  child: Container(
                    color: (Theme.of(context).brightness == Brightness.dark 
                            ? Theme.of(context).colorScheme.surface 
                            : config.primaryColor).withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),

          // 3. HEADER CONTENT (Layer 2 - Always Visible, Transparent)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: headerHeight,
                child: AppBar(
                  primary: false,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: Colors.transparent, // Completely transparent
                  centerTitle: !config.isWinit,
                  leading: IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.bars,
                      // Interpolate color for Light Mode: Primary -> White as header fades in
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Color.lerp(config.primaryColor, Colors.white, _scrollOpacity),
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  actions: buildHeaderActions(
                    context, 
                    colorOverride: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Color.lerp(config.primaryColor, Colors.white, _scrollOpacity),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


