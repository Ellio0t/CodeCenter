import 'package:flutter/material.dart';
import 'package:winit/screens/home_screen.dart';
import 'package:winit/screens/rss_feed_screen.dart';
import 'package:winit/screens/profile_screen.dart';
import 'package:winit/widgets/floating_nav_bar.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  
  // Pages
  // 0: Home
  // 1: Cashback (Money Back)
  // 2: Games
  // 3: Profile
  final List<Widget> _pages = [
    HomeScreen(isBottomNav: true), // Modified constructor needed potentially, or just use as is
    const RssFeedScreen(filterCategory: 'Money Back'),
    const RssFeedScreen(filterCategory: 'Games'),
    const ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Critical for floating effect
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: FloatingNavBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
