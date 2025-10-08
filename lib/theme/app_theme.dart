import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color.fromARGB(255, 4, 139, 83); // Main accent
  static const Color secondary = Color.fromARGB(
    255,
    0,
    100,
    45,
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
