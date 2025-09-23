import 'package:flutter/material.dart';

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
        ],
      ),
    );
  }
}
