import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'code_search_delegate.dart';
import '../services/firestore_service.dart';
import '../models/cashback_code.dart';
import '../screens/notification_center_screen.dart';

List<Widget> buildHeaderActions(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final iconColor = isDark ? Colors.white70 : Colors.white;

  return [
    // 1. Search (Magnifying Glass)
    IconButton(
      icon: FaIcon(FontAwesomeIcons.magnifyingGlass, color: iconColor, size: 20),
      tooltip: 'Search Codes',
      onPressed: () {
        showSearch(
          context: context,
          delegate: CodeSearchDelegate(),
        );
      },
    ),
    
    // 2. Share
    IconButton(
      icon: FaIcon(FontAwesomeIcons.shareNodes, color: iconColor, size: 20),
      tooltip: 'Share App',
      onPressed: () => _shareApp(context),
    ),

    // 3. Notification Bell with Badge
    StreamBuilder<List<CashbackCode>>(
      stream: FirestoreService().getCodes(),
      builder: (context, snapshot) {
        int activeCount = 0;
        if (snapshot.hasData) {
          final now = DateTime.now();
          activeCount = snapshot.data!.where((code) {
             var expiration = code.date;
             if (expiration.hour == 0 && expiration.minute == 0 && expiration.second == 0) {
                expiration = DateTime(expiration.year, expiration.month, expiration.day, 23, 59, 59);
             }
             return expiration.isAfter(now);
          }).length;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: FaIcon(FontAwesomeIcons.bell, color: iconColor, size: 22),
              tooltip: 'Notifications',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationCenterScreen()),
                );
              },
            ),
            if (activeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    activeCount > 9 ? '9+' : activeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    ),
    const SizedBox(width: 8), // Right padding
  ];
}

void _shareApp(BuildContext context) {
  String message = 'Check out this app for cashback codes and discounts! ';
  String link = 'https://play.google.com/store/apps/details?id=com.andromo.dev717025.app1043119';

  if (!kIsWeb) {
    if (Platform.isAndroid) {
      link = 'https://play.google.com/store/apps/details?id=com.andromo.dev717025.app1043119';
    } else if (Platform.isIOS) {
      link = 'https://apps.apple.com/app/winit/id123456789'; 
    }
  }

  Share.share('$message\n\n$link');
}
