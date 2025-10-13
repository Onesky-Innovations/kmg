import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kmg/screens/ads/BannerDetailScreen.dart';
import 'package:kmg/screens/ads/ad_detail_screen.dart';
import 'package:kmg/widgets/auto_scroll_ad.dart'; // Ensure the path is correct

class FeaturedScreen extends StatelessWidget {
  const FeaturedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    final featuredClassifieds = firestore
        .collection('classifieds')
        .where('isFeatured', isEqualTo: true)
        .snapshots();

    // ✅ FIX: Query is now set to the top-level 'banners' collection
    final bannersStream = firestore
        .collection('banners') // <--- CORRECTED COLLECTION PATH
        .orderBy("createdAt", descending: true)
        .snapshots();

    // This is not used in the final build for the banner, but kept for context
    final bannerHeight = MediaQuery.of(context).size.width * 200 / 1080;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Featured"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📌 Banners",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Use the correct bannersStream here
            StreamBuilder<QuerySnapshot>(
              stream: bannersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Using the calculated height for the loading indicator
                  return SizedBox(
                    height: bannerHeight,
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

                // Pass the fetched documents to AutoScrollAd
                return AutoScrollAd(
                  height: 150,
                  ads: bannerDocs, // ✅ PASSING THE CORRECT LIST
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

            const SizedBox(height: 20),

            const Text(
              "🔥 Featured Classifieds",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ... (The rest of your featured classifieds code remains here)
            StreamBuilder<QuerySnapshot>(
              stream: featuredClassifieds,
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
                    final price = data['price'] ?? '';

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
                              userId: '',
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
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
