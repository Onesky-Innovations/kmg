import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ads/ad_detail_screen.dart';

class AdsFeedScreen extends StatelessWidget {
  const AdsFeedScreen({super.key});

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
          return const Center(
            child: Text(
              "No classifieds available",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Filter only "Active" classifieds
        final activeAds = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final expiry = data['expiryDate'] != null
              ? (data['expiryDate'] as Timestamp).toDate()
              : null;
          return data['status'] == 'Active' &&
              (expiry == null || expiry.isAfter(DateTime.now()));
        }).toList();

        if (activeAds.isEmpty) {
          return const Center(
            child: Text(
              "No active classifieds available",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: activeAds.length,
          itemBuilder: (ctx, index) {
            final ad = activeAds[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListTile(
                leading: ad["images"] != null && ad["images"].isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          ad["images"][0],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 60,
                              height: 60,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 40);
                          },
                        ),
                      )
                    : const Icon(Icons.image, size: 40),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad['userId'] ?? "Unknown User",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad['title'] ?? "No title",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Text(
                  "Price: ${ad['price'] != null ? "₹${ad['price']}" : "Not specified"}\n"
                  "Expiry: ${ad['expiryDate'] != null ? (ad['expiryDate'] as Timestamp).toDate().toString().split(" ").first : "N/A"}",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdDetailScreen(
                        adDoc: activeAds[index],
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
