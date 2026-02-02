import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'main_common.dart';

void main() async {
  AppConfig.create(
    flavor: AppFlavor.perks,
    appName: "Perks",
    packageName: "com.andromo.dev717025.app994579",
    primaryColor: const Color(0xFFF33308),
    hasCodesFeature: true,
    rssUrl: "https://feeds.feedburner.com/pointperk",
    drawerImage: "images/perk_drawer.png",
    logoImage: "images/perk-app.png",
    primeImage: "images/per_prime.png",
    elliotLogoImage: "images/elliot_perk.png",
    designerColor: const Color(0xFF18FFFF), // Cyan Accent
  );

  await mainCommon();
}
