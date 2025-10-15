import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// NOTE: You must also import the necessary screens for admin functionality
// For now, we only add the required properties
// import 'package:kmg/screens/admin/AddBannerFAB.dart';
// import 'package:kmg/screens/admin/ManageClassifiedsScreen.dart'; // Or your main admin screen

class BannerDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String description;
  final String phone;
  // NEW ADMIN PROPERTIES: Add these to support future edit logic
  final String? adId;
  final String? userId;
  final Map<String, dynamic>? adData;

  const BannerDetailScreen({
    super.key,
    required this.imageUrl,
    required this.description,
    required this.phone,
    // Initialize new fields
    this.adId,
    this.userId,
    this.adData,
  });

  // Function to launch the phone dialer with user feedback
  void _callNumber(BuildContext context, String number) async {
    // Clean up the number by removing non-digit characters
    final String cleanNumber = number.replaceAll(RegExp(r'\D'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleanNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Provide user feedback if the dialer can't be launched
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the phone dialer. Please check the number or device settings.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription = description.trim().isNotEmpty;
    final hasPhone = phone.trim().isNotEmpty;

    const primaryColor = Colors.deepPurple;
    const accentColor = Colors.green;
    const detailPadding = 20.0;

    return Scaffold(
      backgroundColor: primaryColor.shade900,

      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 🖼️ Image Section - Respects image size and aspect ratio
              SliverToBoxAdapter(
                child: Container(
                  color: primaryColor.shade900,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Hero(
                      tag: imageUrl,
                      child: InteractiveViewer(
                        maxScale: 3.0,
                        minScale: 1.0,
                        child: Center(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 200,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white70,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              alignment: Alignment.center,
                              color: primaryColor.shade800,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.white70,
                                    size: 60,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Image Not Found',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 📄 Info Content (SliverList)
              SliverList(
                delegate: SliverChildListDelegate([
                  // Info Section Container with Curved Top and Shadow
                  Container(
                    padding: const EdgeInsets.all(detailPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Description Section ---
                        _buildHeader(
                          'Description',
                          Icons.description_outlined,
                          primaryColor,
                        ),
                        const SizedBox(height: 12),

                        if (hasDescription)
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          )
                        else
                          _buildFallbackBox(
                            "No detailed description was provided for this advertisement. 😔\n\nPlease refer to the image or contact the advertiser directly for more information.",
                            Colors.deepPurple.shade50,
                            Colors.deepPurple,
                          ),

                        const SizedBox(height: 25),
                        const Divider(
                          color: Colors.black12,
                          thickness: 1,
                        ), // Visual separator
                        const SizedBox(height: 25),

                        // --- Contact Section ---
                        _buildHeader(
                          'Contact Advertiser',
                          Icons.phone_in_talk_outlined,
                          primaryColor,
                        ),
                        const SizedBox(height: 12),

                        if (hasPhone)
                          _buildCallButton(
                            context,
                            phone,
                            accentColor,
                            _callNumber,
                          )
                        else
                          _buildFallbackBox(
                            "📱 Contact number is unavailable.\n\n"
                            "You might find contact details within the advertisement image itself.",
                            Colors.orange.shade50,
                            Colors.orange,
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),

          // ⬅️ Floating Back Button for quick dismissal
          Positioned(
            top: 40, // Adjust based on device safe area/status bar height
            left: 10,
            child: Material(
              color: Colors
                  .black54, // Semi-transparent background for visibility on any image
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackBox(
    String message,
    Color backgroundColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 15,
          color: borderColor.shade800,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCallButton(
    BuildContext context,
    String number,
    Color color,
    Function(BuildContext, String) onCall,
  ) {
    return SizedBox(
      width: double.infinity, // Make the button full width
      child: ElevatedButton.icon(
        onPressed: () => onCall(context, number),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          elevation: 5,
        ),
        icon: const Icon(Icons.call, size: 24),
        label: Text(
          'Call: $number',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

extension on Color {
  Color get shade800 {
    // Basic implementation for this specific use case
    if (this == Colors.deepPurple) return Colors.deepPurple.shade800;
    if (this == Colors.orange) return Colors.orange.shade800;
    return this;
  }

  Color get shade900 {
    // Basic implementation for this specific use case
    if (this == Colors.deepPurple) return Colors.deepPurple.shade900;
    return this;
  }

  Color get shade50 {
    // Basic implementation for this specific use case
    if (this == Colors.deepPurple) return Colors.deepPurple.shade50;
    if (this == Colors.orange) return Colors.orange.shade50;
    return this;
  }
}
