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
    );
  }

  // Helper to check if current flavor is Winit (for legacy checks if needed)
  bool get isWinit => flavor == AppFlavor.winit;
}
