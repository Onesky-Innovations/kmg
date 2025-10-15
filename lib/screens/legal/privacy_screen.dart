// import 'package:flutter/material.dart';

// class PrivacyPolicyScreen extends StatelessWidget {
//   const PrivacyPolicyScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Privacy Policy')),
//       body: const SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Privacy Policy',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text('Last updated: October 6, 2025'),
//             SizedBox(height: 20),
//             Text(
//               'KMG Classifieds & Matrimony ("we", "our", "us") is developed and operated by Onesky Innovations. '
//               'We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '1. Information We Collect',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Personal Information: Name, age, gender, and profile details provided during registration.\n'
//               'Contact Information: Phone number, email address, and communication details.\n'
//               'Location Information: City, state, or approximate location for relevant ads and matches.\n'
//               'Media and Uploads: Photos, profile pictures, or other media you upload.\n'
//               'Chats and Messages: Messages exchanged within the app, stored securely for communication purposes.\n'
//               'Device and Technical Data: Device type, OS, crash data, and analytics information (via Firebase & Google Analytics).\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '2. How We Use Your Information',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               '• To create and manage user accounts.\n'
//               '• To display relevant classified or matrimony content.\n'
//               '• To facilitate communication between users (with consent).\n'
//               '• To improve app functionality and user experience.\n'
//               '• To provide customer support and respond to inquiries.\n'
//               '• To send important notifications and account updates.\n'
//               '• To analyze app performance using Firebase and Google Analytics.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '3. Data Sharing and Disclosure',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'We do not sell, rent, or trade your personal data. Information may only be shared in the following cases:\n\n'
//               '• With your consent: When you choose to share your details publicly.\n'
//               '• Service Providers: With trusted third parties such as Firebase, Google Analytics, and Google Cloud Storage.\n'
//               '• Legal Requirements: When required by law or to protect our legal rights, users, or the public.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '4. Data Retention',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'We retain your personal data as long as your account is active or as needed to provide our services. '
//               'You can request deletion of your data or account at any time by contacting us at Oneskyinnovations@gmail.com.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '5. User Rights',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               '• Access, review, or update your personal information.\n'
//               '• Request deletion of your account and data.\n'
//               '• Withdraw consent for data processing (may limit app functionality).\n'
//               '• Contact us regarding any privacy concerns at Oneskyinnovations@gmail.com.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '6. Security of Your Information',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'We use industry-standard security measures, including encryption and secure authentication. '
//               'However, no system can be guaranteed 100% secure, so we recommend using strong passwords and avoiding sharing sensitive details with others.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '7. Children’s Privacy',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'This app is intended for users aged 18 and above. We do not knowingly collect information from minors. '
//               'If such data is collected inadvertently, we will delete it immediately upon discovery.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '8. Third-Party Services',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               '• Firebase (Google LLC) – for authentication, analytics, and data storage.\n'
//               '• Google Analytics – for app performance tracking.\n'
//               '• Google Cloud Storage – for storing user-generated content securely.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '9. Changes to This Privacy Policy',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'We may update this Privacy Policy from time to time. Updates will be reflected with a new “Last updated” date. '
//               'Continued use of the app after updates indicates acceptance of the revised policy.\n',
//             ),
//             SizedBox(height: 10),
//             Text(
//               '10. Contact Us',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Text(
//               'Email: Oneskyinnovations@gmail.com\n'
//               'Developer: Onesky Innovations\n'
//               'Country: India\n'
//               '© 2025 Onesky Innovations. All rights reserved.\n',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
// Note: You would still need url_launcher for the external link
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  // Use the external URL for redundancy and verification
  final String externalPolicyUrl =
      'https://sites.google.com/view/kmgclassifieds/privacy-policy';
  final String contactEmail = 'Oneskyinnovations@gmail.com';

  const PrivacyPolicyScreen({super.key});

  // Helper function to launch URLs/Emails
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // In a real app, you'd show a Snackbar error here
      throw 'Could not launch $url';
    }
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title and Date ---
            const Text(
              'KMG Classifieds & Matrimony',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Last updated: October 11, 2025',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 30),

            const Text(
              'KMG Classifieds & Matrimony ("we", "our", "us") is developed and operated by Onesky Innovations. '
              'We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),

            // --- 1. Information We Collect ---
            _buildSectionHeader('1. Information We Collect'),
            const Text(
              '• Personal Information: Name, age, gender, and profile details provided during registration.\n'
              '• Contact Information: Phone number, email address, and communication details.\n'
              '• Location Information: City, state, or approximate location for relevant ads and matches.\n'
              '• Media and Uploads: Photos, profile pictures, or other media you upload.\n'
              '• Chats and Messages: Messages exchanged within the app, stored securely for communication purposes.\n'
              '• Device and Technical Data: Device type, OS, crash data, and analytics information (via Firebase & Google Analytics).',
            ),

            // --- 2. How We Use Your Information ---
            _buildSectionHeader('2. How We Use Your Information'),
            const Text(
              'We use your information to:\n'
              '• Create and manage user accounts.\n'
              '• Display relevant classified or matrimony content.\n'
              '• Facilitate communication between users (with consent).\n'
              '• Improve app functionality and user experience.\n'
              '• Provide customer support and respond to inquiries.\n'
              '• Send important notifications and account updates.\n'
              '• Analyze app performance using Firebase and Google Analytics.',
            ),

            // --- 3. Data Sharing and Disclosure ---
            _buildSectionHeader('3. Data Sharing and Disclosure'),
            const Text(
              'We do not sell, rent, or trade your personal data. Information may only be shared in the following cases:\n'
              '• With your consent: When you choose to share details publicly (e.g., in ads or profiles).\n'
              '• Service Providers: With trusted third parties such as Firebase, Google Analytics, and Google Cloud Storage.\n'
              '• Legal Requirements: When required by law or to protect our rights, users, or the public.',
            ),

            // --- 4. Data Retention and Account Deletion ---
            _buildSectionHeader('4. Data Retention and Account Deletion'),
            const Text(
              'You can request account deletion directly from within the app (Settings -> Delete Account) or by contacting us at the email below.\n\n'
              'When you request deletion:\n'
              '• All your personal data, profile information, uploaded media, and listings will be permanently deleted from our database.\n'
              '• Your authentication record (such as your email and user ID) may be retained for a limited time for audit or security purposes.\n'
              '• No personal content or identifying data will remain accessible.',
            ),

            // --- 5. User Rights ---
            _buildSectionHeader('5. User Rights'),
            const Text(
              'You have the right to:\n'
              '• Access, review, or update your personal information.\n'
              '• Request deletion of your account and associated data.\n'
              '• Withdraw consent for data processing (which may limit app functionality).\n'
              '• Contact us at the email below for any privacy-related concerns.',
            ),

            // --- 6. Security of Your Information ---
            _buildSectionHeader('6. Security of Your Information'),
            const Text(
              'We use industry-standard security measures including encryption, secure authentication, and limited data access. '
              'However, no digital system can be guaranteed 100% secure. We encourage users to use strong passwords and avoid sharing sensitive details.',
            ),

            // --- 7. Children’s Privacy ---
            _buildSectionHeader('7. Children’s Privacy'),
            const Text(
              'This app is intended for users aged 18 and above. We do not knowingly collect data from minors. '
              'If such data is discovered, it will be deleted immediately.',
            ),

            // --- 8. Third-Party Services ---
            _buildSectionHeader('8. Third-Party Services'),
            const Text(
              'We rely on the following third-party services to operate securely and effectively:\n'
              '• Firebase (Google LLC) – authentication, analytics, and secure data storage.\n'
              '• Google Analytics – performance and usage analysis.\n'
              '• Google Cloud Storage – secure storage of user-generated content.',
            ),

            // --- 9. Changes to This Privacy Policy ---
            _buildSectionHeader('9. Changes to This Privacy Policy'),
            const Text(
              'We may update this Privacy Policy periodically to reflect new legal or operational requirements. '
              'The updated version will include a new “Last updated” date. Continued use of the app indicates acceptance of the latest version.',
            ),

            // --- 10. Contact Us & External Link (Improved) ---
            _buildSectionHeader('10. Contact Us'),

            // EMAIL LINK (Clickable)
            GestureDetector(
              onTap: () => _launchUrl('mailto:$contactEmail'),
              child: SelectableText(
                'Email: $contactEmail',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text('Developer: Onesky Innovations'),
            const Text('Country: India'),

            const SizedBox(height: 20),

            // EXTERNAL LINK (Redundancy)
            const Text(
              'For the most current version, you can also view the policy online:',
            ),
            GestureDetector(
              onTap: () => _launchUrl(externalPolicyUrl),
              child: Text(
                externalPolicyUrl,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              '© 2025 Onesky Innovations. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
