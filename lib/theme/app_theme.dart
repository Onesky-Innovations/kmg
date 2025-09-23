import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color.fromARGB(255, 79, 91, 254);
  static const Color secondary = Color.fromARGB(255, 236, 134, 236);
  static const Color background = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color iconOnPrimary = Colors.white;
}
