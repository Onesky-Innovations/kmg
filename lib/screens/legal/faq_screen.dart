import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int? openIndex;

  final List<Map<String, String>> faqList = [
    {
      "question": "1. What is KMG Classifieds & Matrimony?",
      "answer":
          "KMG Classifieds & Matrimony is a platform that allows users to post, browse, and connect for classifieds listings and matrimony profiles in a safe and user-friendly environment.",
    },
    {
      "question": "2. How do I create an account?",
      "answer":
          "You can create an account using your email and password. Provide accurate information such as name, age, and contact details.",
    },
    {
      "question": "3. How can I delete my account?",
      "answer":
          "You can request account deletion via the app by navigating to Settings → Account → Delete Account. Once processed, all your personal data, messages, and media will be permanently removed. For any issues, contact us at Oneskyinnovations@gmail.com.",
    },
    {
      "question": "4. Who can see my information?",
      "answer":
          "Your personal information is private by default. It is only visible if you choose to share it in a public listing or profile. Chats and messages are private between participants.",
    },
    {
      "question": "5. Is my data secure?",
      "answer":
          "We use Firebase, Google Cloud Storage, and Google Analytics to securely store and manage your data. Use a strong password and avoid sharing login details.",
    },
    {
      "question": "6. How can I contact support?",
      "answer":
          "For account issues, technical problems, or general inquiries, email us at Oneskyinnovations@gmail.com. We aim to respond within 24 hours.",
    },
    {
      "question": "7. Are there age restrictions?",
      "answer":
          "Yes. Users must be 18 years or older. Accounts found underage will be deleted immediately.",
    },
    {
      "question": "8. Safety tips for users",
      "answer":
          "- Avoid sharing personal information like bank details or passwords.\n- Report suspicious activity immediately.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Header ---
            Column(
              children: const [
                Text(
                  "Frequently Asked Questions (FAQ)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4A148C),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Find answers to common questions about KMG Classifieds & Matrimony. Tap on each question to view the answer.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
                SizedBox(height: 25),
              ],
            ),

            // --- FAQ Items ---
            ...List.generate(faqList.length, (index) {
              final faq = faqList[index];
              final isOpen = openIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      openIndex = isOpen ? null : index;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Question ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 25,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xFFF0E4FF)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                faq["question"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A148C),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              isOpen
                                  ? Icons.remove_circle_outline
                                  : Icons.add_circle_outline,
                              color: const Color(0xFF4A148C),
                            ),
                          ],
                        ),
                      ),

                      // --- Answer ---
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        firstChild: const SizedBox.shrink(),
                        secondChild: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          color: Colors.white,
                          child: Text(
                            faq["answer"]!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                        crossFadeState: isOpen
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
