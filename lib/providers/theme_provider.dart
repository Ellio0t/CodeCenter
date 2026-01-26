import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Accessing window platform brightness requires SchedulerBinding or context
      // For simplicity in non-UI logic, we might default or check bindings
      // But typically we reply on the UI to rebuild.
      // Here we just return true if strictly dark, but UI handles system automatically.
      return _themeMode == ThemeMode.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', isDark ? 'dark' : 'light');
  }
  
  // Method to set system default
  void setSystem() async {
    _themeMode = ThemeMode.system;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('themeMode');
  }
}
