// // lib/screens/ads/matri_detail_screen.dart

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:kmg/theme/app_theme.dart'; // Import the defined theme

// // Use constants from the imported AppTheme
// const Color primaryColor = AppTheme.primaryColor;  //if we activate app thee file this error gone
// const Color accentColor = AppTheme.accentColor;

// class MatriDetailScreen extends StatelessWidget {
//   final String profileId;

//   // The 'profile' is required by the original constructor, though unused here
//   const MatriDetailScreen({
//     super.key,
//     required this.profileId,
//     required Map<String, dynamic> profile,
//   });

//   void _launchCaller(String number) async {
//     final url = 'tel:$number';
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url));
//     } else {
//       debugPrint("Cannot call $number");
//     }
//   }

//   Widget _infoRow(
//     IconData icon,
//     String label,
//     String value, {
//     bool isContact = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: primaryColor.withOpacity(0.7)),
//               const SizedBox(width: 12),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[700],
//                   fontSize: 15,
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: Text(
//               value.isNotEmpty ? value : 'N/A',
//               textAlign: TextAlign.right,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: isContact ? FontWeight.bold : FontWeight.normal,
//                 color: isContact ? primaryColor : Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionCard({required String title, required List<Widget> children}) {
//     if (children.isEmpty) return const SizedBox.shrink();
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.only(bottom: 20),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//             ),
//             const Divider(color: accentColor, thickness: 2, height: 20),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: FutureBuilder<DocumentSnapshot>(
//         future: firestore.collection("matrimony").doc(profileId).get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: primaryColor),
//             );
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text("Profile not found or deleted."));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>;

//           return CustomScrollView(
//             slivers: [
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _ProfileHeaderDelegate(data: data),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 20,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // Basic Info
//                       _sectionCard(
//                         title: "Basic Information",
//                         children: [
//                           _infoRow(
//                             Icons.cake_outlined,
//                             "Age",
//                             data['age'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.person_outline,
//                             "Gender",
//                             data['gender'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.height_outlined,
//                             "Height",
//                             data['height'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.monitor_weight_outlined,
//                             "Weight",
//                             data['weight'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.location_on_outlined,
//                             "Place",
//                             data['place'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.calendar_today_outlined,
//                             "Expires",
//                             (data["expiryDate"] as Timestamp?)
//                                     ?.toDate()
//                                     .toLocal()
//                                     .toString()
//                                     .split(' ')[0] ??
//                                 '',
//                           ),
//                         ],
//                       ),

//                       // Religious & Community
//                       _sectionCard(
//                         title: "Religious & Community",
//                         children: [
//                           _infoRow(
//                             Icons.menu_book_outlined,
//                             "Religion",
//                             data['religion'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.group_outlined,
//                             "Caste",
//                             data['caste'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.star_border,
//                             "Star",
//                             data['star'] ?? '',
//                           ),
//                         ],
//                       ),

//                       // Professional & Other Details
//                       _sectionCard(
//                         title: "Professional & Other Details",
//                         children: [
//                           _infoRow(
//                             Icons.school_outlined,
//                             "Education",
//                             data['education'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.work_outline,
//                             "Job",
//                             data['job'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.attach_money_outlined,
//                             "Income",
//                             data['income'] ?? '',
//                           ),
//                           _infoRow(
//                             Icons.verified_user_outlined,
//                             "Created By",
//                             data['createdBy'] ?? '',
//                           ),
//                           // Demand: show even if empty string
//                           _infoRow(
//                             Icons.monetization_on_outlined,
//                             "Demand",
//                             data['demand']?.toString() ?? 'N/A',
//                           ),
//                         ],
//                       ),

