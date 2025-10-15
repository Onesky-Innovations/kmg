// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:kmg/screens/admin/Add_Classified_FAB.dart';
// import 'package:kmg/screens/settings/sign_in_screen.dart';
// import 'package:kmg/utils/user_name_fetcher.dart' as user_utils;
// import 'package:url_launcher/url_launcher.dart';
// // import 'package:kmg/theme/app_theme.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// class AdDetailScreen extends StatelessWidget {
//   final DocumentSnapshot adDoc;
//   final bool isAdmin;

//   const AdDetailScreen({
//     super.key,
//     required this.adDoc,
//     this.isAdmin = false,
//     required String adId,
//     required Map<String, dynamic> adData,
//     required String userId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final ad = adDoc.data() as Map<String, dynamic>? ?? {};
//     final expiryDate = ad['expiryDate'] != null
//         ? (ad['expiryDate'] as Timestamp).toDate()
//         : null;
//     final postedDate = ad['postedAt'] != null
//         ? (ad['postedAt'] as Timestamp).toDate()
//         : null;

//     final soldStatus = (ad['soldStatus'] ?? 'unsold').toString();
//     final isSold = soldStatus == 'sold';

//     if (!isAdmin && (ad['type'] ?? '') == 'Banner') {
//       return Scaffold(
//         backgroundColor:Theme.of(context).scaffoldBackgroundColor,,
//         body: Center(
//           child: Text(
//             "This ad is not visible.",
//             style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
//           ),
//         ),
//       );
//     }

//     final userId = ad['userId']?.toString() ?? 'Unknown User';
//     final title = ad['title']?.toString() ?? 'Ad Details';
//     final category = ad['category']?.toString();
//     final place = ad['place']?.toString();
//     final condition = ad['condition']?.toString();
//     final price = ad['price'] != null ? "₹${ad['price']}" : "Not specified";
//     final images = List<String>.from(ad['images'] ?? []);
//     final status = ad['status']?.toString() ?? '-';
//     final type = ad['type']?.toString() ?? 'Unknown';
//     final durationDays = ad['durationDays']?.toString() ?? '30';
//     final description =
//         ad['description']?.toString() ?? 'No description provided.';
//     final contact = ad['contact']?.toString();

//     final currentUser = FirebaseAuth.instance.currentUser;
//     final isSignedIn = currentUser != null;

//     return Scaffold(
//       backgroundColor:Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//         elevation: 4,
//         title: Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
//         ),

//         // Save/Unsave
//         actions: [
//           if (isSignedIn)
//             StreamBuilder<DocumentSnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(currentUser.uid)
//                   .collection('saved_ads')
//                   .doc(adDoc.id)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 final isSaved = snapshot.data?.exists ?? false;
//                 return IconButton(
//                   icon: Icon(
//                     isSaved ? Icons.bookmark : Icons.bookmark_border,
//                     color: isSaved ? Colors.yellow.shade700 : Colors.white,
//                   ),
//                   tooltip: isSaved ? 'Remove from saved' : 'Save this ad',
//                   onPressed: () async {
//                     try {
//                       final savedRef = FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(currentUser.uid)
//                           .collection('saved_ads')
//                           .doc(adDoc.id);

