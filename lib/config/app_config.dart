import 'package:flutter/material.dart';

enum AppFlavor {
  winit,
  perks,
  swag,
  codblox,
  crypto,
}

class AppConfig {
  final AppFlavor flavor;
  final String appName;
  final String packageName;
  final Color primaryColor;
  final bool hasCodesFeature;
  final String rssUrl;
  final String drawerImage;
  final String logoImage;
  final String primeImage; // Added for customized Prime Logo
  final String elliotLogoImage; // Added for customized Elliot Logo
  final Color designerColor; // Added for customized Designed By Text
  
  // Singleton instance
  static AppConfig? _instance;

  // Private constructor
  AppConfig._internal({
    required this.flavor,
    required this.appName,
    required this.packageName,
    required this.primaryColor,
    required this.hasCodesFeature,
    required this.rssUrl,
    required this.drawerImage,
    required this.logoImage,
    required this.primeImage,
    required this.elliotLogoImage,
    required this.designerColor,
  });

  // Global access to the current config
  static AppConfig get shared {
    if (_instance == null) {
      throw Exception("AppConfig not initialized. Call AppConfig.create() first.");
    }
    return _instance!;
  }

  // Initialization method called from main_*.dart
  static void create({
    required AppFlavor flavor,
    required String appName,
    required String packageName,
    required Color primaryColor,
    required bool hasCodesFeature,
    required String rssUrl,
    required String drawerImage,
    required String logoImage,
    required String primeImage,
    required String elliotLogoImage,
    required Color designerColor,
  }) {
    _instance = AppConfig._internal(
      flavor: flavor,
      appName: appName,
      packageName: packageName,
      primaryColor: primaryColor,
      hasCodesFeature: hasCodesFeature,
      rssUrl: rssUrl,
      drawerImage: drawerImage,
      logoImage: logoImage,
      primeImage: primeImage,
      elliotLogoImage: elliotLogoImage,
      designerColor: designerColor,
    );
  }

  // Helper to check if current flavor is Winit (for legacy checks if needed)
  bool get isWinit => flavor == AppFlavor.winit;
}
