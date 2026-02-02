import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'main_common.dart';

void main() async {
  // Default entry point runs Winit flavor
  AppConfig.create(
    flavor: AppFlavor.winit,
    appName: "WinIt",
    packageName: "com.winit.app",
    primaryColor: const Color(0xFF00C853),
    hasCodesFeature: true,
    rssUrl: "https://www.winitcode.com/rss.xml",
    drawerImage: "images/menu.png",
    logoImage: "images/winit-app.png",
    primeImage: "images/primer.png",
  );

  await mainCommon();
}

