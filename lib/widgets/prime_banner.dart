import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prime_provider.dart';
import '../screens/prime_offer_screen.dart';
import '../config/app_config.dart'; // Added

class PrimeBanner extends StatelessWidget {
  const PrimeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // If user is already Prime, hide this banner
    final isPrime = context.watch<PrimeProvider>().isPrime;
    if (isPrime) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrimeOfferScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // Background Container
              Container(
                constraints: const BoxConstraints(minHeight: 70), // Dynamic height with minimum
                margin: const EdgeInsets.only(left: 30),
                padding: const EdgeInsets.only(left: 80, right: 16, top: 4, bottom: 4), 
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF10D34E), // WinIt Green
                      Color(0xFFFFD700), // Gold
                      Color(0xFFFFA500), // Orange
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10D34E).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Upgrade to Prime',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16, // Reduced to fix overflow
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Remove ads & get exclusive features!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10, // Reduced from 11
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 14, // Reduced size
                    ),
                  ],
                ),
              ),
              // Pop-out Image
              Positioned(
                left: -15,
                bottom: -5,
                child: Stack( // Wrapped in Stack for Glow
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                             color: const Color(0xFFFFD700).withOpacity(0.8), // Stronger Gold Glow
                             blurRadius: 25,
                             spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      AppConfig.shared.drawerImage, // Dynamic Flavor Image
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
