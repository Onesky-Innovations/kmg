import 'package:flutter/material.dart';
import 'package:kmg/screens/matrimony/matri_screens/matri_submit_screen.dart';

class MatrimonyProfileSecurityPage extends StatefulWidget {
  const MatrimonyProfileSecurityPage({super.key});

  @override
  State<MatrimonyProfileSecurityPage> createState() =>
      _MatrimonyProfileSecurityPageState();
}

class _MatrimonyProfileSecurityPageState
    extends State<MatrimonyProfileSecurityPage> {
  bool isEnglish = false; // false = Malayalam, true = English

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Matrimony Profile Security' : 'വിവാഹ പ്രൊഫൈൽ സുരക്ഷ',
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          Row(
            children: [
              const Text('ML', style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: isEnglish,
                onChanged: (value) {
                  setState(() {
                    isEnglish = value;
                  });
                },
                activeThumbColor: const Color.fromARGB(255, 112, 112, 112),
                inactiveThumbColor: const Color.fromARGB(255, 70, 69, 69),
              ),
              const Text('EN', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Check Section
            Text(
              isEnglish
                  ? 'Matrimony Profile Security 🔒'
                  : 'വിവാഹ പ്രൊഫൈൽ സുരക്ഷ 🔒',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: isEnglish
                        ? 'The Matrimony section contains your most personal and private details related to finding a life partner. '
                              'To ensure maximum security and privacy, we treat this area as a high-security zone. '
                              'The system requires a quick, separate login verification (or a recent re-check) before granting access. '
                              'This acts as a crucial extra security layer, instantly confirming your identity. '
                              'It protects your sensitive matrimonial data from being accessed or modified in the rare event that your general app session is compromised, '
                              'ensuring only you are managing your profile.'
                        : 'നിങ്ങളുടെ ജീവിത പങ്കാളിയെ കണ്ടെത്തുന്നതിനുള്ള ഏറ്റവും വ്യക്തിപരവും സ്വകാര്യവുമായ വിവരങ്ങൾ ഉൾക്കൊള്ളിച്ചിരിക്കുന്നു. '
                              'പരമമായ സുരക്ഷയും സ്വകാര്യതയും ഉറപ്പാക്കുന്നതിനായി, ഈ മേഖലയെ ഉയർന്ന സുരക്ഷാ സോണായി കരുതുന്നു. '
                              'പ്രവേശനത്തിന് മുമ്പ്, സിസ്റ്റം ഒരു വ്യത്യസ്ത ലോഗിൻ പരിശോധന (അഥവാ ഏറ്റവും പുതിയ പരിശോധന) ആവശ്യപ്പെടുന്നു. '
                              'ഇത് ഒരു അത്യന്താപേക്ഷിത അധിക സുരക്ഷാ പാളിയുള്ളതാണ്, നിങ്ങളുടെ തിരിച്ചറിയൽ ഉടൻ സ്ഥിരീകരിക്കുന്നു. '
                              'നിങ്ങൾ മാത്രമേ നിങ്ങളുടെ പ്രൊഫൈൽ നിയന്ത്രിക്കൂ.',
                  ),
                  TextSpan(
                    text: isEnglish
                        ? ' In KMG Matrimony, to securely access and manage your profile, you need a unique username & user ID.'
                        : ' KMG മാട്രിമോണിയിൽ സുരക്ഷിതമായി പ്രവേശിക്കുകയും പ്രൊഫൈൽ നിയന്ത്രിക്കാനും നിങ്ങൾക്ക് യുണിക് യൂസർനെയിം & യൂസർ ഐഡി ആവശ്യമാണ്.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // How to Create Section
            Text(
              isEnglish
                  ? 'How to Create Your New Matrimony Profile'
                  : 'പുതിയ വിവാഹ പ്രൊഫൈൽ എങ്ങനെ സൃഷ്ടിക്കാം',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Step 1
            Card(
              color: Colors.deepPurple[50],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish
                          ? 'Step 1: Initial Basic Information Submission'
                          : 'Step 1: പ്രാഥമിക അടിസ്ഥാന വിവരങ്ങൾ സമർപ്പിക്കൽ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnglish
                          ? '• Click on the "Create New Profile" button.\n'
                                '• Complete the brief form asking for your basic information (e.g., name and contact details).\n'
                                '• Upon submission, your initial data is securely transferred to the KMG Community Team\'s administration desk.'
                          : '• "Create New Profile" ബട്ടൺ അമർത്തുക.\n'
                                '• നിങ്ങളുടെ അടിസ്ഥാന വിവരങ്ങൾ (ഉദാ: പേര്, ബന്ധപ്പെടാനുള്ള വിവരങ്ങൾ) ചേർക്കുന്ന ചെറിയ ഫോം പൂരിപ്പിക്കുക.\n'
                                '• സമർപ്പിച്ചതിന് ശേഷം, നിങ്ങളുടെ പ്രാഥമിക ഡാറ്റ KMG Community ടീമിന്റെ അഡ്മിനിസ്ട്രേഷൻ ഡെസ്കിലേക്ക് സുരക്ഷിതമായി അയയ്ക്കപ്പെടും.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Step 2
            Card(
              color: Colors.deepPurple[50],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish
                          ? 'Step 2: Profile Finalization and Credential Issuance'
                          : 'Step 2: പ്രൊഫൈൽ ഫൈനലൈസേഷൻ & ക്രെഡൻഷ്യൽ ലഭിക്കൽ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnglish
                          ? '• The KMG Community Team will communicate directly with you (via the contact method provided) '
                                'to gather all remaining detailed information and necessary documentation (such as photos, full biodata, etc.).\n'
                                '• Once the KMG Community Team has compiled and validated all details, they will create and activate your final Matrimony Profile.\n'
                                '• You will then be provided with your unique Username and User ID to securely access and manage your profile in the app.'
                          : '• KMG Community ടീം നിങ്ങൾക്കൊപ്പം നേരിട്ട് ബന്ധപ്പെടുകയും (നൽകിയിരിക്കുന്ന കോൺടാക്റ്റ് വഴി) ബാക്കി വിശദ വിവരങ്ങളും ആവശ്യമായ രേഖകളും (ഫോട്ടോകൾ, പൂർണ്ണ ബയോഡാറ്റ തുടങ്ങിയവ) ശേഖരിക്കുകയും ചെയ്യും.\n'
                                '• എല്ലാ വിശദാംശങ്ങളും പരിശോധിച്ച ശേഷം, അവർ നിങ്ങളുടെ അന്തിമ വിവാഹ പ്രൊഫൈൽ സൃഷ്ടിക്കുകയും സജീവമാക്കുകയും ചെയ്യും.\n'
                                '• തുടർന്ന്, ആപ്പിൽ സുരക്ഷിതമായി പ്രവേശിക്കുകയും പ്രൊഫൈൽ നിയന്ത്രിക്കാനും നിങ്ങൾക്ക് യുണിക് യൂസർനെയിം & യൂസർ ഐഡി ലഭിക്കും.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Create Profile Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the profile creation form
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MatriSubmitScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEnglish
                      ? 'Create New Profile'
                      : 'പുതിയ പ്രൊഫൈൽ സൃഷ്ടിക്കുക',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
