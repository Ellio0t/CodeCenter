import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'about_screen.dart';
import '../screens/faq_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Master Switch
  bool _notificationsEnabled = true;
  
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
    
    // 1. Load Master Preference & Static Groups
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
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

  // Helper to generate consistent keys/topics
  String _getPrefKey(String provider) => 'sub_${provider.replaceAll(RegExp(r'\s+'), '').toLowerCase()}';
  String _getTopic(String provider) => 'topic_${provider.replaceAll(RegExp(r'\s+'), '').toLowerCase()}';

  Future<void> _toggleMasterSwitch(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = value;
    });
    await prefs.setBool('notifications_enabled', value);

    if (value) {
      // Re-subscribe to everything enabled
      if (_moneyBackEnabled) NotificationService().subscribeToTopic('money_back');
      if (_gamesEnabled) NotificationService().subscribeToTopic('game_center');
      
      for (var provider in _providers) {
        if (_subscriptions[provider] == true) {
          NotificationService().subscribeToTopic(_getTopic(provider));
        }
      }
      NotificationService().subscribeToTopic('new_codes'); // Always sub to general
    } else {
      // Unsubscribe from EVERYTHING
      NotificationService().unsubscribeFromTopic('money_back');
      NotificationService().unsubscribeFromTopic('game_center');
      for (var provider in _providers) {
        NotificationService().unsubscribeFromTopic(_getTopic(provider));
      }
      NotificationService().unsubscribeFromTopic('new_codes');
    }
  }

  Future<void> _toggleMoneyBack(bool value) async {
    if (!_notificationsEnabled) return;
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
    if (!_notificationsEnabled) return;
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
     if (!_notificationsEnabled) return;

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
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: primaryColor),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isGuest = AuthService().currentUser?.isAnonymous ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // MASTER SWITCH
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    title: const Text('Receive Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Enable or disable all app notifications'),
                    value: _notificationsEnabled,
                    activeColor: primaryColor,
                    onChanged: isGuest ? null : _toggleMasterSwitch,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (isGuest)
                   Padding(
                     padding: const EdgeInsets.only(top: 24.0),
                     child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.lock_outline, color: Colors.grey, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to manage preferences",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                          ),
                        ],
                      ),
                                       ),
                   )
                else
                  Opacity(
                    opacity: _notificationsEnabled ? 1.0 : 0.5,
                    child: IgnorePointer(
                      ignoring: !_notificationsEnabled,
                      child: Column(
                        children: [
                          // GROUP 1: CASHBACK
                          _buildGroupTile(context, 'CASHBACK', Icons.monetization_on_rounded, [
                             SwitchListTile(
                              title: const Text('Money Back'), // Removed 'Alerts'
                              value: _moneyBackEnabled,
                              activeColor: primaryColor,
                              onChanged: _toggleMoneyBack,
                            ),
                          ]),

                          // GROUP 2: GAMES
                          _buildGroupTile(context, 'GAMES', Icons.games_rounded, [
                            SwitchListTile(
                              title: const Text('Game Center'), // Removed 'Alerts'
                              value: _gamesEnabled,
                              activeColor: primaryColor,
                              onChanged: _toggleGames,
                            ),
                          ]),

                          // GROUP 3: CODES
                          _buildGroupTile(context, 'CODES', Icons.qr_code, 
                            _providers.map((provider) {
                              return SwitchListTile(
                                title: Text(provider),
                                dense: true,
                                value: _subscriptions[provider] ?? true,
                                activeColor: primaryColor,
                                onChanged: (val) => _toggleProvider(provider, val),
                              );
                            }).toList(),
                            initiallyExpanded: true, // Keep Codes open by default contextually? User said reduce buttons. False might be better, but Codes is main feature. Let's stick to user request for less clutter -> Default closed or open? I'll make it default false actually, or true only for codes. Let's leave false for all to be cleaner.
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // SUPPORT SECTION
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.help_outline, color: primaryColor),
                        title: const Text('Frequently Questions'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FaqScreen()),
                          );
                        },
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? Colors.white10 : Colors.grey[100]),
                      ListTile(
                        leading: Icon(Icons.info_outline, color: primaryColor),
                        title: const Text('About App'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AboutScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    'WinIt Version 2.2.1',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
    );
  }
}
