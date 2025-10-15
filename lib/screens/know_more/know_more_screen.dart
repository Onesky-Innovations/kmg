import 'package:flutter/material.dart';

class KnowMoreScreen extends StatefulWidget {
  const KnowMoreScreen({super.key});

  @override
  State<KnowMoreScreen> createState() => _KnowMoreScreenState();
}

class _KnowMoreScreenState extends State<KnowMoreScreen> {
  // Default language is English
  bool _isEnglish = true;

  // English Content
  final String _englishTitle = "About KMG - Kerala's Community Hub";
  final String _englishContent =
      "Welcome to the official mobile app of Kerala’s leading community group – KMG!\n\n"
      "The KMG App is designed to bring our community closer together by offering a single, easy-to-use platform for both local classifieds and matrimony services.\n\n"
      "In the Classifieds section, users can browse local listings, contact sellers directly, and submit their own ads to reach people across Kerala. From household items and vehicles to services and offers, you can find everything nearby. Once an item is sold, it can be marked as sold so others know it’s no longer available.\n\n"
      "The Matrimony section of the KMG App helps members find genuine life partners within the community. Users can create detailed matrimony profiles, explore suitable matches, and connect safely through verified channels. Each profile is reviewed to maintain authenticity, privacy, and cultural values. For privacy and authenticity, detailed information about each matrimony post is accessible only to verified members who hold a valid Matrimony ID, ensuring a trusted and secure experience for all users. KMG Matrimony makes it easier for families and individuals to meet compatible matches in a respectful, secure, and community-based environment.\n\n"
      "With KMG, you’re not just browsing listings or profiles — you’re becoming part of a trusted Kerala network that values connection, security, and community growth.\n\n"
      "Join the KMG App today and experience Kerala’s trusted space to connect, share, and find your future.";

