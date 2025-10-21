// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:kmg/screens/matrimony/widgets/viewcount.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:kmg/screens/matrimony/matri_screens/MatriLoginScreen.dart';
// import 'package:kmg/screens/matrimony/matri_screens/userMatriProfileScreen.dart';
// import 'package:kmg/screens/matrimony/matri_screens/matri_submit_screen.dart';
// import 'package:kmg/screens/matrimony/widgets/profile_card_widget.dart';
// import 'package:kmg/screens/matrimony/widgets/matrimony_appbar.dart';
// import 'package:kmg/screens/matrimony/widgets/matrimony_filters.dart';
// // import 'viewcount.dart';

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
//   Map<String, dynamic>? _loggedInUser;
//   String _userGender = "";
//   List<String> _favorites = [];
//   RangeValues _currentAgeRange = const RangeValues(20, 35);
//   final double _minSliderAge = 18;
//   final double _maxSliderAge = 70;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//     _searchController.addListener(() {
//       setState(() {});
//     });
//   }

//   Future<void> _loadInitialData() async {
//     await _loadLoggedInUser();
//     await _loadRecentlyViewed();
//     await _loadViewedRecommended();
//     await _loadFavorites();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadLoggedInUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userString = prefs.getString("loggedInUser");
//     if (userString != null) {
//       try {
//         final data = json.decode(userString) as Map<String, dynamic>;
//         setState(() {
//           _loggedInUser = data;
//           _userGender = (data['gender'] ?? "").toString().toLowerCase();
//         });
//         _setInitialAgeRange(data['age']);
//         // Ensure visitedProfiles exists
//         _loggedInUser!['visitedProfiles'] ??= [];
//         _loggedInUser!['viewCount'] ??= 0;
//         _loggedInUser!['accessibleProfiles'] ??= 5;
//       } catch (_) {}
//     }
//   }

//   void _setInitialAgeRange(dynamic userAge) {
//     final age = int.tryParse(userAge?.toString() ?? '25') ?? 25;
//     setState(() {
//       final start = (age - 5).clamp(_minSliderAge, _maxSliderAge).toDouble();
//       final end = (age + 5).clamp(_minSliderAge, _maxSliderAge).toDouble();
//       _currentAgeRange = RangeValues(start, end);
//     });
//   }

//   Future<void> _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove("loggedInUser");
//     setState(() {
//       _loggedInUser = null;
//       _userGender = "";
//       _recentlyViewed = [];
//       _viewedRecommended = [];
//       _favorites = [];
//     });
//   }

//   Future<void> _requireLogin() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const MatriLoginScreen()),
//     );
//     if (result != null && result is Map<String, dynamic>) {
//       await _loadInitialData();
//     }
//   }

//   Future<void> _addToRecentlyViewed(Map<String, dynamic> rawProfile) async {
//     final prefs = await SharedPreferences.getInstance();

//     final profile = <String, dynamic>{};
//     rawProfile.forEach((key, value) {
//       if (value is Timestamp) {
//         profile[key] = value.toDate().toIso8601String();
//       } else {
//         profile[key] = value;
//       }
//     });

//     _recentlyViewed.removeWhere((p) => p["id"] == profile["id"]);
//     _recentlyViewed.insert(0, profile);

//     if (_recentlyViewed.length > 5) {
//       _recentlyViewed = _recentlyViewed.sublist(0, 5);
//     }

//     final encodedList = _recentlyViewed.map((p) => json.encode(p)).toList();
//     await prefs.setStringList("recentlyViewed", encodedList);

//     setState(() {});
//   }

//   Future<void> _loadRecentlyViewed() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getStringList("recentlyViewed") ?? [];
//     setState(() {
//       _recentlyViewed = data
//           .map((e) => Map<String, dynamic>.from(json.decode(e)))
//           .toList();
//     });
//   }

//   Future<void> _loadViewedRecommended() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getStringList("viewedRecommended") ?? [];
//     final now = DateTime.now();
//     final fourDaysAgo = now.subtract(const Duration(days: 4));

//     setState(() {
//       _viewedRecommended = data
//           .map((e) {
//             final map = Map<String, dynamic>.from(json.decode(e));
//             return {
//               "id": map["id"]?.toString() ?? "",
//               "viewedAt": map["viewedAt"] ?? now.toIso8601String(),
//             };
//           })
//           .where((p) {
//             final viewedAt = DateTime.tryParse(p["viewedAt"] ?? "") ?? now;
//             return viewedAt.isAfter(fourDaysAgo);
//           })
//           .toList();
//     });
//     await prefs.setStringList(
//       "viewedRecommended",
//       _viewedRecommended.map((p) => json.encode(p)).toList(),
//     );
//   }

//   Future<void> _addToViewedRecommended(String? id) async {
//     if (id == null || id.isEmpty) return;
//     final prefs = await SharedPreferences.getInstance();
//     final now = DateTime.now();
//     await _loadViewedRecommended();
//     _viewedRecommended.removeWhere((p) => p["id"] == id);
//     _viewedRecommended.insert(0, {"id": id, "viewedAt": now.toIso8601String()});
//     await prefs.setStringList(
//       "viewedRecommended",
//       _viewedRecommended.map((p) => json.encode(p)).toList(),
//     );
//     setState(() {});
//   }

//   Future<void> _loadFavorites() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _favorites = prefs.getStringList("favorites") ?? [];
//     });
//   }

//   Future<void> _toggleFavorite(String? profileId) async {
//     if (_loggedInUser == null) {
//       _requireLogin();
//       return;
//     }

//     final id = profileId?.toString() ?? '';
//     if (id.isEmpty) return;

//     if (_favorites.contains(id)) {
//       _favorites.remove(id);
//     } else {
//       if (_favorites.length >= 5) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("You can add only 5 favorites.")),
//         );
//         return;
//       }
//       _favorites.add(id);
//     }
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList("favorites", _favorites);
//     setState(() {});
//   }

