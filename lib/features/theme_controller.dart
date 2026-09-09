import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const _key = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'dark') {
      value = ThemeMode.dark;
    } else if (saved == 'light') {
      value = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value == ThemeMode.dark ? 'dark' : 'light');
  }
}
