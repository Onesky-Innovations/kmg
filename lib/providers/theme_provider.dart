// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider with ChangeNotifier {
//   static const String _themeKey = 'isDarkMode';
//   bool _isDarkMode = false;

//   bool get isDarkMode => _isDarkMode;

//   ThemeProvider() {
//     _loadTheme();
//   }

//   void _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDarkMode = prefs.getBool(_themeKey) ?? false;
//     // Notify listeners so MyApp can get the saved theme immediately
//     notifyListeners();
//   }

//   // 💡 FIX: This method is now called by SettingsScreen
//   void toggleTheme(bool isOn) async {
//     _isDarkMode = isOn;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_themeKey, isOn);
//     // Notify listeners to rebuild the whole app with the new theme
//     notifyListeners();
//   }
// }

// // Custom Colors based on your original primary/secondary:
// const Color _lightPrimary = Color.fromARGB(255, 108, 55, 144);
// const Color _lightSecondary = Color.fromARGB(255, 81, 20, 134);

// // ----------------------------------------------------
// // THEME DEFINITIONS (Crucial for Dark Mode to work)
// // ----------------------------------------------------

// final ThemeData lightTheme = ThemeData(
//   brightness: Brightness.light,
//   primaryColor: _lightPrimary,
//   hintColor: _lightSecondary,
//   scaffoldBackgroundColor: const Color(0xFFF0F2F5),
//   cardColor: Colors.white,
//   appBarTheme: const AppBarTheme(
//     backgroundColor: _lightPrimary,
//     foregroundColor: Colors.white,
//   ),
//   colorScheme: const ColorScheme.light(
//     primary: _lightPrimary,
//     secondary: _lightSecondary,
//     background: Color(0xFFF0F2F5),
//     surface: Colors.white,
//   ),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: Color(0xFF212121)),
//     bodyMedium: TextStyle(color: Color(0xFF757575)),
//   ),
//   useMaterial3: true, // Recommended for modern Flutter apps
// );

// final ThemeData darkTheme = ThemeData(
//   brightness: Brightness.dark,
//   primaryColor: const Color.fromARGB(255, 51, 51, 51),
//   hintColor: const Color.fromARGB(255, 110, 110, 110),
//   scaffoldBackgroundColor: Colors.black,
//   cardColor: Colors.grey[900],
//   appBarTheme: AppBarTheme(
//     backgroundColor: const Color.fromARGB(255, 119, 119, 119),
//     foregroundColor: const Color.fromARGB(255, 182, 181, 181),
//   ),
//   colorScheme: ColorScheme.dark(
//     primary: const Color.fromARGB(255, 136, 135, 136),
//     secondary: const Color.fromARGB(255, 46, 46, 46),
//     background: Colors.black,
//     surface: Colors.grey[900]!,
//   ),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: Color.fromARGB(255, 153, 153, 153)),
//     bodyMedium: TextStyle(color: Colors.white70),
//   ),
//   useMaterial3: true,
// );

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeProvider - Handles persistent light/dark mode toggle.
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isOn);
    notifyListeners();
  }
}

//
// ───────────────────────────────────────────────────────────
// 🎨 COLOR SYSTEM
// ───────────────────────────────────────────────────────────
//

// --- Light Mode Colors ---
const Color _lightPrimary = Color(0xFF6C37C9);
const Color _lightSecondary = Color(0xFF512086);
const Color _lightSurface = Colors.white;
const Color _lightBackground = Color(0xFFF5F6FA);
const Color _lightText = Color(0xFF1C1C1E);
const Color _lightSubText = Color(0xFF707070);

// --- Dark Mode Colors ---
const Color _darkPrimary = Color(0xFFB79CFF);
const Color _darkSecondary = Color(0xFF8C6EFF);
const Color _darkSurface = Color(0xFF1E1E2C);
const Color _darkBackground = Color(0xFF12121B);
const Color _darkText = Color(0xFFECECEC);
const Color _darkSubText = Color(0xFFB8B8C6);

//
// ───────────────────────────────────────────────────────────
// 🌞 LIGHT THEME
// ───────────────────────────────────────────────────────────
//
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: _lightPrimary,
  scaffoldBackgroundColor: _lightBackground,

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: _lightPrimary,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),

  cardTheme: CardThemeData(
    color: _lightSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    shadowColor: Colors.black.withOpacity(0.1),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _lightPrimary,
    foregroundColor: Colors.white,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _lightSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightSecondary.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _lightPrimary, width: 1.4),
    ),
  ),

  colorScheme: const ColorScheme.light(
    primary: _lightPrimary,
    secondary: _lightSecondary,
    surface: _lightSurface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: _lightText,
  ),

  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: _lightText,
    ),
    bodyLarge: TextStyle(color: _lightText, fontSize: 16),
    bodyMedium: TextStyle(color: _lightSubText, fontSize: 14),
  ),
);

//
// ───────────────────────────────────────────────────────────
// 🌚 DARK THEME
// ───────────────────────────────────────────────────────────
//
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: const Color.fromARGB(255, 37, 26, 68),
  scaffoldBackgroundColor: const Color.fromARGB(255, 65, 65, 80),

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Color.fromARGB(255, 51, 51, 71),
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),

  cardTheme: CardThemeData(
    color: _darkSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    shadowColor: Colors.black.withOpacity(0.3),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color.fromARGB(255, 30, 5, 99),
    foregroundColor: Colors.white,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkSecondary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color.fromARGB(255, 59, 59, 75),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkSecondary.withOpacity(0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _darkPrimary, width: 1.4),
    ),
  ),

  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 51, 51, 104),
    secondary: Color.fromARGB(255, 30, 22, 59),
    surface: _darkSurface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: _darkText,
  ),

  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: _darkText,
    ),
    bodyLarge: TextStyle(color: _darkText, fontSize: 16),
    bodyMedium: TextStyle(color: _darkSubText, fontSize: 14),
  ),
);
