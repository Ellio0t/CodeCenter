import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'main_common.dart';

void main() async {
  AppConfig.create(
    flavor: AppFlavor.swag,
    appName: "Swag",
    packageName: "net.andromo.dev717025.app859913",
    primaryColor: const Color(0xFFAAD324),
    hasCodesFeature: true,
    rssUrl: "http://feeds.feedburner.com/SwagbucksFeed",
    drawerImage: "images/swag_drawer.png",
    logoImage: "images/swag-app.png",
    primeImage: "images/swag-app.png",
    elliotLogoImage: "images/elliot_swag.png",
    designerColor: const Color(0xFFE040FB), // Purple Accent
  );

  await mainCommon();
}
