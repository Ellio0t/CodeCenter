import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/prime_provider.dart';
import '../widgets/custom_header.dart';
import '../widgets/header_actions.dart';
import '../config/app_config.dart'; // Added

class PrimeOfferScreen extends StatelessWidget {
  const PrimeOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primeProvider = Provider.of<PrimeProvider>(context);
    final isPrime = primeProvider.isPrime;
    final products = primeProvider.products;
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: 'WINIT PRIME',
            actions: buildHeaderActions(context),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Theme.of(context).brightness == Brightness.dark 
                    ? [Theme.of(context).scaffoldBackgroundColor, const Color(0xFF121212)] 
                    : [Colors.white, const Color(0xFFF0FDF4)],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (primeProvider.statusMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          primeProvider.statusMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Golden Glow Logo
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.6), // Gold Glow
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          AppConfig.shared.drawerImage, // Dynamic Flavor Image
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isPrime ? 'You are a Prime Member!' : 'Upgrade to Prime',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPrime 
                          ? 'Thank you for supporting WinIt. Enjoy your ad-free experience.' 
                          : 'Enjoy a distraction-free experience and support the development of WinIt.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (!isPrime) ...[
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFeatureRow(context, 'No More Ads', FontAwesomeIcons.ban),
                            const SizedBox(height: 16),
                            _buildFeatureRow(context, 'Prioritized Code Updates', FontAwesomeIcons.bolt),
                            const SizedBox(height: 16),
                            _buildFeatureRow(context, 'Get Early Access to New Reward Sites', FontAwesomeIcons.bell),
                            const SizedBox(height: 16),
                            _buildFeatureRow(context, 'Exclusive Premium Support', FontAwesomeIcons.headset),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      if (!primeProvider.isAvailable)
                        const Text('Store unavailable', style: TextStyle(color: Colors.red))
                      else if (products.isEmpty)
                         if (primeProvider.statusMessage != null)
                           const SizedBox.shrink()
                         else
                           const CircularProgressIndicator(color: Color(0xFF10D34E))
                      else
                        ElevatedButton(
                          onPressed: () {
                            primeProvider.buyPrime();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10D34E),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Get Prime for ${products.first.price}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                       const SizedBox(height: 16),
                       TextButton(
                         onPressed: () {
                           primeProvider.restorePurchases();
                         },
                         child: const Text('Restore Purchases', style: TextStyle(color: Color(0xFF10D34E))),
                       ),

                    ] else ...[
                       const Icon(Icons.check_circle, color: Color(0xFF10D34E), size: 64),
                       const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFeatureRow(BuildContext context, String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF10D34E), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
