import 'package:flutter/material.dart';
import '../widgets/code_list.dart';
import '../widgets/ad_placeholder.dart';
import '../widgets/custom_header.dart';
import '../widgets/header_actions.dart';
import '../widgets/suggest_site_card.dart';

class ClaimCodeScreen extends StatelessWidget {
  const ClaimCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: 'CLAIM CODE',
            actions: buildHeaderActions(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
              children: [
                 const SizedBox(height: 16),
                 const AdPlaceholder(),
                 const SizedBox(height: 16),
                 const Padding(
                   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                   child: SuggestSiteCard(),
                 ),
                 const SizedBox(height: 16),
                 CodeList(
                   showAds: true,
                   useNativeAds: true,
                   limit: 12,
                 ),
                 const SizedBox(height: 24),
                 const Padding(
                   padding: EdgeInsets.symmetric(horizontal: 16.0),
                   child: SuggestSiteCard(),
                 ),
                 const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
