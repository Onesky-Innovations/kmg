import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Last updated: October 6, 2025'),
            SizedBox(height: 20),
            Text(
              'KMG Classifieds & Matrimony ("we", "our", "us") is developed and operated by Onesky Innovations. '
              'We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.\n',
            ),
            SizedBox(height: 10),
            Text(
              '1. Information We Collect',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Personal Information: Name, age, gender, and profile details provided during registration.\n'
              'Contact Information: Phone number, email address, and communication details.\n'
              'Location Information: City, state, or approximate location for relevant ads and matches.\n'
              'Media and Uploads: Photos, profile pictures, or other media you upload.\n'
              'Chats and Messages: Messages exchanged within the app, stored securely for communication purposes.\n'
              'Device and Technical Data: Device type, OS, crash data, and analytics information (via Firebase & Google Analytics).\n',
            ),
            SizedBox(height: 10),
            Text(
              '2. How We Use Your Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '• To create and manage user accounts.\n'
              '• To display relevant classified or matrimony content.\n'
              '• To facilitate communication between users (with consent).\n'
              '• To improve app functionality and user experience.\n'
              '• To provide customer support and respond to inquiries.\n'
              '• To send important notifications and account updates.\n'
              '• To analyze app performance using Firebase and Google Analytics.\n',
            ),
            SizedBox(height: 10),
            Text(
              '3. Data Sharing and Disclosure',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'We do not sell, rent, or trade your personal data. Information may only be shared in the following cases:\n\n'
              '• With your consent: When you choose to share your details publicly.\n'
              '• Service Providers: With trusted third parties such as Firebase, Google Analytics, and Google Cloud Storage.\n'
              '• Legal Requirements: When required by law or to protect our legal rights, users, or the public.\n',
            ),
            SizedBox(height: 10),
            Text(
              '4. Data Retention',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'We retain your personal data as long as your account is active or as needed to provide our services. '
              'You can request deletion of your data or account at any time by contacting us at Oneskyinnovations@gmail.com.\n',
            ),
            SizedBox(height: 10),
            Text(
              '5. User Rights',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '• Access, review, or update your personal information.\n'
              '• Request deletion of your account and data.\n'
              '• Withdraw consent for data processing (may limit app functionality).\n'
              '• Contact us regarding any privacy concerns at Oneskyinnovations@gmail.com.\n',
            ),
            SizedBox(height: 10),
            Text(
              '6. Security of Your Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'We use industry-standard security measures, including encryption and secure authentication. '
              'However, no system can be guaranteed 100% secure, so we recommend using strong passwords and avoiding sharing sensitive details with others.\n',
            ),
            SizedBox(height: 10),
            Text(
              '7. Children’s Privacy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'This app is intended for users aged 18 and above. We do not knowingly collect information from minors. '
              'If such data is collected inadvertently, we will delete it immediately upon discovery.\n',
            ),
            SizedBox(height: 10),
            Text(
              '8. Third-Party Services',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '• Firebase (Google LLC) – for authentication, analytics, and data storage.\n'
              '• Google Analytics – for app performance tracking.\n'
              '• Google Cloud Storage – for storing user-generated content securely.\n',
            ),
            SizedBox(height: 10),
            Text(
              '9. Changes to This Privacy Policy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'We may update this Privacy Policy from time to time. Updates will be reflected with a new “Last updated” date. '
              'Continued use of the app after updates indicates acceptance of the revised policy.\n',
            ),
            SizedBox(height: 10),
            Text(
              '10. Contact Us',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Email: Oneskyinnovations@gmail.com\n'
              'Developer: Onesky Innovations\n'
              'Country: India\n'
              '© 2025 Onesky Innovations. All rights reserved.\n',
            ),
          ],
        ),
      ),
    );
  }
}
