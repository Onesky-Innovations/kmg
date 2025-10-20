// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:kmg/screens/ads/ad_detail_screen.dart';
// import 'package:kmg/screens/settings/sign_in_screen.dart';

// class SavedItemsScreen extends StatelessWidget {
//   const SavedItemsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     // 🔒 Not signed in UI
//     if (currentUser == null) {
//       return Scaffold(
//         backgroundColor: Colors.grey.shade50,
//         appBar: AppBar(
//           title: const Text("Saved Items"),
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           foregroundColor: Theme.of(context).colorScheme.onPrimary,
//           elevation: 2,
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.bookmark_border,
//                   size: 90,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Please sign in to view your saved ads.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 17, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const SignInScreen(fromFab: false),
//                       ), // ✅ Link
//                     );
//                   },
//                   icon: const Icon(Icons.login),
//                   label: const Text("Sign In"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 28,
//                       vertical: 14,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     textStyle: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     // ✅ Signed in — Fetch saved ads
//     final savedAdsRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUser.uid)
//         .collection('saved_ads')
//         .orderBy('savedAt', descending: true);

//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text("Saved Items"),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//         elevation: 2,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: savedAdsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.bookmark_outline,
//                     size: 90,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     "No saved items yet.",
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     "Tap the bookmark icon on an ad to save it.",
//                     style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final savedAds = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: savedAds.length,
//             padding: const EdgeInsets.all(12),
//             itemBuilder: (context, index) {
//               final ad = savedAds[index].data() as Map<String, dynamic>;
//               final adId = ad['adId'];
//               final title = ad['title'] ?? 'Untitled';
//               final category = ad['category'] ?? 'Unknown';
//               final place = ad['place'] ?? '-';
//               final images = List<String>.from(ad['images'] ?? []);
//               final thumbnail = images.isNotEmpty ? images.first : null;

//               return InkWell(
//                 onTap: () async {
//                   final adDoc = await FirebaseFirestore.instance
//                       .collection('classifieds')
//                       .doc(adId)
//                       .get();

//                   if (!adDoc.exists) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("This ad is no longer available."),
//                       ),
//                     );
//                     return;
//                   }

//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => AdDetailScreen(
//                         adDoc: adDoc,
//                         adId: adId,
//                         adData: adDoc.data() ?? {},
//                         userId: adDoc['userId'] ?? '',
//                       ),
//                     ),
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(15),
//                 child: Card(
//                   elevation: 3,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Thumbnail
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: thumbnail != null
//                               ? Image.network(
//                                   thumbnail,
//                                   width: 90,
//                                   height: 90,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stack) =>
//                                       const Icon(
//                                         Icons.broken_image,
//                                         size: 50,
//                                         color: Colors.grey,
//                                       ),
//                                 )
//                               : Container(
//                                   width: 90,
//                                   height: 90,
//                                   color: Colors.grey.shade200,
//                                   child: const Icon(
//                                     Icons.image,
//                                     size: 50,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                         ),
//                         const SizedBox(width: 12),

//                         // Info
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 title,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "$category • $place",
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kmg/screens/ads/ad_detail_screen.dart';
import 'package:kmg/screens/settings/sign_in_screen.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final List<DocumentSnapshot> savedAds = [];
  bool isLoading = false;
  bool isInitialLoad = true; // 🌟 New state to track the first fetch
  bool hasMore = true;
  final int pageSize = 10;
  DocumentSnapshot? lastDoc;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      // Start the initial fetch
      _fetchSavedAds();
    }
  }

  Future<void> _fetchSavedAds() async {
    // If not initial load, check hasMore and isLoading
    if (!isInitialLoad && (!hasMore || isLoading)) return;

    setState(() {
      isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('saved_ads')
          .orderBy('savedAt', descending: true)
          .limit(pageSize);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;
        savedAds.addAll(snapshot.docs);
        if (snapshot.docs.length < pageSize) hasMore = false;
      } else {
        // If snapshot is empty, and we didn't start after a doc, it's an empty list.
        // If snapshot is empty, and we did start after a doc, we've reached the end.
        hasMore = false;
      }
    } catch (e) {
      // Handle error, e.g., show a Snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load saved items: $e')),
        );
      }
    }

    setState(() {
      isLoading = false;
      isInitialLoad = false; // 🎯 Crucial: Set to false after the first attempt
    });
  }

  // Helper method for loading indicator widget
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // Helper method for empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 90, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No saved items yet.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap the bookmark icon on an ad to save it.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      // 🔒 Not signed in UI
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text("Saved Items"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 90,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Please sign in to view your saved ads.",
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
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Sign In"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Handle initial loading state
    if (isInitialLoad && isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Saved Items"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: _buildLoadingIndicator(),
      );
    }

    // Handle empty state after initial load
    if (!isInitialLoad && savedAds.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Saved Items"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: _buildEmptyState(),
      );
    }

    // ✅ Signed in — Display saved ads
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Saved Items"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Trigger fetch when user scrolls near the end
          if (!isLoading &&
              hasMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent * 0.9) {
            _fetchSavedAds();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          // Add 1 to itemCount if more data is available to show a loading indicator
          itemCount: savedAds.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Show pagination loading indicator at the end of the list
            if (index == savedAds.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }

            final ad = savedAds[index].data() as Map<String, dynamic>;
            final adId = ad['adId'];
            final ownerId = ad['userId'];
            final title = ad['title'] ?? 'Untitled';
            final category = ad['category'] ?? 'Unknown';
            final place = ad['place'] ?? '-';
            final images = List<String>.from(ad['images'] ?? []);
            final thumbnail = images.isNotEmpty ? images.first : null;

            return InkWell(
              onTap: () async {
                if (adId == null || ownerId == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Cannot open this ad. Missing ID."),
                      ),
                    );
                  }
                  return;
                }

                // Fetch the original classified ad document
                final adDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(ownerId)
                    .collection('classifieds')
                    .doc(adId)
                    .get();

                if (!adDoc.exists) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "This ad is no longer available. It will be removed on next refresh.",
                        ),
                      ),
                    );
                  }
                  // Optionally, automatically remove the stale saved item here
                  return;
                }

                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdDetailScreen(
                        adDoc: adDoc,
                        adId: adId,
                        adData: adDoc.data() ?? {},
                        userId: ownerId,
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(15),
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: thumbnail != null
                            ? Image.network(
                                thumbnail,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                            : Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$category • $place",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
