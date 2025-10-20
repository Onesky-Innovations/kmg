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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:kmg/screens/ads/BannerDetailScreen.dart';

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
//             .collection("banners")
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data?.docs ?? [];

//           // ✅ FIX: Check if the database returned zero documents immediately
//           if (docs.isEmpty) {
//             return const Center(child: Text("No banners available"));
//           }
//           // ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^

//           // Filter out banners without images
//           final bannersWithImages = docs.where((doc) {
//             final ad = doc.data() as Map<String, dynamic>;
//             final images = ad['images'] as List<dynamic>? ?? [];
//             return images.isNotEmpty;
//           }).toList();

//           // Check if no banners remain after filtering by images
//           if (bannersWithImages.isEmpty) {
//             return const Center(child: Text("No banners available"));
//           }

//           // Restart auto-scroll if new data count changes
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
//               final description =
//                   ad['description'] ?? 'No description available';
//               final phone = ad['phone'] ?? '';

//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => BannerDetailScreen(
//                         imageUrl: imageUrl,
//                         description: description,
//                         phone: phone,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(color: Colors.grey.shade300);
//                       },
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
// import 'package:kmg/screens/ads/BannerDetailScreen.dart'; // Assuming this import is correct

class AutoScrollAd extends StatefulWidget {
  final double height;

  const AutoScrollAd({
    super.key,
    this.height = 180,
    required List<QueryDocumentSnapshot<Object?>> ads,
    required Null Function(dynamic index) onTap,
    // The 'ads' and 'onTap' properties in the constructor seem unused in the State,
    // as the data is fetched inside the build method via StreamBuilder.
    // I'm removing them for clarity but keeping them if you intend to pass data instead of fetching.
    // required List<QueryDocumentSnapshot<Object?>> ads,
    // required Null Function(dynamic index) onTap,
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

  // --- Optimization: Pre-caching Function ---
  void _precacheImages(
    List<QueryDocumentSnapshot> banners,
    BuildContext context,
  ) {
    for (final doc in banners) {
      final ad = doc.data() as Map<String, dynamic>;
      final images = ad['images'] as List<dynamic>? ?? [];
      if (images.isNotEmpty && images[0] is String) {
        // Start pre-caching the image.
        // This requests the image data and stores it in the image cache.
        precacheImage(NetworkImage(images[0] as String), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: StreamBuilder<QuerySnapshot>(
        // 🔑 Optimization: The connection to Firebase is the first bottleneck.
        // This part is unavoidable if you need real-time data.
        stream: FirebaseFirestore.instance
            .collection("banners")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ✅ Optimization: Return a simple, height-correct placeholder
            // instead of a centered indicator if the screen design allows.
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No banners available"));
          }

          final bannersWithImages = docs.where((doc) {
            final ad = doc.data() as Map<String, dynamic>;
            final images = ad['images'] as List<dynamic>? ?? [];
            return images.isNotEmpty;
          }).toList();

          if (bannersWithImages.isEmpty) {
            return const Center(child: Text("No banners available"));
          }

          // 🔑 Optimization: Pre-cache images as soon as data arrives
          // This allows images to be downloaded in the background while the UI is built.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _precacheImages(bannersWithImages, context);
          });

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
              final imageUrl = images[0] as String;
              final description =
                  ad['description'] ?? 'No description available';
              final phone = ad['phone'] ?? '';

              return GestureDetector(
                onTap: () {
                  // Assuming BannerDetailScreen is defined elsewhere
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => BannerDetailScreen(
                  //       imageUrl: imageUrl,
                  //       description: description,
                  //       phone: phone,
                  //     ),
                  //   ),
                  // );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    // 🔑 Optimization: Use loadingBuilder for a smooth transition
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        // Return a colored container as a placeholder while loading
                        return Container(
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: LinearProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: Theme.of(context).primaryColor,
                            backgroundColor: Colors.transparent,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // Return a light gray container on error
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
