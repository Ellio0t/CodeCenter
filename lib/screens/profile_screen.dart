import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import 'suggest_site_screen.dart';
import '../widgets/suggest_site_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  
  // Group 1: Cashback & Games
  bool _moneyBackEnabled = true;
  bool _gamesEnabled = true;

  // Group 2: Codes (Dynamic Providers)
  List<String> _providers = [];
  final Map<String, bool> _subscriptions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // 1. Load Preferences
    final prefs = await SharedPreferences.getInstance();
    _moneyBackEnabled = prefs.getBool('sub_money_back') ?? true;
    _gamesEnabled = prefs.getBool('sub_game_center') ?? true;

    // 2. Fetch Providers from Firestore
    try {
      _providers = await FirestoreService().getUniqueProviders();
    } catch (e) {
      _providers = []; 
    }

    // 3. Load Subscription States
    for (var provider in _providers) {
      final key = _getPrefKey(provider);
      _subscriptions[provider] = prefs.getBool(key) ?? true;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Helpers
  String _getPrefKey(String provider) => 'sub_${provider.replaceAll(RegExp(r'\s+'), '').toLowerCase()}';
  String _getTopic(String provider) => 'topic_${provider.replaceAll(RegExp(r'\s+'), '').toLowerCase()}';

  Future<void> _toggleMoneyBack(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _moneyBackEnabled = value);
    await prefs.setBool('sub_money_back', value);
    
    if (value) {
      NotificationService().subscribeToTopic('money_back');
    } else {
      NotificationService().unsubscribeFromTopic('money_back');
    }
  }

  Future<void> _toggleGames(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _gamesEnabled = value);
    await prefs.setBool('sub_game_center', value);
    
    if (value) {
      NotificationService().subscribeToTopic('game_center');
    } else {
      NotificationService().unsubscribeFromTopic('game_center');
    }
  }

  Future<void> _toggleProvider(String provider, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _subscriptions[provider] = value;
    });
    await prefs.setBool(_getPrefKey(provider), value);

    final topic = _getTopic(provider);
    if (value) {
      NotificationService().subscribeToTopic(topic);
    } else {
      NotificationService().unsubscribeFromTopic(topic);
    }
  }

  Widget _buildGroupTile(BuildContext context, String title, IconData icon, List<Widget> children, {bool initiallyExpanded = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: primaryColor),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF10D34E)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // USER INFO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                   CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF10D34E).withOpacity(0.2),
                    backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.displayName ?? user.email ?? "U")[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32, color: Color(0xFF10D34E), fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(Icons.person, "Name", user.displayName ?? "Guest User", isDark),
                  Divider(height: 1, indent: 52, color: isDark ? Colors.white10 : Colors.grey[100]),
                  _buildInfoRow(Icons.email, "Email", user.email ?? "No Email Linked", isDark),
                  Divider(height: 1, indent: 52, color: isDark ? Colors.white10 : Colors.grey[100]),
                  _buildInfoRow(Icons.calendar_today, "Joined", 
                    user.metadata.creationTime != null 
                      ? "${user.metadata.creationTime!.year}-${user.metadata.creationTime!.month.toString().padLeft(2, '0')}-${user.metadata.creationTime!.day.toString().padLeft(2, '0')}"
                      : "Unknown", 
                  isDark),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            // Notification Preferences
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 4),
                child: Text(
                  "SUBSCRIPTIONS", 
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            if (user.isAnonymous)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Sign in to manage your subscriptions.",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            else if (_isLoading)
               const Center(child: CircularProgressIndicator())
            else
               Column(
                 children: [
                    _buildGroupTile(context, 'CASHBACK', Icons.monetization_on_rounded, [
                       SwitchListTile(
                        title: Text('Money Back', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                        value: _moneyBackEnabled,
                        activeColor: primaryColor,
                        onChanged: _toggleMoneyBack,
                      ),
                    ]),

                    _buildGroupTile(context, 'GAMES', Icons.games_rounded, [
                      SwitchListTile(
                        title: Text('Game Center', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                        value: _gamesEnabled,
                        activeColor: primaryColor,
                        onChanged: _toggleGames,
                      ),
                    ]),

                    _buildGroupTile(context, 'CODES', Icons.qr_code, 
                      _providers.map((provider) {
                        return SwitchListTile(
                          title: Text(provider, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                          dense: true,
                          value: _subscriptions[provider] ?? true,
                          activeColor: primaryColor,
                          onChanged: (val) => _toggleProvider(provider, val),
                        );
                      }).toList(),
                      initiallyExpanded: true,
                    ),
                 ],
               ),


            const SizedBox(height: 24),
            const SuggestSiteCard(),
            const SizedBox(height: 24),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _authService.signOut();
                  if (mounted) Navigator.pop(context); 
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
