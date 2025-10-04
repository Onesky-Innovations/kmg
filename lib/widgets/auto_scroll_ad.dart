// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AutoScrollAd extends StatefulWidget {
//   final double height;

//   const AutoScrollAd({super.key, this.height = 180});

//   @override
//   State<AutoScrollAd> createState() => _AutoScrollAdState();
// }

// class _AutoScrollAdState extends State<AutoScrollAd> {
//   late final PageController _pageController;
//   int _currentPage = 0;
//   Timer? _timer;
//   int _lastItemCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }

//   void _startAutoScroll(int itemCount) {
//     _timer?.cancel();
//     if (itemCount <= 1) return; // Only scroll if more than 1 banner

//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (!_pageController.hasClients) return;

//       _currentPage = (_currentPage + 1) % itemCount;
//       _pageController.animateToPage(
//         _currentPage,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: widget.height,
//       child: StreamBuilder<QuerySnapshot>(
//         stream:FirebaseFirestore.instance
//         .collection("classifieds")
//         .doc("baners")
//         .collection("baner")
//         .orderBy("createdAt", descending: true).snapshots(),
//         builder: (context, snapshot) {

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data?.docs ?? [];
//           if (docs.isEmpty) {
//             return const Center(child: Text("No banners available"));
//           }

//           // Start auto-scroll if banner count changes
//           if (_lastItemCount != docs.length) {
//             _lastItemCount = docs.length;
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _startAutoScroll(docs.length);
//             });
//           }

//           return PageView.builder(
//             controller: _pageController,
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final ad = docs[index].data() as Map<String, dynamic>;
//               final images = ad['images'] as List<dynamic>? ?? [];
//               final imageUrl = images.isNotEmpty ? images[0] : null;

//               return Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.blueAccent.shade100,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: imageUrl != null
//                             ? Image.network(
//                                 imageUrl,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return _placeholder();
//                                 },
//                               )
//                             : _placeholder(),
//                       ),
//                       Positioned(
//                         bottom: 12,
//                         left: 12,
//                         right: 12,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black54,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             ad['title'] ?? 'No title',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _placeholder() {
//     return Container(
//       color: Colors.blueAccent.shade200,
//       child: const Center(
//         child: Icon(Icons.image, size: 64, color: Colors.white),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutoScrollAd extends StatefulWidget {
  final double height;

  const AutoScrollAd({super.key, this.height = 180});

  @override
  State<AutoScrollAd> createState() => _AutoScrollAdState();
}

class _AutoScrollAdState extends State<AutoScrollAd> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  int _lastItemCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _startAutoScroll(int itemCount) {
    _timer?.cancel();
    if (itemCount <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_pageController.hasClients) return;

      _currentPage = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("classifieds")
            .doc("baners")
            .collection("baner")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          // Filter out banners without images
          final bannersWithImages = docs.where((doc) {
            final ad = doc.data() as Map<String, dynamic>;
            final images = ad['images'] as List<dynamic>? ?? [];
            return images.isNotEmpty;
          }).toList();

          if (bannersWithImages.isEmpty) {
            return const Center(child: Text("No banners available"));
          }

          if (_lastItemCount != bannersWithImages.length) {
            _lastItemCount = bannersWithImages.length;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoScroll(bannersWithImages.length);
            });
          }

          return PageView.builder(
            controller: _pageController,
            itemCount: bannersWithImages.length,
            itemBuilder: (context, index) {
              final ad =
                  bannersWithImages[index].data() as Map<String, dynamic>;
              final images = ad['images'] as List<dynamic>;
              final imageUrl = images[0];

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Show nothing if image fails
                      return Container(color: Colors.grey.shade300);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
