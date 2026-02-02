import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/prime_provider.dart';
import '../widgets/header_actions.dart';
import '../config/app_config.dart';

class PrimeOfferScreen extends StatelessWidget {
  const PrimeOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primeProvider = Provider.of<PrimeProvider>(context);
    final isPrime = primeProvider.isPrime;
    final products = primeProvider.products;
    final config = AppConfig.shared;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use app primary color or Golden for Prime branding? 
    // Usually Prime implies Gold/Premium, but maintaining app consistency is key.
    // Let's use a dynamic gradient based on app color but "richer".
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''), // Clean Look
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: buildHeaderActions(context, colorOverride: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. Premium Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                 ? [const Color(0xFF121212), Color.lerp(Colors.black, config.primaryColor, 0.2)!] // Carbon Black + Glow
                 : [
                     Color.lerp(config.primaryColor, Colors.black, 0.4)!,  
                     Color.lerp(config.primaryColor, Colors.black, 0.8)!
                   ], // Much darker/richer for premium feel & less eye strain
              ),
            ),
          ),
          
          // 2. Main Content
          SafeArea(
            child: SizedBox(
               width: double.infinity,
               child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center, // Center vertically if space allows
                  children: [
                    const SizedBox(height: 10), // Reduced from 20
                    
                    // Crown / Prime Badge (Simplified & Compact)
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(config.flavor == AppFlavor.perks ? 0.3 : 0.6), // Dimmer for Perks
                            blurRadius: config.flavor == AppFlavor.perks ? 25 : 50, // Less blur for Perks
                            spreadRadius: 1, 
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        config.primeImage,
                        height: 120, // Increased from 90
                        width: 120, 
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 20), // Reduced from 32
                    
                    // Title
                    Text(
                      isPrime ? 'PRIME MEMBER' : 'UPGRADE TO PRIME',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22, // Reduced from 26
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,4))],
                      ),
                    ),
                    
                    const SizedBox(height: 8), // Reduced from 12
                    
                    // Subtitle
                    Text(
                      isPrime 
                        ? 'Thank you for your support!' 
                        : 'Remove ads and unlock the full potential of ${config.appName}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, // Reduced from 15
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 24), // Reduced from 48

                    // Feature List (Compact Glass Card)
                    if (!isPrime) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Reduced padding
                      decoration: BoxDecoration(
                         color: Colors.black.withOpacity(0.2), // Dark transparent card
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureItem(Icons.block, 'Ad-Free Experience', 'Browse without interruptions'),
                          const Divider(color: Colors.white12, height: 20), // Reduced height
                          _buildFeatureItem(Icons.bolt, 'Priority Updates', 'Get new codes faster'),
                          const Divider(color: Colors.white12, height: 20), // Reduced height
                          _buildFeatureItem(Icons.verified_user_outlined, 'Premium Support', 'Direct access to developer'),
                        ],
                      ),
                    ) else 
                    // Success View
                    Container(
                       padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(24),
                         border: Border.all(color: Colors.greenAccent),
                       ),
                       child: Column(
                         children: const [
                           Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 50),
                           SizedBox(height: 12),
                           Text(
                             "You are all set!",
                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                           ),
                         ],
                       ),
                    ),

                    const SizedBox(height: 24), // Reduced from 48

                    // Action Button
                    if (!isPrime) 
                      if (products.isEmpty)
                         primeProvider.statusMessage != null 
                             ? Text(primeProvider.statusMessage!, style: const TextStyle(color: Colors.white)) 
                             : const CircularProgressIndicator(color: Colors.white)
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => primeProvider.buyPrime(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: config.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14), // Reduced padding
                              elevation: 8,
                              shadowColor: Colors.black45,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'UPGRADE FOR ${products.first.price}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),

                    if (!isPrime) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => primeProvider.restorePurchases(),
                        child: Text(
                          'Restore Purchase',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
         Container(
           padding: const EdgeInsets.all(10),
           decoration: BoxDecoration(
             color: Colors.white.withOpacity(0.1),
             shape: BoxShape.circle,
           ),
           child: Icon(icon, color: Colors.white, size: 24),
         ),
         const SizedBox(width: 16),
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 title,
                 style: const TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.bold,
                   fontSize: 16,
                 ),
               ),
               const SizedBox(height: 4),
               Text(
                 subtitle,
                 style: TextStyle(
                   color: Colors.white.withOpacity(0.7),
                   fontSize: 13,
                 ),
               ),
             ],
           ),
         )
      ],
    );
  }
}
