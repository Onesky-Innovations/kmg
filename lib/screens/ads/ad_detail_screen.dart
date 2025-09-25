import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kmg/screens/admin/Add_Classified_FAB.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'Add_Classified_FAB.dart';

class AdDetailScreen extends StatelessWidget {
  final DocumentSnapshot adDoc;
  final bool isAdmin;

  const AdDetailScreen({
    super.key,
    required this.adDoc,
    this.isAdmin = false, // default false for normal users
  });

  @override
  Widget build(BuildContext context) {
    final ad = adDoc.data() as Map<String, dynamic>;
    final expiryDate = ad['expiryDate'] != null
        ? (ad['expiryDate'] as Timestamp).toDate()
        : null;

    // Skip banners for normal users
    if (!isAdmin && ad['type'] == 'Banner') {
      return const Scaffold(
        body: Center(child: Text("This ad is not visible.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(ad['title'] ?? "Ad Details"),
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddClassifiedFAB(
                        type: ad['type'],
                        userId: ad['userId'],
                        adId: adDoc.id,
                      ),
                    ),
                  );
                } else if (value == 'extend') {
                  _showExtendDialog(context, adDoc.id, ad);
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text(
                        "Are you sure you want to delete this ad?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await FirebaseFirestore.instance
                        .collection("classifieds")
                        .doc(adDoc.id)
                        .delete();
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: "edit", child: Text("Edit")),
                PopupMenuItem(value: "extend", child: Text("Extend")),
                PopupMenuItem(value: "delete", child: Text("Delete")),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User ID (top)
            Text(
              "User: ${ad['userId'] ?? '-'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Images
            if (ad['images'] != null && (ad['images'] as List).isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: (ad['images'] as List)
                      .map<Widget>(
                        (imgUrl) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.network(
                            imgUrl,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 12),

            // Title
            Text(
              ad['title'] ?? "-",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              ad['description'] ?? "-",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Details
            _buildDetailRow("Category", ad['category']),
            _buildDetailRow("Place", ad['place']),
            _buildDetailRow("Condition", ad['condition']),
            _buildDetailRow(
              "Price",
              ad['price'] != null ? "₹${ad['price']}" : "Not specified",
            ),

            if (isAdmin)
              _buildDetailRow(
                "Duration (days)",
                ad['durationDays']?.toString(),
              ),
            if (isAdmin) _buildDetailRow("Status", ad['status']),
            if (expiryDate != null && isAdmin)
              _buildDetailRow(
                "Expiry Date",
                DateFormat('yyyy-MM-dd').format(expiryDate),
              ),
            const SizedBox(height: 12),

            // Featured (only admin)
            if (isAdmin)
              Row(
                children: [
                  const Text("Featured Ad: "),
                  ad['isFeatured'] == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.grey),
                ],
              ),

            // Call / Chat button (only user)
            if (!isAdmin && ad['contact'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Call phone
                        launchUrl(Uri.parse('tel:${ad['contact']}'));
                      },
                      icon: const Icon(Icons.call),
                      label: const Text("Call"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // WhatsApp / chat
                        launchUrl(
                          Uri.parse(
                            'https://wa.me/${ad['contact']}?text=Hello',
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text("Chat"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _showExtendDialog(
    BuildContext context,
    String adId,
    Map<String, dynamic> ad,
  ) {
    int extendDays = 7;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text("Extend ${ad['title']}"),
          content: DropdownButton<int>(
            value: extendDays,
            items: [7, 15, 30]
                .map((e) => DropdownMenuItem(value: e, child: Text("$e days")))
                .toList(),
            onChanged: (val) {
              if (val != null) setStateDialog(() => extendDays = val);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newExpiry = (ad["expiryDate"] as Timestamp).toDate().add(
                  Duration(days: extendDays),
                );
                await FirebaseFirestore.instance
                    .collection("classifieds")
                    .doc(adId)
                    .update({"expiryDate": newExpiry});
                if (!context.mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text("Extend"),
            ),
          ],
        ),
      ),
    );
  }
}
