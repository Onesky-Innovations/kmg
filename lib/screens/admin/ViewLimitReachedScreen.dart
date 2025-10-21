import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kmg/notifiers/view_limit_notifier.dart';

const String matrimonySettingsDoc = 'matrimony_view_config';

class ViewLimitReachedScreen extends StatefulWidget {
  const ViewLimitReachedScreen({super.key});

  @override
  State<ViewLimitReachedScreen> createState() => _ViewLimitReachedScreenState();
}

class _ViewLimitReachedScreenState extends State<ViewLimitReachedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  ThemeData get theme => Theme.of(context);
  Color get primaryColor => theme.primaryColor;
  Color get onPrimaryColor => theme.appBarTheme.foregroundColor ?? Colors.white;

  bool _isFemaleLimitEnabled = false;

  late final StreamSubscription<DocumentSnapshot> _settingsSub;

  DocumentReference get _settingsRef =>
      _firestore.collection('appSettings').doc(matrimonySettingsDoc);

  @override
  void initState() {
    super.initState();

    // Initialize default value
    _isFemaleLimitEnabled = false;
    viewLimitNotifier.updateFemaleLimit(false);

    // Search listener
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() => _searchText = _searchController.text.toLowerCase());
    });

    // Firestore listener for global settings
    _settingsSub = _settingsRef.snapshots().listen((doc) {
      if (!mounted) return; // ✅ only update if widget is active
      try {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final newValue = data['applyLimitToFemale'] ?? false;
        setState(() => _isFemaleLimitEnabled = newValue);
        viewLimitNotifier.updateFemaleLimit(newValue);
      } catch (e) {
        debugPrint("Error reading global settings: $e");
      }
    });
  }

  @override
  void dispose() {
    _settingsSub.cancel(); // ✅ cancel subscription
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleFemaleLimit(bool newValue) async {
    try {
      await _settingsRef.set({
        'applyLimitToFemale': newValue,
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _isFemaleLimitEnabled = newValue);
      viewLimitNotifier.updateFemaleLimit(newValue);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Limit for female viewers ${newValue ? 'ENABLED' : 'DISABLED'}.",
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error updating global setting: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating global setting.")),
      );
    }
  }

  void _editProfileLimit(String profileId, int currentLimit) {
    final controller = TextEditingController(text: currentLimit.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit View Limit"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Profiles Accessible Count",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final newLimit = int.tryParse(controller.text);
              if (newLimit == null || newLimit < 0) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid number.")),
                );
                return;
              }

              try {
                await _firestore.collection("matrimony").doc(profileId).update({
                  "accessibleProfiles": newLimit,
                });

                viewLimitNotifier.updateLimit(newLimit);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile limit updated successfully"),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error updating profile limit: $e")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Global View Restriction Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Apply View Limit to Female Viewers",
                style: TextStyle(fontSize: 16),
              ),
              Switch(
                value: _isFemaleLimitEnabled,
                onChanged: _toggleFemaleLimit,
                activeThumbColor: Colors.pink,
              ),
            ],
          ),
          const Divider(),
          const Text(
            "ENABLED: Both male and female viewers restricted by 'accessibleProfiles'.\n"
            "DISABLED: Only male viewers restricted.",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileUserLimitsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: "Search by Name or Gender",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection("matrimony").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var profiles = snapshot.data!.docs;

              // Apply search filter
              if (_searchText.isNotEmpty) {
                profiles = profiles.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? "").toString().toLowerCase();
                  final gender = (data['gender'] ?? "")
                      .toString()
                      .toLowerCase();
                  return name.contains(_searchText) ||
                      gender.contains(_searchText);
                }).toList();
              }

              if (profiles.isEmpty) {
                return const Center(child: Text("No profiles found."));
              }

              // Sort by nearest to view limit
              profiles.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aRem =
                    (aData['accessibleProfiles'] ?? 20) -
                    (aData['currentViewCount'] ?? 0);
                final bRem =
                    (bData['accessibleProfiles'] ?? 20) -
                    (bData['currentViewCount'] ?? 0);
                return aRem.compareTo(bRem);
              });

              return ListView.builder(
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final doc = profiles[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final profileId = doc.id;
                  final name = data['name'] ?? "Unknown";
                  final gender = data['gender'] ?? "N/A";
                  final limit = data['accessibleProfiles'] ?? 20;
                  final viewCount = data['currentViewCount'] ?? 0;
                  final remaining = limit - viewCount;

                  Color balanceColor = remaining <= 0
                      ? Colors.red
                      : remaining <= (limit * 0.25)
                      ? Colors.orange
                      : Colors.green;

                  return ListTile(
                    title: Text(name),
                    subtitle: Text(
                      "Gender: $gender | Total: $limit | Viewed: $viewCount",
                      style: TextStyle(color: balanceColor),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          remaining <= 0
                              ? "LIMIT REACHED"
                              : "Remaining: $remaining",
                          style: TextStyle(
                            color: balanceColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editProfileLimit(profileId, limit),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("View Limit Management"),
          bottom: TabBar(
            labelColor: onPrimaryColor,
            unselectedLabelColor: onPrimaryColor.withOpacity(0.7),
            indicatorColor: onPrimaryColor,
            tabs: const [
              Tab(text: "Profiles & User Limits", icon: Icon(Icons.list)),
              Tab(text: "Global Settings", icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildProfileUserLimitsTab(), _buildSettingsTab()],
        ),
      ),
    );
  }
}