//   bool _isFavorite(String? profileId) {
//     final id = profileId?.toString() ?? '';
//     return id.isNotEmpty && _favorites.contains(id);
//   }

//   bool _isValidImageUrl(dynamic url) {
//     if (url is! String || url.isEmpty) return false;
//     return Uri.tryParse(url)?.isAbsolute ?? false;
//   }

//   Widget _buildHorizontalList(
//     String title,
//     List<Map<String, dynamic>> profiles,
//   ) {
//     final nonNullProfiles = profiles.where((p) => p["id"] != null).toList();
//     if (nonNullProfiles.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: Text(
//             title,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//         ),
//         SizedBox(
//           height: 125,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: nonNullProfiles.length,
//             itemBuilder: (context, index) {
//               final profile = nonNullProfiles[index];
//               return ProfileCardWidget(
//                 profileId: profile["id"]?.toString() ?? '',
//                 name: profile["name"]?.toString() ?? '-',
//                 age: profile["age"]?.toString() ?? '-',
//                 place: profile["place"]?.toString() ?? '-',
//                 photoUrl: profile["photo"]?.toString() ?? '',
//                 hasPhoto: _isValidImageUrl(profile["photo"]),
//                 isFavorite: _isFavorite(profile["id"]?.toString()),
//                 horizontalMode: true,
//                 onTap: () =>
//                     _navigateToDetail(profile["id"]?.toString() ?? '', profile),
//                 onFavoriteToggle: () =>
//                     _toggleFavorite(profile["id"]?.toString() ?? ''),
//               );
//             },
//           ),
//         ),
//         const Divider(),
//       ],
//     );
//   }

//   // Navigate to profile with view limit check
//   Future<void> _navigateToDetail(
//     String docId,
//     Map<String, dynamic> profileData,
//   ) async {
//     if (_loggedInUser == null) {
//       await _requireLogin();
//       return;
//     }

//     final viewCountService = ViewCountService();

//     // Increment Alice's local viewCount only
//     final canView = await viewCountService.tryViewProfile(
//       profileId: docId,
//       visitorData: _loggedInUser!,
//       context: context,
//     );

//     if (!canView) return; // Limit reached

//     // Track recently viewed locally
//     await _addToRecentlyViewed(profileData);

//     // Navigate to profile screen
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => MatriProfileScreen(userData: profileData),
//       ),
//     );

//     // Refresh local lists
//     _loadRecentlyViewed();
//     _loadFavorites();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: MatrimonyAppBar(
//         loggedInUser: _loggedInUser,
//         onLogout: _logout,
//         requireLogin: _requireLogin,
//         onProfileTap: () {
//           if (_loggedInUser != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     MatriProfileScreen(userData: _loggedInUser!),
//               ),
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const MatriSubmitScreen()),
//           );
//         },
//         icon: const Icon(Icons.add),
//         label: const Text("Register"),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               MatrimonyFilters(
//                 searchController: _searchController,
//                 currentRange: _currentAgeRange,
//                 minSliderAge: _minSliderAge,
//                 maxSliderAge: _maxSliderAge,
//                 onRangeChanged: (values) =>
//                     setState(() => _currentAgeRange = values),
//                 onSearchChanged: (text) => setState(() => _searchQuery = text),
//               ),
//               _buildHorizontalList(
//                 "My Favorites",
//                 _recentlyViewed
//                     .where((p) => _favorites.contains(p["id"]?.toString()))
//                     .toList(),
//               ),
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('matrimony')
//                     .orderBy('createdAt', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   final allProfiles = snapshot.data!.docs;

//                   final filteredProfiles = allProfiles.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>? ?? {};
//                     final name = data['name']?.toString().toLowerCase() ?? '';
//                     final place = data['place']?.toString().toLowerCase() ?? '';
//                     final gender =
//                         data['gender']?.toString().toLowerCase() ?? '';
//                     final age =
//                         int.tryParse(data['age']?.toString() ?? "0") ?? 0;

//                     final searchMatch =
//                         _searchQuery.isEmpty ||
//                         name.contains(_searchQuery) ||
//                         place.contains(_searchQuery);
//                     if (!searchMatch) return false;
//                     if (age < _currentAgeRange.start ||
//                         age > _currentAgeRange.end) {
//                       return false;
//                     }
//                     if (_loggedInUser != null && gender == _userGender) {
//                       return false;
//                     }
//                     return true;
//                   }).toList();

//                   final recentlyViewedProfiles = _recentlyViewed
//                       .where((p) => p['gender']?.toString() != _userGender)
//                       .toList();
//                   final recommendedProfiles = allProfiles
//                       .map((doc) => doc.data() as Map<String, dynamic>)
//                       .where((p) {
//                         final id = p['id']?.toString() ?? '';
//                         return !_viewedRecommended.any((v) => v['id'] == id);
//                       })
//                       .toList();

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildHorizontalList(
//                         "Recently Viewed",
//                         recentlyViewedProfiles,
//                       ),
//                       _buildHorizontalList(
//                         "Recommended for You",
//                         recommendedProfiles,
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
//                         child: Text(
//                           "All Profiles",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                       GridView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: filteredProfiles.length,
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                               childAspectRatio: 0.9,
//                             ),
//                         itemBuilder: (context, index) {
//                           final doc = filteredProfiles[index];
//                           final data =
//                               doc.data() as Map<String, dynamic>? ?? {};
//                           return ProfileCardWidget(
//                             profileId: doc.id,
//                             name: data['name']?.toString() ?? '-',
//                             age: data['age']?.toString() ?? '-',
//                             place: data['place']?.toString() ?? '-',
//                             photoUrl: data['photo']?.toString() ?? '',
//                             hasPhoto: _isValidImageUrl(data['photo']),
//                             isFavorite: _isFavorite(doc.id),
//                             onTap: () => _navigateToDetail(doc.id, data),
//                             onFavoriteToggle: () => _toggleFavorite(doc.id),
//                             horizontalMode: false,
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 80),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // ⭐️ Single Notifier Import
import 'package:kmg/notifiers/matrimony_notifier.dart'; // Assuming path
import 'package:kmg/screens/matrimony/matri_screens/matri_detail_screen.dart';
import 'package:kmg/screens/matrimony/matri_screens/MatriLoginScreen.dart';
import 'package:kmg/screens/matrimony/matri_screens/userMatriProfileScreen.dart';
import 'package:kmg/screens/matrimony/matri_screens/matri_submit_screen.dart';
import 'package:kmg/screens/matrimony/widgets/profile_card_widget.dart';
import 'package:kmg/screens/matrimony/widgets/matrimony_appbar.dart';
import 'package:kmg/screens/matrimony/widgets/matrimony_filters.dart';

