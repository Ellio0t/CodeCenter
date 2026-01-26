import 'dart:io';

class AdHelper {
  // ============================================================
  // AD UNIT IDS - REPLACE THESE WITH YOUR PRODUCTION IDS
  // ============================================================

  // Android Ad Unit IDs
  static const String _androidAppOpenAdId = 'ca-app-pub-5133623535393963/2065084575'; 
  static const String _androidRewardedInterstitialAdId = 'ca-app-pub-5133623535393963/1737781517'; 
  static const String _androidBannerAdId = 'ca-app-pub-5133623535393963/3839015453'; 
  static const String _androidNativeAdId = 'ca-app-pub-5133623535393963/3378166241';

  // iOS Ad Unit IDs
  static const String _iosAppOpenAdId = 'ca-app-pub-3940256099942544/5662855259'; // Test ID
  static const String _iosRewardedInterstitialAdId = 'ca-app-pub-3940256099942544/6978759866'; // Test ID
  static const String _iosBannerAdId = 'ca-app-pub-3940256099942544/2934735716'; // Test ID
  static const String _iosNativeAdId = 'ca-app-pub-3940256099942544/3986624511'; // Test ID

  // ============================================================

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) return _androidAppOpenAdId;
    if (Platform.isIOS) return _iosAppOpenAdId;
    return '';
  }

  static String get rewardedInterstitialAdUnitId {
    if (Platform.isAndroid) return _androidRewardedInterstitialAdId;
    if (Platform.isIOS) return _iosRewardedInterstitialAdId;
    return '';
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) return _androidBannerAdId;
    if (Platform.isIOS) return _iosBannerAdId;
    return '';
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) return _androidNativeAdId;
    if (Platform.isIOS) return _iosNativeAdId;
    return '';
  }
}
