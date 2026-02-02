import 'package:flutter/material.dart';
import '../models/referral_site.dart';
import '../screens/rss_feed_screen.dart';
import '../config/app_config.dart';

class ReferralSection extends StatelessWidget {
  final List<ReferralSite> referralSites;

  const ReferralSection({super.key, required this.referralSites});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const RssFeedScreen()),
                   );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DISCOVER MORE',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 20, // Match RECENT CODES size

                        color: AppConfig.shared.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppConfig.shared.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Unleash Your Earning Potential',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: referralSites.length,
            itemBuilder: (context, index) {
              final site = referralSites[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? AppConfig.shared.primaryColor // Dynamic Dark Border
                              : AppConfig.shared.primaryColor.withOpacity(0.3), 
                            width: 1
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? AppConfig.shared.primaryColor.withOpacity(0.15) // Dynamic Dark Background
                              : AppConfig.shared.primaryColor.withOpacity(0.08), // Dynamic Light Background
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: site.logoAssetsPath != null
                                ? Image.asset(
                                    site.logoAssetsPath!,
                                    fit: BoxFit.contain,
                                  )
                                : Text(site.name[0],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      site.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}



