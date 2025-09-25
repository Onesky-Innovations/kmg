import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutoScrollAd extends StatefulWidget {
  final double height;

  const AutoScrollAd({
    super.key,
    this.height = 180,
    required List<IconData> adIcons,
  });

  @override
  State<AutoScrollAd> createState() => _AutoScrollAdState();
}

class _AutoScrollAdState extends State<AutoScrollAd> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _startAutoScroll(int itemCount) {
    _timer?.cancel();
    if (itemCount <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < itemCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classifieds')
            .where('type', isEqualTo: 'Banner')
            .where('status', isEqualTo: 'Active')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No banners available"));
          }

          // Start auto-scroll when data arrives
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startAutoScroll(docs.length);
          });

          return PageView.builder(
            controller: _pageController,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final ad = docs[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Image or Placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: (ad['images'] != null && ad['images'].isNotEmpty)
                            ? Image.network(
                                ad['images'][0],
                                height: widget.height,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: widget.height,
                                width: double.infinity,
                                color: Colors.blueAccent.shade200,
                                child: const Icon(
                                  Icons.image,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                      ),

                      // Title overlay
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ad['title'] ?? 'No title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
