import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/cashback_code.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of Cashback Codes
  Stream<List<CashbackCode>> getCodes() {
    print('FirestoreService: Fetching codes...');
    // Aumentamos el límite para asegurar que obtenemos una mezcla reciente
    // y ordenamos en memoria para corregir posibles inconsistencias de formato de fecha en la BD.
    return _db.collection('codes')
        .orderBy('date', descending: true)
        .limit(50) 
        .snapshots()
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
          
          // Filtering logic: Skip invalid or placeholder entries
          if (siteName == 'No Name' || siteName.isEmpty ||
              code == 'No Code' || code.isEmpty ||
              description == 'No Description') {
            continue;
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
      // Fetch a reasonable number of recent codes to find active providers
      final snapshot = await _db.collection('codes')
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      final Set<String> providers = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final siteName = data['siteName'] as String?;
        if (siteName != null && siteName.isNotEmpty && siteName != 'No Name' && siteName != 'Unknown') {
          providers.add(siteName);
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
    await _db.collection('site_suggestions').add({
      'name': name,
      'url': url,
      'reason': reason,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }
}
