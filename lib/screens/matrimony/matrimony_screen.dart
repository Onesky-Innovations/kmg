// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:kmg/theme/app_theme.dart';
// import 'package:kmg/screens/ads/matri_detail_screen.dart';
// import 'package:kmg/screens/ads/matri_submit_screen.dart';

// class MatrimonyScreen extends StatefulWidget {
//   const MatrimonyScreen({super.key});

//   @override
//   State<MatrimonyScreen> createState() => _MatrimonyScreenState();
// }

// class _MatrimonyScreenState extends State<MatrimonyScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = "";
//   List<Map<String, dynamic>> _recentlyViewed = [];
//   List<Map<String, dynamic>> _viewedRecommended = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadRecentlyViewed();
//     _loadViewedRecommended();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text.toLowerCase();
//     });
//   }

//   // --------------------- Recently Viewed Logic ---------------------
//   Future<void> _loadRecentlyViewed() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getStringList("recentlyViewed") ?? [];
//     setState(() {
//       _recentlyViewed = data
//           .map((e) => Map<String, dynamic>.from(json.decode(e)))
//           .toList();
//     });
//   }

//   Future<void> _addToRecentlyViewed(Map<String, dynamic> profile) async {
//     final prefs = await SharedPreferences.getInstance();
//     _recentlyViewed.removeWhere((p) => p["id"] == profile["id"]);
//     _recentlyViewed.insert(0, profile);
//     if (_recentlyViewed.length > 5) {
//       _recentlyViewed = _recentlyViewed.sublist(0, 5);
//     }
//     await prefs.setStringList(
//       "recentlyViewed",
//       _recentlyViewed.map((p) => json.encode(p)).toList(),
//     );
//     setState(() {});
//   }

//   // --------------------- Viewed Recommended Logic ---------------------
//   Future<void> _loadViewedRecommended() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getStringList("viewedRecommended") ?? [];
//     final now = DateTime.now();
//     setState(() {
//       _viewedRecommended = data
//           .map((e) {
//             final map = Map<String, dynamic>.from(json.decode(e));
//             return {
//               "id": map["id"],
//               "viewedAt": map["viewedAt"] ?? now.toIso8601String(),
//             };
//           })
//           .where((p) {
//             final viewedAt = DateTime.tryParse(p["viewedAt"] ?? "") ?? now;
//             return now.difference(viewedAt).inDays <
//                 4; // Keep only recent views
//           })
//           .toList();
//     });
//   }

//   Future<void> _addToViewedRecommended(String id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final now = DateTime.now();
//     _viewedRecommended.removeWhere((p) => p["id"] == id);
//     _viewedRecommended.insert(0, {"id": id, "viewedAt": now.toIso8601String()});
//     await prefs.setStringList(
//       "viewedRecommended",
//       _viewedRecommended.map((p) => json.encode(p)).toList(),
//     );
//     setState(() {});
//   }

//   // --------------------- Utility ---------------------

//   /// Safely checks if a dynamic value is a string and a valid absolute URL.
//   bool _isValidImageUrl(dynamic url) {
//     if (url is! String || url.isEmpty) return false;
//     // Check if URI parsing is successful and it results in an absolute URI
//     return Uri.tryParse(url)?.isAbsolute ?? false;
//   }

//   Map<String, dynamic> _extractAndConvertProfileData(
//     Map<String, dynamic> rawData,
//     String docId,
//   ) {
//     return {
//       "id": docId,
//       "name": rawData["name"] ?? "",
//       "age": rawData["age"] ?? "",
//       "place": rawData["place"] ?? "",
//       "photo": rawData["photo"] ?? "",
//       "createdAt": (rawData["createdAt"] is Timestamp)
//           ? (rawData["createdAt"] as Timestamp).toDate().toIso8601String()
//           : (rawData["createdAt"] ?? ""),
//     };
//   }

//   void _navigateToDetail(String docId, Map<String, dynamic> profileData) {
//     final profile = _extractAndConvertProfileData(profileData, docId);
//     _addToRecentlyViewed(profile);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             MatriDetailScreen(profileId: docId, profile: profileData),
//       ),
//     );
//   }

