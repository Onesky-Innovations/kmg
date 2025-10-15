import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart'; // 💡 NEW: Import Provider
import 'package:kmg/providers/theme_provider.dart'; // 💡 NEW: Import ThemeProvider
import 'package:kmg/screens/legal/privacy_screen.dart';

// Placeholder screens - replace with your actual screen imports
import 'delete_account_screen.dart';
import 'package:kmg/screens/settings/sign_in_screen.dart';
import 'package:kmg/screens/legal/contact_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 🚨 PRODUCTION NOTE: In a real app, this should come from a global state manager (e.g., Provider/BLoC).
  bool isLoggedIn = false;

  // 🗑️ REMOVED: bool isDarkMode = false; (State is now managed by ThemeProvider)

  String selectedLanguage = "English";

  // --- Production-Ready Action Handlers ---

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache Cleared! (Real logic pending)')),
    );
  }

  void _handleAuthAction() {
    if (isLoggedIn) {
      // 🚀 REAL IMPLEMENTATION: Call AuthService.logout()
      _showLogoutConfirmation();
    } else {
      // 💡 FIX: Pass a result type to push and check the returned value.
      Navigator.of(context)
          .push(
            MaterialPageRoute<bool>(
              // Specify the return type is boolean
              builder: (context) => const SignInScreen(fromFab: true),
            ),
          )
          // Check if the returned result is true (meaning successful login)
          .then((result) {
            if (result == true && mounted) {
              // Only set state if result is true
              setState(() => isLoggedIn = true);
            }
          });
    }
  }

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

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => isLoggedIn = false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged Out successfully!')),
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    // 💡 FIX 1: Access the ThemeProvider and listen for changes
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ------------------------------------
          // 1. GENERAL SETTINGS
          // ------------------------------------
          _buildSettingsHeader('General'),
          const Divider(),

          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDarkMode, // 💡 FIX 2: Use the state from the Provider
            secondary: const Icon(Icons.brightness_4),
            onChanged: (val) {
              // 💡 FIX 3: Call the toggleTheme method on the Provider
              themeProvider.toggleTheme(val);
            },
          ),

          _buildLanguageSelector(),

          const SizedBox(height: 20),
          // ... (Rest of the settings content remains the same)
          // ------------------------------------
          // 2. ACCOUNT & PRIVACY (Logged-in Only)
          // ------------------------------------
          if (isLoggedIn) ...[
            _buildSettingsHeader('Account & Privacy'),
            const Divider(),

            ListTile(
              title: const Text("Update Profile"),
              subtitle: const Text("Change name, email, or password"),
              leading: const Icon(Icons.person),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 🚀 REAL IMPLEMENTATION: Navigate to your Profile Edit Screen
              },
            ),
            const SizedBox(height: 20),
          ],

          // ------------------------------------
          // 3. SUPPORT & LEGAL (All Users)
          // ------------------------------------
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

          const SizedBox(height: 10),

          // ------------------------------------
          // 4. AUTHENTICATION (Dynamic Log In/Out)
          // ------------------------------------
          ListTile(
            title: Text(
              isLoggedIn ? "Log Out" : "Log In / Sign Up",
              style: TextStyle(
                color: isLoggedIn ? Colors.blueAccent : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Icon(
              isLoggedIn ? Icons.logout : Icons.login,
              color: isLoggedIn ? Colors.blueAccent : Colors.green,
            ),
            onTap: _handleAuthAction,
          ),

          // ------------------------------------
          // 5. DELETE ACCOUNT (Logged-in Only - Danger Zone)
          // ------------------------------------
          if (isLoggedIn) ...[
            const SizedBox(height: 5),
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

  // --- Reusable Widget Builders ---

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
              // SimpleDialogOption(
              //   onPressed: () => Navigator.pop(context, "Spanish"),
              //   child: const Text("Spanish"),
              // ),
            ],
          ),
        );
        if (lang != null) {
          setState(() => selectedLanguage = lang);
          // ⚙️ REAL IMPLEMENTATION: Save and apply new locale here
        }
      },
    );
  }
}
