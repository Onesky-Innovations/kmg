import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Increment ONLY visitor's (Alice's--eg for understanding) viewCount
  Future<bool> tryViewProfile({
    required String profileId, // The profile Alice is viewing
    required Map<String, dynamic>
    visitorData, // Alice's info from SharedPreferences
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Initialize visitor tracking if missing
    visitorData['visitedProfiles'] ??= [];
    visitorData['viewCount'] ??= 0;
    visitorData['accessibleProfiles'] ??= 5;

    List visitedProfiles = List.from(visitorData['visitedProfiles']);
    int viewCount = visitorData['viewCount'];
    int accessibleProfiles = visitorData['accessibleProfiles'];

    // Already visited → allow, do NOT increment
    if (visitedProfiles.contains(profileId)) return true;

    // Check if Alice has reached her limit
    if (viewCount >= accessibleProfiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have reached your profile view limit."),
        ),
      );
      return false;
    }

    // Increment Alice’s local viewCount
    viewCount += 1;
    visitedProfiles.add(profileId);

    // Update visitor data
    visitorData['viewCount'] = viewCount;
    visitorData['visitedProfiles'] = visitedProfiles;

    // Save locally
    await prefs.setString("loggedInUser", json.encode(visitorData));
    print(
      "✅ Alice’s local viewCount incremented: $viewCount / $accessibleProfiles",
    );

    // --- Firestore update ---
    try {
      // If doc ID is known
      if (visitorData['matrimonyId'] != null) {
        final visitorRef = _firestore
            .collection('matrimony')
            .doc(visitorData['matrimonyId']);
        await visitorRef.set({'viewCount': viewCount}, SetOptions(merge: true));
        print("✅ Alice’s Firestore viewCount updated (by doc ID): $viewCount");
      } else {
        // If only userId is available, query the profile
        final query = await _firestore
            .collection('matrimony')
            .where('userId', isEqualTo: visitorData['userId'])
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final docRef = query.docs.first.reference;
          await docRef.set({'viewCount': viewCount}, SetOptions(merge: true));
          print(
            "✅ Alice’s Firestore viewCount updated (by userId): $viewCount",
          );

          // Save doc ID locally for next time
          visitorData['matrimonyId'] = docRef.id;
          await prefs.setString("loggedInUser", json.encode(visitorData));
        } else {
          print("⚠️ Alice’s matrimony profile not found in Firestore");
        }
      }
    } catch (e) {
      print("❌ Firestore update failed: $e");
    }

    return true;
  }
}
