import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kmg/screens/matrimony/matri_screens/MatriLoginScreen.dart';
import 'package:kmg/screens/matrimony/matri_screens/matri_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'view_limit_notifier.dart';
// import 'matri_login_screen.dart';
// import 'matri_detail_screen.dart';

class MatrimonyNotifier extends ChangeNotifier {
  Map<String, dynamic>? _loggedInUser;
  String _userGender = "";
  List<String> _favorites = [];
  List<Map<String, dynamic>> _recentlyViewed = [];
  List<Map<String, dynamic>> _viewedRecommended = [];

  int _userViewCount = 0;
  final ValueNotifier<int> _userViewLimitNotifier = ValueNotifier<int>(20);
  bool _isFemaleLimitEnabled = false;

  static const String _viewCountKey = "userViewCount";
  static const String _userKey = "loggedInUser";
  static const String _recentlyViewedKey = "recentlyViewed";
  static const String _viewedRecommendedKey = "viewedRecommended";
  static const String _favoritesKey = "favorites";

  Map<String, dynamic>? get loggedInUser => _loggedInUser;
  String get userGender => _userGender;
  List<String> get favorites => List.unmodifiable(_favorites);
  List<Map<String, dynamic>> get recentlyViewed =>
      List.unmodifiable(_recentlyViewed);
  List<Map<String, dynamic>> get viewedRecommended =>
      List.unmodifiable(_viewedRecommended);

  ValueNotifier<int> get userViewLimitNotifier => _userViewLimitNotifier;
  int get userViewCount => _userViewCount;
  bool get isFemaleLimitEnabled => _isFemaleLimitEnabled;

  bool get isLimitApplicable {
    final bool isMaleUser = _userGender == 'male';
    final bool isFemaleUser = _userGender == 'female';
    return isMaleUser || (isFemaleUser && _isFemaleLimitEnabled);
  }

  int get remaining => _userViewLimitNotifier.value - _userViewCount;

  MatrimonyNotifier() {
    viewLimitNotifier.addListener(_onNotifierUpdate);
    _loadAllData();
  }

  @override
  void dispose() {
    viewLimitNotifier.removeListener(_onNotifierUpdate);
    _userViewLimitNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await _loadLoggedInUser();
    await _loadUserViewCount();
    await _loadFavorites();
    await _loadRecentlyViewed();
    await _loadViewedRecommended();
    _onNotifierUpdate();
    notifyListeners();
  }

  void _onNotifierUpdate() {
    if (_loggedInUser != null) {
      _userViewLimitNotifier.value =
          (_loggedInUser!['accessibleProfiles'] is int)
          ? _loggedInUser!['accessibleProfiles'] as int
          : viewLimitNotifier.viewLimit;
    } else {
      _userViewLimitNotifier.value = viewLimitNotifier.viewLimit;
    }
    _isFemaleLimitEnabled = viewLimitNotifier.applyLimitToFemale;
    notifyListeners();
  }

