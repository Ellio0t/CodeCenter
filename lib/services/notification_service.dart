import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

// This must be a top-level function
@pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }

  // OPTIMIZATION: Check this FIRST.
  // If the message brings a notification payload, Android displays it automatically.
  // We exit immediately to save resources/battery and prevent duplicates.
  if (message.notification != null) {
      // print("System handling notification. Exiting background handler."); 
      return; 
  }

  // Initialize Local Notifications only if we absolutely need to post a manual notification (Data-only message)
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('small_icon');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await localNotifications.initialize(initializationSettings);

  await NotificationService.showNotification(message, localNotifications);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request Permission (iOS / Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // I will replace the block inside initialize() 
    
    // Subscribe to topics (Not supported on Web yet)
    // Subscribe to topics (Not supported on Web yet)
    if (!kIsWeb) {
      // 1. Global Channel for all flavors
      await _firebaseMessaging.subscribeToTopic('center');
      if (kDebugMode) print("Subscribed to global topic: center");

      // 2. Flavor specific channel (Legacy 'new_codes' for Winit compatibility)
      try {
        final flavor = AppConfig.shared.flavor;
        String flavorTopic;

        if (flavor == AppFlavor.winit) {
          flavorTopic = 'new_codes';
        } else {
          flavorTopic = 'new_codes_${flavor.name}';
        }

        await _firebaseMessaging.subscribeToTopic(flavorTopic);
        if (kDebugMode) print("Subscribed to flavor topic: $flavorTopic");

      } catch (e) {
        print("Error getting AppConfig flavor: $e");
        // Fallback or ignore
      }

      // 3. Restore User Preferences Subscriptions (Money Back, Games)
      try {
        final prefs = await SharedPreferences.getInstance();
        final bool masterEnabled = prefs.getBool('notifications_enabled') ?? true;

        if (masterEnabled) {
          // Money Back
          if (prefs.getBool('sub_money_back') ?? true) {
            await _firebaseMessaging.subscribeToTopic('money_back');
            if (kDebugMode) print("Restored subscription: money_back");
          }
          // Game Center
          if (prefs.getBool('sub_game_center') ?? true) {
            await _firebaseMessaging.subscribeToTopic('game_center');
            if (kDebugMode) print("Restored subscription: game_center");
          }
        }
      } catch (e) {
        print("Error restoring subscriptions: $e");
      }
    }

    // 2. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Setup Local Notifications (for Foreground display)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('small_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
         if (kDebugMode) {
           print("Notification tapped with payload: ${response.payload}");
         }
      },
    );
    
    // Create a high importance channel for Android
    if (!kIsWeb) {
      await _createNotificationChannel();
    }

    // 4. Listen to Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showNotification(message, _localNotifications);
      }
    });

    _isInitialized = true;
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel_v2', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications and new codes.', // description
      importance: Importance.max,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Static method to be used by both foreground and background handlers
  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) { // Removed 'android != null' check to force display even if android metadata is missing
      BigPictureStyleInformation? bigPictureStyleInformation;
      
      // Load Large Icon (large192x192.png) - ALWAYS
      Uint8List? largeIcon;
      try {
        final ByteData iconBytes = await rootBundle.load('images/large192x192.png');
        largeIcon = iconBytes.buffer.asUint8List();
      } catch (e) {
        if (kDebugMode) print('Error loading large icon: $e');
      }

      // Custom Text Formatting and Categorization
      String finalTitle = notification.title ?? "WinIt Code Center";
      String finalBody = notification.body ?? "Tap to check for new codes";

      // Categorization Logic (based on data payload)
      // Expecting data: { "type": "code" | "money_back" | "game_center" | "news" }
      if (message.data.containsKey('type')) {
        final String type = message.data['type'].toString().toLowerCase();
        
        switch (type) {
          case 'code':
            finalTitle = finalTitle;
            break;
          case 'money_back':
          case 'cashback':
            finalTitle = finalTitle;
            break;
          case 'game_center':
          case 'games':
            finalTitle = finalTitle;
            break;
          case 'news':
            finalTitle = finalTitle;
            break;
          default:
            finalTitle = finalTitle;
        }
      } else {
         finalTitle = finalTitle; 
      }

      // Big Picture Logic: URL or Default Local Asset (big500x300.png)
      if (android?.imageUrl != null) {
        try {
          final http.Response response = await http.get(Uri.parse(android!.imageUrl!));
          if (response.statusCode == 200) {
            final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(response.bodyBytes);
             bigPictureStyleInformation = BigPictureStyleInformation(
              bigPicture,
              largeIcon: largeIcon != null ? ByteArrayAndroidBitmap(largeIcon) : null, 
              contentTitle: finalTitle,
              hideExpandedLargeIcon: true, 
              htmlFormatContentTitle: true,
              summaryText: finalBody,
              htmlFormatSummaryText: true,
            );
          }
        } catch (e) {
          if (kDebugMode) print('Error downloading notification image: $e');
        }
      } 
      
      // Fallback: Use local big500x300.png
      if (bigPictureStyleInformation == null) {
         try {
           final ByteData bannerBytes = await rootBundle.load('images/big500x300.png'); 
           final Uint8List bannerIcon = bannerBytes.buffer.asUint8List();
           final ByteArrayAndroidBitmap defaultBigPicture = ByteArrayAndroidBitmap(bannerIcon);

           bigPictureStyleInformation = BigPictureStyleInformation(
              defaultBigPicture,
              largeIcon: largeIcon != null ? ByteArrayAndroidBitmap(largeIcon) : null,
              contentTitle: finalTitle,
              hideExpandedLargeIcon: true, 
              htmlFormatContentTitle: true,
              summaryText: finalBody,
              htmlFormatSummaryText: true,
           );
         } catch (e) {
           if (kDebugMode) print('Error loading default banner: $e');
         }
      }

      await fln.show(
        notification.hashCode,
        finalTitle,
        finalBody,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel_v2',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications and new codes.',
            icon: 'small_icon',
            color: const Color(0xFFFE3406),
            largeIcon: largeIcon != null ? ByteArrayAndroidBitmap(largeIcon) : null, 
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false, // Hide timestamp/date
            // Styling options
            styleInformation: bigPictureStyleInformation ?? BigTextStyleInformation(finalBody),
          ),
        ),
      );
    }
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // --- Topic Subscription Management for Settings ---
  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) return; // Topics not supported on web client SDK yet
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) print('Subscribed to topic: $topic');
    } catch (e) {
      if (kDebugMode) print('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) return;
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) print('Unsubscribed from topic: $topic');
    } catch (e) {
      if (kDebugMode) print('Error unsubscribing from topic $topic: $e');
    }
  }
}

