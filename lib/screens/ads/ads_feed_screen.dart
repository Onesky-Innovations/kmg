// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../ads/ad_detail_screen.dart';

// class AdsFeedScreen extends StatelessWidget {
//   final String? selectedCategory;
//   final String searchQuery; // live search
//   final String selectedPlace; // new: filter by place

//   const AdsFeedScreen({
//     super.key,
//     this.selectedCategory,
//     this.searchQuery = "",
//     this.selectedPlace = "All Places",
//     required String currentUserId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection("classifieds")
//           .orderBy("createdAt", descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(
//             child: Text(
//               "No classifieds available",
//               style: TextStyle(fontSize: 18),
//             ),
//           );
//         }

//         final docs = snapshot.data!.docs;

//         final activeAds = docs.where((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           final expiry = data['expiryDate'] != null
//               ? (data['expiryDate'] as Timestamp).toDate()
//               : null;

//           final isActive =
//               data['status'] == 'Active' &&
//               (expiry == null || expiry.isAfter(DateTime.now()));

//           final matchesCategory =
//               selectedCategory == null || data['category'] == selectedCategory;

//           final matchesSearch =
//               searchQuery.isEmpty ||
//               (data['title'] ?? "").toString().toLowerCase().contains(
//                 searchQuery,
//               ) ||
//               (data['category'] ?? "").toString().toLowerCase().contains(
//                 searchQuery,
//               );

//           final matchesPlace =
//               selectedPlace == "All Places" ||
//               (data['place'] ?? "").toString().toLowerCase() ==
//                   selectedPlace.toLowerCase();

//           return isActive && matchesCategory && matchesSearch && matchesPlace;
//         }).toList();

//         if (activeAds.isEmpty) {
//           return Center(
//             child: Text(
//               searchQuery.isNotEmpty
//                   ? "No results found"
//                   : selectedCategory == null
//                   ? "No active classifieds available"
//                   : "No classifieds found in $selectedCategory",
//               style: const TextStyle(fontSize: 18),
//             ),
//           );
//         }

//         return ListView.builder(
//           itemCount: activeAds.length,
//           itemBuilder: (ctx, index) {
//             final ad = activeAds[index].data() as Map<String, dynamic>;
//             return Card(
//               margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//               child: ListTile(
//                 leading: ad["images"] != null && ad["images"].isNotEmpty
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           ad["images"][0],
//                           width: 60,
//                           height: 60,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : const Icon(Icons.image, size: 40),
//                 title: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       ad['userId'] ?? "Unknown User",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueAccent,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       ad['title'] ?? "No title",
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 subtitle: Text(
//                   "Place: ${ad['place'] ?? 'N/A'}\n"
//                   "Price: ${ad['price'] != null ? "₹${ad['price']}" : "Not specified"}\n"
//                   "Expiry: ${ad['expiryDate'] != null ? (ad['expiryDate'] as Timestamp).toDate().toString().split(" ").first : "N/A"}",
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => AdDetailScreen(
//                         adDoc: activeAds[index],
//                         isAdmin: false,
//                         adId: '',
//                         adData: {},
//                         userId: '',
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// //-----------------------------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kmg/screens/ads/ad_detail_screen.dart';
import 'package:kmg/utils/user_name_fetcher.dart'
    as user_utils; // ✅ Alias to avoid conflicts

class AdsFeedScreen extends StatelessWidget {
  final String? selectedCategory;
  final String searchQuery;
  final String selectedPlace;
  final String _currentUserId;

  const AdsFeedScreen({
    super.key,
    this.selectedCategory,
    this.searchQuery = "",
    this.selectedPlace = "All Places",
    required String currentUserId,
  }) : _currentUserId = currentUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("classifieds")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No classifieds available"));
        }

        final docs = snapshot.data!.docs;

        final activeAds = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final expiry = data['expiryDate'] != null
              ? (data['expiryDate'] as Timestamp).toDate()
              : null;

          final isActive =
              data['status'] == 'Active' &&
              (expiry == null || expiry.isAfter(DateTime.now()));

          final matchesCategory =
              selectedCategory == null || data['category'] == selectedCategory;

          final matchesSearch =
              searchQuery.isEmpty ||
              (data['title'] ?? "").toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              (data['category'] ?? "").toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

          final matchesPlace =
              selectedPlace == "All Places" ||
              (data['place'] ?? "").toString().toLowerCase() ==
                  selectedPlace.toLowerCase();

          return isActive && matchesCategory && matchesSearch && matchesPlace;
        }).toList();

        if (activeAds.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isNotEmpty
                  ? "No results found"
                  : selectedCategory == null
                  ? "No active classifieds available"
                  : "No classifieds found in $selectedCategory",
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: activeAds.length,
          itemBuilder: (ctx, index) {
            final adDoc = activeAds[index];
            final ad = adDoc.data() as Map<String, dynamic>;
            final adUserId = (ad['userId'] ?? '').toString().trim();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListTile(
                leading: ad["images"] != null && ad["images"].isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        // ✅ This image URL handling is safe for the thumbnail
                        child: Image.network(
                          ad["images"][0],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 40),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ✅ Fetch and show user name correctly
                    user_utils.UserNameFetcher(userId: adUserId),
                    const SizedBox(height: 4),
                    Text(
                      ad['title'] ?? "No title",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Text(
                  "Place: ${ad['place'] ?? 'N/A'}\n"
                  "Price: ${ad['price'] != null ? "₹${ad['price']}" : "Not specified"}\n"
                  "Expiry: ${ad['expiryDate'] != null ? (ad['expiryDate'] as Timestamp).toDate().toString().split(' ').first : 'N/A'}",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdDetailScreen(
                        adDoc: adDoc,
                        adId: adDoc.id,
                        adData: ad,
                        userId: adUserId,
                        isAdmin: false,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
