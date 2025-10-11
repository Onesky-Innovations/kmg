import 'package:flutter/material.dart';
import 'delete_account_screen.dart'; // Make sure this file exists

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  String selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDarkMode,
            onChanged: (val) => setState(() => isDarkMode = val),
          ),
          SwitchListTile(
            title: const Text("Notifications"),
            value: notificationsEnabled,
            onChanged: (val) => setState(() => notificationsEnabled = val),
          ),
          ListTile(
            title: const Text("Language"),
            subtitle: Text(selectedLanguage),
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
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, "Spanish"),
                      child: const Text("Spanish"),
                    ),
                  ],
                ),
              );
              if (lang != null) setState(() => selectedLanguage = lang);
            },
          ),

          // Delete Account Section
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            "Delete Account",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "If you wish to permanently delete your account and all associated data, you can do so here. "
            "This action cannot be undone.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 36, // smaller height
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 36), // compact width & height
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DeleteAccountScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Delete My Account",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