  Future<void> _loadUserViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    _userViewCount = prefs.getInt(_viewCountKey) ?? 0;
    notifyListeners();
  }

  Future<void> saveUserViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_viewCountKey, _userViewCount);
  }

  Future<void> _loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      try {
        final data = json.decode(userString) as Map<String, dynamic>;
        _loggedInUser = data;
        _userGender = (data['gender'] ?? "").toString().toLowerCase();
      } catch (_) {
        _loggedInUser = null;
        _userGender = "";
      }
    } else {
      _loggedInUser = null;
      _userGender = "";
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> _loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_recentlyViewedKey) ?? [];
    final parsed = <Map<String, dynamic>>[];
    for (final e in data) {
      try {
        parsed.add(Map<String, dynamic>.from(json.decode(e) as Map));
      } catch (_) {}
    }
    _recentlyViewed = parsed;
  }

  Future<void> _loadViewedRecommended() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_viewedRecommendedKey) ?? [];
    final now = DateTime.now();
    final fourDaysAgo = now.subtract(const Duration(days: 4));

    final parsed = data
        .map((e) {
          try {
            final map = Map<String, dynamic>.from(json.decode(e) as Map);
            return {
              "id": map["id"]?.toString() ?? "",
              "viewedAt": map["viewedAt"] ?? now.toIso8601String(),
            };
          } catch (_) {
            return {"id": "", "viewedAt": now.toIso8601String()};
          }
        })
        .where((p) {
          final viewedAt = DateTime.tryParse(p["viewedAt"] ?? "") ?? now;
          return viewedAt.isAfter(fourDaysAgo);
        })
        .toList();

    _viewedRecommended = parsed;
    await prefs.setStringList(
      _viewedRecommendedKey,
      _viewedRecommended.map((p) => json.encode(p)).toList(),
    );
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loggedInUser = null;
    _userGender = "";
    _userViewCount = 0;
    _userViewLimitNotifier.value = viewLimitNotifier.viewLimit;
    _recentlyViewed = [];
    _viewedRecommended = [];
    _favorites = [];
    notifyListeners();
  }

  Future<void> requireLogin(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MatriLoginScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      await _loadAllData();
    }
  }

  Future<void> toggleFavorite(BuildContext context, String? profileId) async {
    if (_loggedInUser == null) {
      requireLogin(context);
      return;
    }

    final id = profileId?.toString();
    if (id == null || id.isEmpty) return;

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
    await prefs.setStringList(_favoritesKey, _favorites);
    notifyListeners();
  }

  bool isFavorite(String? profileId) {
    final id = profileId?.toString();
    if (id == null || id.isEmpty) return false;
    return _favorites.contains(id);
  }

  Map<String, dynamic> _extractAndConvertProfileData(
    Map<String, dynamic> rawData,
    String docId,
  ) {
    return {
      "id": docId,
      "name": rawData["name"]?.toString() ?? "",
      "age": rawData["age"]?.toString() ?? "",
      "place": rawData["place"]?.toString() ?? "",
      "gender": rawData["gender"]?.toString() ?? "",
      "photo": rawData["photo"]?.toString() ?? "",
      "createdAt": (rawData["createdAt"] is Timestamp)
          ? (rawData["createdAt"] as Timestamp).toDate().toIso8601String()
          : (rawData["createdAt"]?.toString() ?? ""),
    };
  }

  Future<void> _addToRecentlyViewed(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    _recentlyViewed.removeWhere(
      (p) => p["id"]?.toString() == profile["id"]?.toString(),
    );
    _recentlyViewed.insert(0, profile);
    if (_recentlyViewed.length > 5) {
      _recentlyViewed = _recentlyViewed.sublist(0, 5);
    }
    await prefs.setStringList(
      _recentlyViewedKey,
      _recentlyViewed.map((p) => json.encode(p)).toList(),
    );
  }

  Future<void> _addToViewedRecommended(String? id) async {
    if (id == null || id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    _viewedRecommended.removeWhere((p) => p["id"] == id);
    _viewedRecommended.insert(0, {"id": id, "viewedAt": now.toIso8601String()});
    if (_viewedRecommended.length > 100) {
      _viewedRecommended = _viewedRecommended.sublist(0, 100);
    }
    await prefs.setStringList(
      _viewedRecommendedKey,
      _viewedRecommended.map((p) => json.encode(p)).toList(),
    );
  }

  void navigateToDetail(
    BuildContext context,
    String docId,
    Map<String, dynamic> profileData,
  ) async {
    if (_loggedInUser == null) {
      requireLogin(context);
      return;
    }

    final int userViewLimit = _userViewLimitNotifier.value;
    final isRecentlyViewed = _recentlyViewed.any(
      (p) => p["id"]?.toString() == docId,
    );

    if (isLimitApplicable &&
        !isRecentlyViewed &&
        _userViewCount >= userViewLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "View limit ($userViewLimit) reached. Please visit help page.",
          ),
        ),
      );
      return;
    }

    if (isLimitApplicable && !isRecentlyViewed) {
      _userViewCount++;
      await saveUserViewCount();
      notifyListeners();
    }

    final profile = _extractAndConvertProfileData(profileData, docId);
    await _addToRecentlyViewed(profile);
    await _addToViewedRecommended(docId);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MatriDetailScreen(profileId: docId, profile: profileData),
      ),
    );

    await _loadFavorites();
    notifyListeners();
  }
}
