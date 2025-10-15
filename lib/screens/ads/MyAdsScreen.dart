// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:kmg/screens/settings/sign_in_screen.dart';
// import 'package:kmg/theme/app_theme.dart';

// class MyAdsScreen extends StatefulWidget {
//   const MyAdsScreen({super.key});

//   @override
//   State<MyAdsScreen> createState() => _MyAdsScreenState();
// }

// class _MyAdsScreenState extends State<MyAdsScreen> {
//   final _auth = FirebaseAuth.instance;

//   // 🎯 Function to update the sold status (KEPT)
//   Future<void> _updateSoldStatus(String adId, String newStatus) async {
//     final currentUser = _auth.currentUser;
//     if (currentUser == null) return;

//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .collection('classifieds')
//           .doc(adId)
//           .update({'soldStatus': newStatus});

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Ad marked as ${newStatus.toUpperCase()} successfully!",
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error updating status: $e")));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = _auth.currentUser;

//     if (currentUser == null) {
//       return Scaffold(
//         backgroundColor: Colors.grey.shade50,
//         appBar: AppBar(
//           title: const Text("My Ads"),
//           backgroundColor: AppTheme.primary,
//           foregroundColor: AppTheme.iconOnPrimary,
//           elevation: 2,
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.ads_click, size: 90, color: Colors.grey.shade400),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Please sign in to view your ads.",
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
//                     backgroundColor: AppTheme.primary,
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

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Ads"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser.uid)
//             .collection('classifieds')
//             // Using 'createdAt' (or your correct timestamp field)
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("You have no ads yet."));
//           }

//           final ads = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: ads.length,
//             itemBuilder: (context, index) {
//               final adDoc = ads[index];
//               final ad = adDoc.data() as Map<String, dynamic>;
//               final adId = adDoc.id;

//               final generalStatus = (ad['status'] ?? 'Draft').toString();
//               final soldStatus = (ad['soldStatus'] ?? 'unsold').toString();
//               final isSold = soldStatus == 'sold';

//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   leading: ad["images"] != null && ad["images"].isNotEmpty
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.network(
//                             ad["images"][0],
//                             width: 60,
//                             height: 60,
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       : const Icon(Icons.image, size: 40),
//                   title: Text(ad['title'] ?? 'No Title'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Price: ₹${ad['price'] ?? 'N/A'}"),
//                       Text("Category: ${ad['category'] ?? 'N/A'}"),
//                       Text("Place: ${ad['place'] ?? 'N/A'}"),
//                       const SizedBox(height: 4),
//                       // Display general status
//                       Text(
//                         "Ad Status: ${generalStatus.toUpperCase()}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: generalStatus == 'Active'
//                               ? Colors.blue
//                               : Colors.grey,
//                         ),
//                       ),
//                       // Display sold status
//                       Text(
//                         "Sale Status: ${soldStatus.toUpperCase()}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: isSold ? Colors.green : Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // MARK SOLD/UNSOLD BUTTON (KEPT)
//                       TextButton(
//                         onPressed: () {
//                           final newStatus = isSold ? 'unsold' : 'sold';
//                           _updateSoldStatus(adId, newStatus);
//                         },
//                         child: Text(
//                           isSold ? "Mark Unsold" : "Mark Sold",
//                           style: TextStyle(
//                             color: isSold ? Colors.red : Colors.green,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     // Navigate to Ad Detail/Edit Screen (placeholder)
//                   },
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
import 'package:kmg/screens/settings/sign_in_screen.dart';
// import 'package:kmg/theme/app_theme.dart'; // ❌ REMOVED OBSOLETE IMPORT

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
    final theme = Theme.of(context); // 💡 Cache theme for cleaner access

    if (currentUser == null) {
      return Scaffold(
        // 💡 1. Replace static background color
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("My Ads"),
          // 💡 2. Replace AppBar colors
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 2,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 💡 3. Make icon color theme-aware (using secondary text color for muted effect)
                Icon(
                  Icons.ads_click,
                  size: 90,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(height: 16),
                Text(
                  "Please sign in to view your ads.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    // 💡 4. Make text color theme-aware (using secondary text color for muted effect)
                    color: theme.textTheme.bodySmall?.color,
                  ),
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
                    // 💡 5. Replace Button colors
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
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
      // 💡 6. Ensure main scaffold background is also theme-aware
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Ads"),
        // 💡 7. Fix hardcoded Colors.blueAccent
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('classifieds')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // 💡 8. Make 'No ads' text theme-aware
            return Center(
              child: Text(
                "You have no ads yet.",
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
            );
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
                // 💡 9. Card color is already theme-aware by default, but we can ensure
                color: theme.cardColor,
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
                      // 💡 10. Make placeholder icon theme-aware
                      : Icon(
                          Icons.image,
                          size: 40,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),

                  // Title and Subtitle text colors are theme-aware by default in ListTile,
                  // but custom colors need fixing:
                  title: Text(ad['title'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: ₹${ad['price'] ?? 'N/A'}"),
                      Text("Category: ${ad['category'] ?? 'N/A'}"),
                      Text("Place: ${ad['place'] ?? 'N/A'}"),
                      const SizedBox(height: 4),
                      // Display general status (Colors.blue is acceptable, but you can make it dynamic too)
                      Text(
                        "Ad Status: ${generalStatus.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // 💡 11. Use primary color for 'Active' status
                          color: generalStatus == 'Active'
                              ? theme.colorScheme.primary
                              : theme
                                    .textTheme
                                    .bodySmall
                                    ?.color, // Use muted color for non-active
                        ),
                      ),
                      // Display sold status
                      Text(
                        "Sale Status: ${soldStatus.toUpperCase()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // 💡 12. Keep Green/Red for status clarity, but ensure readability
                          color: isSold
                              ? Colors.green.shade400
                              : Colors.red.shade400,
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
                            // 💡 13. Keep Green/Red, but make them shade-aware for contrast
                            color: isSold
                                ? Colors.red.shade400
                                : Colors.green.shade400,
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
