import 'package:flutter/material.dart';
import '../models/cashback_code.dart';
import '../services/firestore_service.dart';
import '../widgets/code_card.dart';

class CodeSearchDelegate extends SearchDelegate {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  String get searchFieldLabel => 'Search Codes...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFF10D34E),
        foregroundColor: isDark ? Colors.white70 : Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.white70),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: isDark ? Colors.white70 : Colors.white,
          fontSize: 18,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: isDark ? const Color(0xFF10D34E) : Colors.white,
        selectionColor: isDark ? const Color(0xFF10D34E).withOpacity(0.3) : Colors.white24,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchList();
  }

  Widget _buildSearchList() {
    return StreamBuilder<List<CashbackCode>>(
      stream: _firestoreService.getCodes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading codes'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final codes = snapshot.data ?? [];
        
        final filteredCodes = codes.where((code) {
          final q = query.toLowerCase();
          final siteName = code.siteName.toLowerCase();
          final codeText = code.code.toLowerCase();
          final description = code.description.toLowerCase();

          return siteName.contains(q) || 
                 codeText.contains(q) || 
                 description.contains(q);
        }).toList();

        if (filteredCodes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$query"',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredCodes.length,
          itemBuilder: (context, index) {
            return CodeCard(cashbackCode: filteredCodes[index]);
          },
        );
      },
    );
  }
}
