import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kmg/screens/admin/AddBannerFAB.dart';
import 'Add_Classified_FAB.dart';
// import 'Add_Banner_FAB.dart'; // ✅ Import your banner FAB
import '../ads/ad_detail_screen.dart';

class ManageClassifiedsScreen extends StatefulWidget {
  const ManageClassifiedsScreen({super.key});

  @override
  State<ManageClassifiedsScreen> createState() =>
      _ManageClassifiedsScreenState();
}

class _ManageClassifiedsScreenState extends State<ManageClassifiedsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _tabs = ["Active", "Expired", "Featured", "Banners"];
  late TabController _tabController;

  bool isLoading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _fetchAdminStatus();
  }

  Future<void> _fetchAdminStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection("users").doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          isAdmin = doc.data()?['admin'] == true;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search ads.........",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  // 👇 Different collection for Banners
                  final query = tab == "Banners"
                      ? FirebaseFirestore.instance
                            .collection("classifieds")
                            .doc("baners")
                            .collection("baner")
                            .orderBy("createdAt", descending: true)
                      : FirebaseFirestore.instance
                            .collection("classifieds")
                            .orderBy("createdAt", descending: true);

                  return StreamBuilder<QuerySnapshot>(
                    stream: query.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            tab == "Banners"
                                ? "No banners found"
                                : "No classifieds found",
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;
                      final now = DateTime.now();

                      final filteredAds = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final expiryDate = data["expiryDate"] != null
                            ? (data["expiryDate"] as Timestamp).toDate()
                            : null;

                        // 🔍 Search filter
                        if (_searchController.text.isNotEmpty &&
                            !(data["title"] ?? "")
                                .toString()
                                .toLowerCase()
                                .contains(
                                  _searchController.text.toLowerCase(),
                                )) {
                          return false;
                        }

                        // Tab filters
                        if (tab == "Active") {
                          return data["status"] == "Active" &&
                              expiryDate != null &&
                              expiryDate.isAfter(now);
                        }
                        if (tab == "Expired") {
                          return data["status"] == "Expired" ||
                              (expiryDate != null && expiryDate.isBefore(now));
                        }
                        if (tab == "Featured") {
                          return data["isFeatured"] == true;
                        }
                        if (tab == "Banners") {
                          return data["status"] ==
                              "Active"; // banners already separate
                        }

                        return true;
                      }).toList();

                      if (filteredAds.isEmpty) {
                        return const Center(
                          child: Text("No ads match criteria"),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredAds.length,
                        itemBuilder: (ctx, index) {
                          final ad =
                              filteredAds[index].data() as Map<String, dynamic>;
                          final adId = filteredAds[index].id;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            child: ListTile(
                              leading:
                                  ad["images"] != null &&
                                      ad["images"].isNotEmpty
                                  ? Image.network(
                                      ad["images"][0],
                                      width: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.image, size: 40),
                              title: Text(ad['title'] ?? "No title"),
                              subtitle: Text(
                                tab == "Banners"
                                    ? "Banner Ad"
                                    : "User: ${ad['userId']}\nExpiry: ${ad['expiryDate']?.toDate()?.toString().split(" ").first ?? "N/A"}",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdDetailScreen(
                                      adDoc: filteredAds[index],
                                      isAdmin: isAdmin,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                onPressed: _showAddClassifiedOptions,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  void _showAddClassifiedOptions() {
    String? selectedType;
    final TextEditingController userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Classified Ad"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Ad Type"),
              items: ["Normal", "Banner"]
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (val) => selectedType = val,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: "User ID",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedType == null ||
                  userIdController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Select type and enter User ID"),
                  ),
                );
                return;
              }
              Navigator.pop(ctx);

              // ✅ Navigate based on selection
              if (selectedType == "Banner") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddBannerFAB(
                      userId: userIdController.text.trim(),
                      adId: '',
                      // adId: null,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddClassifiedFAB(
                      type: selectedType!,
                      userId: userIdController.text.trim(),
                    ),
                  ),
                );
              }
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  void _showExtendDialog(String adId, Map<String, dynamic> ad) {
    int extendDays = 7;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text("Extend ${ad['title']}"),
          content: DropdownButton<int>(
            value: extendDays,
            items: [7, 15, 30]
                .map((e) => DropdownMenuItem(value: e, child: Text("$e days")))
                .toList(),
            onChanged: (val) {
              if (val != null) setStateDialog(() => extendDays = val);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newExpiry = (ad["expiryDate"] as Timestamp).toDate().add(
                  Duration(days: extendDays),
                );
                await FirebaseFirestore.instance
                    .collection("classifieds")
                    .doc(adId)
                    .update({"expiryDate": newExpiry});
                if (!mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text("Extend"),
            ),
          ],
        ),
      ),
    );
  }
}
