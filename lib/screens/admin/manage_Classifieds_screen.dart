import 'package:flutter/material.dart';
import 'package:kmg/screens/admin/add_classified_fab.dart'; // <-- your new add classified screen

class ManageClassifiedsScreen extends StatefulWidget {
  const ManageClassifiedsScreen({super.key});

  @override
  State<ManageClassifiedsScreen> createState() =>
      _ManageClassifiedsScreenState();
}

class _ManageClassifiedsScreenState extends State<ManageClassifiedsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // Tabs
  final List<String> _tabs = ["Active", "Expired", "Featured", "Banners"];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Sample Ad model
  List<Map<String, dynamic>> ads = List.generate(10, (index) {
    return {
      "title": "Bike for Sale $index",
      "user": "User $index",
      "status": index % 2 == 0 ? "Active" : "Expired",
      "isFeatured": index % 3 == 0,
      "type": index % 4 == 0 ? "Banner" : "Normal",
      "expiryDate": "2025-10-${index + 1}"
    };
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Classifieds"),
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: Column(
          children: [
            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search ads...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            // 📋 Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  List<Map<String, dynamic>> filteredAds = ads.where((ad) {
                    if (tab == "Active") return ad['status'] == "Active";
                    if (tab == "Expired") return ad['status'] == "Expired";
                    if (tab == "Featured") return ad['isFeatured'] == true;
                    if (tab == "Banners") return ad['type'] == "Banner";
                    return true;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredAds.length,
                    itemBuilder: (ctx, index) {
                      final ad = filteredAds[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        child: ListTile(
                          title: Text(ad['title']),
                          subtitle: Text(
                              "User: ${ad['user']}\nExpiry: ${ad['expiryDate']}"),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "edit") {
                                // TODO: navigate to edit ad
                              } else if (value == "extend") {
                                _showExtendDialog(ad);
                              } else if (value == "delete") {
                                // TODO: delete ad
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                  value: "edit", child: Text("Edit")),
                              const PopupMenuItem(
                                  value: "extend", child: Text("Extend")),
                              const PopupMenuItem(
                                  value: "delete", child: Text("Delete")),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        // ➕ Admin FAB: Select type & user ID before navigating
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: _showAddClassifiedOptions,
        ),
      ),
    );
  }

  // 📝 Show dialog to select Normal/Banner and enter User ID
  void _showAddClassifiedOptions() {
    String? selectedType;
    final TextEditingController _userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Classified Ad"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Select Type
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Ad Type"),
              items: ["Normal", "Banner"]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (val) => selectedType = val,
              validator: (val) => val == null ? "Select type" : null,
            ),
            const SizedBox(height: 12),
            // Enter User ID manually
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: "User ID",
                hintText: "Enter user ID for this ad",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (selectedType == null || _userIdController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Select type and enter User ID")),
                );
                return;
              }
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddClassifiedFAB(
                    type: selectedType!,
                    userId: _userIdController.text.trim(),
                  ),
                ),
              );
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  // 📝 Show Extend Dialog
  void _showExtendDialog(Map<String, dynamic> ad) {
    int _extendDays = 7;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Extend ${ad['title']}"),
        content: DropdownButton<int>(
          value: _extendDays,
          items: [7, 15, 30]
              .map((e) => DropdownMenuItem(value: e, child: Text("$e days")))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _extendDays = val);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // TODO: Extend ad expiry
              Navigator.pop(ctx);
            },
            child: const Text("Extend"),
          ),
        ],
      ),
    );
  }
}
