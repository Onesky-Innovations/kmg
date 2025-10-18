// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:provider/provider.dart'; // 💡 NEW: Import Provider
// import 'package:kmg/providers/theme_provider.dart'; // 💡 NEW: Import ThemeProvider
// import 'package:kmg/screens/legal/privacy_screen.dart';

// // Placeholder screens - replace with your actual screen imports
// import 'delete_account_screen.dart';
// import 'package:kmg/screens/settings/sign_in_screen.dart';
// import 'package:kmg/screens/legal/contact_support_screen.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   String selectedLanguage = "English";

//   Future<void> _launchExternalUrl(String url) async {
//     final uri = Uri.parse(url);
//     if (!await launchUrl(uri)) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Could not open $url')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDarkMode = themeProvider.isDarkMode;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // ------------------------------------
//           // 1. GENERAL SETTINGS
//           // ------------------------------------
//           _buildSettingsHeader('General'),
//           const Divider(),

//           SwitchListTile(
//             title: const Text("Dark Mode"),
//             value: isDarkMode,
//             secondary: const Icon(Icons.brightness_4),
//             onChanged: (val) {
//               themeProvider.toggleTheme(val);
//             },
//           ),

//           _buildLanguageSelector(),

//           const SizedBox(height: 20),

//           // ------------------------------------
//           // 2. SUPPORT & LEGAL (All Users)
//           // ------------------------------------
//           _buildSettingsHeader('Support & Legal'),
//           const Divider(),

//           ListTile(
//             title: const Text("Contact Us"),
//             leading: const Icon(Icons.headphones_outlined),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const ContactSupportScreen('general'),
//                 ),
//               );
//             },
//           ),
//           ListTile(
//             title: const Text("Privacy Policy"),
//             leading: const Icon(Icons.policy),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
//               );
//             },
//           ),
//           ListTile(
//             title: const Text("View Policy Online"),
//             subtitle: const Text("External link for legal notice"),
//             leading: const Icon(Icons.open_in_new, size: 20),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () => _launchExternalUrl(
//               'https://sites.google.com/view/kmgclassifieds/privacy-policy',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Reusable Widget Builders ---

//   Widget _buildSettingsHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguageSelector() {
//     return ListTile(
//       title: const Text("Language"),
//       subtitle: Text(selectedLanguage),
//       leading: const Icon(Icons.language),
//       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: () async {
//         final lang = await showDialog<String>(
//           context: context,
//           builder: (context) => SimpleDialog(
//             title: const Text("Select Language"),
//             children: [
//               SimpleDialogOption(
//                 onPressed: () => Navigator.pop(context, "English"),
//                 child: const Text("English"),
//               ),
//             ],
//           ),
//         );
//         if (lang != null) {
//           setState(() => selectedLanguage = lang);
//         }
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kmg/providers/theme_provider.dart';
import 'package:kmg/screens/legal/privacy_screen.dart';
import 'package:kmg/screens/legal/contact_support_screen.dart';
import 'delete_account_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = "English";

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // GENERAL SETTINGS
          _buildSettingsHeader('General'),
          const Divider(),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDarkMode,
            secondary: const Icon(Icons.brightness_4),
            onChanged: themeProvider.toggleTheme,
          ),
          _buildLanguageSelector(),
          const SizedBox(height: 20),

          // SUPPORT & LEGAL
          _buildSettingsHeader('Support & Legal'),
          const Divider(),
          ListTile(
            title: const Text("Contact Us"),
            leading: const Icon(Icons.headphones_outlined),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContactSupportScreen('general'),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Privacy Policy"),
            leading: const Icon(Icons.policy),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          ListTile(
            title: const Text("View Policy Online"),
            subtitle: const Text("External link for legal notice"),
            leading: const Icon(Icons.open_in_new, size: 20),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _launchExternalUrl(
              'https://sites.google.com/view/kmgclassifieds/privacy-policy',
            ),
          ),

          const SizedBox(height: 20),

          // DELETE ACCOUNT - Only for logged-in users
          if (isLoggedIn) ...[
            const Divider(),
            ListTile(
              title: const Text(
                "Delete My Account",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              subtitle: const Text("Permanently remove your account and data."),
              leading: const Icon(Icons.warning, color: Colors.red),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeleteAccountScreen(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // --- Reusable Widgets ---
  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text("Language"),
      subtitle: Text(selectedLanguage),
      leading: const Icon(Icons.language),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        final lang = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text("Select Language"),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, "English"),
                child: const Text("English"),
              ),
            ],
          ),
        );
        if (lang != null) setState(() => selectedLanguage = lang);
      },
    );
  }
}
