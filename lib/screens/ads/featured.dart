import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kmg/screens/ads/BannerDetailScreen.dart';
import 'package:kmg/screens/ads/ad_detail_screen.dart';
import 'package:kmg/widgets/auto_scroll_ad.dart';

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    // 1️⃣ Banners Stream (top-level)
    final bannersStream = firestore
        .collection('banners')
        .orderBy('createdAt', descending: true)
        .snapshots();

    // 2️⃣ Featured Classifieds Stream (collectionGroup)
    final featuredClassifiedsStream = firestore
        .collectionGroup('classifieds')
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            // Banner Section
            StreamBuilder<QuerySnapshot>(
              stream: bannersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 150,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox(
                    height: 150,
                    child: Center(child: Text("No banners found")),
                  );
                }

                final bannerDocs = snapshot.data!.docs;

                return AutoScrollAd(
                  height: 150,
                  ads: bannerDocs,
                  onTap: (index) {
                    final data =
                        bannerDocs[index].data() as Map<String, dynamic>;
                    final images = data['images'] as List<dynamic>? ?? [];
                    final imageUrl = images.isNotEmpty ? images[0] : '';
                    final description = data['description'] ?? '';
                    final phone = data['phone'] ?? '';

                    if (imageUrl.isNotEmpty) {
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
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 30),
            const Text(
              "🔥 Featured Classifieds",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Featured Classifieds Section
            StreamBuilder<QuerySnapshot>(
              stream: featuredClassifiedsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No featured classifieds found"),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Untitled';
                    final images = data['images'] as List<dynamic>? ?? [];
                    final imageUrl = images.isNotEmpty ? images[0] : '';
                    final price = data['price'] ?? 'N/A';
                    final place = data['place'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdDetailScreen(
                              adDoc: doc,
                              isAdmin: false,
                              adId: doc.id,
                              adData: data,
                              userId: data['userId'] ?? '',
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: Colors.black.withOpacity(0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Price: $price"),
                                  Text("Place: $place"),
                                ],
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
          ],
        ),
      ),
    );
  }
}