class MatrimonyScreen extends StatefulWidget {
  const MatrimonyScreen({super.key});

  @override
  State<MatrimonyScreen> createState() => _MatrimonyScreenState();
}

class _MatrimonyScreenState extends State<MatrimonyScreen> {
  // ⭐️ Keep only local UI state here
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  RangeValues _currentAgeRange = const RangeValues(20, 35);
  final double _minSliderAge = 18;
  final double _maxSliderAge = 70;

  // Filter state variables
  bool _showFavoritesOnly = false;
  String? _selectedReligion;
  String? _selectedCaste;
  String? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    // Set initial age range based on the user loaded by the Notifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<MatrimonyNotifier>(context, listen: false);
      _setInitialAgeRange(notifier.loggedInUser?['age']);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setInitialAgeRange(dynamic userAge) {
    final age = int.tryParse(userAge?.toString() ?? '25') ?? 25;
    setState(() {
      final start = (age - 5).clamp(_minSliderAge, _maxSliderAge).toDouble();
      final end = (age + 5).clamp(_minSliderAge, _maxSliderAge).toDouble();
      _currentAgeRange = RangeValues(start, end);
    });
  }

  // Helper to check if the image URL is valid
  bool _isValidImageUrl(dynamic url) {
    if (url is! String || url.isEmpty) return false;
    return Uri.tryParse(url)?.isAbsolute ?? false;
  }