  // Malayalam Content (Translation of the above)
  final String _malayalamTitle =
      "കെ.എം.ജി.യെക്കുറിച്ച് - കേരളത്തിന്റെ കമ്യൂണിറ്റി ഹബ്";
  final String _malayalamContent =
      "കേരളത്തിലെ പ്രമുഖ കമ്യൂണിറ്റി ഗ്രൂപ്പായ കെ.എം.ജി-യുടെ ഔദ്യോഗിക മൊബൈൽ ആപ്പിലേക്ക് സ്വാഗതം!\n\n"
      "പ്രാദേശിക ക്ലാസിഫൈഡുകൾക്കും വിവാഹ സേവനങ്ങൾക്കുമായി ഒരൊറ്റ, ഉപയോഗിക്കാൻ എളുപ്പമുള്ള പ്ലാറ്റ്‌ഫോം നൽകി ഞങ്ങളുടെ സമൂഹത്തെ കൂടുതൽ അടുപ്പിക്കാൻ വേണ്ടിയാണ് കെ.എം.ജി ആപ്പ് രൂപകൽപ്പന ചെയ്തിരിക്കുന്നത്.\n\n"
      "ക്ലാസിഫൈഡ്സ് വിഭാഗത്തിൽ, ഉപയോക്താക്കൾക്ക് പ്രാദേശിക ലിസ്റ്റിംഗുകൾ ബ്രൗസ് ചെയ്യാനും, വിൽപ്പനക്കാരുമായി നേരിട്ട് ബന്ധപ്പെടാനും, കേരളത്തിലുടനീളമുള്ള ആളുകളിലേക്ക് എത്താൻ സ്വന്തമായി പരസ്യങ്ങൾ നൽകാനും കഴിയും. വീട്ടുപകരണങ്ങളും വാഹനങ്ങളും മുതൽ സേവനങ്ങളും ഓഫറുകളും വരെ നിങ്ങൾക്ക് സമീപത്ത് എല്ലാം കണ്ടെത്താനാകും. ഒരു സാധനം വിറ്റുപോയാൽ, അത് 'വിറ്റത്' എന്ന് അടയാളപ്പെടുത്താൻ സാധിക്കും, അങ്ങനെ മറ്റുള്ളവർക്ക് അത് ലഭ്യമല്ലെന്ന് മനസ്സിലാക്കാം.\n\n"
      "കെ.എം.ജി. ആപ്പിന്റെ മാട്രിമോണി വിഭാഗം, സമൂഹത്തിനുള്ളിൽ യഥാർത്ഥ ജീവിത പങ്കാളികളെ കണ്ടെത്താൻ അംഗങ്ങളെ സഹായിക്കുന്നു. ഉപയോക്താക്കൾക്ക് വിശദമായ മാട്രിമോണി പ്രൊഫൈലുകൾ സൃഷ്ടിക്കാനും, അനുയോജ്യമായ പൊരുത്തങ്ങൾ കണ്ടെത്താനും, വെരിഫൈ ചെയ്ത ചാനലുകളിലൂടെ സുരക്ഷിതമായി ബന്ധപ്പെടാനും കഴിയും. ആധികാരികതയും സ്വകാര്യതയും സാംസ്കാരിക മൂല്യങ്ങളും നിലനിർത്തുന്നതിനായി ഓരോ പ്രൊഫൈലും അവലോകനം ചെയ്യുന്നു. സ്വകാര്യതയ്ക്കും ആധികാരികതയ്ക്കുമായി, ഓരോ മാട്രിമോണി പോസ്റ്റിനെക്കുറിച്ചുള്ള വിശദമായ വിവരങ്ങളും ഒരു സാധുതയുള്ള മാട്രിമോണി ഐഡി കൈവശമുള്ള വെരിഫൈഡ് അംഗങ്ങൾക്ക് മാത്രമേ ലഭ്യമാകൂ, ഇത് എല്ലാ ഉപയോക്താക്കൾക്കും വിശ്വസ്തവും സുരക്ഷിതവുമായ അനുഭവം ഉറപ്പാക്കുന്നു. മാട്രിമോണി വിഭാഗം ബഹുമാനവും സുരക്ഷിതത്വവും സമൂഹത്തെ അടിസ്ഥാനമാക്കിയുള്ളതുമായ ഒരന്തരീക്ഷത്തിൽ അനുയോജ്യമായ പങ്കാളികളെ കണ്ടുമുട്ടാൻ കുടുംബങ്ങൾക്കും വ്യക്തികൾക്കും എളുപ്പമാക്കുന്നു.\n\n"
      "കെ.എം.ജി-യിൽ, നിങ്ങൾ ലിസ്റ്റിംഗുകളോ പ്രൊഫൈലുകളോ ബ്രൗസ് ചെയ്യുക മാത്രമല്ല - കണക്ഷനും, സുരക്ഷയ്ക്കും, സാമൂഹിക വളർച്ചയ്ക്കും പ്രാധാന്യം നൽകുന്ന ഒരു വിശ്വസ്ത കേരള നെറ്റ്‌വർക്കിന്റെ ഭാഗമാവുകയാണ്.\n\n"
      "ഇന്ന് തന്നെ കെ.എം.ജി ആപ്പിൽ ചേരുക, ബന്ധപ്പെടാനും, പങ്കുവെക്കാനും, നിങ്ങളുടെ ഭാവി കണ്ടെത്താനുമുള്ള കേരളത്തിന്റെ വിശ്വസ്തമായ ഇടം അനുഭവിക്കുക.";

  // A simple function to toggle the language state
  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEnglish
              ? "Know More"
              : "കൂടുതൽ അറിയുക", // Updated title based on language
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 2,
        actions: [
          // Language Switch Button
          TextButton(
            onPressed: _toggleLanguage,
            child: Text(
              _isEnglish
                  ? "മലയാളം"
                  : "English", // Text shows the language to switch TO
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 20),
            Text(
              _isEnglish ? _englishTitle : _malayalamTitle, // Dynamic Title
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _isEnglish
                  ? _englishContent
                  : _malayalamContent, // Dynamic Content
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: Text(
                _isEnglish ? "Back" : "തിരികെ", // Dynamic 'Back' text
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
