// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:kmg/screens/admin/add_matrimony_fab.dart';
// import 'package:kmg/screens/matrimony/matri_detail_screen.dart';

// class ManageMatrimonyScreen extends StatefulWidget {
//   const ManageMatrimonyScreen({super.key});

//   @override
//   State<ManageMatrimonyScreen> createState() => _ManageMatrimonyScreenState();
// }

// class _ManageMatrimonyScreenState extends State<ManageMatrimonyScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final List<String> _tabs = ["Active", "Expired", "Featured"];
//   late TabController _tabController;

//   bool isLoading = true;
//   bool isAdmin = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _fetchAdminStatus();
//   }

//   Future<void> _fetchAdminStatus() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       final doc = await _firestore.collection("users").doc(user.uid).get();
//       if (doc.exists) {
//         setState(() {
//           isAdmin = doc.data()?['admin'] == true;
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _deleteProfile(String profileId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Confirm Deletion"),
//         content: const Text("Are you sure you want to delete this profile?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await _firestore.collection("matrimony").doc(profileId).delete();
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile deleted successfully")),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error deleting profile: $e")));
//       }
//     }
//   }

//   void _editProfile(String profileId, Map<String, dynamic> profileData) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddMatrimonyFAB(
//           userId: profileData["userId"] ?? "",
//           existingProfileId: profileId,
//           existingData: profileData,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return DefaultTabController(
//       length: _tabs.length,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Manage Matrimony"),
//           bottom: TabBar(
//             controller: _tabController,
//             tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
//           ),
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search profiles...",
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onChanged: (_) => setState(() {}),
//               ),
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: _tabs.map((tab) {
//                   final query = FirebaseFirestore.instance
//                       .collection("matrimony")
//                       .orderBy("createdAt", descending: true);

//                   return StreamBuilder<QuerySnapshot>(
//                     stream: query.snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(child: Text("No profiles found"));
//                       }

//                       final docs = snapshot.data!.docs;
//                       final now = DateTime.now();

//                       final filteredProfiles = docs.where((doc) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         final expiryDate = data["expiryDate"] != null
//                             ? (data["expiryDate"] as Timestamp).toDate()
//                             : null;

//                         if (_searchController.text.isNotEmpty &&
//                             !(data["name"] ?? "")
//                                 .toString()
//                                 .toLowerCase()
//                                 .contains(
//                                   _searchController.text.toLowerCase(),
//                                 )) {
//                           return false;
//                         }

//                         if (tab == "Active") {
//                           return data["status"] == "Active" &&
//                               expiryDate != null &&
//                               expiryDate.isAfter(now);
//                         }
//                         if (tab == "Expired") {
//                           return data["status"] == "Expired" ||
//                               (expiryDate != null && expiryDate.isBefore(now));
//                         }
//                         if (tab == "Featured") {
//                           return data["isFeatured"] == true;
//                         }

//                         return true;
//                       }).toList();

//                       if (filteredProfiles.isEmpty) {
//                         return const Center(
//                           child: Text("No profiles match criteria"),
//                         );
//                       }

//                       return GridView.builder(
//                         padding: const EdgeInsets.all(8),
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 8,
//                               mainAxisSpacing: 8,
//                               childAspectRatio: 0.7,
//                             ),
//                         itemCount: filteredProfiles.length,
//                         itemBuilder: (ctx, index) {
//                           final profile =
//                               filteredProfiles[index].data()
//                                   as Map<String, dynamic>;
//                           final profileId = filteredProfiles[index].id;

//                           return GestureDetector(
//                             onTap: () {
//                               // TODO: Navigate to detail page if needed
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => MatriDetailScreen(
//                                     profileId: profileId,
//                                     profile: {},
//                                   ),
//                                 ),
//                               );
//                             },

//                             // return GestureDetector(
//                             //   onTap: () {
//                             //     // TODO: Navigate to detail page if needed
//                             //   },
//                             child: Card(
//                               elevation: 3,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     child: profile["photo"] != null
//                                         ? ClipRRect(
//                                             borderRadius:
//                                                 const BorderRadius.vertical(
//                                                   top: Radius.circular(12),
//                                                 ),
//                                             child: Image.network(
//                                               profile["photo"],
//                                               width: double.infinity,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           )
//                                         : Container(
//                                             decoration: BoxDecoration(
//                                               color: Colors.grey[300],
//                                               borderRadius:
//                                                   const BorderRadius.vertical(
//                                                     top: Radius.circular(12),
//                                                   ),
//                                             ),
//                                             child: const Center(
//                                               child: Icon(
//                                                 Icons.person,
//                                                 size: 50,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                           ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           profile['name'] ?? "No Name",
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         Text("Age: ${profile['age'] ?? 'N/A'}"),
//                                         Text(
//                                           "Place: ${profile['place'] ?? 'N/A'}",
//                                         ),
//                                         if (profile["expiryDate"] != null)
//                                           Text(
//                                             "Expires: ${(profile["expiryDate"] as Timestamp).toDate().toLocal().toString().split(' ')[0]}",
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.red,
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                   if (isAdmin)
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(
//                                             Icons.edit,
//                                             color: Colors.blue,
//                                           ),
//                                           onPressed: () =>
//                                               _editProfile(profileId, profile),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(
//                                             Icons.delete,
//                                             color: Colors.red,
//                                           ),
//                                           onPressed: () =>
//                                               _deleteProfile(profileId),
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: isAdmin
//             ? FloatingActionButton(
//                 onPressed: () {
//                   final TextEditingController userIdController =
//                       TextEditingController();
//                   showDialog(
//                     context: context,
//                     builder: (ctx) => AlertDialog(
//                       title: const Text("Enter User ID"),
//                       content: TextField(
//                         controller: userIdController,
//                         decoration: const InputDecoration(
//                           labelText: "User ID",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(ctx),
//                           child: const Text("Cancel"),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(ctx);
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => AddMatrimonyFAB(
//                                   userId: userIdController.text.trim(),
//                                   existingProfileId: '',
//                                   existingData: {},
//                                 ),
//                               ),
//                             );
//                           },
//                           child: const Text("Continue"),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 child: const Icon(Icons.add),
//               )
//             : null,
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// // NOTE: Assuming this is the path to your new screen, as requested
// import 'package:kmg/screens/admin/ViewLimitReachedScreen.dart';
// import 'package:kmg/screens/admin/add_matrimony_fab.dart';
// import 'package:kmg/screens/matrimony/matri_screens/matri_detail_screen.dart';

// class ManageMatrimonyScreen extends StatefulWidget {
//   const ManageMatrimonyScreen({super.key});

//   @override
//   State<ManageMatrimonyScreen> createState() => _ManageMatrimonyScreenState();
// }

// class _ManageMatrimonyScreenState extends State<ManageMatrimonyScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final List<String> _tabs = ["Active", "Expired", "Featured"];
//   late TabController _tabController;

//   bool isLoading = true;
//   bool isAdmin = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _fetchAdminStatus();
//   }

//   Future<void> _fetchAdminStatus() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       final doc = await _firestore.collection("users").doc(user.uid).get();
//       if (doc.exists) {
//         setState(() {
//           isAdmin = doc.data()?['admin'] == true;
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _deleteProfile(String profileId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Confirm Deletion"),
//         content: const Text("Are you sure you want to delete this profile?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text("Delete"),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await _firestore.collection("matrimony").doc(profileId).delete();
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile deleted successfully")),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error deleting profile: $e")));
//       }
//     }
//   }

//   void _editProfile(String profileId, Map<String, dynamic> profileData) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddMatrimonyFAB(
//           userId: profileData["userId"] ?? "",
//           existingProfileId: profileId,
//           existingData: profileData,
//         ),
//       ),
//     );
//   }

//   // New method to handle navigation to the ViewLimitReachedScreen
//   void _navigateToViewLimitScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         // Assuming the ViewLimitReachedScreen is now your multi-tab management screen
//         builder: (context) => const ViewLimitReachedScreen(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return DefaultTabController(
//       length: _tabs.length,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Manage Matrimony"),
//           // 1. ADD THE SETTINGS ICON BUTTON HERE
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.settings),
//               onPressed: isAdmin
//                   ? _navigateToViewLimitScreen
//                   : null, // Only admin can access
//               tooltip: "Manage View Limits",
//             ),
//           ],
//           bottom: TabBar(
//             controller: _tabController,
//             tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
//           ),
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search profiles...",
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onChanged: (_) => setState(() {}),
//               ),
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: _tabs.map((tab) {
//                   final query = FirebaseFirestore.instance
//                       .collection("matrimony")
//                       .orderBy("createdAt", descending: true);

//                   return StreamBuilder<QuerySnapshot>(
//                     stream: query.snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(child: Text("No profiles found"));
//                       }

//                       final docs = snapshot.data!.docs;
//                       final now = DateTime.now();

//                       final filteredProfiles = docs.where((doc) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         final expiryDate = data["expiryDate"] != null
//                             ? (data["expiryDate"] as Timestamp).toDate()
//                             : null;

//                         if (_searchController.text.isNotEmpty &&
//                             !(data["name"] ?? "")
//                                 .toString()
//                                 .toLowerCase()
//                                 .contains(
//                                   _searchController.text.toLowerCase(),
//                                 )) {
//                           return false;
//                         }

//                         if (tab == "Active") {
//                           return data["status"] == "Active" &&
//                               expiryDate != null &&
//                               expiryDate.isAfter(now);
//                         }
//                         if (tab == "Expired") {
//                           return data["status"] == "Expired" ||
//                               (expiryDate != null && expiryDate.isBefore(now));
//                         }
//                         if (tab == "Featured") {
//                           return data["isFeatured"] == true;
//                         }

//                         return true;
//                       }).toList();

//                       if (filteredProfiles.isEmpty) {
//                         return const Center(
//                           child: Text("No profiles match criteria"),
//                         );
//                       }

//                       return GridView.builder(
//                         padding: const EdgeInsets.all(8),
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 8,
//                               mainAxisSpacing: 8,
//                               childAspectRatio: 0.7,
//                             ),
//                         itemCount: filteredProfiles.length,
//                         itemBuilder: (ctx, index) {
//                           final profile =
//                               filteredProfiles[index].data()
//                                   as Map<String, dynamic>;
//                           final profileId = filteredProfiles[index].id;

//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => MatriDetailScreen(
//                                     profileId: profileId,
//                                     profile: {},
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Card(
//                               elevation: 3,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     child: profile["photo"] != null
//                                         ? ClipRRect(
//                                             borderRadius:
//                                                 const BorderRadius.vertical(
//                                                   top: Radius.circular(12),
//                                                 ),
//                                             child: Image.network(
//                                               profile["photo"],
//                                               width: double.infinity,
//                                               fit: BoxFit.cover,
//                                             ),
//                                           )
//                                         : Container(
//                                             decoration: BoxDecoration(
//                                               color: Colors.grey[300],
//                                               borderRadius:
//                                                   const BorderRadius.vertical(
//                                                     top: Radius.circular(12),
//                                                   ),
//                                             ),
//                                             child: const Center(
//                                               child: Icon(
//                                                 Icons.person,
//                                                 size: 50,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                           ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           profile['name'] ?? "No Name",
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         Text("Age: ${profile['age'] ?? 'N/A'}"),
//                                         Text(
//                                           "Place: ${profile['place'] ?? 'N/A'}",
//                                         ),
//                                         if (profile["expiryDate"] != null)
//                                           Text(
//                                             "Expires: ${(profile["expiryDate"] as Timestamp).toDate().toLocal().toString().split(' ')[0]}",
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.red,
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                   if (isAdmin)
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         IconButton(
//                                           icon: const Icon(
//                                             Icons.edit,
//                                             color: Colors.blue,
//                                           ),
//                                           onPressed: () =>
//                                               _editProfile(profileId, profile),
//                                         ),
//                                         IconButton(
//                                           icon: const Icon(
//                                             Icons.delete,
//                                             color: Colors.red,
//                                           ),
//                                           onPressed: () =>
//                                               _deleteProfile(profileId),
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: isAdmin
//             ? FloatingActionButton(
//                 onPressed: () {
//                   final TextEditingController userIdController =
//                       TextEditingController();
//                   showDialog(
//                     context: context,
//                     builder: (ctx) => AlertDialog(
//                       title: const Text("Enter User ID"),
//                       content: TextField(
//                         controller: userIdController,
//                         decoration: const InputDecoration(
//                           labelText: "User ID",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(ctx),
//                           child: const Text("Cancel"),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(ctx);
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => AddMatrimonyFAB(
//                                   userId: userIdController.text.trim(),
//                                   existingProfileId: '',
//                                   existingData: {},
//                                 ),
//                               ),
//                             );
//                           },
//                           child: const Text("Continue"),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 child: const Icon(Icons.add),
//               )
//             : null,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kmg/screens/admin/ViewLimitReachedScreen.dart';
import 'package:kmg/screens/admin/add_matrimony_fab.dart';
import 'package:kmg/screens/matrimony/matri_screens/matri_detail_screen.dart';

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

  String? _selectedGender;
  int _totalMaleCount = 0;
  int _totalFemaleCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _fetchAdminStatus();
    _fetchTotalCounts();
  }

  Future<void> _fetchTotalCounts() async {
    try {
      final snapshot = await _firestore.collection("matrimony").get();
      int maleCount = 0;
      int femaleCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['gender'] == 'Male') {
          maleCount++;
        } else if (data['gender'] == 'Female') {
          femaleCount++;
        }
      }

      if (mounted) {
        setState(() {
          _totalMaleCount = maleCount;
          _totalFemaleCount = femaleCount;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error fetching total counts: $e");
        setState(() => isLoading = false);
      }
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection("matrimony").doc(profileId).delete();
        _fetchTotalCounts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
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

  void _navigateToViewLimitScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewLimitReachedScreen()),
    );
  }

  Widget _buildStaticCountChip(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            "$count",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    Map<String, dynamic> profile,
    String profileId,
    String tab,
    bool isAdmin,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final photoUrl =
        profile["photo"] is String &&
            (profile["photo"] as String).startsWith('http')
        ? profile["photo"]
        : null;

    final isMale = profile['gender'] == 'Male';
    final genderColor = isMale ? Colors.blueAccent : Colors.pinkAccent;

    final expiryDate = profile["expiryDate"] != null
        ? (profile["expiryDate"] as Timestamp).toDate()
        : null;
    final isExpired = expiryDate != null && expiryDate.isBefore(DateTime.now());

    return Card(
      elevation: theme.cardTheme.elevation ?? 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MatriDetailScreen(profileId: profileId, profile: const {}),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.2),
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(genderColor),
                        )
                      : _buildPlaceholderImage(genderColor),
                ),
                if (tab == "Featured" || isExpired)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tab == "Featured"
                            ? Colors.amber[700]
                            : Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tab == "Featured" ? "⭐ Featured" : "🛑 Expired",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile['name'] ?? "No Name",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isMale ? Icons.male : Icons.female,
                        color: genderColor,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "${profile['age'] ?? 'N/A'} yrs",
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Text(" • "),
                      Expanded(
                        child: Text(
                          profile['place'] ?? 'N/A',
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isAdmin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          color: colorScheme.primary,
                          onPressed: () => _editProfile(profileId, profile),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_forever,
                          color: Colors.redAccent,
                          onPressed: () => _deleteProfile(profileId),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(Color genderColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 60, color: genderColor.withOpacity(0.5)),
          Text(
            "No Photo",
            style: TextStyle(color: genderColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Manage Matrimony Profiles"),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: isAdmin ? _navigateToViewLimitScreen : null,
              tooltip: "Manage View Limits",
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: colorScheme.onPrimary,
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: Colors.white70,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStaticCountChip(
                    context,
                    label: "Male",
                    count: _totalMaleCount,
                    color: Colors.blueAccent,
                    icon: Icons.male,
                  ),
                  _buildStaticCountChip(
                    context,
                    label: "Female",
                    count: _totalFemaleCount,
                    color: Colors.pinkAccent,
                    icon: Icons.female,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedGender,
                            icon: Icon(
                              Icons.filter_list,
                              color: colorScheme.primary,
                            ),
                            hint: Text(
                              "Filter",
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            onChanged: (String? newValue) {
                              setState(() => _selectedGender = newValue);
                            },
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text("All Profiles"),
                              ),
                              DropdownMenuItem(
                                value: "Male",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.male,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Male"),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Female",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.female,
                                      color: Colors.pinkAccent,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Female"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by Name, Place, Religion, Caste, or Age...",
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  fillColor: colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  final query = _firestore
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
                      final searchText = _searchController.text.toLowerCase();

                      final filteredProfiles = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final expiryDate = data["expiryDate"] != null
                            ? (data["expiryDate"] as Timestamp).toDate()
                            : null;

                        if (_selectedGender != null &&
                            data["gender"] != _selectedGender) {
                          return false;
                        }

                        if (searchText.isNotEmpty) {
                          final name = (data["name"] ?? "")
                              .toString()
                              .toLowerCase();
                          final place = (data["place"] ?? "")
                              .toString()
                              .toLowerCase();
                          final age = (data["age"] ?? "")
                              .toString()
                              .toLowerCase();
                          final religion = (data["religion"] ?? "")
                              .toString()
                              .toLowerCase();
                          final caste = (data["caste"] ?? "")
                              .toString()
                              .toLowerCase();

                          if (!name.contains(searchText) &&
                              !place.contains(searchText) &&
                              !age.contains(searchText) &&
                              !religion.contains(searchText) &&
                              !caste.contains(searchText)) {
                            return false;
                          }
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
                        return Center(
                          child: Text(
                            "No ${tab.toLowerCase()} profiles match the current filters.",
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: filteredProfiles.length,
                        itemBuilder: (ctx, index) {
                          final profile =
                              filteredProfiles[index].data()
                                  as Map<String, dynamic>;
                          final profileId = filteredProfiles[index].id;

                          return _buildProfileCard(
                            context,
                            profile,
                            profileId,
                            tab,
                            isAdmin,
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
                    builder: (ctx) {
                      final TextEditingController userIdController =
                          TextEditingController();
                      String? errorText;

                      return StatefulBuilder(
                        builder: (ctx, setState) => AlertDialog(
                          title: const Text("Enter User ID"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: userIdController,
                                decoration: InputDecoration(
                                  labelText: "User ID",
                                  border: const OutlineInputBorder(),
                                  errorText: errorText,
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
                                final userId = userIdController.text.trim();
                                if (userId.isEmpty) {
                                  setState(
                                    () => errorText = "User ID is required",
                                  );
                                  return;
                                }

                                Navigator.pop(
                                  ctx,
                                ); // close dialog only if valid
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddMatrimonyFAB(userId: userId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                              child: const Text("Continue"),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
