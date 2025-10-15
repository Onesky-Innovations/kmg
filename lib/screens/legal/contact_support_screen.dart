import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen(String adId, {super.key});

  // Contact Information (UNCHANGED as requested)
  final String whatsappNumber = "+919744422238";
  final String email = "kmg.project1@gmail.com";
  final String customerCareNumber = "+919744422238";

  // --- Utility Functions ---

  // Centralized URL launcher with error handling
  Future<void> _launchUrl(
    BuildContext context,
    String url, {
    bool external = true,
  }) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: external
              ? LaunchMode.externalApplication
              : LaunchMode.platformDefault,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to launch. Protocol not supported on this device for: $url',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred while launching. Please try again. ($e)',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Confirmation dialog (More professional wording)
  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Proceed"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Problem input dialog (Kept structure, improved UI)
  Future<String?> _showProblemInputDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Customer Hotline Support"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kindly describe your inquiry briefly before initiating the call:",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Need help for creating profile",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Call"),
          ),
        ],
      ),
    );
    return result;
  }

  // --- Contact Handlers ---

  // Open WhatsApp
  Future<void> _openWhatsApp(BuildContext context) async {
    final url = "https://wa.me/$whatsappNumber";
    final confirmed = await _showConfirmationDialog(
      context,
      "WhatsApp Support Chat",
      "You are about to launch WhatsApp to chat directly with a support agent. Proceed?",
    );
    if (confirmed) {
      await _launchUrl(context, url);
    }
  }

  // Open Email
  Future<void> _openEmail(BuildContext context) async {
    // Added subject and body pre-fill for professionalism
    final url =
        "mailto:$email?subject=URGENT%20Support%20Request%20via%20App&body=Dear%20Support%20Team,%0A%0A%5BPlease%20detail%20your%20issue%20here%5D%0A%0A%20Thank%20you.%0A";
    final confirmed = await _showConfirmationDialog(
      context,
      "Email Customer Service",
      "This will open your default email application to compose a message to $email. Proceed?",
    );
    if (confirmed) {
      await _launchUrl(context, url);
    }
  }

  // Call Customer Care
  Future<void> _callCustomerCare(BuildContext context) async {
    String? problem = await _showProblemInputDialog(context);
    // Original logic maintained: Call only proceeds if description is provided
    if (problem != null && problem.isNotEmpty) {
      final url = "tel:$customerCareNumber";
      await _launchUrl(context, url, external: true);
    } else if (problem != null) {
      // Show informative message if user pressed 'Call' but left it empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Description is required before calling the hotline for better service.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // --- UI Components ---

  Widget _buildContactCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
        leading: Icon(icon, color: color, size: 36),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dedicated Support Center"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How can we assist you today?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please select your preferred method to connect with our highly-trained support professionals.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 40),

            // WhatsApp Support
            _buildContactCard(
              context: context,
              title: "Instant Chat Support",
              subtitle: "Connect instantly via WhatsApp",
              icon: Icons.chat,
              color: Colors.green.shade600,
              onTap: () => _openWhatsApp(context),
            ),

            // Email Support
            _buildContactCard(
              context: context,
              title: "Formal Email Inquiry",
              subtitle: "Submit detailed requests via e-mail",
              icon: Icons.mail_outline,
              color: Colors.blue.shade600,
              onTap: () => _openEmail(context),
            ),

            // Customer Hotline
            _buildContactCard(
              context: context,
              title: "Customer Service Hotline",
              subtitle: "For urgent matters, call us ",
              icon: Icons.phone_in_talk_outlined,
              color: Colors.red.shade600,
              onTap: () => _callCustomerCare(context),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                "Our team is available 24/7 to provide prompt assistance.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
