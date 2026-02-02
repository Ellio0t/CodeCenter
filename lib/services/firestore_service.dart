import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/cashback_code.dart';
import '../config/app_config.dart';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart'; // Import generated options

class FirestoreService {
  // Use a future to ensure initialization
  Future<FirebaseFirestore> _getDb() async {
    // 1. Check if current default app is 'winitcode' (The Master DB)
    if (Firebase.app().options.projectId == 'winitcode') {
      return FirebaseFirestore.instance;
    }

    // 2. If we are in a flavor (e.g. Perks/point-perks), we need to connect to WinitCode
    try {
      // Check if already initialized
      final app = Firebase.app('CodeCenterMaster');
      return FirebaseFirestore.instanceFor(app: app);
    } catch (e) {
      // Not initialized, initialize it now
      // We use 'android' options as a baseline
      FirebaseOptions options = DefaultFirebaseOptions.currentPlatform;

      // CRITICAL: Override AppID for specific flavors to match what is registered in 'winitcode' project.
      // This ensures the Package Name + App ID pair is valid for API Key restrictions.
      if (defaultTargetPlatform == TargetPlatform.android) {
         final flavor = AppConfig.shared.flavor;
         if (flavor == AppFlavor.perks) {
            // "Perks" App ID registered in 'winitcode' project
            options = FirebaseOptions(
              apiKey: options.apiKey,
              appId: '1:66500442999:android:8d7e6d4fd33c5be28c3f72', 
              messagingSenderId: options.messagingSenderId,
              projectId: options.projectId,
              databaseURL: options.databaseURL,
              storageBucket: options.storageBucket,
            );
         } else if (flavor == AppFlavor.swag) {
             options = FirebaseOptions(
              apiKey: options.apiKey, // Using generic API Key from winitcode
              appId: '1:66500442999:android:2eff0b7d8f9e9ede8c3f72', // Swag App ID
              messagingSenderId: options.messagingSenderId,
              projectId: options.projectId,
              databaseURL: options.databaseURL,
              storageBucket: options.storageBucket,
            );
         } else if (flavor == AppFlavor.codblox) {
             options = FirebaseOptions(
              apiKey: options.apiKey,
              appId: '1:66500442999:android:d541a20a96bb8a2d8c3f72', // Codblox App ID
              messagingSenderId: options.messagingSenderId,
              projectId: options.projectId,
              databaseURL: options.databaseURL,
              storageBucket: options.storageBucket,
            );
         } else if (flavor == AppFlavor.crypto) {
             options = FirebaseOptions(
              apiKey: options.apiKey,
              appId: '1:66500442999:android:f6b454661662f6be8c3f72', // Crypto App ID
              messagingSenderId: options.messagingSenderId,
              projectId: options.projectId,
              databaseURL: options.databaseURL,
              storageBucket: options.storageBucket,
            );
         }
      }

      final masterApp = await Firebase.initializeApp(
        name: 'CodeCenterMaster',
        options: options, 
      );
      return FirebaseFirestore.instanceFor(app: masterApp);
    }
  }

