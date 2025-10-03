// import 'package:flutter/material.dart';

// class AppTheme {
//   static const Color primary = Color.fromARGB(255, 255, 176, 57);
//   static const Color secondary = Color.fromARGB(255, 247, 50, 247);
//   static const Color background = Colors.white;

//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [primary, secondary],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//   static const Color iconOnPrimary = Colors.white;
//   static const Color ActiveIconOnPrimary = Color.fromARGB(255, 247, 50, 247);

//   static var primaryColor;

//   static var darkText;
// }

// import 'package:flutter/material.dart';

// class AppTheme {
//   static const Color primary = Color.fromARGB(
//     255,
//     255,
//     176,
//     57,
//   ); // Your defined primary color
//   static const Color secondary = Color.fromARGB(255, 247, 50, 247);
//   static const Color background = Colors.white;

//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [primary, secondary],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//   static const Color iconOnPrimary = Colors.white;
//   static const Color activeIconOnPrimary = Color.fromARGB(
//     255,
//     247,
//     50,
//     247,
//   ); // Corrected casing

//   // CORRECTED: Initialize primaryColor and darkText
//   static const Color primaryColor = primary; // Referencing your 'primary' color
//   static const Color darkText = Color(0xFF212121); // A dark gray for text
//   static const Color lightText = Color(
//     0xFF757575,
//   ); // A lighter gray for secondary text
// }

// kmg/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color.fromARGB(255, 255, 176, 57); // Main accent
  static const Color secondary = Color.fromARGB(
    255,
    247,
    50,
    247,
  ); // Secondary accent

  static const Color background = Color(
    0xFFF0F2F5,
  ); // Lighter, modern background
  static const Color cardBackground = Colors.white; // White for cards

  static const Color darkText = Color(0xFF212121);
  static const Color lightText = Color(0xFF757575); // For secondary text

  static const Color primaryColor = primary; // Alias for consistent use
  static const Color accentColor = secondary; // Alias for consistent use

  static const Color iconOnPrimary =
      Colors.white; // Icons on primary background
  static const Color activeIconOnPrimary =
      secondary; // Active icon color on primary

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
