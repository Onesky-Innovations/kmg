import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kmg/notifiers/saved_ads_notifier.dart';
import 'package:kmg/screens/admin/Add_Classified_FAB.dart';
import 'package:kmg/screens/settings/sign_in_screen.dart';
import 'package:kmg/utils/user_name_fetcher.dart' as user_utils;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ⭐️ NEW IMPORTS for State Management
import 'package:provider/provider.dart';
// import 'package:kmg/providers/saved_ads_notifier.dart';

class AdDetailScreen extends StatefulWidget {
  final DocumentSnapshot adDoc;
  final Map<String, dynamic> adData;
  final String adId;
  final String userId;
  final bool isAdmin;

  const AdDetailScreen({
    super.key,
    required this.adDoc,
    required this.adData,
    required this.adId,
    required this.userId,
    this.isAdmin = false,
  });

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ❌ REMOVED: Set<String> savedAdIds = {};
  // ❌ REMOVED: bool isLoadingSaved = true;

  // ❌ REMOVED: initState() and the _loadSavedAds() function entirely!

  // The logic for toggling the save status now calls the Notifier.
  void _handleToggleSaveAd() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showSignInDialog();
      return;
    }

    // 🚀 Call the global function on the Notifier
    Provider.of<SavedAdsNotifier>(context, listen: false).toggleSaveAd(
      adId: widget.adDoc.id,
      // Pass the adData map directly as required by the Notifier's toggleSaveAd function
      adData: widget.adData,
      context: context,
    );
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sign in required"),
        content: const Text("To save this ad, please sign in."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignInScreen(fromFab: false),
                ),
              );
            },
            child: const Text("Sign In"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ 1. WATCH the SavedAdsNotifier to react to global changes (like signing in or toggling save)
    final savedAdsNotifier = context.watch<SavedAdsNotifier>();

    // ⭐️ 2. Get status directly from the notifier
    final bool isSaveStatusLoading = savedAdsNotifier.isLoading;
    final bool isSaved = savedAdsNotifier.savedAdIds.contains(widget.adDoc.id);

    final ad = widget.adDoc.data() as Map<String, dynamic>? ?? {};
    final expiryDate = ad['expiryDate'] != null
        ? (ad['expiryDate'] as Timestamp).toDate()
        : null;
    final postedDate = ad['postedAt'] != null
        ? (ad['postedAt'] as Timestamp).toDate()
        : null;

    final soldStatus = (ad['soldStatus'] ?? 'unsold').toString();
    final isSold = soldStatus == 'sold';

    if (!widget.isAdmin && (ad['type'] ?? '') == 'Banner') {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(
            "This ad is not visible.",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final userId = ad['userId']?.toString() ?? 'Unknown User';
    final title = ad['title']?.toString() ?? 'Ad Details';
    final category = ad['category']?.toString();
    final place = ad['place']?.toString();
    final condition = ad['condition']?.toString();
    final price = ad['price'] != null ? "₹${ad['price']}" : "Not specified";
    final images = List<String>.from(ad['images'] ?? []);
    final status = ad['status']?.toString() ?? '-';
    final type = ad['type']?.toString() ?? 'Unknown';
    final durationDays = ad['durationDays']?.toString() ?? '30';
    final description =
        ad['description']?.toString() ?? 'No description provided.';
    final contact = ad['contact']?.toString();

    final currentUser = _auth.currentUser;
    final isSignedIn = currentUser != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          // ⭐️ OPTIMIZED: Uses global state, not local future/loading flag
          if (isSignedIn)
            IconButton(
              icon: isSaveStatusLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.yellow.shade700 : Colors.white,
                    ),
              tooltip: isSaved ? 'Remove from saved' : 'Save this ad',
              // Use the new simplified handler
              onPressed: isSaveStatusLoading ? null : _handleToggleSaveAd,
            )
          else
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              tooltip: 'Save this ad',
              onPressed: _showSignInDialog,
            ),

          // Share and Admin Actions remain the same...
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () async {
              final safeTitle = title.replaceAll('"', "'");
              final shareText =
                  'Check out this ad "$safeTitle" on KMG app: https://kmg.example.com/ad/${widget.adDoc.id ?? ''}';

              if (kIsWeb) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Sharing is not supported on web platform.",
                      ),
                    ),
                  );
                }
                return;
              }

              try {
                await Share.share(shareText, subject: 'Interesting Ad');
              } catch (e) {
                debugPrint("Share failed: $e");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Unable to share this ad.")),
                  );
                }
              }
            },
          ),

          if (widget.isAdmin)
            PopupMenuButton<String>(
              color: Theme.of(context).cardColor,
              elevation: 8,
              onSelected: (value) async {
                if (value == 'edit') {
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddClassifiedFAB(
                          type: type,
                          userId: userId,
                          adId: widget.adDoc.id,
                          adOwnerId: ad['userId'],
                        ),
                      ),
                    );
                  }
                } else if (value == 'extend') {
                  if (context.mounted) {
                    _showExtendDialog(context, widget.adDoc.id, ad);
                  }
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: const Text(
                        "Confirm Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      content: const Text(
                        "Are you sure you want to delete this ad?",
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await FirebaseFirestore.instance
                          .collection("classifieds")
                          .doc(widget.adDoc.id)
                          .delete();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Ad deleted successfully."),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      debugPrint("Delete failed: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to delete ad.")),
                        );
                      }
                    }
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: "edit",
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: "extend",
                  child: Text(
                    "Extend",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: "delete",
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posted by
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Posted by: ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  user_utils.UserNameFetcher(
                    userId: ad['userId'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),

            // Images
            if (images.isNotEmpty)
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final imageUrl = images[index];
                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                backgroundColor: Colors.black,
                                body: Stack(
                                  children: [
                                    Center(
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.white54,
                                                    size: 100,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 200,
                                            top: 100,
                                          ),
                                          child: Text(
                                            'KMG',
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(77),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 36,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 40,
                                      right: 20,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Transform.translate(
                              offset: const Offset(20, 0),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    imageUrl,
                                    width: 300,
                                    height: 220,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[200],
                                              width: 300,
                                              height: 220,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 25,
                              child: Text(
                                'KMG',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 3,
                                      color: Colors.black,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isSold)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'SOLD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),

            // Specifications
            Text(
              "Specifications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(context, "Category", category),
            _buildDetailRow(context, "Place", place),
            _buildDetailRow(context, "Condition", condition),
            _buildDetailRow(context, "Price", price, isPrice: true),
            if (postedDate != null)
              _buildDetailRow(
                context,
                "Posted On",
                DateFormat('yyyy-MM-dd').format(postedDate),
              ),
            if (widget.isAdmin)
              _buildDetailRow(context, "Duration (days)", durationDays),
            if (widget.isAdmin) _buildDetailRow(context, "Status", status),
            if (expiryDate != null && widget.isAdmin)
              _buildDetailRow(
                context,
                "Expiry Date",
                DateFormat('yyyy-MM-dd').format(expiryDate),
                isExpiry: true,
              ),
            const SizedBox(height: 20),

            // Call / WhatsApp buttons for user
            if (!widget.isAdmin && contact != null)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGradientButton(
                      context: context,
                      label: "Call Now",
                      icon: Icons.call,
                      onPressed: () async {
                        final url = Uri.parse('tel:$contact');
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Cannot make a call."),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildGradientButton(
                      context: context,
                      label: "Chat on WhatsApp",
                      icon: Icons.chat,
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://wa.me/$contact?text=Hello%20I%20saw%20your%20ad%20"$title"%20on%20KMG.',
                        );
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Cannot open WhatsApp."),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // NOTE: The helper methods (_buildGradientButton, _buildDetailRow, _showExtendDialog)
  // are assumed to remain the same as your original code.

  Widget _buildGradientButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        icon: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
        label: Text(label),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String? value, {
    bool isPrice = false,
    bool isExpiry = false,
  }) {
    Color valueColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    TextStyle valueStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    if (isPrice) {
      valueColor = Theme.of(context).colorScheme.secondary;
      valueStyle = valueStyle.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 18,
      );
    } else if (isExpiry) {
      valueColor = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade200,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value ?? "-",
              style: valueStyle.copyWith(color: valueColor),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Extend ${ad['title'] ?? 'Ad'}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select duration to extend:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: extendDays,
                    isExpanded: true,
                    items: [7, 15, 30]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              "$e days",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => extendDays = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final oldExpiry = ad["expiryDate"] as Timestamp?;
                DateTime newExpiryDate;
                if (oldExpiry == null ||
                    oldExpiry.toDate().isBefore(DateTime.now())) {
                  newExpiryDate = DateTime.now().add(
                    Duration(days: extendDays),
                  );
                } else {
                  newExpiryDate = oldExpiry.toDate().add(
                    Duration(days: extendDays),
                  );
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('classifieds')
                      .doc(adId)
                      .update({
                        'expiryDate': Timestamp.fromDate(newExpiryDate),
                        'durationDays': (ad['durationDays'] ?? 0) + extendDays,
                      });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Ad extended by $extendDays days. New expiry: ${DateFormat('yyyy-MM-dd').format(newExpiryDate)}",
                        ),
                      ),
                    );
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  debugPrint("Error extending ad: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to extend ad.")),
                    );
                  }
                }
              },
              child: const Text("Extend"),
            ),
          ],
        ),
      ),
    );
  }
}
