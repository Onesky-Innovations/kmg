import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kmg/screens/admin/add_matrimony_fab.dart';
import 'package:kmg/screens/ads/matri_detail_screen.dart';

class ManageMatrimonyScreen extends StatefulWidget {
  const ManageMatrimonyScreen({super.key});

  @override
  State<ManageMatrimonyScreen> createState() => _ManageMatrimonyScreenState();
}

class _ManageMatrimonyScreenState extends State<ManageMatrimonyScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _tabs = ["Active", "Expired", "Featured"];
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

  void _deleteProfile(String profileId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this profile?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection("matrimony").doc(profileId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting profile: $e")));
      }
    }
  }

  void _editProfile(String profileId, Map<String, dynamic> profileData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMatrimonyFAB(
          userId: profileData["userId"] ?? "",
          existingProfileId: profileId,
          existingData: profileData,
        ),
      ),
    );
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
          title: const Text("Manage Matrimony"),
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
                  hintText: "Search profiles...",
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
                  final query = FirebaseFirestore.instance
                      .collection("matrimony")
                      .orderBy("createdAt", descending: true);

                  return StreamBuilder<QuerySnapshot>(
                    stream: query.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No profiles found"));
                      }

                      final docs = snapshot.data!.docs;
                      final now = DateTime.now();

                      final filteredProfiles = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final expiryDate = data["expiryDate"] != null
                            ? (data["expiryDate"] as Timestamp).toDate()
                            : null;

                        if (_searchController.text.isNotEmpty &&
                            !(data["name"] ?? "")
                                .toString()
                                .toLowerCase()
                                .contains(
                                  _searchController.text.toLowerCase(),
                                )) {
                          return false;
                        }

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

                        return true;
                      }).toList();

                      if (filteredProfiles.isEmpty) {
                        return const Center(
                          child: Text("No profiles match criteria"),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: filteredProfiles.length,
                        itemBuilder: (ctx, index) {
                          final profile =
                              filteredProfiles[index].data()
                                  as Map<String, dynamic>;
                          final profileId = filteredProfiles[index].id;

                          return GestureDetector(
                            onTap: () {
                              // TODO: Navigate to detail page if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MatriDetailScreen(
                                    profileId: profileId,
                                    profile: {},
                                  ),
                                ),
                              );
                            },

                            // return GestureDetector(
                            //   onTap: () {
                            //     // TODO: Navigate to detail page if needed
                            //   },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: profile["photo"] != null
                                        ? ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                            child: Image.network(
                                              profile["photo"],
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(12),
                                                  ),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile['name'] ?? "No Name",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text("Age: ${profile['age'] ?? 'N/A'}"),
                                        Text(
                                          "Place: ${profile['place'] ?? 'N/A'}",
                                        ),
                                        if (profile["expiryDate"] != null)
                                          Text(
                                            "Expires: ${(profile["expiryDate"] as Timestamp).toDate().toLocal().toString().split(' ')[0]}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () =>
                                              _editProfile(profileId, profile),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteProfile(profileId),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
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
                onPressed: () {
                  final TextEditingController userIdController =
                      TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Enter User ID"),
                      content: TextField(
                        controller: userIdController,
                        decoration: const InputDecoration(
                          labelText: "User ID",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddMatrimonyFAB(
                                  userId: userIdController.text.trim(),
                                  existingProfileId: '',
                                  existingData: {},
                                ),
                              ),
                            );
                          },
                          child: const Text("Continue"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
