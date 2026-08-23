import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  static const Color _softPink = Color(0xFFF7C6D4);
  static const Color _darkBackground = Color(0xFF180D12);
  static const Color _darkSurface = Color(0xFF26171E);

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _softPink,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 2,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF9FC),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFFE783A5),
      unselectedItemColor: Color(0xFFB79BA7),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _softPink,
      brightness: Brightness.dark,
      surface: _darkBackground,
    ),
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _softPink,
      foregroundColor: Color(0xFF3A1725),
      elevation: 2,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _softPink,
      unselectedItemColor: Color(0xFFD6B9C4),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF49313B)),
  );

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