//                       if (isSaved) {
//                         await savedRef.delete();
//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Ad removed from saved."),
//                             ),
//                           );
//                         }
//                       } else {
//                         await savedRef.set({
//                           'adId': adDoc.id,
//                           'title': ad['title'] ?? '',
//                           'category': ad['category'] ?? '',
//                           'place': ad['place'] ?? '',
//                           'images': ad['images'] ?? [],
//                           'savedAt': FieldValue.serverTimestamp(),
//                         });
//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Ad saved successfully."),
//                             ),
//                           );
//                         }
//                       }
//                     } catch (e, st) {
//                       debugPrint("Error saving ad: $e\n$st");
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Failed to save the ad."),
//                           ),
//                         );
//                       }
//                     }
//                   },
//                 );
//               },
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.bookmark_border),
//               tooltip: 'Save this ad',
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (ctx) => AlertDialog(
//                     title: const Text("Sign in required"),
//                     content: const Text("To save this ad, please sign in."),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(ctx),
//                         child: const Text("Cancel"),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(ctx);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   const SignInScreen(fromFab: false),
//                             ),
//                           );
//                           // ✅ link to SignInScreen
//                         },
//                         child: const Text("Sign In"),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),

//           // Share
//           IconButton(
//             icon: const Icon(Icons.share),
//             tooltip: 'Share',
//             onPressed: () async {
//               final safeTitle = title.replaceAll('"', "'");
//               final shareText =
//                   'Check out this ad "$safeTitle" on KMG app: https://kmg.example.com/ad/${adDoc.id ?? ''}';

//               if (kIsWeb) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Sharing is not supported on web platform."),
//                   ),
//                 );
//                 return;
//               }

//               try {
//                 await Share.share(shareText, subject: 'Interesting Ad');
//               } catch (e) {
//                 debugPrint("Share failed: $e");
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Unable to share this ad.")),
//                   );
//                 }
//               }
//             },
//           ),

//           // Admin Actions
//           if (isAdmin)
//             PopupMenuButton<String>(
//               color: Theme.of(context).cardColor,
//               elevation: 8,
//               onSelected: (value) async {
//                 if (value == 'edit') {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => AddClassifiedFAB(
//                         type: type,
//                         userId: userId,
//                         adId: adDoc.id,
//                       ),
//                     ),
//                   );
//                 } else if (value == 'extend') {
//                   _showExtendDialog(context, adDoc.id, ad);
//                 } else if (value == 'delete') {
//                   final confirm = await showDialog<bool>(
//                     context: context,
//                     builder: (ctx) => AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       title: const Text(
//                         "Confirm Delete",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red,
//                         ),
//                       ),
//                       content: const Text(
//                         "Are you sure you want to delete this ad?",
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(ctx, false),
//                           style: TextButton.styleFrom(
//                             foregroundColor: Colors.grey.shade600,
//                           ),
//                           child: const Text("Cancel"),
//                         ),
//                         ElevatedButton(
//                           onPressed: () => Navigator.pop(ctx, true),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text("Delete"),
//                         ),
//                       ],
//                     ),
//                   );

//                   if (confirm == true) {
//                     try {
//                       await FirebaseFirestore.instance
//                           .collection("classifieds")
//                           .doc(adDoc.id)
//                           .delete();
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Ad deleted successfully."),
//                           ),
//                         );
//                         Navigator.pop(context);
//                       }
//                     } catch (e) {
//                       debugPrint("Delete failed: $e");
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("Failed to delete ad.")),
//                         );
//                       }
//                     }
//                   }
//                 }
//               },
//               itemBuilder: (_) => [
//   PopupMenuItem( // Removed 'const'
//     value: "edit",
//     child: Text(
//       "Edit",
//       style: TextStyle( // Removed 'const'
//         color: Theme.of(context).colorScheme.primary,
//       ),
//     ),
//   ),
//   PopupMenuItem( // Removed 'const'
//     value: "extend",
//     child: Text(
//       "Extend",
//       style: TextStyle( // Removed 'const'
//         color: Theme.of(context).colorScheme.primary,
//       ),
//     ),
//   ),
//   const PopupMenuItem( // This can remain constant as Colors.red is static
//     value: "delete",
//     child: Text("Delete", style: TextStyle(color: Colors.red)),
//   ),
// ],
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Posted by
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),

//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                    Text(
//                     "Posted by: ",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                   user_utils.UserNameFetcher(
//                     userId: ad['userId'] ?? '',
//                     style: TextStyle( // 💡 Removed 'const'
//   fontSize: 14,
//   fontWeight: FontWeight.w600,
//   // 💡 Replaced static color with dynamic theme primary color
//   color: Theme.of(context).colorScheme.primary,
// ),
//                   ),
//                 ],
//               ),

//               //   child: Text(
//               //     "Posted by: ${ad['userId'] ?? 'Unknown User'}",
//               //     style: const TextStyle(
//               //       fontSize: 14,
//               //       fontWeight: FontWeight.w600,
//               //       color: AppTheme.primary,
//               //     ),
//               //   ),
//               //   child: Text(
//               //     "Posted by: $userId",
//               //     style: const TextStyle(
//               //       fontSize: 14,
//               //       fontWeight: FontWeight.w600,
//               //       color: AppTheme.primary,
//               //     ),
//               //   ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Images
//             if (images.isNotEmpty)
//               SizedBox(
//                 height: 220,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: images.length,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),

