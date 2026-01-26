import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/ad_service.dart';
import '../models/cashback_code.dart';
import '../widgets/code_card.dart';
import '../providers/prime_provider.dart';
import '../services/ad_helper.dart';
import '../widgets/suggest_site_card.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  BannerAd? _topAd;
  BannerAd? _bottomAd;
  bool _isTopAdLoaded = false;
  bool _isBottomAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  void _loadAds() {
    if (kIsWeb) return;

    // Top Ad (Medium Rectangle for "Native" feel)
    _topAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId, // Using Banner ID but separate instance
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isTopAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('NotificationCenter: Top Ad failed to load: $error');
        },
      ),
    )..load();

    // Bottom Ad (Medium Rectangle)
    _bottomAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('NotificationCenter: Bottom Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _topAd?.dispose();
    _bottomAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPrime = Provider.of<PrimeProvider>(context).isPrime;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<CashbackCode>>(
        stream: FirestoreService().getCodes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error loading codes: ${snapshot.error}'));
          }

          final allCodes = snapshot.data ?? [];
          final now = DateTime.now();

          // Filter for ACTIVE codes only
          final activeCodes = allCodes.where((code) {
             var expiration = code.date;
             if (expiration.hour == 0 && expiration.minute == 0 && expiration.second == 0) {
                expiration = DateTime(expiration.year, expiration.month, expiration.day, 23, 59, 59);
             }
             return expiration.isAfter(now);
          }).toList();

          if (activeCodes.isEmpty) {
             return const Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('No active notifications right now.', style: TextStyle(color: Colors.grey)),
                 ],
               ),
             );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              // Top Ad
              if (!isPrime && _isTopAdLoaded && _topAd != null)
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  width: _topAd!.size.width.toDouble(),
                  height: _topAd!.size.height.toDouble(),
                  child: AdWidget(ad: _topAd!),
                ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'ACTIVE CODES (${activeCodes.length})',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              ...activeCodes.map((code) => CodeCard(cashbackCode: code)),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: SuggestSiteCard(),
              ),

              // Bottom Ad
              if (!isPrime && _isBottomAdLoaded && _bottomAd != null)
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  width: _bottomAd!.size.width.toDouble(),
                  height: _bottomAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bottomAd!),
                ),
            ],
          );
        },
      ),
    );
  }
}
