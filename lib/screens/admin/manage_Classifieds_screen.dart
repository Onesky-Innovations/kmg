import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Note: Ensure AddBannerFAB and Add_Classified_FAB are correctly imported
import 'package:kmg/screens/admin/AddBannerFAB.dart';
import 'package:kmg/screens/ads/BannerDetailScreen.dart';
import 'package:kmg/screens/ads/ad_detail_screen.dart';
import 'Add_Classified_FAB.dart';

class ManageClassifiedsScreen extends StatefulWidget {
  const ManageClassifiedsScreen({super.key});

  @override
  State<ManageClassifiedsScreen> createState() =>
      _ManageClassifiedsScreenState();
}

class _ManageClassifiedsScreenState extends State<ManageClassifiedsScreen>
    with SingleTickerProviderStateMixin {
  Color _getTabColor(int index) {
    switch (index) {
      case 0:
        return Colors.green.shade600; // Active (slightly darker for pop)
      case 1:
        return Colors.redAccent; // Expired
      case 2:
        return Colors.orange.shade700; // Featured (slightly darker)
      case 3:
        return Colors.blueAccent; // Banners
      default:
        return Colors.grey;
    }
  }

  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _tabs = ["Active", "Expired", "Featured", "Banners"];
  late TabController _tabController;

  bool isLoading = true;
  bool isAdmin = false;

  // State variable to hold the current search term (lowercase for filtering)
  String _currentSearchTerm = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _fetchAdminStatus();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Only update the state if the search term has actually changed
    final newSearchTerm = _searchController.text.trim().toLowerCase();
    if (_currentSearchTerm != newSearchTerm) {
      setState(() {
        _currentSearchTerm = newSearchTerm;
      });
    }
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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // UPDATED Filtering logic for stability and efficiency
  // UPDATED Filtering logic for stability and efficiency
  List<QueryDocumentSnapshot> _filterAds(
    String tab,
    List<QueryDocumentSnapshot> docs,
  ) {
    final now = DateTime.now();
    final searchQuery = _currentSearchTerm;

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Check if the document belongs to the 'banners' collection
      final isBannerDoc = doc.reference.parent.id == "banners";

      // --- Handle Banners ---
      if (tab == "Banners") {
        // Only show Banners in the Banners tab
        return isBannerDoc;
      }

      // --- Exclude Banners from Classifieds Tabs ---
      if (isBannerDoc) {
        return false;
      }

      // --- Common Search Filter (Applied ONLY to Classifieds) ---
      final title = (data["title"] ?? "").toString().toLowerCase();
      if (searchQuery.isNotEmpty && !title.contains(searchQuery)) {
        return false;
      }

      // --- Tab-Specific Filtering Logic for Classifieds ---

      // Get expiry date safely once for Classifieds
      final expiryDate = data["expiryDate"] is Timestamp
          ? (data["expiryDate"] as Timestamp).toDate()
          : null;

      final isActive = expiryDate != null && expiryDate.isAfter(now);

      if (tab == "Featured") {
        // Server filters by isFeatured=true. Client filters to ensure it's still Active.
        return (data["isFeatured"] == true) && isActive;
      }

      if (tab == "Active") {
        return (data["status"] == "Active" || data["status"] == null) &&
            isActive; // Reuse isActive check
      }

      if (tab == "Expired") {
        // Includes ads explicitly marked Expired OR where the date has passed
        final isExpiredByStatus = data["status"] == "Expired";
        final isExpiredByDate = !isActive; // If not active, it's expired
        return isExpiredByStatus || isExpiredByDate;
      }

      return false; // Should not be reached for Classifieds
    }).toList();
  }

  // Helper function to build the ListTile for clarity
  Widget _buildAdListTile(String tab, QueryDocumentSnapshot adDoc) {
    final ad = adDoc.data() as Map<String, dynamic>;
    final adId = adDoc.id;

    final isBanner = adDoc.reference.parent.id == "banners";
    // NOTE: For classifieds, parentUserId is doc.reference.parent.parent?.id (the user doc ID)
    final classifiedParentUserId = isBanner
        ? null
        : adDoc.reference.parent.parent?.id;
    // NOTE: For banners, the userId is stored directly in the document (ad['userId'])

    // Determine image URL
    final imageUrl = ad["images"] is List && ad["images"].isNotEmpty
        ? ad["images"][0]
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: imageUrl != null
            ? Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 40),
              )
            : const Icon(Icons.image, size: 40),
        title: Text(ad['title'] ?? (isBanner ? "Banner Ad" : "No title")),
        subtitle: isBanner
            ? Text(
                "Banner • Created: ${ad['createdAt'] is Timestamp ? (ad['createdAt'] as Timestamp).toDate().toString().split(' ').first : 'N/A'}\nUser ID: ${ad['userId'] ?? 'N/A'}",
              )
            : Text(
                "User: ${ad['userId'] ?? 'N/A'}\nExpiry: ${ad['expiryDate'] is Timestamp ? (ad['expiryDate'] as Timestamp).toDate().toString().split(' ').first : 'N/A'}",
              ),

        onTap: () {
          final adData = adDoc.data() as Map<String, dynamic>;

          if (isBanner) {
            final description = adData['description'] as String? ?? 'N/A';
            final phone = adData['phone'] as String? ?? 'N/A';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BannerDetailScreen(
                  imageUrl: imageUrl,
                  description: description,
                  phone: phone,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdDetailScreen(
                  adDoc: adDoc,
                  isAdmin: isAdmin,
                  adId: adId,
                  adData: adData,
                  userId: adData['userId'] ?? classifiedParentUserId ?? '',
                ),
              ),
            );
          }
        },
        // MODIFIED: Use the trailing button for all admin actions
        trailing: isAdmin
            ? IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  if (isBanner) {
                    _showBannerActions(adId, ad); // Handle banner actions
                  } else if (classifiedParentUserId != null) {
                    // Handle classified ad actions
                    _showAdActions(classifiedParentUserId, adId, ad);
                  }
                },
              )
            : null,
      ),
    );
  }

  // ... (rest of the file remains the same)

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
          // Set a clean white background for the AppBar and dark text
          // backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1, // Subtle shadow for a lift effect
          bottom: TabBar(
            controller: _tabController,
            // Use the dynamic color for the selected label, and a dark color for unselected
            labelColor: _getTabColor(_tabController.index),
            unselectedLabelColor: Colors.white,

            // Set indicator style to be a solid rectangle below the tab, matching the tab's color
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 4.0, // Thicker underline
                color: _getTabColor(_tabController.index),
              ),
              insets: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ), // Give it some padding
            ),

            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            onTap: (index) {
              // Must call setState to update the labelColor and indicator color
              setState(() {});
            },
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
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  // 💡 CRITICAL FIX: Separate 'Featured' query to reduce client-side filtering
                  Query query;

                  if (tab == "Banners") {
                    // Query for Banners only
                    query = _firestore
                        .collection("banners")
                        .orderBy("createdAt", descending: true);
                  } else if (tab == "Featured") {
                    // Query for Featured ads, filtered server-side
                    query = _firestore
                        .collectionGroup("classifieds")
                        .where("isFeatured", isEqualTo: true) // Server Filter
                        .orderBy("createdAt", descending: true);
                  } else {
                    // Query for ALL classifieds (Active/Expired require complex client-side date checks)
                    query = _firestore
                        .collectionGroup("classifieds")
                        .orderBy("createdAt", descending: true);
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: query.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
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

                      // APPLY FILTERING: Apply the search and tab filter to the data
                      final filteredAds = _filterAds(tab, docs);

                      if (filteredAds.isEmpty) {
                        return const Center(
                          child: Text("No ads match criteria"),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredAds.length,
                        itemBuilder: (ctx, index) {
                          return _buildAdListTile(tab, filteredAds[index]);
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

  // --- NEW Helper for Deletion Confirmation ---

  void _confirmDelete({
    required bool isBanner,
    required String id,
    required String title,
    String? parentUserId,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to permanently delete '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              if (isBanner) {
                _deleteBanner(id, title);
              } else {
                // We know parentUserId is non-null for classifieds
                _deleteAd(parentUserId!, id, title);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Banner Management Helpers ---

  void _showBannerActions(String bannerId, Map<String, dynamic> bannerData) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Banner'),
              onTap: () {
                Navigator.pop(ctx);
                // FIX/EDIT: Ensure correct parameters for edit mode are passed.
                // The actual form logic (pre-filling fields and using .update())
                // must be handled inside AddBannerFAB.dart.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddBannerFAB(
                      userId:
                          bannerData['userId'] ?? '', // Pass existing userId
                      adId: bannerId, // Pass the banner ID to enable edit mode
                      existingData:
                          bannerData, // Pass existing data for pre-filling
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Banner'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(
                  isBanner: true,
                  id: bannerId,
                  title: bannerData['title'] ?? 'this banner',
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBanner(String bannerId, String title) async {
    try {
      await _firestore.collection("banners").doc(bannerId).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$title deleted successfully")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting banner: $e")));
    }
  }

  // --- Classified Ad Management Helpers (Updated for Delete Confirmation) ---

  void _showAdActions(
    String parentUserId,
    String adId,
    Map<String, dynamic> ad,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ad['expiryDate'] != null)
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Extend Ad Duration'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showExtendDialog(parentUserId, adId, ad);
                },
              ),
            ListTile(
              leading: const Icon(Icons.featured_play_list),
              title: Text(
                ad['isFeatured'] == true ? 'Unfeature Ad' : 'Feature Ad',
              ),
              onTap: () {
                Navigator.pop(ctx);
                _toggleFeatured(parentUserId, adId, ad['isFeatured'] != true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Ad'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(
                  isBanner: false,
                  id: adId,
                  title: ad['title'] ?? 'this ad',
                  parentUserId: parentUserId,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleFeatured(
    String parentUserId,
    String adId,
    bool isFeatured,
  ) async {
    try {
      await _firestore
          .collection("users")
          .doc(parentUserId)
          .collection("classifieds")
          .doc(adId)
          .update({"isFeatured": isFeatured});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFeatured ? "Ad marked as Featured" : "Ad removed from Featured",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating feature status: $e")),
      );
    }
  }

  Future<void> _deleteAd(String parentUserId, String adId, String title) async {
    try {
      await _firestore
          .collection("users")
          .doc(parentUserId)
          .collection("classifieds")
          .doc(adId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$title deleted successfully")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting ad: $e")));
    }
  }

  // --- Add/Extend Dialogs ---

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
            StatefulBuilder(
              builder: (context, setStateDialog) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Ad Type"),
                  items: ["Normal", "Banner"]
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setStateDialog(() {
                      selectedType = val;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: "User ID (Required)",
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

              if (selectedType == "Banner") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddBannerFAB(
                      userId: userIdController.text.trim(),
                      adId: '',
                      existingData: {},
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

  void _showExtendDialog(
    String parentUserId,
    String adId,
    Map<String, dynamic> ad,
  ) {
    int extendDays = 7;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text("Extend ${ad['title'] ?? 'Ad'}"),
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
                final expiryDateTimestamp = ad["expiryDate"] as Timestamp?;

                final currentExpiry =
                    expiryDateTimestamp?.toDate() ?? DateTime.now();

                final newExpiry = currentExpiry.add(Duration(days: extendDays));

                await _firestore
                    .collection("users")
                    .doc(parentUserId)
                    .collection("classifieds")
                    .doc(adId)
                    .update({"expiryDate": newExpiry, "status": "Active"});

                if (!mounted) return;
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Ad extended to ${newExpiry.toString().split(' ').first}",
                    ),
                  ),
                );
              },
              child: const Text("Extend"),
            ),
          ],
        ),
      ),
    );
  }
}
