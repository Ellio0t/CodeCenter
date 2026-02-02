import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'main_common.dart';

void main() async {
  AppConfig.create(
    flavor: AppFlavor.crypto,
    appName: "Crypto",
    packageName: "com.newandromo.dev9693.app1383025",
    primaryColor: const Color(0xFF0465FF),
    hasCodesFeature: false,
    rssUrl: "https://www.airdropcrypto.net/rss.xml",
    drawerImage: "images/crypto_drawer.png",
    logoImage: "images/aidrop_app.png",
    primeImage: "images/aidrop_app.png",
    elliotLogoImage: "images/elliot_crypto.png",
    designerColor: const Color(0xFFFFD740), // Amber Accent
  );

  await mainCommon();
}
