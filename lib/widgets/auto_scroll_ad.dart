// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AutoScrollAd extends StatefulWidget {
//   final double height;

//   const AutoScrollAd({
//     super.key,
//     this.height = 180,
//     required List<QueryDocumentSnapshot<Object?>> ads,
//     required Null Function(dynamic index) onTap,
//   });

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
//     if (itemCount <= 1) return;

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
//         stream: FirebaseFirestore.instance
//             .collection("classifieds")
//             .doc("baners")
//             .collection("baner")
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data?.docs ?? [];
//           // Filter out banners without images
//           final bannersWithImages = docs.where((doc) {
//             final ad = doc.data() as Map<String, dynamic>;
//             final images = ad['images'] as List<dynamic>? ?? [];
//             return images.isNotEmpty;
//           }).toList();

//           if (bannersWithImages.isEmpty) {
//             return const Center(child: Text("No banners available"));
//           }

//           if (_lastItemCount != bannersWithImages.length) {
//             _lastItemCount = bannersWithImages.length;
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _startAutoScroll(bannersWithImages.length);
//             });
//           }

//           return PageView.builder(
//             controller: _pageController,
//             itemCount: bannersWithImages.length,
//             itemBuilder: (context, index) {
//               final ad =
//                   bannersWithImages[index].data() as Map<String, dynamic>;
//               final images = ad['images'] as List<dynamic>;
//               final imageUrl = images[0];

//               return Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       // Show nothing if image fails
//                       return Container(color: Colors.grey.shade300);
//                     },
//                   ),
//                 ),
//               );
//             },
//           );
//         },
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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AutoScrollAd extends StatefulWidget {
//   final double height;
//   final List<QueryDocumentSnapshot<Object?>> ads;
//   final void Function(int index) onTap; // use proper type

//   const AutoScrollAd({
//     super.key,
//     this.height = 180,
//     required this.ads,
//     required this.onTap,
//   });

//   @override
//   State<AutoScrollAd> createState() => _AutoScrollAdState();
// }

// class _AutoScrollAdState extends State<AutoScrollAd> {
//   late final PageController _pageController;
//   int _currentPage = 0;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _startAutoScroll(widget.ads.length);
//   }

//   void _startAutoScroll(int itemCount) {
//     _timer?.cancel();
//     if (itemCount <= 1) return;

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
//     if (widget.ads.isEmpty) {
//       return SizedBox(
//         height: widget.height,
//         child: const Center(child: Text("No banners available")),
//       );
//     }

//     return SizedBox(
//       height: widget.height,
//       child: PageView.builder(
//         controller: _pageController,
//         itemCount: widget.ads.length,
//         itemBuilder: (context, index) {
//           final ad = widget.ads[index].data() as Map<String, dynamic>;
//           final images = ad['images'] as List<dynamic>? ?? [];
//           if (images.isEmpty) return const SizedBox();

//           final imageUrl = images[0];

//           return GestureDetector(
//             onTap: () => widget.onTap(index), // handle tap
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.network(
//                   imageUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(color: Colors.grey.shade300);
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
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
import 'package:kmg/screens/ads/BannerDetailScreen.dart';

class AutoScrollAd extends StatefulWidget {
  final double height;

  const AutoScrollAd({
    super.key,
    this.height = 180,
    required List<QueryDocumentSnapshot<Object?>> ads,
    required Null Function(dynamic index) onTap,
  });

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
            .collection("banners")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          // ✅ FIX: Check if the database returned zero documents immediately
          if (docs.isEmpty) {
            return const Center(child: Text("No banners available"));
          }
          // ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^

          // Filter out banners without images
          final bannersWithImages = docs.where((doc) {
            final ad = doc.data() as Map<String, dynamic>;
            final images = ad['images'] as List<dynamic>? ?? [];
            return images.isNotEmpty;
          }).toList();

          // Check if no banners remain after filtering by images
          if (bannersWithImages.isEmpty) {
            return const Center(child: Text("No banners available"));
          }

          // Restart auto-scroll if new data count changes
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
              final description =
                  ad['description'] ?? 'No description available';
              final phone = ad['phone'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BannerDetailScreen(
                        imageUrl: imageUrl,
                        description: description,
                        phone: phone,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey.shade300);
                      },
                    ),
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
