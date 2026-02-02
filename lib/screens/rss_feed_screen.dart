import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_header.dart';
import '../widgets/header_actions.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../widgets/banner_ad_widget.dart'; // Keeping for now if needed, or remove if unused.
import '../widgets/ad_placeholder.dart';
import '../widgets/suggest_site_card.dart';
import 'dart:io';
import '../config/app_config.dart';

class RssFeedScreen extends StatefulWidget {
  final String? filterCategory;

  const RssFeedScreen({super.key, this.filterCategory});

  @override
  _RssFeedScreenState createState() => _RssFeedScreenState();
}

class _RssFeedScreenState extends State<RssFeedScreen> {
  // static const String rssUrl = 'https://www.winitcode.com/rss.xml'; // REMOVED
  String get rssUrl => AppConfig.shared.rssUrl;
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _readIds = {};

  @override
  void initState() {
    super.initState();
    _loadReadStatus();
    _fetchFeed();
  }

  Future<void> _loadReadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList('read_news_ids');
      print('RSS: Loading read status - Found ${savedIds?.length ?? 0} read items');
      if (savedIds != null && mounted) {
        setState(() {
          _readIds = Set<String>.from(savedIds);
        });
        print('RSS: Loaded read IDs: $_readIds');
      }
    } catch (e) {
      print('RSS: Error loading read status: $e');
    }
  }

  Future<void> _markAsRead(String id) async {
    if (id.isEmpty || _readIds.contains(id)) {
      print('RSS: Skipping mark as read - ID: $id (empty: ${id.isEmpty}, already read: ${_readIds.contains(id)})');
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _readIds.add(id);
      });
      await prefs.setStringList('read_news_ids', _readIds.toList());
      print('RSS: Marked as read - ID: $id, Total read: ${_readIds.length}');
    } catch (e) {
      print('RSS: Error marking as read: $e');
    }
  }

  Future<void> _fetchFeed() async {
    try {
      print('RSS: [STEP 1] Starting fetch sequence via rss2json...');
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
          _items = [];
        });
      }

      // rss2json is extremely reliable for Flutter Web as it acts as a permanent CORS proxy
      final String apiUrl = 'https://api.rss2json.com/v1/api.json?rss_url=${Uri.encodeComponent(rssUrl)}';
      
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 15));
      print('RSS: [STEP 2] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok') {
          if (mounted) {
            setState(() {
              List<dynamic> allItems = data['items'] ?? [];
              if (widget.filterCategory != null) {
                _items = allItems.where((item) {
                   final categories = item['categories'];
                   if (categories is List) {
                     // If filtering by 'Games', use a broader set of keywords
                     if (widget.filterCategory == 'Games') {
                       final gameKeywords = ['game', 'games', 'gaming', 'play', 'bingo', 'puzzle', 'casino', 'slot', 'arcade', 'matches', 'mahjong', 'solitaire', 'esport', 'console', 'mobile'];
                       return categories.any((cat) {
                         final lowerCat = cat.toString().toLowerCase();
                         return gameKeywords.any((keyword) => lowerCat.contains(keyword));
                       });
                     }
                     // Default single category match
                     // Relaxed Money Back filter: Check for 'Money' (covers Money Back) only
                     if (widget.filterCategory == 'Money Back') {
                       return categories.any((cat) {
                         final lowerCat = cat.toString().toLowerCase();
                         return lowerCat.contains('money'); 
                       });
                     }
                     return categories.any((cat) => cat.toString().toLowerCase().contains(widget.filterCategory!.toLowerCase()));
                   }
                   return false;
                }).toList();
              } else {
                if (allItems.length > 9) {
                  _items = allItems.take(9).toList();
                } else {
                  _items = allItems;
                }
              }
              _isLoading = false;
            });
          }
          print('RSS: [STEP 3] Successfully loaded ${_items.length} items (Filter: ${widget.filterCategory})');
        } else {
          throw 'API Error: ${data['message'] ?? 'Unknown'}';
        }
      } else {
        throw 'HTTP Error: ${response.statusCode}';
      }
    } catch (e) {
      print('RSS: [ERROR] $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'COULD NOT LOAD NEWS. ERROR: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  String? _extractImageUrl(dynamic item) {
    String? rawUrl;
    
    // 1. Try thumbnail first (often low res, but we will fix it later)
    if (item['thumbnail'] != null && item['thumbnail'].toString().isNotEmpty) {
      rawUrl = item['thumbnail'];
    } 
    // 2. Look in enclosure
    else if (item['enclosure'] != null && item['enclosure']['link'] != null) {
      rawUrl = item['enclosure']['link'];
    }
    // 3. Parse content/description for img tags
    else {
      final content = item['content'] ?? item['description'] ?? '';
      if (content.isNotEmpty) {
        try {
          final document = parse(content);
          final imgTag = document.getElementsByTagName('img').firstOrNull;
          rawUrl = imgTag?.attributes['src'];
        } catch (_) {}
      }
    }

    if (rawUrl == null) return null;

    // --- UPGRADE QUALITY (Blogger/Google Images) ---
    // s0 = Original Size on Blogger/Google Photos
    final RegExp sizePattern = RegExp(r'([/=])s\d+([-][chw])?');
    if (rawUrl.contains('googleusercontent.com') || rawUrl.contains('blogspot.com')) {
      rawUrl = rawUrl.replaceAllMapped(sizePattern, (match) => '${match.group(1)}s0');
    }

    // Force proxy to ensure CORS compliance and high quality on Web
    // q=100 for maximum quality, w=1200 for crisp HD cards
    return 'https://images.weserv.nl/?url=${Uri.encodeComponent(rawUrl)}&w=1200&q=100&n=-1';
  }

  @override
  Widget build(BuildContext context) {
    // Determine Color based on Category
    Color? headerColor;
    if (widget.filterCategory == 'Money Back') {
      headerColor = AppConfig.shared.primaryColor; // Green/Brand for Money Back
    }
    // Reverted Games color to default (Green/Theme) by not setting it here for Games

    return Scaffold(
      body: Column(
        children: [
          // Custom Header matching Home Screen
          CustomHeader(
            title: widget.filterCategory == 'Money Back' 
                ? 'CASHBACK' 
                : (widget.filterCategory == 'Games' ? 'GAMES' : 'NEWS'),
            backgroundColor: headerColor,
            onRefresh: _fetchFeed,
          ),
          
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppConfig.shared.primaryColor),
                        const SizedBox(height: 16),
                        const Text('LOADING LATEST NEWS...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchFeed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConfig.shared.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('RETRY'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length + 2, // +1 for header, +1 for footer
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              children: [
                                const SizedBox(height: 16),
                                const AdPlaceholder(),
                                const SizedBox(height: 16),
                              ],
                            );
                          }
                          
                          // Footer: Suggest Site Card
                          if (index == _items.length + 1) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 32.0, top: 16.0),
                              child: SuggestSiteCard(),
                            );
                          }

                          // adjustedIndex is the index within _items
                          final int adjustedIndex = index - 1;
                          final item = _items[adjustedIndex];
                          
                          // --- AD LOGIC: Insert Native Ad every 3 items ---
                          if (adjustedIndex > 0 && (adjustedIndex + 1) % 3 == 0 && !kIsWeb) {
                             return Column(
                               children: [
                                 _buildNewsCard(item),
                                 const SizedBox(height: 16),
                                 const AdPlaceholder(),
                                 const SizedBox(height: 16),
                               ],
                             );
                          }
                          // ---------------------------------------------
                          
                          return _buildNewsCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Extracted card builder for reuse
  Widget _buildNewsCard(dynamic item) {
                        final imageUrl = _extractImageUrl(item);
                        final itemId = item['guid']?.toString() ?? item['link']?.toString() ?? '';
                        final bool isNew = !_readIds.contains(itemId);
                        print('RSS: Item ID: $itemId, isNew: $isNew');

                        return GestureDetector(
                          onTap: () {
                            print('RSS: Tapped item with ID: $itemId');
                            if (itemId.isNotEmpty) _markAsRead(itemId);
                            _launchUrl(item['link'] ?? '');
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            height: 170, 
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppConfig.shared.primaryColor,
                                  AppConfig.shared.primaryColor.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              image: imageUrl != null && imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.45), // Lighter overlay
                                      BlendMode.darken,
                                    ),
                                  )
                                : null,
                          ),
                          child: Stack(
                            children: [
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      gradient: isNew ? LinearGradient(
                                        colors: [AppConfig.shared.primaryColor, AppConfig.shared.primaryColor.withOpacity(0.6)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ) : null,
                                      color: isNew ? null : Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isNew 
                                          ? Colors.transparent 
                                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.white24),
                                      ),
                                      boxShadow: isNew ? [
                                        BoxShadow(
                                          color: AppConfig.shared.primaryColor.withOpacity(0.6),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        )
                                      ] : [],
                                    ),
                                    child: Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: isNew ? FontWeight.w900 : FontWeight.bold,
                                        letterSpacing: 2.0,
                                        shadows: isNew ? [
                                          const Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          )
                                        ] : [],
                                      ),
                                    ),
                                  ),
                                ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Text(
                                    item['title'] ?? 'No Title',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18, // Reduced size
                                      fontWeight: FontWeight.bold, // Reduced weight
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 15.0, // Reduced blur
                                          color: Colors.black,
                                          offset: Offset(0, 0),
                                        ),
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black,
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ],
                            ),
                          ),
                        );
  }
}

// BannerAdWidget refactored to separate file