//   // --------------------- UI Components ---------------------

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: TextField(
//         controller: _searchController,
//         decoration: InputDecoration(
//           hintText: "Search by name, location...",
//           hintStyle: TextStyle(color: AppTheme.lightText.withOpacity(0.7)),
//           prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
//           suffixIcon: _searchController.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear, color: AppTheme.lightText),
//                   onPressed: () {
//                     _searchController.clear();
//                     _onSearchChanged();
//                   },
//                 )
//               : null,
//           filled: true,
//           fillColor: AppTheme.cardBackground,
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 16,
//             horizontal: 16,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none, // Hide default border
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: const BorderSide(
//               color: AppTheme.primaryColor,
//               width: 2,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sectionHeader(
//     String title, {
//     String? actionText,
//     VoidCallback? onActionPressed,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800, // Make it very bold
//               color: AppTheme.darkText,
//             ),
//           ),
//           if (actionText != null && onActionPressed != null)
//             TextButton(
//               onPressed: onActionPressed,
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.zero,
//                 minimumSize: const Size(50, 20),
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               child: Text(
//                 actionText,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppTheme.primaryColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _horizontalProfileTile(Map<String, dynamic> profile, String docId) {
//     // Used for Recently Viewed / Recommended sections
//     final photoUrl = profile["photo"];
//     final hasPhoto = _isValidImageUrl(photoUrl);

//     return GestureDetector(
//       onTap: () => _navigateToDetail(docId, profile),
//       child: Container(
//         width: 100, // Slightly wider tile
//         margin: const EdgeInsets.only(left: 16, right: 4),
//         padding: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: AppTheme.cardBackground,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 3,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: AppTheme.primaryColor.withOpacity(0.4),
//                   width: 2,
//                 ),
//               ),
//               child: CircleAvatar(
//                 radius: 30,
//                 backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
//                 backgroundImage: hasPhoto
//                     ? NetworkImage(photoUrl as String)
//                     : null,
//                 child: !hasPhoto
//                     ? const Icon(
//                         Icons.person_4,
//                         size: 30,
//                         color: AppTheme.primaryColor,
//                       )
//                     : null,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               profile["name"] ?? "N/A",
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.darkText,
//               ),
//             ),
//             Text(
//               "${profile["age"] ?? 'N/A'} | ${profile["place"] ?? 'N/A'}",
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 10,
//                 color: AppTheme.lightText.withOpacity(0.8),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGridProfileCard(Map<String, dynamic> data, String docId) {
//     // Used for the main list of profiles (GridView)
//     final photoUrl = data["photo"];
//     final hasPhoto = _isValidImageUrl(photoUrl);

//     return GestureDetector(
//       onTap: () => _navigateToDetail(docId, data),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         elevation: 6, // Higher elevation for prominence
//         color: AppTheme.cardBackground,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(16),
//                 ),
//                 child: hasPhoto
//                     ? Image.network(
//                         photoUrl
//                             as String, // Safe cast because _isValidImageUrl checked the type
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             const Center(
//                               child: Icon(
//                                 Icons.person_off_rounded,
//                                 size: 40,
//                                 color: AppTheme.lightText,
//                               ),
//                             ),
//                       )
//                     : Container(
//                         color: AppTheme.primaryColor.withOpacity(0.1),
//                         child: const Center(
//                           child: Icon(
//                             Icons.person_4_outlined,
//                             size: 60,
//                             color: AppTheme.primaryColor,
//                           ),
//                         ),
//                       ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     data["name"] ?? "Unknown",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       color: AppTheme.darkText,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.cake_outlined,
//                         size: 14,
//                         color: AppTheme.lightText,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         "${data["age"] ?? 'N/A'} years",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: AppTheme.lightText,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.location_on_outlined,
//                         size: 14,
//                         color: AppTheme.lightText,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           data["place"] ?? "Location N/A",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: AppTheme.lightText,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --------------------- Sections Builders ---------------------

//   Widget _buildRecentlyViewed() {
//     if (_recentlyViewed.isEmpty) return const SizedBox.shrink();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionHeader(
//           "Recently Viewed",
//           actionText: "View All",
//           onActionPressed: () {
//             // Placeholder for navigation to a full list of recently viewed
//           },
//         ),
//         const SizedBox(height: 4),
//         SizedBox(
//           height: 125, // Adjusted height for slightly taller tiles
//           child: ListView.builder(
//             padding: const EdgeInsets.only(
//               right: 16,
//             ), // Ensures padding on the right edge
//             scrollDirection: Axis.horizontal,
//             itemCount: _recentlyViewed.length,
//             itemBuilder: (context, index) {
//               final profile = _recentlyViewed[index];
//               return _horizontalProfileTile(
//                 profile,
//                 profile["id"] ?? "unknown",
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRecommendations(List<QueryDocumentSnapshot> allProfiles) {
//     final now = DateTime.now();
//     final recommendedProfiles = allProfiles
//         .where((doc) {
//           final id = doc.id;
//           final viewed = _viewedRecommended.any((v) {
//             final viewedAt = DateTime.tryParse(v["viewedAt"] ?? "") ?? now;
//             return v["id"] == id && now.difference(viewedAt).inDays < 4;
//           });
//           return !viewed;
//         })
//         .take(5) // Limit the number of recommendations
//         .toList();

//     if (recommendedProfiles.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionHeader(
//           "Recommended for You",
//           actionText: "More",
//           onActionPressed: () {
//             // Placeholder for navigation to a full list of recommendations
//           },
//         ),
//         const SizedBox(height: 4),
//         SizedBox(
//           height: 125, // Adjusted height for slightly taller tiles
//           child: ListView.builder(
//             padding: const EdgeInsets.only(
//               right: 16,
//             ), // Ensures padding on the right edge
//             scrollDirection: Axis.horizontal,
//             itemCount: recommendedProfiles.length,
//             itemBuilder: (context, index) {
//               final doc = recommendedProfiles[index];
//               return _horizontalProfileTile(
//                 doc.data() as Map<String, dynamic>,
//                 doc.id,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // --------------------- Main Build ---------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Matrimony Profiles",
//           style: TextStyle(
//             color: AppTheme.iconOnPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         flexibleSpace: Container(
//           // Subtle gradient for a premium feel
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 AppTheme.primaryColor,
//                 AppTheme.primaryColor.withOpacity(0.8),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         elevation: 4, // Add elevation for depth
//       ),
//       backgroundColor: AppTheme.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSearchBar(),
//               _buildRecentlyViewed(),
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('matrimony')
//                     .orderBy("createdAt", descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Padding(
//                       padding: EdgeInsets.all(32),
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           color: AppTheme.primaryColor,
//                         ),
//                       ),
//                     );
//                   }

//                   if (snapshot.hasError) {
//                     return Padding(
//                       padding: const EdgeInsets.all(24),
//                       child: Text(
//                         "Error loading profiles: ${snapshot.error}",
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: AppTheme.darkText),
//                       ),
//                     );
//                   }

//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Padding(
//                       padding: EdgeInsets.all(24),
//                       child: Center(
//                         child: Text(
//                           "No profiles available at the moment.",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: AppTheme.lightText,
//                           ),
//                         ),
//                       ),
//                     );
//                   }

//                   final allProfiles = snapshot.data!.docs;
//                   final filteredProfiles = allProfiles.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final name = (data["name"] ?? "").toLowerCase();
//                     final place = (data["place"] ?? "").toLowerCase();
//                     return name.contains(_searchQuery) ||
//                         place.contains(_searchQuery);
//                   }).toList();

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (_searchQuery.isEmpty)
//                         _buildRecommendations(allProfiles),

//                       _sectionHeader(
//                         _searchQuery.isEmpty
//                             ? "All Profiles"
//                             : "Search Results (${filteredProfiles.length})",
//                       ),

//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: filteredProfiles.length,
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 childAspectRatio:
//                                     0.75, // Better aspect ratio for photo and text
//                                 mainAxisSpacing: 16,
//                                 crossAxisSpacing: 16,
//                               ),
//                           itemBuilder: (context, index) {
//                             final doc = filteredProfiles[index];
//                             final data = doc.data() as Map<String, dynamic>;
//                             return _buildGridProfileCard(data, doc.id);
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 100), // Space for FAB
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const MatriSubmitScreen()),
//           );
//         },
//         label: const Text(
//           "Add Profile",
//           style: TextStyle(
//             color: AppTheme.iconOnPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         icon: const Icon(Icons.person_add_alt_1, color: AppTheme.iconOnPrimary),
//         backgroundColor: AppTheme.primaryColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:kmg/theme/app_theme.dart';
import 'package:kmg/screens/ads/matri_detail_screen.dart';
import 'package:kmg/screens/ads/matri_submit_screen.dart';
import 'package:kmg/screens/matrimony/premium.user.dart';

class MatrimonyScreen extends StatefulWidget {
  const MatrimonyScreen({super.key});

  @override
  State<MatrimonyScreen> createState() => _MatrimonyScreenState();
}

class _MatrimonyScreenState extends State<MatrimonyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<Map<String, dynamic>> _recentlyViewed = [];
  List<Map<String, dynamic>> _viewedRecommended = [];
  Map<String, dynamic>? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _loadRecentlyViewed();
    _loadViewedRecommended();
    _loadLoggedInUser();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  // ------------------- Logged-in / Premium Logic -------------------
  Future<void> _loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("loggedInUser");
    if (data != null) {
      setState(() {
        _loggedInUser = json.decode(data);
      });
    }
  }

  Future<void> _saveLoggedInUser(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("loggedInUser", json.encode(profile));
    setState(() {
      _loggedInUser = profile;
    });
  }

  void _openSignIn() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MatriSubmitScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      _saveLoggedInUser(result);
    }
  }

  void _navigateToDetail(String docId, Map<String, dynamic> profileData) async {
    // Check if this user is premium
    final premiumSnap = await FirebaseFirestore.instance
        .collection('premium_users')
        .doc(profileData['userId'])
        .get();

    final isPremium = premiumSnap.exists;

    if (isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MatriDetailScreen(profileId: docId, profile: profileData),
        ),
      );
    } else {
      // Not premium, prompt upgrade
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Premium Access Required"),
          content: const Text(
            "Upgrade to premium to view full profile details.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _openSignIn();
              },
              child: const Text("Sign In / Upgrade"),
            ),
          ],
        ),
      );
    }
  }

  // --------------------- Recently Viewed ---------------------
  Future<void> _loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("recentlyViewed") ?? [];
    setState(() {
      _recentlyViewed = data
          .map((e) => Map<String, dynamic>.from(json.decode(e)))
          .toList();
    });
  }

  Future<void> _addToRecentlyViewed(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    _recentlyViewed.removeWhere((p) => p["id"] == profile["id"]);
    _recentlyViewed.insert(0, profile);
    if (_recentlyViewed.length > 5)
      _recentlyViewed = _recentlyViewed.sublist(0, 5);
    await prefs.setStringList(
      "recentlyViewed",
      _recentlyViewed.map((p) => json.encode(p)).toList(),
    );
    setState(() {});
  }

  // --------------------- Viewed Recommended ---------------------
  Future<void> _loadViewedRecommended() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("viewedRecommended") ?? [];
    final now = DateTime.now();
    setState(() {
      _viewedRecommended = data
          .map((e) {
            final map = Map<String, dynamic>.from(json.decode(e));
            return {
              "id": map["id"],
              "viewedAt": map["viewedAt"] ?? now.toIso8601String(),
            };
          })
          .where((p) {
            final viewedAt = DateTime.tryParse(p["viewedAt"] ?? "") ?? now;
            return now.difference(viewedAt).inDays < 4;
          })
          .toList();
    });
  }

  Future<void> _addToViewedRecommended(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    _viewedRecommended.removeWhere((p) => p["id"] == id);
    _viewedRecommended.insert(0, {"id": id, "viewedAt": now.toIso8601String()});
    await prefs.setStringList(
      "viewedRecommended",
      _viewedRecommended.map((p) => json.encode(p)).toList(),
    );
    setState(() {});
  }

  // --------------------- Utilities ---------------------
  bool _isValidImageUrl(dynamic url) {
    if (url is! String || url.isEmpty) return false;
    return Uri.tryParse(url)?.isAbsolute ?? false;
  }

  Map<String, dynamic> _extractAndConvertProfileData(
    Map<String, dynamic> rawData,
    String docId,
  ) {
    return {
      "id": docId,
      "name": rawData["name"] ?? "",
      "age": rawData["age"] ?? "",
      "place": rawData["place"] ?? "",
      "photo": rawData["photo"] ?? "",
      "createdAt": (rawData["createdAt"] is Timestamp)
          ? (rawData["createdAt"] as Timestamp).toDate().toIso8601String()
          : (rawData["createdAt"] ?? ""),
    };
  }

  void _navigateAndAddRecentlyViewed(
    String docId,
    Map<String, dynamic> profileData,
  ) {
    final profile = _extractAndConvertProfileData(profileData, docId);
    _addToRecentlyViewed(profile);
    _navigateToDetail(docId, profileData);
  }

  // --------------------- UI Components ---------------------
  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Search by name, location...",
        hintStyle: TextStyle(color: AppTheme.lightText.withOpacity(0.7)),
        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.lightText),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged();
                },
              )
            : null,
        filled: true,
        fillColor: AppTheme.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );

  Widget _sectionHeader(
    String title, {
    String? actionText,
    VoidCallback? onActionPressed,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkText,
          ),
        ),
        if (actionText != null && onActionPressed != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _horizontalProfileTile(Map<String, dynamic> profile, String docId) {
    final hasPhoto = _isValidImageUrl(profile["photo"]);

    return GestureDetector(
      onTap: () => _navigateAndAddRecentlyViewed(docId, profile),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(left: 16, right: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: hasPhoto
                      ? NetworkImage(profile["photo"])
                      : null,
                  child: !hasPhoto
                      ? const Icon(
                          Icons.person_4,
                          size: 30,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                if (profile['premium'] == true)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              profile["name"] ?? "N/A",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            Text(
              "${profile["age"] ?? 'N/A'} | ${profile["place"] ?? 'N/A'}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.lightText.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridProfileCard(Map<String, dynamic> data, String docId) {
    final hasPhoto = _isValidImageUrl(data["photo"]);
    return GestureDetector(
      onTap: () => _navigateAndAddRecentlyViewed(docId, data),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        color: AppTheme.cardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: hasPhoto
                    ? Image.network(data["photo"], fit: BoxFit.cover)
                    : Container(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.person_4_outlined,
                            size: 60,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["name"] ?? "Unknown",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.cake_outlined,
                        size: 14,
                        color: AppTheme.lightText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${data["age"] ?? 'N/A'} years",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.lightText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data["place"] ?? "Location N/A",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.lightText,
                          ),
                        ),
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

  Widget _buildRecentlyViewed() {
    if (_recentlyViewed.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Recently Viewed"),
        const SizedBox(height: 4),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: _recentlyViewed.length,
            itemBuilder: (context, index) {
              final profile = _recentlyViewed[index];
              return _horizontalProfileTile(
                profile,
                profile["id"] ?? "unknown",
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(List<QueryDocumentSnapshot> allProfiles) {
    final now = DateTime.now();
    final recommendedProfiles = allProfiles
        .where((doc) {
          final id = doc.id;
          final viewed = _viewedRecommended.any((v) {
            final viewedAt = DateTime.tryParse(v["viewedAt"] ?? "") ?? now;
            return v["id"] == id && now.difference(viewedAt).inDays < 4;
          });
          return !viewed;
        })
        .take(5)
        .toList();

    if (recommendedProfiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Recommended for You"),
        const SizedBox(height: 4),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: recommendedProfiles.length,
            itemBuilder: (context, index) {
              final doc = recommendedProfiles[index];
              return _horizontalProfileTile(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            },
          ),
        ),
      ],
    );
  }

  // --------------------- Main Build ---------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Matrimony Profiles",
          style: TextStyle(
            color: AppTheme.iconOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumUserScreen()),
              );
            },
            icon: const Icon(
              Icons.workspace_premium,
              color: Colors.amberAccent,
            ),
            tooltip: "Premium Users",
          ),
        ],
      ),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              _buildRecentlyViewed(),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('matrimony')
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          "No profiles available at the moment.",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.lightText,
                          ),
                        ),
                      ),
                    );
                  }
                  final allProfiles = snapshot.data!.docs;
                  final filteredProfiles = allProfiles.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data["name"] ?? "").toLowerCase();
                    final place = (data["place"] ?? "").toLowerCase();
                    return name.contains(_searchQuery) ||
                        place.contains(_searchQuery);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_searchQuery.isEmpty)
                        _buildRecommendations(allProfiles),
                      _sectionHeader(
                        _searchQuery.isEmpty
                            ? "All Profiles"
                            : "Search Results (${filteredProfiles.length})",
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredProfiles.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                          itemBuilder: (context, index) {
                            final doc = filteredProfiles[index];
                            final data = doc.data() as Map<String, dynamic>;
                            return _buildGridProfileCard(data, doc.id);
                          },
                        ),
                      ),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MatriSubmitScreen()),
          );
        },
        label: const Text(
          "Add Profile",
          style: TextStyle(
            color: AppTheme.iconOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.person_add_alt_1, color: AppTheme.iconOnPrimary),
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
