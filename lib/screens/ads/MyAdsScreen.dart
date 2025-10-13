import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kmg/screens/settings/sign_in_screen.dart';
import 'package:kmg/theme/app_theme.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final _auth = FirebaseAuth.instance;

  // 🎯 Function to update the sold status (KEPT)
  Future<void> _updateSoldStatus(String adId, String newStatus) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('classifieds')
          .doc(adId)
          .update({'soldStatus': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Ad marked as ${newStatus.toUpperCase()} successfully!",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating status: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text("My Ads"),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.iconOnPrimary,
          elevation: 2,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ads_click, size: 90, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  "Please sign in to view your ads.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignInScreen(fromFab: false),
                      ), // ✅ Link
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Sign In"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Ads"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('classifieds')
            // Using 'createdAt' (or your correct timestamp field)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You have no ads yet."));
          }

          final ads = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final adDoc = ads[index];
              final ad = adDoc.data() as Map<String, dynamic>;
              final adId = adDoc.id;

              final generalStatus = (ad['status'] ?? 'Draft').toString();
              final soldStatus = (ad['soldStatus'] ?? 'unsold').toString();
              final isSold = soldStatus == 'sold';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: ad["images"] != null && ad["images"].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            ad["images"][0],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image, size: 40),
                  title: Text(ad['title'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: ₹${ad['price'] ?? 'N/A'}"),
                      Text("Category: ${ad['category'] ?? 'N/A'}"),
                      Text("Place: ${ad['place'] ?? 'N/A'}"),
                      const SizedBox(height: 4),
                      // Display general status
                      Text(
                        "Ad Status: ${generalStatus.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: generalStatus == 'Active'
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                      // Display sold status
                      Text(
                        "Sale Status: ${soldStatus.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSold ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // MARK SOLD/UNSOLD BUTTON (KEPT)
                      TextButton(
                        onPressed: () {
                          final newStatus = isSold ? 'unsold' : 'sold';
                          _updateSoldStatus(adId, newStatus);
                        },
                        child: Text(
                          isSold ? "Mark Unsold" : "Mark Sold",
                          style: TextStyle(
                            color: isSold ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to Ad Detail/Edit Screen (placeholder)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
