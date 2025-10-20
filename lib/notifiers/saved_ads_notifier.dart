import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedAdsNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Set<String> _savedAdIds = {};
  bool _isLoading = true;

  Set<String> get savedAdIds => _savedAdIds;
  bool get isLoading => _isLoading;

  SavedAdsNotifier() {
    // Listen to auth state changes to load/clear saved ads
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadSavedAds(user.uid);
      } else {
        clearSavedAds();
      }
    });
  }

  void clearSavedAds() {
    _savedAdIds = {};
    _isLoading = false;
    notifyListeners();
  }

  // Called ONCE when the app loads or user signs in
  Future<void> loadSavedAds(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_ads')
          .get();

      _savedAdIds = snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      debugPrint("Error loading saved ads: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handles both saving and unsaving
  Future<void> toggleSaveAd({
    required String adId,
    required Map<String, dynamic> adData,
    required BuildContext context,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Handle the sign-in requirement logic here (or ensure this check happens in UI)
      return;
    }

    final isCurrentlySaved = _savedAdIds.contains(adId);
    final savedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('saved_ads')
        .doc(adId);

    // 1. Optimistic UI Update: Update the local state instantly
    if (isCurrentlySaved) {
      _savedAdIds.remove(adId);
    } else {
      _savedAdIds.add(adId);
    }
    notifyListeners(); // Instant UI update (no spinner!)

    // 2. Network Operation
    try {
      if (isCurrentlySaved) {
        await savedRef.delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ad removed from saved.")),
          );
        }
      } else {
        await savedRef.set({
          'adId': adId,
          'userId': adData['userId'],
          'title': adData['title'] ?? '',
          'category': adData['category'] ?? '',
          'place': adData['place'] ?? '',
          'images': adData['images'] ?? [],
          'savedAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ad saved successfully.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving ad: $e");
      // 3. Rollback (In case of error, revert the local state)
      if (isCurrentlySaved) {
        _savedAdIds.add(adId);
      } else {
        _savedAdIds.remove(adId);
      }
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlySaved ? "Failed to remove ad." : "Failed to save ad.",
            ),
          ),
        );
      }
    }
  }
}
