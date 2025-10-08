import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: October 6, 2025\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Welcome to KMG Classifieds & Matrimony ("we", "our", "us"). '
              'By downloading, accessing, or using our mobile application, you agree to comply with and be bound by these Terms & Conditions. '
              'If you do not agree, please do not use the app.\n\n'
              '1. Eligibility\nOur app is intended for users aged 18 and above. By using the app, you confirm that you meet the minimum age requirement.\n\n'
              '2. User Accounts\nTo access certain features, you must create an account. You agree to provide accurate, current, and complete information and to keep your login credentials confidential. You are responsible for all activity under your account.\n\n'
              '3. User Conduct\nYou must not post content that is illegal, offensive, or violates the rights of others.\nYou agree not to harass, threaten, or harm other users.\nYou must not use the app to distribute spam or unsolicited advertising.\n\n'
              '4. Content and Privacy\nBy posting content on the app, you consent to our Privacy Policy. Content shared publicly may be visible to other users. We are not responsible for content posted by users.\n\n'
              '5. Prohibited Activities\n• Attempting to hack, interfere with, or damage the app or its servers.\n• Collecting or storing personal data of other users without consent.\n• Impersonating another person or entity.\n\n'
              '6. Termination\nWe reserve the right to suspend or terminate your account at our discretion for violation of these terms, illegal activities, or harmful behavior.\n\n'
              '7. Limitation of Liability\nThe app is provided "as is" and "as available" without warranties of any kind. We are not liable for any damages, losses, or claims arising from your use of the app.\n\n'
              '8. Changes to Terms\nWe may update these Terms & Conditions from time to time. Updated terms will be reflected with a new “Last updated” date. Continued use of the app constitutes acceptance of the revised terms.\n\n'
              '9. Governing Law\nThese terms are governed by the laws of India. Any disputes arising in connection with these terms will be subject to the exclusive jurisdiction of courts in India.\n\n'
              '10. Contact Us\nIf you have any questions about these Terms & Conditions, please contact us at:\n\n'
              'Email: Oneskyinnovations@gmail.com\nDeveloper: Onesky Innovations\nCountry: India\n© 2025 Onesky Innovations. All rights reserved.',
            ),
          ],
        ),
      ),
    );
  }
}
