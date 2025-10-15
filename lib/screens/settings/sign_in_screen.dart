import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kmg/screens/legal/contact_support_screen.dart';
import 'sign_up_screen.dart'; // Ensure this path is correct

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required bool fromFab});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  bool isLoading = false;
  bool isPasswordVisible = false;

  bool _showForgotPassword = true;
  bool _isEnglish = true; // true = English, false = Malayalam

  // --- Multi-language mapping ---
  String _getTranslatedText(String key) {
    // Retaining your translation map
    final Map<String, Map<String, String>> translations = {
      'en': {
        'welcome': 'Welcome Back!',
        'subtitle': 'Sign in to access your profile and listings.',
        'email_label': 'Email Address',
        'password_label': 'Password',
        'sign_in': 'SIGN IN',
        'forgot_password': 'Forgot Password?',
        'help': 'Need Help?',
        'create_account': 'CREATE NEW ACCOUNT',
        'reset_title': 'Password Reset Assistance',
        'reset_message_1':
            'If you requested a password reset, check your email:',
        'reset_message_2': '1. Check the Spam or Junk folder.',
        'reset_message_3': '2. Wait 5 minutes for delivery.',
        'reset_message_4': '3. Ensure you entered the correct email.',
        'reset_contact': 'Still need help? Contact Support.',
        'reset_done': 'I Checked, Done',
        'email_reset_sent':
            "Password reset email sent to $email. Check your inbox!",
        'email_validation': "Please enter your email to reset the password.",
        'sign_in_failed': "Sign in failed",
        'welcome_back': "Welcome back! 👋",
      },
      'ml': {
        'welcome': 'തിരികെ സ്വാഗതം!',
        'subtitle':
            'നിങ്ങളുടെ പ്രൊഫൈലും ലിസ്റ്റിംഗുകളും ആക്‌സസ് ചെയ്യാൻ സൈൻ ഇൻ ചെയ്യുക.',
        'email_label': 'ഇമെയിൽ വിലാസം',
        'password_label': 'പാസ്‌വേർഡ്',
        'sign_in': 'സൈൻ ഇൻ ചെയ്യുക',
        'forgot_password': 'പാസ്‌വേർഡ് മറന്നുപോയോ?',
        'help': 'സഹായം വേണോ?',
        'create_account': 'പുതിയ അക്കൗണ്ട് സൃഷ്ടിക്കുക',
        'reset_title': 'പാസ്‌വേർഡ് റീസെറ്റ് സഹായം',
        'reset_message_1':
            'നിങ്ങൾ ഒരു പാസ്‌വേർഡ് റീസെറ്റിനായി അഭ്യർത്ഥിച്ചിട്ടുണ്ടെങ്കിൽ, നിങ്ങളുടെ ഇമെയിൽ പരിശോധിക്കുക:',
        'reset_message_2': '1. സ്പാം അല്ലെങ്കിൽ ജങ്ക് ഫോൾഡർ പരിശോധിക്കുക.',
        'reset_message_3': '2. ഇമെയിൽ എത്താൻ 5 മിനിറ്റ് കാത്തിരിക്കുക.',
        'reset_message_4': '3. ശരിയായ ഇമെയിൽ നൽകിയിട്ടുണ്ടെന്ന് ഉറപ്പാക്കുക.',
        'reset_contact': 'ഇനിയും സഹായം വേണമെങ്കിൽ? സപ്പോർട്ടുമായി ബന്ധപ്പെടുക.',
        'reset_done': 'ഞാൻ പരിശോധിച്ചു, ശരിയായി',
        'email_reset_sent':
            "പാസ്‌വേർഡ് റീസെറ്റ് ഇമെയിൽ $email-ലേക്ക് അയച്ചു. നിങ്ങളുടെ ഇൻബോക്സ് പരിശോധിക്കുക!",
        'email_validation':
            "പാസ്‌വേർഡ് റീസെറ്റ് ചെയ്യാൻ നിങ്ങളുടെ ഇമെയിൽ നൽകുക.",
        'sign_in_failed': "സൈൻ ഇൻ പരാജയപ്പെട്ടു",
        'welcome_back': "തിരികെ സ്വാഗതം! 👋",
      },
    };
    final langKey = _isEnglish ? 'en' : 'ml';
    return translations[langKey]![key] ?? translations['en']![key]!;
  }

  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      bool isAdmin = doc.exists ? doc.data()!['admin'] == true : false;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedText('welcome_back'))),
      );

      Navigator.pop(context, {'signedIn': true, 'isAdmin': isAdmin});
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        setState(() {
          _showForgotPassword = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? _getTranslatedText('sign_in_failed')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _forgotPassword() async {
    _formKey.currentState!.save();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedText('email_validation'))),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getTranslatedText('email_reset_sent'))),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Failed to send reset email.")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showEmailHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_getTranslatedText('reset_title')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getTranslatedText('reset_message_1')),
                const SizedBox(height: 10),
                Text(_getTranslatedText('reset_message_2')), // Check Spam
                Text(_getTranslatedText('reset_message_3')), // Wait
                Text(_getTranslatedText('reset_message_4')), // Correct Email
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Navigate to Contact Us Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ContactSupportScreen('password_reset'),
                      ),
                    );
                  },
                  child: Text(_getTranslatedText('reset_contact')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_getTranslatedText('reset_done')),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen(fromFab: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslatedText('sign_in')),
        actions: [
          // Language Toggle Button
          TextButton(
            onPressed: _toggleLanguage,
            child: Text(
              _isEnglish ? 'മലയാളം' : 'English',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTranslatedText('welcome'),
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: primaryColor,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTranslatedText('subtitle'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // --- Email Field ---
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: _getTranslatedText('email_label'),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: primaryColor,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => email = val!.trim(),
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),

                        // --- Password Field ---
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: _getTranslatedText('password_label'),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: primaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: theme.textTheme.bodyMedium!.color,
                              ),
                              onPressed: () {
                                setState(
                                  () => isPasswordVisible = !isPasswordVisible,
                                );
                              },
                            ),
                          ),
                          obscureText: !isPasswordVisible,
                          onSaved: (val) => password = val!.trim(),
                          style: theme.textTheme.bodyLarge,
                        ),

                        const SizedBox(height: 10),

                        // --- FIX APPLIED HERE: Using FittedBox to prevent text overflow in Row ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 1. The Help/Sahaayam icon (Left side)
                            FittedBox(
                              // Ensures the long Malayalam text scales down to fit
                              child: TextButton.icon(
                                onPressed: _showEmailHelpDialog,
                                icon: Icon(
                                  Icons.help_outline,
                                  color: primaryColor,
                                  size: 18,
                                ),
                                label: Text(
                                  _getTranslatedText('help'),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _forgotPassword,
                              child: Text(
                                _getTranslatedText('forgot_password'),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // --- END FIX ---
                        const SizedBox(height: 20),

                        // --- Sign In Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            child: Text(_getTranslatedText('sign_in')),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- Divider and Sign Up ---
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: theme.textTheme.bodyMedium!.color,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                "OR",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: theme.textTheme.bodyMedium!.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _navigateToSignUp,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _getTranslatedText('create_account'),
                              style: TextStyle(color: primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
