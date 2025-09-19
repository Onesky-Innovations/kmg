import 'package:flutter/material.dart';

class AppLogoName extends StatelessWidget {
  final String logoPath;
  final String appName;
  final double logoSize;
  final TextStyle? nameStyle;

  const AppLogoName({
    super.key,
    this.logoPath = 'assets/logo.png', // dummy logo
    this.appName = 'KMG', // dummy app name
    this.logoSize = 40,
    this.nameStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // App logo
        Image.asset(
          logoPath,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Show a placeholder if logo not found
            return Container(
              width: logoSize,
              height: logoSize,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            );
          },
        ),
        const SizedBox(width: 8),
        // App name
        Text(
          appName,
          style: nameStyle ??
              const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}
