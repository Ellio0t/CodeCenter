import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/ad_service.dart';
import 'package:provider/provider.dart';
import 'providers/prime_provider.dart';
import 'providers/theme_provider.dart';
import 'config/app_config.dart'; // Import AppConfig

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On Android/iOS, we rely on the native GoogleService-Info.plist / google-services.json
  // which are flavor-specific. Passing 'options' overrides this with the default (Winit) config.
  // We only use the Dart-configured options for Web/Desktop.
  FirebaseOptions? options;
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || 
      defaultTargetPlatform == TargetPlatform.linux || 
      defaultTargetPlatform == TargetPlatform.macOS) {
    options = DefaultFirebaseOptions.currentPlatform;
  }

  await Firebase.initializeApp(
    options: options,
  );

  // Enable Edge-to-Edge for Android 15 compliance
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrimeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        StreamProvider<User?>(
          create: (_) => AuthService().authStateChanges,
          initialData: FirebaseAuth.instance.currentUser,
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  late Future<void> _appInitFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appInitFuture = _initServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !kIsWeb) {
      final isPrime = Provider.of<PrimeProvider>(context, listen: false).isPrime;
      if (!isPrime) {
        AdService().showAppOpenAdIfAvailable();
      }
    }
  }

  Future<void> _initServices() async {
    // Firebase is already initialized in main
    if (!kIsWeb) {
      await AdService().initialize();
    }
    final notificationService = NotificationService();
    notificationService.initialize();
    
    if (!kIsWeb) {
      notificationService.getToken().then((token) {
        if (kDebugMode) print('FCM Token: $token');
      });

      // Poll for App Open Ad availability REMOVED for speed
      // int attempts = 0;
      // while (!AdService().isAdAvailable && attempts < 20) { ... }

      if (mounted) {
        final isPrime = Provider.of<PrimeProvider>(context, listen: false).isPrime;
        if (!isPrime) {
           AdService().showAppOpenAdIfAvailable();
        }
      }
    }
    
    // Auto-login as Guest if not authenticated - Fire and forget for speed
    final authService = AuthService();
    if (authService.currentUser == null) {
       authService.signInAnonymously().catchError((e) {
        debugPrint("Error auto-signing in as guest: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<User?>(context);
    
    // 🎨 Get Dynamic Config
    final config = AppConfig.shared;

    return MaterialApp(
      title: config.appName, // dynamic Title
      themeMode: themeProvider.themeMode,
      // Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: config.primaryColor, // dynamic Color
          primary: config.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
           backgroundColor: Colors.white,
           surfaceTintColor: Colors.transparent,
        ),
      ),
      // Dark Theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: config.primaryColor, // dynamic Color
          primary: config.primaryColor, // Use primary as base
          // secondary: const Color(0xFF43A047), // Defaulting secondary to derived
          surface: const Color(0xFF1E1E1E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF1E1E1E),
        canvasColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
           backgroundColor: Color(0xFF121212),
           surfaceTintColor: Colors.transparent,
           foregroundColor: Colors.white,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFFB0BEC5), // Muted icon color
          textColor: Color(0xFFE0E0E0), // Off-white text
        ),
      ),
      home: FutureBuilder(
        future: _appInitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Updated: Always go to HomeScreen (Guest Mode supported)
            return HomeScreen();
          }
          return const SplashScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