//                   // centers list
//                   itemBuilder: (context, index) {
//                     final imageUrl = images[index];
//                     return Center(
//                       child: GestureDetector(
//                         onTap: () {
//                           // ✅ Full screen view with watermark + close (X)
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => Scaffold(
//                                 backgroundColor: Colors.black,
//                                 body: Stack(
//                                   children: [
//                                     Center(
//                                       child: InteractiveViewer(
//                                         child: Image.network(
//                                           imageUrl,
//                                           fit: BoxFit.contain,
//                                           errorBuilder:
//                                               (context, error, stackTrace) =>
//                                                   const Icon(
//                                                     Icons.broken_image,
//                                                     color: Colors.white54,
//                                                     size: 100,
//                                                   ),
//                                         ),
//                                       ),
//                                     ),

//                                     // ✅ Watermark on both corners in full screen
//                                     Positioned.fill(
//                                       child: Align(
//                                         alignment: Alignment.center,
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                             right: 200,
//                                             top: 100,
//                                           ), // 👈 adjust here
//                                           child: Text(
//                                             'KMG',
//                                             style: TextStyle(
//                                               color: Colors.white.withOpacity(
//                                                 0.5,
//                                               ),
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 36,
//                                               letterSpacing: 2,
//                                               shadows: const [
//                                                 Shadow(
//                                                   blurRadius: 6,
//                                                   color: Colors.black,
//                                                   offset: Offset(2, 2),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),

//                                     // ✅ Close (X) button
//                                     Positioned(
//                                       top: 40,
//                                       right: 20,
//                                       child: IconButton(
//                                         icon: const Icon(
//                                           Icons.close,
//                                           color: Colors.white,
//                                           size: 30,
//                                         ),
//                                         onPressed: () => Navigator.pop(context),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         child: Stack(
//                           children: [
//                             // 👇 Move image slightly (adjust offset to left/right as needed)
//                             Transform.translate(
//                               offset: const Offset(
//                                 20,
//                                 0,
//                               ), // +10 → move RIGHT | -10 → move LEFT
//                               child: Container(
//                                 margin: const EdgeInsets.only(right: 12),
//                                 width: 300,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(16),
//                                   child: Image.network(
//                                     imageUrl,
//                                     width: 300,
//                                     height: 220,
//                                     fit: BoxFit.cover,
//                                     errorBuilder:
//                                         (context, error, stackTrace) =>
//                                             Container(
//                                               color: Colors.grey[200],
//                                               width: 300,
//                                               height: 220,
//                                               child: const Icon(
//                                                 Icons.image_not_supported,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                   ),
//                                 ),
//                               ),
//                             ),

//                             // ✅ Watermark (bottom-left)
//                             Positioned(
//                               bottom: 8,
//                               left: 25,
//                               child: Text(
//                                 'KMG',
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.7),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                   shadows: const [
//                                     Shadow(
//                                       blurRadius: 3,
//                                       color: Colors.black,
//                                       offset: Offset(1, 1),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             if (isSold)
//                               Positioned(
//                                 top: 0, // Position at the top
//                                 left: 0,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red.shade700,
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(16),
//                                       bottomRight: Radius.circular(16),
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'SOLD',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w900,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//             const SizedBox(height: 20),
//             Text(
//               description,
//               style: TextStyle(
//                 fontSize: 16,
//                 height: 1.5,
//                 color: Colors.grey[700],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Specifications
//             Text(
//               "Specifications",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildDetailRow(context, "Category", category),
//             _buildDetailRow(context, "Place", place),
//             _buildDetailRow(context, "Condition", condition),
//             _buildDetailRow(context, "Price", price, isPrice: true),
//             if (postedDate != null)
//               _buildDetailRow(
//                 context,
//                 "Posted On",
//                 DateFormat('yyyy-MM-dd').format(postedDate),
//               ),
//             if (isAdmin)
//               _buildDetailRow(context, "Duration (days)", durationDays),
//             if (isAdmin) _buildDetailRow(context, "Status", status),
//             if (expiryDate != null && isAdmin)
//               _buildDetailRow(
//                 context,
//                 "Expiry Date",
//                 DateFormat('yyyy-MM-dd').format(expiryDate),
//                 isExpiry: true,
//               ),
//             const SizedBox(height: 20),

//             // Call / WhatsApp buttons for user
//             if (!isAdmin && contact != null)
//               Center(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildGradientButton(
//                       context: context,
//                       label: "Call Now",
//                       icon: Icons.call,
//                       onPressed: () async {
//                         final url = Uri.parse('tel:$contact');
//                         if (await canLaunchUrl(url)) {
//                           launchUrl(url);
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Cannot make a call."),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                     const SizedBox(width: 16),
//                     _buildGradientButton(
//                       context: context,
//                       label: "Chat on WhatsApp",
//                       icon: Icons.chat,
//                       onPressed: () async {
//                         final url = Uri.parse(
//                           'https://wa.me/$contact?text=Hello%20I%20saw%20your%20ad%20"$title"%20on%20KMG.',
//                         );
//                         if (await canLaunchUrl(url)) {
//                           launchUrl(url);
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Cannot open WhatsApp."),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientButton({
//     required BuildContext context,
//     required String label,
//     required IconData icon,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           // 💡 Use the dynamic primary and secondary colors
//           colors: [
//             Theme.of(
//               context,
//             ).colorScheme.primary, // Corresponds to AppTheme.primary
//             Theme.of(
//               context,
//             ).colorScheme.secondary, // Corresponds to AppTheme.secondary
//           ],
//           // Keep the original alignment properties
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             // 💡 Replaced AppTheme.primary with the dynamic primary color
//             color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//           foregroundColor: Theme.of(context).colorScheme.onPrimary,
//           textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         icon: Icon(
//           icon,
//           // 💡 Use the color that contrasts with the primary color
//           color: Theme.of(context).colorScheme.onPrimary,
//         ),
//         label: Text(label),
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     BuildContext context,
//     String label,
//     String? value, {
//     bool isPrice = false,
//     bool isExpiry = false,
//   }) {
//     Color valueColor = Colors.black87;
//     TextStyle valueStyle = const TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w500,
//     );

//     if (isPrice) {
//       valueColor:
//       AlwaysStoppedAnimation<Color>(
//         // 💡 Use the dynamic secondary color
//         Theme.of(context).colorScheme.secondary,
//       );
//       valueStyle = valueStyle.copyWith(
//         fontWeight: FontWeight.w800,
//         fontSize: 18,
//       );
//     } else if (isExpiry) {
//       valueColor = Colors.red.shade700;
//     }

//     return // Assumes this widget is inside a build method or receives a BuildContext.
// Container(
//   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//   margin: const EdgeInsets.only(bottom: 6),
//   decoration: BoxDecoration(
//     // 💡 1. Replace AppTheme.background with the dynamic background/card color
//     color: Theme.of(context).cardColor,
//     borderRadius: BorderRadius.circular(12),

//     // 💡 2. Make border color theme-aware for better visibility in Dark Mode
//     border: Border.all(
//       color: Theme.of(context).brightness == Brightness.dark
//           ? Colors.grey.shade700 // Dark mode border
//           : Colors.grey.shade200, // Light mode border
//     ),

//     // 💡 3. Make BoxShadow theme-aware (or remove in Dark Mode for simplicity)
//     boxShadow: Theme.of(context).brightness == Brightness.light
//         ? [
//             BoxShadow(
//               // Shadow is subtle, using a transparent black/grey works for both
//               color: Colors.grey.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ]
//         : null, // Box shadows often look bad on pure black dark mode
//   ),
//   child: Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       SizedBox(
//         width: 120,
//         child: Text(
//           "$label:",
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//             // 💡 4. Replace static 'Colors.black' with the primary text color
//             color: Theme.of(context).textTheme.bodyLarge?.color,
//           ),
//         ),
//       ),
//       const SizedBox(width: 12),
//       Expanded(
//         child: Text(
//           value ?? "-",
//           // Assumes 'valueStyle' and 'valueColor' are defined elsewhere,
//           // but if 'valueColor' was static, it must be replaced here too.
//           style: valueStyle.copyWith(color: valueColor),
//         ),
//       ),
//     ],
//   ),
// );
//   }

//   void _showExtendDialog(
//     BuildContext context,
//     String adId,
//     Map<String, dynamic> ad,
//   ) {
//     int extendDays = 7;
//     showDialog(
//       context: context,
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setStateDialog) => AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           title: Text(
//   "Extend ${ad['title'] ?? 'Ad'}",
//   style: TextStyle( // 💡 Removed 'const' because the style is no longer constant
//     fontWeight: FontWeight.bold,
//     // 💡 Replaced static color with dynamic theme color
//     color: Theme.of(context).colorScheme.primary,
//   ),
// ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Select duration to extend:",
//                 style: TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//     border: Border.all(
//       // 💡 Replaced static color with dynamic theme primary color
//       color: Theme.of(context).colorScheme.primary,
//     ),
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<int>(
//                     value: extendDays,
//                     isExpanded: true,
//                     items: [7, 15, 30]
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(
//                               "$e days",
//                               style: const TextStyle(color: Colors.black87),
//                             ),
//                           ),
//                         )
//                         .toList(),
//                     onChanged: (val) {
//                       if (val != null) setStateDialog(() => extendDays = val);
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.grey.shade600,
//               ),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final oldExpiry = ad["expiryDate"] as Timestamp?;
//                 final newExpiry = oldExpiry?.toDate().add(
//                   Duration(days: extendDays),
//                 );
//                 if (newExpiry != null) {
//                   try {
//                     await FirebaseFirestore.instance
//                         .collection("classifieds")
//                         .doc(adId)
//                         .update({"expiryDate": newExpiry});
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             "Ad extended by $extendDays days successfully.",
//                           ),
//                         ),
//                       );
//                       Navigator.pop(ctx);
//                     }
//                   } catch (e) {
//                     debugPrint("Extend failed: $e");
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Failed to extend the ad."),
//                         ),
//                       );
//                     }
//                   }
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//   // 💡 Replaced AppTheme.primary with dynamic primary color
//   backgroundColor: Theme.of(context).colorScheme.primary,

//   // 💡 Replaced AppTheme.iconOnPrimary with dynamic 'onPrimary' color
//   foregroundColor: Theme.of(context).colorScheme.onPrimary,

//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(10),
//   ),
//   padding: const EdgeInsets.symmetric(
//     horizontal: 20,
//     vertical: 10,
//   ),
// ),
//               child: const Text("Extend"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kmg/screens/admin/Add_Classified_FAB.dart';
import 'package:kmg/screens/settings/sign_in_screen.dart';
import 'package:kmg/utils/user_name_fetcher.dart' as user_utils;
import 'package:url_launcher/url_launcher.dart';
// import 'package:kmg/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdDetailScreen extends StatelessWidget {
  final DocumentSnapshot adDoc;
  final bool isAdmin;

  const AdDetailScreen({
    super.key,
    required this.adDoc,
    this.isAdmin = false,
    required String adId,
    required Map<String, dynamic> adData,
    required String userId,
  });

  @override
  Widget build(BuildContext context) {
    final ad = adDoc.data() as Map<String, dynamic>? ?? {};
    final expiryDate = ad['expiryDate'] != null
        ? (ad['expiryDate'] as Timestamp).toDate()
        : null;
    final postedDate = ad['postedAt'] != null
        ? (ad['postedAt'] as Timestamp).toDate()
        : null;

    final soldStatus = (ad['soldStatus'] ?? 'unsold').toString();
    final isSold = soldStatus == 'sold';

    if (!isAdmin && (ad['type'] ?? '') == 'Banner') {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(
            "This ad is not visible.",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final userId = ad['userId']?.toString() ?? 'Unknown User';
    final title = ad['title']?.toString() ?? 'Ad Details';
    final category = ad['category']?.toString();
    final place = ad['place']?.toString();
    final condition = ad['condition']?.toString();
    final price = ad['price'] != null ? "₹${ad['price']}" : "Not specified";
    final images = List<String>.from(ad['images'] ?? []);
    final status = ad['status']?.toString() ?? '-';
    final type = ad['type']?.toString() ?? 'Unknown';
    final durationDays = ad['durationDays']?.toString() ?? '30';
    final description =
        ad['description']?.toString() ?? 'No description provided.';
    final contact = ad['contact']?.toString();

    final currentUser = FirebaseAuth.instance.currentUser;
    final isSignedIn = currentUser != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),

        // Save/Unsave
        actions: [
          if (isSignedIn)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('saved_ads')
                  .doc(adDoc.id)
                  .snapshots(),
              builder: (context, snapshot) {
                final isSaved = snapshot.data?.exists ?? false;
                return IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Colors.yellow.shade700 : Colors.white,
                  ),
                  tooltip: isSaved ? 'Remove from saved' : 'Save this ad',
                  onPressed: () async {
                    try {
                      final savedRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .collection('saved_ads')
                          .doc(adDoc.id);

                      if (isSaved) {
                        await savedRef.delete();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Ad removed from saved."),
                            ),
                          );
                        }
                      } else {
                        await savedRef.set({
                          'adId': adDoc.id,
                          'title': ad['title'] ?? '',
                          'category': ad['category'] ?? '',
                          'place': ad['place'] ?? '',
                          'images': ad['images'] ?? [],
                          'savedAt': FieldValue.serverTimestamp(),
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Ad saved successfully."),
                            ),
                          );
                        }
                      }
                    } catch (e, st) {
                      debugPrint("Error saving ad: $e\n$st");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to save the ad."),
                          ),
                        );
                      }
                    }
                  },
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              tooltip: 'Save this ad',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Sign in required"),
                    content: const Text("To save this ad, please sign in."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SignInScreen(fromFab: false),
                            ),
                          );
                          // ✅ link to SignInScreen
                        },
                        child: const Text("Sign In"),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Share
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () async {
              final safeTitle = title.replaceAll('"', "'");
              final shareText =
                  'Check out this ad "$safeTitle" on KMG app: https://kmg.example.com/ad/${adDoc.id ?? ''}';

              if (kIsWeb) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Sharing is not supported on web platform."),
                  ),
                );
                return;
              }

              try {
                await Share.share(shareText, subject: 'Interesting Ad');
              } catch (e) {
                debugPrint("Share failed: $e");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Unable to share this ad.")),
                  );
                }
              }
            },
          ),

          // Admin Actions
          if (isAdmin)
            PopupMenuButton<String>(
              color: Theme.of(context).cardColor,
              elevation: 8,
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddClassifiedFAB(
                        type: type,
                        userId: userId,
                        adId: adDoc.id,
                        adOwnerId: ad['userId'], // ✅ added line
                      ),
                    ),
                  );
                } else if (value == 'extend') {
                  _showExtendDialog(context, adDoc.id, ad);
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: const Text(
                        "Confirm Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      content: const Text(
                        "Are you sure you want to delete this ad?",
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await FirebaseFirestore.instance
                          .collection("classifieds")
                          .doc(adDoc.id)
                          .delete();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ad deleted successfully."),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint("Delete failed: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to delete ad.")),
                        );
                      }
                    }
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: "edit",
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: "extend",
                  child: Text(
                    "Extend",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: "delete",
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posted by
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Posted by: ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  user_utils.UserNameFetcher(
                    userId: ad['userId'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      // 💡 Replaced static color with dynamic theme primary color
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color, // Made text color theme-aware
              ),
            ),
            const SizedBox(height: 16),

            // Images
            if (images.isNotEmpty)
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  // centers list
                  itemBuilder: (context, index) {
                    final imageUrl = images[index];
                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          // ✅ Full screen view with watermark + close (X)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                backgroundColor: Colors.black,
                                body: Stack(
                                  children: [
                                    Center(
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.white54,
                                                    size: 100,
                                                  ),
                                        ),
                                      ),
                                    ),

                                    // ✅ Watermark on both corners in full screen
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 200,
                                            top: 100,
                                          ), // 👈 adjust here
                                          child: Text(
                                            'KMG',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 36,
                                              letterSpacing: 2,
                                              shadows: const [
                                                Shadow(
                                                  blurRadius: 6,
                                                  color: Colors.black,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ✅ Close (X) button
                                    Positioned(
                                      top: 40,
                                      right: 20,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            // 👇 Move image slightly (adjust offset to left/right as needed)
                            Transform.translate(
                              offset: const Offset(
                                20,
                                0,
                              ), // +10 → move RIGHT | -10 → move LEFT
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    imageUrl,
                                    width: 300,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[200],
                                              width: 300,
                                              height: 220,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),

                            // ✅ Watermark (bottom-left)
                            Positioned(
                              bottom: 8,
                              left: 25,
                              child: Text(
                                'KMG',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 3,
                                      color: Colors.black,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isSold)
                              Positioned(
                                top: 0, // Position at the top
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'SOLD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color, // Made text color theme-aware
              ),
            ),
            const SizedBox(height: 24),

            // Specifications
            Text(
              "Specifications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(context, "Category", category),
            _buildDetailRow(context, "Place", place),
            _buildDetailRow(context, "Condition", condition),
            _buildDetailRow(context, "Price", price, isPrice: true),
            if (postedDate != null)
              _buildDetailRow(
                context,
                "Posted On",
                DateFormat('yyyy-MM-dd').format(postedDate),
              ),
            if (isAdmin)
              _buildDetailRow(context, "Duration (days)", durationDays),
            if (isAdmin) _buildDetailRow(context, "Status", status),
            if (expiryDate != null && isAdmin)
              _buildDetailRow(
                context,
                "Expiry Date",
                DateFormat('yyyy-MM-dd').format(expiryDate),
                isExpiry: true,
              ),
            const SizedBox(height: 20),

            // Call / WhatsApp buttons for user
            if (!isAdmin && contact != null)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGradientButton(
                      context: context,
                      label: "Call Now",
                      icon: Icons.call,
                      onPressed: () async {
                        final url = Uri.parse('tel:$contact');
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cannot make a call."),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildGradientButton(
                      context: context,
                      label: "Chat on WhatsApp",
                      icon: Icons.chat,
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://wa.me/$contact?text=Hello%20I%20saw%20your%20ad%20"$title"%20on%20KMG.',
                        );
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cannot open WhatsApp."),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // 💡 Use the dynamic primary and secondary colors
          colors: [
            Theme.of(
              context,
            ).colorScheme.primary, // Corresponds to AppTheme.primary
            Theme.of(
              context,
            ).colorScheme.secondary, // Corresponds to AppTheme.secondary
          ],
          // Keep the original alignment properties
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // 💡 Replaced AppTheme.primary with the dynamic primary color
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        icon: Icon(
          icon,
          // 💡 Use the color that contrasts with the primary color
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        label: Text(label),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String? value, {
    bool isPrice = false,
    bool isExpiry = false,
  }) {
    Color valueColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    TextStyle valueStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    if (isPrice) {
      // ✅ FIX: The old code had a colon (:) instead of an assignment operator (=) here.
      // We assign the theme's secondary color directly.
      valueColor = Theme.of(context).colorScheme.secondary;
      valueStyle = valueStyle.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 18,
      );
    } else if (isExpiry) {
      valueColor = Colors.red.shade700;
    }

    return // Assumes this widget is inside a build method or receives a BuildContext.
    Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        // 💡 1. Replace AppTheme.background with the dynamic background/card color
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),

        // 💡 2. Make border color theme-aware for better visibility in Dark Mode
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors
                    .grey
                    .shade700 // Dark mode border
              : Colors.grey.shade200, // Light mode border
        ),

        // 💡 3. Make BoxShadow theme-aware (or remove in Dark Mode for simplicity)
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  // Shadow is subtle, using a transparent black/grey works for both
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null, // Box shadows often look bad on pure black dark mode
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                // 💡 4. Replace static 'Colors.black' with the primary text color
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value ?? "-",
              // Assumes 'valueStyle' and 'valueColor' are defined elsewhere,
              // but if 'valueColor' was static, it must be replaced here too.
              style: valueStyle.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showExtendDialog(
    BuildContext context,
    String adId,
    Map<String, dynamic> ad,
  ) {
    int extendDays = 7;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Extend ${ad['title'] ?? 'Ad'}",
            style: TextStyle(
              // 💡 Removed 'const' because the style is no longer constant
              fontWeight: FontWeight.bold,
              // 💡 Replaced static color with dynamic theme color
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select duration to extend:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    // 💡 Replaced static color with dynamic theme primary color
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: extendDays,
                    isExpanded: true,
                    items: [7, 15, 30]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              "$e days",
                              // 💡 Made text color theme-aware
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => extendDays = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final oldExpiry = ad["expiryDate"] as Timestamp?;
                final newExpiry = oldExpiry?.toDate().add(
                  Duration(days: extendDays),
                );
                if (newExpiry != null) {
                  try {
                    await FirebaseFirestore.instance
                        .collection("classifieds")
                        .doc(adId)
                        .update({"expiryDate": newExpiry});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Ad extended by $extendDays days successfully.",
                          ),
                        ),
                      );
                      Navigator.pop(ctx);
                    }
                  } catch (e) {
                    debugPrint("Extend failed: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to extend the ad."),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                // 💡 Replaced AppTheme.primary with dynamic primary color
                backgroundColor: Theme.of(context).colorScheme.primary,

                // 💡 Replaced AppTheme.iconOnPrimary with dynamic 'onPrimary' color
                foregroundColor: Theme.of(context).colorScheme.onPrimary,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text("Extend"),
            ),
          ],
        ),
      ),
    );
  }
}