  Widget _buildHorizontalList(
    String title,
    List<Map<String, dynamic>> profiles,
    MatrimonyNotifier notifier,
  ) {
    if (notifier.loggedInUser == null) return const SizedBox.shrink();

    final nonNullProfiles = profiles.where((p) => p["id"] != null).toList();
    if (nonNullProfiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: nonNullProfiles.length,
            itemBuilder: (context, index) {
              final profile = nonNullProfiles[index];
              final profileId = profile["id"]?.toString() ?? '';

              return ProfileCardWidget(
                profileId: profileId,
                name: profile["name"]?.toString() ?? '-',
                age: profile["age"]?.toString() ?? '-',
                place: profile["place"]?.toString() ?? '-',
                photoUrl: profile["photo"]?.toString() ?? '',
                hasPhoto: _isValidImageUrl(profile["photo"]),
                // ⭐️ Use Notifier's getter
                isFavorite: notifier.isFavorite(profileId),
                horizontalMode: true,
                // ⭐️ Use Notifier's navigation method
                onTap: () =>
                    notifier.navigateToDetail(context, profileId, profile),
                // ⭐️ Use Notifier's toggle method
                onFavoriteToggle: () =>
                    notifier.toggleFavorite(context, profileId),
              );
            },
          ),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ Watch the single Notifier
    final notifier = context.watch<MatrimonyNotifier>();
    final isLoggedIn = notifier.loggedInUser != null;

    // Use Notifier data
    final loggedInUser = notifier.loggedInUser;
    final userGender = notifier.userGender;
    final favorites = notifier.favorites;
    final recentlyViewed = notifier.recentlyViewed;
    final viewedRecommended = notifier.viewedRecommended;

    return Scaffold(
      appBar: MatrimonyAppBar(
        loggedInUser: loggedInUser,
        // ⭐️ Call Notifier's logout
        onLogout: () => notifier.logout(context),
        // ⭐️ Call Notifier's requireLogin
        requireLogin: () => notifier.requireLogin(context),
        onProfileTap: () {
          if (loggedInUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MatriProfileScreen(userData: loggedInUser),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MatriSubmitScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Register"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MatrimonyFilters(
                searchController: _searchController,
                currentRange: _currentAgeRange,
                minSliderAge: _minSliderAge,
                maxSliderAge: _maxSliderAge,
                onRangeChanged: (values) =>
                    setState(() => _currentAgeRange = values),
                onSearchChanged: (text) {},
                isLoggedIn: isLoggedIn,
                showFavoritesOnly: isLoggedIn ? _showFavoritesOnly : false,
                onToggleFavorites: (value) =>
                    setState(() => _showFavoritesOnly = value!),
                selectedReligion: isLoggedIn ? _selectedReligion : null,
                onReligionSelected: (value) =>
                    setState(() => _selectedReligion = value),
                selectedCaste: isLoggedIn ? _selectedCaste : null,
                onCasteSelected: (value) =>
                    setState(() => _selectedCaste = value),
                selectedPlace: isLoggedIn ? _selectedPlace : null,
                onPlaceSelected: (value) =>
                    setState(() => _selectedPlace = value),
              ),

              // ⭐️ View Limit Counter Display (using ValueListenableBuilder)
              if (isLoggedIn && notifier.isLimitApplicable)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: notifier.userViewLimitNotifier,
                    builder: (context, limit, child) {
                      return Text(
                        'Views Remaining: ${notifier.remaining} / $limit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: notifier.remaining <= 5
                              ? Colors.red
                              : Colors.green,
                        ),
                      );
                    },
                  ),
                ),
              const Divider(height: 1),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('matrimony')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allProfiles = snapshot.data!.docs;

                  // ⭐️ Filtered/Featured Lists Setup
                  final favoritedProfilesData = allProfiles
                      .where(
                        (doc) => favorites.contains(doc.id),
                      ) // ⭐️ Use Notifier's list
                      .map(
                        (doc) =>
                            doc.data() as Map<String, dynamic>..['id'] = doc.id,
                      )
                      .toList();

                  final recommendedProfiles = allProfiles
                      .map(
                        (doc) =>
                            doc.data() as Map<String, dynamic>..['id'] = doc.id,
                      )
                      .where((p) {
                        final id = p['id']?.toString() ?? '';
                        return isLoggedIn &&
                            !viewedRecommended.any(
                              (v) => v['id'] == id,
                            ) && // ⭐️ Use Notifier's list
                            p['gender']?.toString().toLowerCase() != userGender;
                      })
                      .toList();

                  // ⭐️ Main Profile List Filtering
                  final filteredProfiles = allProfiles.where((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final profileId = doc.id;
                    final name = data['name']?.toString().toLowerCase() ?? '';
                    final place = data['place']?.toString().toLowerCase() ?? '';
                    final gender =
                        data['gender']?.toString().toLowerCase() ?? '';
                    final age =
                        int.tryParse(data['age']?.toString() ?? "0") ?? 0;
                    final religion =
                        data['religion']?.toString().toLowerCase() ?? '';
                    final caste = data['caste']?.toString().toLowerCase() ?? '';

                    // 1. Search Filter
                    final searchMatch =
                        _searchQuery.isEmpty ||
                        name.contains(_searchQuery) ||
                        place.contains(_searchQuery);
                    if (!searchMatch) return false;

                    // 2. Age Range Filter
                    if (age < _currentAgeRange.start ||
                        age > _currentAgeRange.end) {
                      return false;
                    }

                    // 3. Gender/Self Filter
                    if (isLoggedIn) {
                      if (gender == userGender) return false;
                      if (profileId == loggedInUser!['id']?.toString()) {
                        return false;
                      }
                    }

                    // 4. Conditional Filters (Apply only if logged in)
                    if (isLoggedIn) {
                      // Favorites Filter
                      if (_showFavoritesOnly &&
                          !favorites.contains(profileId)) {
                        // ⭐️ Use Notifier's list
                        return false;
                      }

                      // Other filters remain the same
                      if (_selectedReligion != null &&
                          _selectedReligion!.isNotEmpty &&
                          religion != _selectedReligion!.toLowerCase()) {
                        return false;
                      }
                      if (_selectedCaste != null &&
                          _selectedCaste!.isNotEmpty &&
                          caste != _selectedCaste!.toLowerCase()) {
                        return false;
                      }
                      if (_selectedPlace != null &&
                          _selectedPlace!.isNotEmpty &&
                          place != _selectedPlace!.toLowerCase()) {
                        return false;
                      }
                    }

                    return true;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // My Favorites List
                      if (isLoggedIn)
                        _buildHorizontalList(
                          "My Favorites",
                          favoritedProfilesData,
                          notifier,
                        ),

                      // Recommended and Recently Viewed (Hide if filters are active or not logged in)
                      if (isLoggedIn &&
                          !_showFavoritesOnly &&
                          _selectedReligion == null &&
                          _selectedCaste == null &&
                          _selectedPlace == null &&
                          _searchQuery.isEmpty) ...[
                        _buildHorizontalList(
                          "Recently Viewed",
                          recentlyViewed
                              .where(
                                (p) => p['gender']?.toString() != userGender,
                              )
                              .toList(),
                          notifier,
                        ),
                        _buildHorizontalList(
                          "Recommended for You",
                          recommendedProfiles,
                          notifier,
                        ),
                      ],

                      // All Profiles Grid
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          "All Profiles",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProfiles.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.9,
                            ),
                        itemBuilder: (context, index) {
                          final doc = filteredProfiles[index];
                          final data =
                              doc.data() as Map<String, dynamic>? ?? {};
                          return ProfileCardWidget(
                            profileId: doc.id,
                            name: data['name']?.toString() ?? '-',
                            age: data['age']?.toString() ?? '-',
                            place: data['place']?.toString() ?? '-',
                            photoUrl: data['photo']?.toString() ?? '',
                            hasPhoto: _isValidImageUrl(data['photo']),
                            // ⭐️ Use Notifier's getter
                            isFavorite: notifier.isFavorite(doc.id),
                            // ⭐️ Use Notifier's navigation method
                            onTap: () => notifier.navigateToDetail(
                              context,
                              doc.id,
                              data,
                            ),
                            // ⭐️ Use Notifier's toggle method
                            onFavoriteToggle: () =>
                                notifier.toggleFavorite(context, doc.id),
                            horizontalMode: false,
                          );
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart'; // A common modern dependency for caching images

// // --- PLACEHOLDER IMPORTS (for a runnable example) ---
// // In a real app, replace these with your actual files.
// class MatriLoginScreen extends StatelessWidget {
//   const MatriLoginScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: const Text("Login")),
//     body: const Center(child: Text("Login Screen")),
//   );
// }

// class MatriProfileScreen extends StatelessWidget {
//   final Map<String, dynamic> userData;
//   const MatriProfileScreen({super.key, required this.userData});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text("${userData['name']}'s Profile")),
//     body: Center(child: Text("Profile for ${userData['name']}")),
//   );
// }

// class MatriSubmitScreen extends StatelessWidget {
//   const MatriSubmitScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: const Text("Register")),
//     body: const Center(child: Text("Registration Screen")),
//   );
// }

// // Placeholder for ViewCountService to allow it to run
// class ViewCountService {
//   Future<bool> tryViewProfile({
//     required String profileId,
//     required Map<String, dynamic> visitorData,
//     required BuildContext context,
//   }) async {
//     // Mock logic: Always allow viewing for this example
//     // In your real code, this would handle your view limit logic
//     return true;
//   }
// }
// // --- END PLACEHOLDER IMPORTS ---

// // --- MODERN CUSTOM WIDGETS ---

// /// Modernized Matrimony AppBar with dynamic title/action.
// class ModernMatrimonyAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final Map<String, dynamic>? loggedInUser;
//   final VoidCallback onLogout;
//   final VoidCallback requireLogin;
//   final VoidCallback onProfileTap;

//   const ModernMatrimonyAppBar({
//     super.key,
//     this.loggedInUser,
//     required this.onLogout,
//     required this.requireLogin,
//     required this.onProfileTap,
//   });

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);

//   @override
//   Widget build(BuildContext context) {
//     final isLoggedIn = loggedInUser != null;
//     final displayName =
//         loggedInUser?['name']?.toString().split(' ').first ?? 'Guest';
//     final hasPhoto =
//         loggedInUser?['photo'] != null && loggedInUser!['photo'].isNotEmpty;
//     final photoUrl = loggedInUser?['photo']?.toString();

//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0, // Flat design
//       title: Text(
//         isLoggedIn ? 'Welcome, $displayName' : 'Find Your Partner',
//         style: const TextStyle(
//           color: Colors.black87,
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//       centerTitle: false,
//       actions: [
//         GestureDetector(
//           onTap: isLoggedIn ? onProfileTap : requireLogin,
//           child: Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: CircleAvatar(
//               radius: 18,
//               backgroundColor: Colors.blueGrey.shade100,
//               child: isLoggedIn
//                   ? (hasPhoto
//                         ? ClipOval(
//                             child: CachedNetworkImage(
//                               imageUrl: photoUrl!,
//                               width: 36,
//                               height: 36,
//                               fit: BoxFit.cover,
//                               placeholder: (context, url) => const Icon(
//                                 Icons.person,
//                                 size: 20,
//                                 color: Colors.blueGrey,
//                               ),
//                               errorWidget: (context, url, error) => const Icon(
//                                 Icons.person_off,
//                                 size: 20,
//                                 color: Colors.blueGrey,
//                               ),
//                             ),
//                           )
//                         : const Icon(
//                             Icons.person,
//                             size: 20,
//                             color: Colors.blueGrey,
//                           ))
//                   : const Icon(Icons.login, size: 20, color: Colors.blueGrey),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// /// Modernized Matrimony Filters widget.
// class ModernMatrimonyFilters extends StatelessWidget {
//   final TextEditingController searchController;
//   final RangeValues currentRange;
//   final double minSliderAge;
//   final double maxSliderAge;
//   final ValueChanged<RangeValues> onRangeChanged;
//   final bool isLoggedIn;
//   final bool showFavoritesOnly;
//   final ValueChanged<bool?> onToggleFavorites;

//   // Simplified and removed many dropdowns for brevity, focusing on core modern UI
//   const ModernMatrimonyFilters({
//     super.key,
//     required this.searchController,
//     required this.currentRange,
//     required this.minSliderAge,
//     required this.maxSliderAge,
//     required this.onRangeChanged,
//     required this.isLoggedIn,
//     required this.showFavoritesOnly,
//     required this.onToggleFavorites,
//     // Original unused/removed props: onSearchChanged, selectedReligion, onReligionSelected, selectedCaste, onCasteSelected, selectedPlace, onPlaceSelected
//   });

//   void _showFilterModal(BuildContext context) {
//     // A modern app often uses a bottom sheet or a dedicated screen for advanced filters
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         maxChildSize: 0.9,
//         minChildSize: 0.5,
//         builder: (_, controller) => Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
//           ),
//           child: ListView(
//             controller: controller,
//             padding: const EdgeInsets.all(20),
//             children: [
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: 16.0),
//                   child: Text(
//                     'Advanced Filters',
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               const Divider(height: 1),
//               _buildFilterSection(
//                 title: 'Age Range',
//                 child: Column(
//                   children: [
//                     RangeSlider(
//                       values: currentRange,
//                       min: minSliderAge,
//                       max: maxSliderAge,
//                       divisions: (maxSliderAge - minSliderAge).toInt(),
//                       labels: RangeLabels(
//                         currentRange.start.round().toString(),
//                         currentRange.end.round().toString(),
//                       ),
//                       onChanged: onRangeChanged,
//                     ),
//                     Text(
//                       'Age: ${currentRange.start.round()} - ${currentRange.end.round()}',
//                     ),
//                   ],
//                 ),
//               ),
//               if (isLoggedIn)
//                 _buildFilterSection(
//                   title: 'Only Favorites',
//                   child: SwitchListTile(
//                     title: const Text('Show only profiles I favorited'),
//                     value: showFavoritesOnly,
//                     onChanged: onToggleFavorites,
//                     activeColor: Theme.of(context).primaryColor,
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                 ),
//               // Placeholder for Religion/Caste/Place filter
//               const SizedBox(height: 10),
//               // Add more filter options here...
//               // Example: Dropdown for Religion, Place, etc.
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   'Apply Filters',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterSection({required String title, required Widget child}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           child,
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search by Name or Place...',
//                 prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
//                 contentPadding: const EdgeInsets.symmetric(
//                   vertical: 10.0,
//                   horizontal: 15,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.blueGrey.shade50,
//               ),
//               onChanged: (text) {
//                 // The main state listener in MatrimonyScreen already handles setState
//               },
//             ),
//           ),
//           const SizedBox(width: 10),
//           GestureDetector(
//             onTap: () => _showFilterModal(context),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).primaryColor,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Theme.of(context).primaryColor.withOpacity(0.3),
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.filter_list_rounded,
//                 color: Colors.white,
//                 size: 28,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Modernized Profile Card Widget for the main grid.
// class ModernProfileCardWidget extends StatelessWidget {
//   final String profileId;
//   final String name;
//   final String age;
//   final String place;
//   final String photoUrl;
//   final bool hasPhoto;
//   final bool isFavorite;
//   final VoidCallback onTap;
//   final VoidCallback onFavoriteToggle;
//   final bool horizontalMode; // Keep this for the separate horizontal layout

//   const ModernProfileCardWidget({
//     super.key,
//     required this.profileId,
//     required this.name,
//     required this.age,
//     required this.place,
//     required this.photoUrl,
//     required this.hasPhoto,
//     required this.isFavorite,
//     required this.onTap,
//     required this.onFavoriteToggle,
//     required this.horizontalMode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (horizontalMode) {
//       // Small card design for horizontal scrolling lists (Recently Viewed/Favorites)
//       return Padding(
//         padding: const EdgeInsets.only(right: 12),
//         child: GestureDetector(
//           onTap: onTap,
//           child: SizedBox(
//             width: 100,
//             child: Column(
//               children: [
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Container(
//                         height: 90,
//                         width: 100,
//                         color: Colors.blueGrey.shade100,
//                         child: hasPhoto
//                             ? CachedNetworkImage(
//                                 imageUrl: photoUrl,
//                                 fit: BoxFit.cover,
//                                 placeholder: (context, url) => const Center(
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                                 errorWidget: (context, url, error) =>
//                                     const Center(
//                                       child: Icon(
//                                         Icons.person_off,
//                                         size: 30,
//                                         color: Colors.blueGrey,
//                                       ),
//                                     ),
//                               )
//                             : const Center(
//                                 child: Icon(
//                                   Icons.person,
//                                   size: 40,
//                                   color: Colors.blueGrey,
//                                 ),
//                               ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 4,
//                       right: 4,
//                       child: GestureDetector(
//                         onTap: onFavoriteToggle,
//                         child: CircleAvatar(
//                           radius: 12,
//                           backgroundColor: Colors.white70,
//                           child: Icon(
//                             isFavorite ? Icons.favorite : Icons.favorite_border,
//                             color: isFavorite ? Colors.redAccent : Colors.white,
//                             size: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   name.split(' ').first,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   '$age, $place',
//                   style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     // Main Grid Card Design
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         clipBehavior: Clip.antiAlias,
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Image Area
//             Container(
//               color: Colors.blueGrey.shade100,
//               child: hasPhoto
//                   ? CachedNetworkImage(
//                       imageUrl: photoUrl,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => const Center(
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                       errorWidget: (context, url, error) => const Center(
//                         child: Icon(
//                           Icons.person_off,
//                           size: 50,
//                           color: Colors.blueGrey,
//                         ),
//                       ),
//                     )
//                   : const Center(
//                       child: Icon(
//                         Icons.person,
//                         size: 80,
//                         color: Colors.blueGrey,
//                       ),
//                     ),
//             ),

//             // Gradient Overlay for text readability
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: 80,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
//                   ),
//                 ),
//               ),
//             ),

//             // Profile Info
//             Positioned(
//               bottom: 10,
//               left: 10,
//               right: 10,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     '$age yrs | $place',
//                     style: const TextStyle(color: Colors.white70, fontSize: 12),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),

//             // Favorite Button
//             Positioned(
//               top: 10,
//               right: 10,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.3),
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     isFavorite
//                         ? Icons.favorite_rounded
//                         : Icons.favorite_border_rounded,
//                     color: isFavorite ? Colors.redAccent : Colors.white,
//                     size: 24,
//                   ),
//                   onPressed: onFavoriteToggle,
//                   tooltip: isFavorite
//                       ? 'Remove from Favorites'
//                       : 'Add to Favorites',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// A modern header for horizontal lists.
// class ModernListHeader extends StatelessWidget {
//   final String title;
//   const ModernListHeader({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.w900,
//               fontSize: 18,
//               color: Colors.black,
//             ),
//           ),
//           Text(
//             'View All',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- MAIN MATRIMONY SCREEN CLASS ---

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
//   Map<String, dynamic>? _loggedInUser;
//   String _userGender = "";
//   List<String> _favorites = [];
//   RangeValues _currentAgeRange = const RangeValues(20, 35);
//   final double _minSliderAge = 18;
//   final double _maxSliderAge = 70;

//   // Filter state variables
//   bool _showFavoritesOnly = false;
//   String? _selectedReligion; // Keeping these for logic, but UI simplified
//   String? _selectedCaste;
//   String? _selectedPlace;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.trim().toLowerCase();
//       });
//     });
//   }

//   Future<void> _loadInitialData() async {
//     await _loadLoggedInUser();
//     await _loadRecentlyViewed();
//     await _loadViewedRecommended();
//     await _loadFavorites();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadLoggedInUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Using mock data for demonstration if not found
//     final userString = prefs.getString("loggedInUser");
//     if (userString != null) {
//       try {
//         final data = json.decode(userString) as Map<String, dynamic>;
//         setState(() {
//           _loggedInUser = data;
//           _userGender = (data['gender'] ?? "").toString().toLowerCase();
//         });
//         _setInitialAgeRange(data['age']);
//         _loggedInUser!['visitedProfiles'] ??= [];
//         _loggedInUser!['viewCount'] ??= 0;
//         _loggedInUser!['accessibleProfiles'] ??= 5;
//       } catch (_) {
//         // Handle error in decoding
//       }
//     } else {
//       // Fallback for a cleaner look if no user is logged in for the demo
//       setState(() {
//         _loggedInUser = null;
//         _userGender = "";
//       });
//     }
//   }

//   void _setInitialAgeRange(dynamic userAge) {
//     final age = int.tryParse(userAge?.toString() ?? '25') ?? 25;
//     setState(() {
//       final start = (age - 5).clamp(_minSliderAge, _maxSliderAge).toDouble();
//       final end = (age + 5).clamp(_minSliderAge, _maxSliderAge).toDouble();
//       _currentAgeRange = RangeValues(start, end);
//     });
//   }

//   Future<void> _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove("loggedInUser");
//     setState(() {
//       _loggedInUser = null;
//       _userGender = "";
//       _recentlyViewed = [];
//       _viewedRecommended = [];
//       _favorites = [];
//       _showFavoritesOnly = false;
//       _selectedReligion = null;
//       _selectedCaste = null;
//       _selectedPlace = null;
//     });
//   }

//   Future<void> _requireLogin() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const MatriLoginScreen()),
//     );
//     if (result != null && result is Map<String, dynamic>) {
//       await _loadInitialData();
//     }
//   }

//   Future<void> _addToRecentlyViewed(Map<String, dynamic> rawProfile) async {
//     final prefs = await SharedPreferences.getInstance();

//     final profile = <String, dynamic>{};
//     rawProfile.forEach((key, value) {
//       if (value is Timestamp) {
//         profile[key] = value.toDate().toIso8601String();
//       } else {
//         profile[key] = value;
//       }
//     });

//     _recentlyViewed.removeWhere((p) => p["id"] == profile["id"]);
//     _recentlyViewed.insert(0, profile);

//     if (_recentlyViewed.length > 5) {
//       _recentlyViewed = _recentlyViewed.sublist(0, 5);
//     }

//     final encodedList = _recentlyViewed.map((p) => json.encode(p)).toList();
//     await prefs.setStringList("recentlyViewed", encodedList);

//     setState(() {});
//   }

//   Future<void> _loadRecentlyViewed() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getStringList("recentlyViewed") ?? [];
//     setState(() {
//       _recentlyViewed = data
//           .map((e) => Map<String, dynamic>.from(json.decode(e)))
//           .toList();
//     });
//   }

//   Future<void> _loadViewedRecommended() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getStringList("viewedRecommended") ?? [];
//     final now = DateTime.now();
//     final fourDaysAgo = now.subtract(const Duration(days: 4));

//     setState(() {
//       _viewedRecommended = data
//           .map((e) {
//             final map = Map<String, dynamic>.from(json.decode(e));
//             return {
//               "id": map["id"]?.toString() ?? "",
//               "viewedAt": map["viewedAt"] ?? now.toIso8601String(),
//             };
//           })
//           .where((p) {
//             final viewedAt = DateTime.tryParse(p["viewedAt"] ?? "") ?? now;
//             return viewedAt.isAfter(fourDaysAgo);
//           })
//           .toList();
//     });
//     await prefs.setStringList(
//       "viewedRecommended",
//       _viewedRecommended.map((p) => json.encode(p)).toList(),
//     );
//   }

//   Future<void> _loadFavorites() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _favorites = prefs.getStringList("favorites") ?? [];
//     });
//   }

//   Future<void> _toggleFavorite(String? profileId) async {
//     if (_loggedInUser == null) {
//       _requireLogin();
//       return;
//     }

//     final id = profileId?.toString() ?? '';
//     if (id.isEmpty) return;

//     if (_favorites.contains(id)) {
//       _favorites.remove(id);
//     } else {
//       if (_favorites.length >= 5) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("You can add only 5 favorites.")),
//         );
//         return;
//       }
//       _favorites.add(id);
//     }
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setStringList("favorites", _favorites);
//     setState(() {});
//   }

//   bool _isFavorite(String? profileId) {
//     final id = profileId?.toString() ?? '';
//     return id.isNotEmpty && _favorites.contains(id);
//   }

//   bool _isValidImageUrl(dynamic url) {
//     if (url is! String || url.isEmpty) return false;
//     // Basic check for a URL-like string
//     return url.startsWith('http');
//   }

//   Widget _buildHorizontalList(
//     String title,
//     List<Map<String, dynamic>> profiles,
//   ) {
//     if (_loggedInUser == null || profiles.isEmpty)
//       return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ModernListHeader(title: title),
//         SizedBox(
//           height: 140, // Increased height for better visual
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: profiles.length,
//             itemBuilder: (context, index) {
//               final profile = profiles[index];
//               final profileId = profile["id"]?.toString() ?? '';

//               return ModernProfileCardWidget(
//                 profileId: profileId,
//                 name: profile["name"]?.toString() ?? '-',
//                 age: profile["age"]?.toString() ?? '-',
//                 place: profile["place"]?.toString() ?? '-',
//                 photoUrl: profile["photo"]?.toString() ?? '',
//                 hasPhoto: _isValidImageUrl(profile["photo"]),
//                 isFavorite: _isFavorite(profileId),
//                 horizontalMode: true,
//                 onTap: () => _navigateToDetail(profileId, profile),
//                 onFavoriteToggle: () => _toggleFavorite(profileId),
//               );
//             },
//           ),
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.0),
//           child: Divider(height: 1, thickness: 0.5),
//         ),
//       ],
//     );
//   }

//   Future<void> _navigateToDetail(
//     String docId,
//     Map<String, dynamic> profileData,
//   ) async {
//     if (_loggedInUser == null) {
//       await _requireLogin();
//       return;
//     }

//     final viewCountService = ViewCountService();

//     // Check view count logic
//     final canView = await viewCountService.tryViewProfile(
//       profileId: docId,
//       visitorData: _loggedInUser!,
//       context: context,
//     );

//     if (!canView) return;

//     // Add to recently viewed, only if successfully navigated
//     await _addToRecentlyViewed(profileData..['id'] = docId); // Ensure ID is set

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => MatriProfileScreen(userData: profileData),
//       ),
//     );

//     // Refresh state after returning from detail screen
//     _loadRecentlyViewed();
//     _loadFavorites();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoggedIn = _loggedInUser != null;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: ModernMatrimonyAppBar(
//         loggedInUser: _loggedInUser,
//         onLogout: _logout,
//         requireLogin: _requireLogin,
//         onProfileTap: () {
//           if (_loggedInUser != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     MatriProfileScreen(userData: _loggedInUser!),
//               ),
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const MatriSubmitScreen()),
//           );
//         },
//         icon: const Icon(Icons.person_add_alt_1),
//         label: const Text("Register Profile"),
//         backgroundColor: Theme.of(context).primaryColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ModernMatrimonyFilters(
//                 searchController: _searchController,
//                 currentRange: _currentAgeRange,
//                 minSliderAge: _minSliderAge,
//                 maxSliderAge: _maxSliderAge,
//                 onRangeChanged: (values) =>
//                     setState(() => _currentAgeRange = values),
//                 isLoggedIn: isLoggedIn,
//                 showFavoritesOnly: isLoggedIn ? _showFavoritesOnly : false,
//                 onToggleFavorites: (value) =>
//                     setState(() => _showFavoritesOnly = value!),
//               ),
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('matrimony')
//                     .orderBy('createdAt', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(40.0),
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   }

//                   final allProfiles = snapshot.data!.docs;

//                   final favoritedProfilesData = allProfiles
//                       .where((doc) => _favorites.contains(doc.id))
//                       .map(
//                         (doc) =>
//                             doc.data() as Map<String, dynamic>..['id'] = doc.id,
//                       )
//                       .toList();

//                   final filteredProfiles = allProfiles.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>? ?? {};
//                     final profileId = doc.id;
//                     final name = data['name']?.toString().toLowerCase() ?? '';
//                     final place = data['place']?.toString().toLowerCase() ?? '';
//                     final gender =
//                         data['gender']?.toString().toLowerCase() ?? '';
//                     final age =
//                         int.tryParse(data['age']?.toString() ?? "0") ?? 0;
//                     final religion =
//                         data['religion']?.toString().toLowerCase() ?? '';
//                     final caste = data['caste']?.toString().toLowerCase() ?? '';

//                     // 1. Search Filter
//                     final searchMatch =
//                         _searchQuery.isEmpty ||
//                         name.contains(_searchQuery) ||
//                         place.contains(_searchQuery);
//                     if (!searchMatch) return false;

//                     // 2. Age Range Filter
//                     if (age < _currentAgeRange.start ||
//                         age > _currentAgeRange.end) {
//                       return false;
//                     }

//                     // 3. Gender/Self Filter
//                     if (isLoggedIn) {
//                       if (gender == _userGender) return false;
//                       if (profileId == _loggedInUser!['id']?.toString())
//                         return false;
//                     }

//                     // 4. Conditional Filters (Apply only if logged in)
//                     if (isLoggedIn) {
//                       // Favorites Filter
//                       if (_showFavoritesOnly &&
//                           !_favorites.contains(profileId)) {
//                         return false;
//                       }

//                       // Religion Filter (Kept original logic, though UI is simplified)
//                       if (_selectedReligion != null &&
//                           _selectedReligion!.isNotEmpty) {
//                         if (religion != _selectedReligion!.toLowerCase()) {
//                           return false;
//                         }
//                       }

//                       // Caste Filter
//                       if (_selectedCaste != null &&
//                           _selectedCaste!.isNotEmpty) {
//                         if (caste != _selectedCaste!.toLowerCase()) {
//                           return false;
//                         }
//                       }

//                       // Place Filter
//                       if (_selectedPlace != null &&
//                           _selectedPlace!.isNotEmpty) {
//                         if (place != _selectedPlace!.toLowerCase()) {
//                           return false;
//                         }
//                       }
//                     }

//                     return true;
//                   }).toList();

//                   final recentlyViewedProfiles = _recentlyViewed
//                       .where((p) => p['gender']?.toString() != _userGender)
//                       .toList();

//                   final recommendedProfiles = allProfiles
//                       .map(
//                         (doc) =>
//                             doc.data() as Map<String, dynamic>..['id'] = doc.id,
//                       )
//                       .where((p) {
//                         final id = p['id']?.toString() ?? '';
//                         return isLoggedIn &&
//                             !_viewedRecommended.any((v) => v['id'] == id) &&
//                             p['gender']?.toString().toLowerCase() !=
//                                 _userGender;
//                       })
//                       .toList();

//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // My Favorites List
//                       if (isLoggedIn)
//                         _buildHorizontalList(
//                           "My Favorites ❤️",
//                           favoritedProfilesData,
//                         ),

//                       // Recommended and Recently Viewed (Hidden if filters are active)
//                       if (isLoggedIn &&
//                           !_showFavoritesOnly &&
//                           _selectedReligion == null &&
//                           _selectedCaste == null &&
//                           _selectedPlace == null &&
//                           _searchQuery.isEmpty) ...[
//                         _buildHorizontalList(
//                           "Recently Viewed 👀",
//                           recentlyViewedProfiles,
//                         ),
//                         _buildHorizontalList(
//                           "Recommended for You ✨",
//                           recommendedProfiles,
//                         ),
//                       ],

//                       const ModernListHeader(title: "All Profiles"),

//                       // Main Profile Grid
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: filteredProfiles.length,
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 crossAxisSpacing: 16, // Increased spacing
//                                 mainAxisSpacing: 16, // Increased spacing
//                                 childAspectRatio: 0.8, // More vertical card
//                               ),
//                           itemBuilder: (context, index) {
//                             final doc = filteredProfiles[index];
//                             final data =
//                                 doc.data() as Map<String, dynamic>? ?? {};
//                             final profileId = doc.id;

//                             return ModernProfileCardWidget(
//                               profileId: profileId,
//                               name: data['name']?.toString() ?? 'N/A',
//                               age: data['age']?.toString() ?? 'N/A',
//                               place: data['place']?.toString() ?? 'Unknown',
//                               photoUrl: data['photo']?.toString() ?? '',
//                               hasPhoto: _isValidImageUrl(data['photo']),
//                               isFavorite: _isFavorite(profileId),
//                               onTap: () => _navigateToDetail(profileId, data),
//                               onFavoriteToggle: () =>
//                                   _toggleFavorite(profileId),
//                               horizontalMode: false,
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 100), // Extra space for FAB
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