  // Stream of Cashback Codes
  Stream<List<CashbackCode>> getCodes() {
    print('FirestoreService: Fetching codes...');
    
    // Convert Future<Firestore> to Stream logic
    // Since we need to await the DB, we use a Stream.fromFuture or async* 
    // But we want to return a Stream that listen to snapshots.
    
    return Stream.fromFuture(_getDb()).asyncExpand((db) {
       print('FirestoreService: Connected to DB Project: ${db.app.options.projectId}');
       return db.collection('codes')
        .orderBy('date', descending: true)
        .limit(500) 
        .snapshots();
    })
    .map((snapshot) {
      print('FirestoreService: Received snapshot with ${snapshot.docs.length} documents.');
      
      List<CashbackCode> allParsedCodes = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        try {
          DateTime parsedDate;
          var dateValue = data['date'];
          
          if (dateValue is Timestamp) {
            parsedDate = dateValue.toDate();
          } else if (dateValue is String) {
            try {
              // Intenta formatos comunes
              parsedDate = DateFormat('MMMM d, yyyy').parse(dateValue);
            } catch (e1) {
              try {
                parsedDate = DateTime.parse(dateValue);
              } catch (e2) {
                parsedDate = DateTime.now(); 
              }
            }
          } else {
            parsedDate = DateTime.now();
          }

          final siteName = data['siteName'] ?? 'No Name';
          final code = data['code'] ?? 'No Code';
          final description = data['description'] ?? 'No Description';
          // Extract flavor, default to 'winit' if missing (Legacy compatibility)
          var codeFlavor = (data['flavor'] as String?)?.toLowerCase() ?? 'winit';
          if (codeFlavor == 'perk') codeFlavor = 'perks';
          
          // Filtering logic: 
          // 1. Skip invalid or placeholder entries
          // 2. Filter by Flavor (Client-side filtering is simpler than maintaining 5+ compound indexes)
          
          if (siteName == 'No Name' || siteName.isEmpty ||
              code == 'No Code' || code.isEmpty ||
              description == 'No Description') {
            continue;
          }

          // Flavor Check:
          final currentFlavor = AppConfig.shared.flavor.name; // e.g., 'winit', 'perks'
          
          // Rules:
          // - If I am Winit: Show 'winit' AND codes with no flavor (legacy) -> Handled by default 'winit' above
          // - If I am Perks: Show ONLY 'perks'
          
          // Auto-Correction for Legacy Data:
          // If flavor is missing (defaulted to 'winit') BUT siteName clearly indicates another app, fix it dynamically.
          String finalFlavor = codeFlavor;
          
          if (finalFlavor == 'winit') { // Only check if it claims to be winit (or default)
            final String lowerSite = siteName.toLowerCase();
            if (lowerSite.contains('swagbucks') || lowerSite.contains('sb')) {
              finalFlavor = 'swag';
            } else if (lowerSite.contains('mypoints') || lowerSite.contains('point') || lowerSite.contains('perk')) {
              finalFlavor = 'perks';
            } else if (lowerSite.contains('roblox')) {
              finalFlavor = 'codblox';
            } else if (lowerSite.contains('crypto') || lowerSite.contains('airdrop')) {
              finalFlavor = 'crypto';
            }
          }

          if (finalFlavor != currentFlavor) {
             // Debug print only if we are in Perks app to see what's being skipped
             if (currentFlavor == 'perks') {
                 print('Skipping code "$code" ($siteName) - Resolved Flavor: $finalFlavor vs Current: $currentFlavor');
             }
             continue; 
          } else {
             if (currentFlavor == 'perks') {
                 print('Including code "$code" ($siteName) for Perks app.');
             }
          }
          
          allParsedCodes.add(CashbackCode(
            siteName: siteName,
            code: code,
            description: description,
            date: parsedDate,
          ));

        } catch (e) {
          print('FirestoreService: Error mapping document ${doc.id}: $e');
        }
      }

      // Ordenar en memoria: Más reciente (Futuro/Hoy) -> Más antiguo
      allParsedCodes.sort((a, b) => b.date.compareTo(a.date));

      // Deduplicación: Mantener el primero que encontremos (que será el más reciente debido al sort)
      final Set<String> seenKeys = {};
      final List<CashbackCode> uniqueSortedCodes = [];

      for (var item in allParsedCodes) {
        final key = '${item.siteName}-${item.code}';
        if (!seenKeys.contains(key)) {
          seenKeys.add(key);
          uniqueSortedCodes.add(item);
        }
      }

      return uniqueSortedCodes;
    }).handleError((error) {
      print('FirestoreService: Stream error: $error');
      // Return empty list on error so stream doesn't die? 
      // Or just rethrow/print. The original code just printed.
      // Keeping consistent return type is hard in map's handleError without changing stream type
      // But we can just let the stream emit the error or handle it in the UI.
      throw error; 
    });
  }
  // Get list of unique providers (site names)
  Future<List<String>> getUniqueProviders() async {
    try {
      final db = await _getDb();
      // Fetch a reasonable number of recent codes to find active providers
      final snapshot = await db.collection('codes')
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      final Set<String> providers = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final siteName = data['siteName'] as String?;
          // 1. Validar nombre base
          if (siteName != null && siteName.isNotEmpty && siteName != 'No Name' && siteName != 'Unknown') {
            
            // 2. EXCLUSIÓN EXPLÍCITA (Solicitado por usuario)
            if (siteName == 'Five Nights TD 2' || siteName == 'Swagbucks') continue;

            // 3. FILTRO ESTRICTO: Solo nombres de UNA PALABRA (sin espacios)
            // Esto elimina automáticamente "Five Nights TD 2", "Bingo Blitz", etc. 
            // Solo permitirá "Bingo", "Swagbucks", "MyPoints", etc.
            if (!siteName.trim().contains(' ')) {
               providers.add(siteName);
            }
          }
      }
      
      // Removed fallback logic to strict filtering: Only return providers found in DB
      
      return providers.toList()..sort();
    } catch (e) {
      print('Error fetching providers: $e');
      return []; // Return empty list instead of hardcoded fallbacks
    }
  }
  // Submit a site suggestion
  Future<void> submitSiteSuggestion({required String name, required String url, required String reason}) async {
    final db = await _getDb();
    await db.collection('site_suggestions').add({
      'name': name,
      'url': url,
      'reason': reason,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }
}
