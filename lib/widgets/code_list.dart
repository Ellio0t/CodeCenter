import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cashback_code.dart';
import '../services/firestore_service.dart';
import '../widgets/code_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/ad_placeholder.dart';
import 'package:flutter/foundation.dart';

class CodeList extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final bool scrollable;
  final bool useSliver;
  final int? limit;
  final bool showAds;
  final bool useNativeAds;

  CodeList({
    super.key, 
    this.scrollable = false,
    this.useSliver = false,
    this.limit,
    this.showAds = false,
    this.useNativeAds = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CashbackCode>>(
      stream: _firestoreService.getCodes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final errorWidget = const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Error loading codes. Please check your connection.'),
            ),
          );
          return useSliver ? SliverToBoxAdapter(child: errorWidget) : errorWidget;
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          final loadingWidget = const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
          return useSliver ? SliverToBoxAdapter(child: loadingWidget) : loadingWidget;
        }
        
        var codes = snapshot.data ?? [];
        if (codes.isEmpty) {
          final emptyWidget = const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No codes available at the moment.'),
            ),
          );
          return useSliver ? SliverToBoxAdapter(child: emptyWidget) : emptyWidget;
        }

        // Filter: Only allow single-word site names (as per app requirements),
        // BUT allow specific exceptions like "My Points" or "Perk Code" as requested.
        codes = codes.where((c) {
           final name = c.siteName.trim();
           if (name.contains(' ')) {
             // Exceptions for multi-word site names that are valid
             final lower = name.toLowerCase();
             if (lower.contains('points') || lower.contains('perk')) {
               return true;
             }
             return false;
           }
           return true;
        }).toList();
        
        if (codes.isEmpty) {
           final emptyWidget = const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No matching codes available.'),
            ),
          );
          return useSliver ? SliverToBoxAdapter(child: emptyWidget) : emptyWidget;
        }

        // Apply Limit if provided
        if (limit != null) {
          codes = codes.take(limit!).toList();
        }

        Widget buildAdWidget() {
           if (useNativeAds) {
             return const AdPlaceholder();
           } else {
             return Container(
               alignment: Alignment.center,
               width: double.infinity,
               height: 60,
               child: const BannerAdWidget(),
             );
           }
        }
        
        // Return SliverList if requested
        if (useSliver) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                 if (showAds && index > 0 && (index + 1) % 3 == 0 && !kIsWeb) {
                   return Column(
                     children: [
                       CodeCard(cashbackCode: codes[index]),
                       const SizedBox(height: 16),
                       buildAdWidget(),
                       const SizedBox(height: 16),
                     ],
                   ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0);
                 }
                return CodeCard(cashbackCode: codes[index])
                    .animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0);
              },
              childCount: codes.length,
            ),
          );
        }

        if (scrollable) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: codes.length,
            itemBuilder: (context, index) {
              if (showAds && index > 0 && (index + 1) % 3 == 0 && !kIsWeb) {
                return Column(
                  children: [
                    CodeCard(cashbackCode: codes[index]),
                    const SizedBox(height: 16),
                    buildAdWidget(),
                    const SizedBox(height: 16),
                  ],
                ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0);
              }
              return CodeCard(cashbackCode: codes[index])
                  .animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0);
            },
          );
        }

        List<Widget> children = [];
        for (int i = 0; i < codes.length; i++) {
          children.add(
            CodeCard(cashbackCode: codes[i])
                .animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0)
          );
          // Insert ad after every 3 items (at index 2, 5, 8...)
          if (showAds && (i + 1) % 3 == 0 && i < codes.length - 1 && !kIsWeb) {
             children.add(const SizedBox(height: 16));
             children.add(buildAdWidget());
             children.add(const SizedBox(height: 16));
          }
        }

        return Column(
          children: children,
        );
      },
    );
  }
}
