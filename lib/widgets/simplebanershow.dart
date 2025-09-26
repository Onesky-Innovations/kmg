// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SimpleBanner extends StatelessWidget {
//   final double height;
//   const SimpleBanner({super.key, this.height = 150});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: height,
//       child: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('classifieds')
//             .doc('baners')
//             .collection('baner')
//             // .where('status', isEqualTo: 'Active')
//             // .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data?.docs ?? [];
//           if (docs.isEmpty) {
//             return const Center(child: Text("No banners available"));
//           }

//           final ad = docs.first.data() as Map<String, dynamic>;
//           final images = ad['images'] as List<dynamic>? ?? [];
//           final imageUrl = images.isNotEmpty ? images[0] : null;

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.blueAccent.shade100,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: imageUrl != null
//                         ? Image.network(imageUrl, fit: BoxFit.cover)
//                         : Container(
//                             color: Colors.blueAccent.shade200,
//                             child: const Center(
//                               child: Icon(
//                                 Icons.image,
//                                 size: 64,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                   ),
//                   Positioned(
//                     bottom: 12,
//                     left: 12,
//                     right: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black54,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         ad['title'] ?? 'No title',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
