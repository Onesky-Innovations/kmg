import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kmg/screens/matrimony/widgets/viewcount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:kmg/screens/matrimony/matri_screens/MatriLoginScreen.dart';
import 'package:kmg/screens/matrimony/matri_screens/userMatriProfileScreen.dart';
import 'package:kmg/screens/matrimony/matri_screens/matri_submit_screen.dart';
import 'package:kmg/screens/matrimony/widgets/profile_card_widget.dart';
import 'package:kmg/screens/matrimony/widgets/matrimony_appbar.dart';
import 'package:kmg/screens/matrimony/widgets/matrimony_filters.dart';
// import 'viewcount.dart';

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
  String _userGender = "";
  List<String> _favorites = [];
  RangeValues _currentAgeRange = const RangeValues(20, 35);
  final double _minSliderAge = 18;
  final double _maxSliderAge = 70;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadInitialData() async {
    await _loadLoggedInUser();
    await _loadRecentlyViewed();
    await _loadViewedRecommended();
    await _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString("loggedInUser");
    if (userString != null) {
      try {
        final data = json.decode(userString) as Map<String, dynamic>;
        setState(() {
          _loggedInUser = data;
          _userGender = (data['gender'] ?? "").toString().toLowerCase();
        });
        _setInitialAgeRange(data['age']);
        // Ensure visitedProfiles exists
        _loggedInUser!['visitedProfiles'] ??= [];
        _loggedInUser!['viewCount'] ??= 0;
        _loggedInUser!['accessibleProfiles'] ??= 5;
      } catch (_) {}
    }
  }

  void _setInitialAgeRange(dynamic userAge) {
    final age = int.tryParse(userAge?.toString() ?? '25') ?? 25;
    setState(() {
      final start = (age - 5).clamp(_minSliderAge, _maxSliderAge).toDouble();
      final end = (age + 5).clamp(_minSliderAge, _maxSliderAge).toDouble();
      _currentAgeRange = RangeValues(start, end);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("loggedInUser");
    setState(() {
      _loggedInUser = null;
      _userGender = "";
      _recentlyViewed = [];
      _viewedRecommended = [];
      _favorites = [];
    });
  }

  Future<void> _requireLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MatriLoginScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      await _loadInitialData();
    }
  }

  Future<void> _addToRecentlyViewed(Map<String, dynamic> rawProfile) async {
    final prefs = await SharedPreferences.getInstance();

    final profile = <String, dynamic>{};
    rawProfile.forEach((key, value) {
      if (value is Timestamp) {
        profile[key] = value.toDate().toIso8601String();
      } else {
        profile[key] = value;
      }
    });

    _recentlyViewed.removeWhere((p) => p["id"] == profile["id"]);
    _recentlyViewed.insert(0, profile);

    if (_recentlyViewed.length > 5) {
      _recentlyViewed = _recentlyViewed.sublist(0, 5);
    }

    final encodedList = _recentlyViewed.map((p) => json.encode(p)).toList();
    await prefs.setStringList("recentlyViewed", encodedList);

    setState(() {});
  }

  Future<void> _loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("recentlyViewed") ?? [];
    setState(() {
      _recentlyViewed = data
          .map((e) => Map<String, dynamic>.from(json.decode(e)))
          .toList();
    });
  }

  Future<void> _loadViewedRecommended() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("viewedRecommended") ?? [];
    final now = DateTime.now();
    final fourDaysAgo = now.subtract(const Duration(days: 4));

    setState(() {
      _viewedRecommended = data
          .map((e) {
            final map = Map<String, dynamic>.from(json.decode(e));
            return {
              "id": map["id"]?.toString() ?? "",
              "viewedAt": map["viewedAt"] ?? now.toIso8601String(),
            };
          })
          .where((p) {
            final viewedAt = DateTime.tryParse(p["viewedAt"] ?? "") ?? now;
            return viewedAt.isAfter(fourDaysAgo);
          })
          .toList();
    });
    await prefs.setStringList(
      "viewedRecommended",
      _viewedRecommended.map((p) => json.encode(p)).toList(),
    );
  }

  Future<void> _addToViewedRecommended(String? id) async {
    if (id == null || id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await _loadViewedRecommended();
    _viewedRecommended.removeWhere((p) => p["id"] == id);
    _viewedRecommended.insert(0, {"id": id, "viewedAt": now.toIso8601String()});
    await prefs.setStringList(
      "viewedRecommended",
      _viewedRecommended.map((p) => json.encode(p)).toList(),
    );
    setState(() {});
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList("favorites") ?? [];
    });
  }

  Future<void> _toggleFavorite(String? profileId) async {
    if (_loggedInUser == null) {
      _requireLogin();
      return;
    }

    final id = profileId?.toString() ?? '';
    if (id.isEmpty) return;

    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      if (_favorites.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can add only 5 favorites.")),
        );
        return;
      }
      _favorites.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("favorites", _favorites);
    setState(() {});
  }

  bool _isFavorite(String? profileId) {
    final id = profileId?.toString() ?? '';
    return id.isNotEmpty && _favorites.contains(id);
  }

  bool _isValidImageUrl(dynamic url) {
    if (url is! String || url.isEmpty) return false;
    return Uri.tryParse(url)?.isAbsolute ?? false;
  }

  Widget _buildHorizontalList(
    String title,
    List<Map<String, dynamic>> profiles,
  ) {
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
              return ProfileCardWidget(
                profileId: profile["id"]?.toString() ?? '',
                name: profile["name"]?.toString() ?? '-',
                age: profile["age"]?.toString() ?? '-',
                place: profile["place"]?.toString() ?? '-',
                photoUrl: profile["photo"]?.toString() ?? '',
                hasPhoto: _isValidImageUrl(profile["photo"]),
                isFavorite: _isFavorite(profile["id"]?.toString()),
                horizontalMode: true,
                onTap: () =>
                    _navigateToDetail(profile["id"]?.toString() ?? '', profile),
                onFavoriteToggle: () =>
                    _toggleFavorite(profile["id"]?.toString() ?? ''),
              );
            },
          ),
        ),
        const Divider(),
      ],
    );
  }

  // Navigate to profile with view limit check
  Future<void> _navigateToDetail(
    String docId,
    Map<String, dynamic> profileData,
  ) async {
    if (_loggedInUser == null) {
      await _requireLogin();
      return;
    }

    final viewCountService = ViewCountService();

    // Increment Alice's local viewCount only
    final canView = await viewCountService.tryViewProfile(
      profileId: docId,
      visitorData: _loggedInUser!,
      context: context,
    );

    if (!canView) return; // Limit reached

    // Track recently viewed locally
    await _addToRecentlyViewed(profileData);

    // Navigate to profile screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatriProfileScreen(userData: profileData),
      ),
    );

    // Refresh local lists
    _loadRecentlyViewed();
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MatrimonyAppBar(
        loggedInUser: _loggedInUser,
        onLogout: _logout,
        requireLogin: _requireLogin,
        onProfileTap: () {
          if (_loggedInUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MatriProfileScreen(userData: _loggedInUser!),
              ),
            );
          }
        },
      ),
      floatingActionButton: _loggedInUser != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MatriSubmitScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Submit Profile"),
            )
          : null,
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
                onSearchChanged: (text) => setState(() => _searchQuery = text),
              ),
              _buildHorizontalList(
                "My Favorites",
                _recentlyViewed
                    .where((p) => _favorites.contains(p["id"]?.toString()))
                    .toList(),
              ),
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

                  final filteredProfiles = allProfiles.where((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final name = data['name']?.toString().toLowerCase() ?? '';
                    final place = data['place']?.toString().toLowerCase() ?? '';
                    final gender =
                        data['gender']?.toString().toLowerCase() ?? '';
                    final age =
                        int.tryParse(data['age']?.toString() ?? "0") ?? 0;

                    final searchMatch =
                        _searchQuery.isEmpty ||
                        name.contains(_searchQuery) ||
                        place.contains(_searchQuery);
                    if (!searchMatch) return false;
                    if (age < _currentAgeRange.start ||
                        age > _currentAgeRange.end) {
                      return false;
                    }
                    if (_loggedInUser != null && gender == _userGender) {
                      return false;
                    }
                    return true;
                  }).toList();

                  final recentlyViewedProfiles = _recentlyViewed
                      .where((p) => p['gender']?.toString() != _userGender)
                      .toList();
                  final recommendedProfiles = allProfiles
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .where((p) {
                        final id = p['id']?.toString() ?? '';
                        return !_viewedRecommended.any((v) => v['id'] == id);
                      })
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHorizontalList(
                        "Recently Viewed",
                        recentlyViewedProfiles,
                      ),
                      _buildHorizontalList(
                        "Recommended for You",
                        recommendedProfiles,
                      ),
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
                            isFavorite: _isFavorite(doc.id),
                            onTap: () => _navigateToDetail(doc.id, data),
                            onFavoriteToggle: () => _toggleFavorite(doc.id),
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
