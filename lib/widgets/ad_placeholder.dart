import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/prime_provider.dart';

import '../services/ad_helper.dart';

class AdPlaceholder extends StatefulWidget {
  const AdPlaceholder({super.key});

  @override
  State<AdPlaceholder> createState() => _AdPlaceholderState();
}

class _AdPlaceholderState extends State<AdPlaceholder> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  late final String _adUnitId;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _adUnitId = AdHelper.nativeAdUnitId;
      _loadAd();
    } else {
      _adUnitId = '';
    }
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('AdPlaceholder: Ad failed to load: $error');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF10D34E),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          style: NativeTemplateFontStyle.italic,
          size: 14.0,
        ),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Prime Check: If Prime, hide ad completely.
    final isPrime = Provider.of<PrimeProvider>(context).isPrime;
    if (isPrime) return const SizedBox.shrink();

    // 2. Web Check: If Web, hide ad.
    if (kIsWeb) return const SizedBox.shrink();

    // 3. Ad Loaded Check: Show ad if ready.
    if (_isAdLoaded && _nativeAd != null) {
      return Container(
        height: 370, // Increased height to prevent vertical cutting
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Reduced margin for more width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AdWidget(ad: _nativeAd!),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
