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
  );

  await mainCommon();
}
