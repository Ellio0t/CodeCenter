import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'ad_helper.dart';

class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  
  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;
  final int _maxFailedLoadAttempts = 3;
  
  DateTime? _appOpenAdLastShownTime;
  static const Duration _appOpenAdCoolDown = Duration(hours: 1);

  DateTime? _rewardedAdLastShownTime;
  static const Duration _rewardedAdCoolDown = Duration(minutes: 3);

  DateTime? _lastAdDismissedTime;


  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadAppOpenAd();
    _loadRewardedInterstitialAd();
  }

  String get appOpenAdUnitId {
    if (kIsWeb) return '';
    return AdHelper.appOpenAdUnitId;
  }

  String get rewardedInterstitialAdUnitId {
    if (kIsWeb) return '';
    return AdHelper.rewardedInterstitialAdUnitId;
  }


  // --- App Open Ad Logic ---

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('AdService: App Open Ad loaded');
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('AdService: App Open Ad failed to load: $error');
        },
      ),
    );
  }

  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAppOpenAdIfAvailable() {
    if (!isAdAvailable || _isShowingAd) {
      print('AdService: Tried to show ad, but unavailable or already showing.');
      _loadAppOpenAd();
      return;
    }

    if (_appOpenAdLastShownTime != null && 
        DateTime.now().difference(_appOpenAdLastShownTime!) < _appOpenAdCoolDown) {
      print('AdService: App Open Ad in cool-down. Not showing.');
      return;
    }

    if (_lastAdDismissedTime != null && 
        DateTime.now().difference(_lastAdDismissedTime!) < const Duration(milliseconds: 2000)) {
       print('AdService: App Open Ad suppressed (recently dismissed another ad).');
       return;
    }
    
    
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        _appOpenAdLastShownTime = DateTime.now();
        print('AdService: onAdShowedFullScreenContent');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('AdService: onAdDismissedFullScreenContent');
        _isShowingAd = false;
        _lastAdDismissedTime = DateTime.now();
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('AdService: onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
  }

  // --- Rewarded Interstitial Logic ---

  void _loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: rewardedInterstitialAdUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('AdService: Rewarded Interstitial Ad loaded');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('AdService: Rewarded Interstitial Ad failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < _maxFailedLoadAttempts) {
              _loadRewardedInterstitialAd();
            }
          },
        ));
  }

  void showRewardedInterstitialAd({required Function onReward, Function? onFailure}) {
    if (_rewardedAdLastShownTime != null && 
        DateTime.now().difference(_rewardedAdLastShownTime!) < _rewardedAdCoolDown) {
      print('AdService: Rewarded Ad in cool-down. Granting reward without showing ad.');
      onReward();
      return;
    }

    if (_rewardedInterstitialAd == null) {
      print('AdService: Warning: Attempted to show rewarded interstitial before loaded.');
      onReward(); // If ad isn't ready, give reward anyway (don't block user)
      _loadRewardedInterstitialAd();
      return;
    }

    bool rewardEarned = false;

    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) {
        print('AdService: Rewarded Interstitial Ad showed.');
        _isShowingAd = true;
        _rewardedAdLastShownTime = DateTime.now();
      },
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('AdService: Rewarded Interstitial Ad dismissed.');
        _isShowingAd = false;
        ad.dispose();
        _lastAdDismissedTime = DateTime.now();
        _rewardedInterstitialAd = null;
        _loadRewardedInterstitialAd();
        
        if (!rewardEarned) {
          if (onFailure != null) onFailure();
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedInterstitialAd ad, AdError error) {
        print('AdService: Rewarded Interstitial Ad failed to show: $error');
        _isShowingAd = false;
        ad.dispose();
        _rewardedInterstitialAd = null;
        _loadRewardedInterstitialAd();
        onReward(); // Use fallback
      },
    );

    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print('AdService: User earned reward: ${reward.amount} ${reward.type}');
        rewardEarned = true;
        onReward();
      });
  }

  // --- Banner Ad Logic ---

  String get bannerAdUnitId {
    if (kIsWeb) return ''; // Return empty or test ID for web
    return AdHelper.bannerAdUnitId;
  }

  BannerAd? createBannerAd() {
    if (kIsWeb) return null; // No banners on web for now
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('AdService: Banner Ad loaded'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('AdService: Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }
}