//                       // About & Interests
//                       if ((data['about'] != null &&
//                               data['about'].toString().isNotEmpty) ||
//                           (data['interests'] != null &&
//                               data['interests'].toString().isNotEmpty))
//                         _sectionCard(
//                           title: "About & Interests",
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 if (data['about'] != null &&
//                                     data['about'].toString().isNotEmpty)
//                                   Padding(
//                                     padding: const EdgeInsets.only(bottom: 8),
//                                     child: Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             data['about'],
//                                             style: const TextStyle(
//                                               fontSize: 14,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 if (data['interests'] != null &&
//                                     data['interests'].toString().isNotEmpty)
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           data['interests'],
//                                           style: const TextStyle(fontSize: 14),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                               ],
//                             ),
//                           ],
//                         ),

//                       // Connect Button
//                       if (data['contact'] != null &&
//                           data['contact'].toString().isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 10, bottom: 20),
//                           child: ElevatedButton.icon(
//                             onPressed: () => _launchCaller(data['contact']),
//                             icon: const Icon(Icons.call, size: 24),
//                             label: Text(
//                               "Connect Now: ${data['contact']}",
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               backgroundColor: Colors.green,
//                               minimumSize: const Size.fromHeight(60),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 8,
//                               shadowColor: Colors.green.withOpacity(0.5),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// // Header delegate
// class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final Map<String, dynamic> data;
//   final double minHeight = 200;
//   final double maxHeight = 260;

//   _ProfileHeaderDelegate({required this.data});

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     final topPadding = MediaQuery.of(context).padding.top;
//     final double avatarRadius = 50;

//     final String? photoUrl =
//         (data["photo"] != null && data["photo"].toString().isNotEmpty)
//         ? data["photo"]
//         : null;

//     return Container(
//       color: Colors.grey[50],
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned(
//             top: topPadding,
//             left: 8,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//           Positioned(
//             top: topPadding + 10,
//             child: CircleAvatar(
//               radius: avatarRadius,
//               backgroundColor: accentColor,
//               backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
//               child: photoUrl == null
//                   ? Icon(
//                       Icons.person_2_outlined,
//                       size: avatarRadius,
//                       color: primaryColor.withOpacity(0.8),
//                     )
//                   : null,
//             ),
//           ),
//           Positioned(
//             top: topPadding + avatarRadius * 2 + 24,
//             child: Column(
//               children: [
//                 Text(
//                   data['name'] ?? "No Name",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor,
//                     fontSize: 20,
//                   ),
//                 ),
//                 Text(
//                   "User ID: ${data['userId'] ?? 'N/A'}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey,
//                     fontSize: 14,
//                   ),
//                 ),
//                 if (data["isFeatured"] == true)
//                   Container(
//                     margin: const EdgeInsets.only(top: 6),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.amber[700],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       "FEATURED",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   double get minExtent => minHeight;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
//       true;
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:kmg/theme/app_theme.dart'; // No longer needed for static colors
// import 'package:kmg/providers/theme_provider.dart'; // Assuming this is not needed directly here

// REMOVED ILLEGAL CODE: Cannot access Theme.of(context) outside of build()
// final Color primaryColor = Theme.of(context).colorScheme.primary;
// final Color accentColor = Theme.of(context).colorScheme.secondary;

class MatriDetailScreen extends StatelessWidget {
  final String profileId;

  const MatriDetailScreen({
    super.key,
    required this.profileId,
    required Map<String, dynamic> profile,
  });

  void _launchCaller(String number) async {
    final url = 'tel:$number';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint("Cannot call $number");
    }
  }

  // UPDATED: Added context and dynamic colors as arguments
  Widget _infoRow(
    BuildContext context,
    Color primaryColor,
    IconData icon,
    String label,
    String value, {
    bool isContact = false,
  }) {
    // Determine the color for the main value text
    final Color valueTextColor = isContact
        ? primaryColor
        : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // FIX: Icon color is now theme-aware
              Icon(icon, size: 20, color: primaryColor.withOpacity(0.7)),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  // FIX: Label color is now theme-aware
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isContact ? FontWeight.bold : FontWeight.normal,
                // FIX: Value color is now theme-aware
                color: valueTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Added context and dynamic colors as arguments
  Widget _sectionCard({
    required BuildContext context,
    required Color primaryColor,
    required Color accentColor,
    required String title,
    required List<Widget> children,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();

    // Use theme-aware colors for card background/text
    final Color cardBackgroundColor = Theme.of(context).cardColor;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      color: cardBackgroundColor, // Use theme-aware card color
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // FIX: Title color is now theme-aware
                color: primaryColor,
              ),
            ),
            // FIX: Divider color is now theme-aware
            Divider(color: accentColor, thickness: 2, height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // FIX: Define dynamic colors inside the build method
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      // FIX: Made background theme-aware
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection("matrimony").doc(profileId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              // FIX: Indicator color is now theme-aware
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Profile not found or deleted."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                // FIX: Pass the dynamic colors to the delegate
                delegate: _ProfileHeaderDelegate(
                  data: data,
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Basic Info
                      _sectionCard(
                        context: context,
                        primaryColor: primaryColor,
                        accentColor: accentColor,
                        title: "Basic Information",
                        children: [
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.cake_outlined,
                            "Age",
                            data['age'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.person_outline,
                            "Gender",
                            data['gender'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.height_outlined,
                            "Height",
                            data['height'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.monitor_weight_outlined,
                            "Weight",
                            data['weight'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.location_on_outlined,
                            "Place",
                            data['place'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.calendar_today_outlined,
                            "Expires",
                            (data["expiryDate"] as Timestamp?)
                                    ?.toDate()
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0] ??
                                '',
                          ),
                        ],
                      ),

                      // Religious & Community
                      _sectionCard(
                        context: context,
                        primaryColor: primaryColor,
                        accentColor: accentColor,
                        title: "Religious & Community",
                        children: [
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.menu_book_outlined,
                            "Religion",
                            data['religion'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.group_outlined,
                            "Caste",
                            data['caste'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.star_border,
                            "Star",
                            data['star'] ?? '',
                          ),
                        ],
                      ),

                      // Professional & Other Details
                      _sectionCard(
                        context: context,
                        primaryColor: primaryColor,
                        accentColor: accentColor,
                        title: "Professional & Other Details",
                        children: [
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.school_outlined,
                            "Education",
                            data['education'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.work_outline,
                            "Job",
                            data['job'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.attach_money_outlined,
                            "Income",
                            data['income'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.verified_user_outlined,
                            "Created By",
                            data['createdBy'] ?? '',
                          ),
                          _infoRow(
                            context,
                            primaryColor,
                            Icons.monetization_on_outlined,
                            "Demand",
                            data['demand']?.toString() ?? 'N/A',
                          ),
                        ],
                      ),

                      // About & Interests
                      if ((data['about'] != null &&
                              data['about'].toString().isNotEmpty) ||
                          (data['interests'] != null &&
                              data['interests'].toString().isNotEmpty))
                        _sectionCard(
                          context: context,
                          primaryColor: primaryColor,
                          accentColor: accentColor,
                          title: "About & Interests",
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data['about'] != null &&
                                    data['about'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['about'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (data['interests'] != null &&
                                    data['interests'].toString().isNotEmpty)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data['interests'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),

                      // Connect Button
                      if (data['contact'] != null &&
                          data['contact'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          child: ElevatedButton.icon(
                            onPressed: () => _launchCaller(data['contact']),
                            icon: const Icon(Icons.call, size: 24),
                            label: Text(
                              "Connect Now: ${data['contact']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              // FIX: Use theme-aware colors for a distinct call button
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSecondary,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              minimumSize: const Size.fromHeight(60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              // FIX: Use secondary color for shadow
                              shadowColor: accentColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Header delegate
class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Map<String, dynamic> data;
  final Color primaryColor; // Added
  final Color accentColor; // Added
  final double minHeight = 200;
  final double maxHeight = 260;

  // UPDATED: Require colors in the constructor
  _ProfileHeaderDelegate({
    required this.data,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;
    final double avatarRadius = 50;

    final String? photoUrl =
        (data["photo"] != null && data["photo"].toString().isNotEmpty)
        ? data["photo"]
        : null;

    return Container(
      // FIX: Made background theme-aware
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: topPadding,
            left: 8,
            child: IconButton(
              // FIX: Icon color is now theme-aware
              icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: topPadding + 10,
            child: CircleAvatar(
              radius: avatarRadius,
              // FIX: Background color is now theme-aware
              backgroundColor: accentColor,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Icon(
                      Icons.person_2_outlined,
                      size: avatarRadius,
                      // FIX: Icon color is now theme-aware
                      color: primaryColor.withOpacity(0.8),
                    )
                  : null,
            ),
          ),
          Positioned(
            top: topPadding + avatarRadius * 2 + 24,
            child: Column(
              children: [
                Text(
                  data['name'] ?? "No Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // FIX: Text color is now theme-aware
                    color: primaryColor,
                    fontSize: 20,
                  ),
                ),
                Text(
                  " ${data['place'] ?? 'N/A'}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    // FIX: Text color is now theme-aware
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
                if (data["isFeatured"] == true)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "FEATURED",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _ProfileHeaderDelegate oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.accentColor != accentColor; // Rebuild if colors change
}
