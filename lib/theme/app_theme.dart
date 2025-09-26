import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color.fromARGB(255, 255, 176, 57);
  static const Color secondary = Color.fromARGB(255, 247, 50, 247);
  static const Color background = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color iconOnPrimary = Colors.white;
}
