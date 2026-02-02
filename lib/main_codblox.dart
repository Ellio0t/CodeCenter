import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'main_common.dart';

void main() async {
  AppConfig.create(
    flavor: AppFlavor.codblox,
    appName: "Codblox",
    packageName: "com.newandromo.dev9693.app884425",
    primaryColor: const Color(0xFF434C53),
    hasCodesFeature: false,
    rssUrl: "https://feeds.feedburner.com/codblox",
    drawerImage: "images/roblox_drawer.png",
    logoImage: "images/roblox-app.png",
    primeImage: "images/roblox-app.png",
    elliotLogoImage: "images/elliot_codblox.png",
    designerColor: const Color(0xFF69F0AE), // Green Accent
  );

  await mainCommon();
}
