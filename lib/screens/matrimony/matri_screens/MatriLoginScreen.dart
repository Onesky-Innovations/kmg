// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class MatriLoginScreen extends StatefulWidget {
//   const MatriLoginScreen({super.key});

//   @override
//   State<MatriLoginScreen> createState() => _MatriLoginScreenState();
// }

// class _MatriLoginScreenState extends State<MatriLoginScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _userIdController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _loading = false;

//   /// ------------------ Helper: Convert Firestore Timestamps ------------------
//   dynamic convertTimestamps(dynamic data) {
//     if (data is Timestamp) {
//       return data.toDate().toIso8601String();
//     } else if (data is Map<String, dynamic>) {
//       return data.map((key, value) => MapEntry(key, convertTimestamps(value)));
//     } else if (data is List) {
//       return data.map((item) => convertTimestamps(item)).toList();
//     } else {
//       return data; // primitives (String, int, bool, etc.)
//     }
//   }

//   /// ------------------------- Login Function -------------------------
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _loading = true;
//     });

//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('matrimony')
//           .where('name', isEqualTo: _nameController.text.trim())
//           .where('userId', isEqualTo: _userIdController.text.trim())
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final userDataRaw = querySnapshot.docs.first.data();

//         // Convert any Timestamp to ISO8601 strings
//         final userData = convertTimestamps(userDataRaw);

//         // Save user locally
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString("loggedInUser", json.encode(userData));

//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Login successful!')));

//         // Return user data to previous screen
//         Navigator.pop(context, userData);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid name or user ID')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _userIdController.dispose();
//     super.dispose();
//   }

//   /// ------------------------- Build UI -------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Matrimony Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Enter your name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _userIdController,
//                 decoration: const InputDecoration(
//                   labelText: 'User ID',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => value == null || value.isEmpty
//                     ? 'Enter your user ID'
//                     : null,
//               ),
//               const SizedBox(height: 24),
//               _loading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _login,
//                       child: const Text('Login'),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kmg/screens/legal/contact_support_screen.dart';
import 'package:kmg/screens/matrimony/matri_screens/MatrimonyProfileSecurityPage.dart';
import 'package:kmg/screens/matrimony/matri_screens/matri_submit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// NOTE: You must have the ThemeProvider and custom themes (lightTheme, darkTheme)
// from your second code block available in your application's MaterialApp/main.dart
// and you should wrap your MatriLoginScreen with a ChangeNotifierProvider
// for ThemeProvider if you want the theme to be dynamic.
// For this single screen, I'm assuming the custom theme is applied globally.

class MatriLoginScreen extends StatefulWidget {
  const MatriLoginScreen({super.key});

  @override
  State<MatriLoginScreen> createState() => _MatriLoginScreenState();
}

class _MatriLoginScreenState extends State<MatriLoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  /// ------------------ Helper: Convert Firestore Timestamps ------------------
  dynamic convertTimestamps(dynamic data) {
    if (data is Timestamp) {
      return data.toDate().toIso8601String();
    } else if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, convertTimestamps(value)));
    } else if (data is List) {
      return data.map((item) => convertTimestamps(item)).toList();
    } else {
      return data; // primitives (String, int, bool, etc.)
    }
  }

  /// ------------------------- Login Function -------------------------
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('matrimony')
          .where('name', isEqualTo: _nameController.text.trim())
          .where('userId', isEqualTo: _userIdController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDataRaw = querySnapshot.docs.first.data();

        // Convert any Timestamp to ISO8601 strings
        final userData = convertTimestamps(userDataRaw);

        // Save user locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("loggedInUser", json.encode(userData));

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));

          // Navigate back and pass user data
          Navigator.pop(context, userData);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid name or user ID')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// ------------------------- Placeholder Navigation -------------------------
  void _navigateToSubmitScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MatriSubmitScreen()),
    );
  }

  void _navigateToContactSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactSupportScreen('general'),
      ),
    );
  }

  void _navigateTomatriSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MatrimonyProfileSecurityPage(),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  /// ------------------------- Build UI -------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Login"),
        // Added Contact Support button to the AppBar's actions
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _navigateTomatriSecurity,
            tooltip: 'Understand Profile Security',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large Icon/Logo for a modern feel
              Icon(Icons.favorite_rounded, size: 80, color: theme.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your Unique Username and User ID\n to continue your search.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // --- Login Form ---
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        hintText: 'Your unique registration ID',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your user ID'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // --- Login Button ---
                    SizedBox(
                      width: double.infinity,
                      child: _loading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: _login,
                              icon: const Icon(Icons.login_rounded),
                              label: const Text(
                                'LOGIN',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Divider for New User/Support Options ---
              const Divider(height: 0),

              const SizedBox(height: 24),

              // --- New Profile and Support Buttons ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Button for MatriSubmitScreen (New Profile Creation)
                  OutlinedButton.icon(
                    onPressed: _navigateToSubmitScreen,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('CREATE NEW PROFILE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button for ContactSupportScreen (Secondary placement)
                  TextButton.icon(
                    onPressed: _navigateToContactSupport,
                    icon: const Icon(Icons.support_agent_rounded, size: 18),
                    label: const Text('NEED HELP? CONTACT SUPPORT'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme
                          .textTheme
                          .bodyMedium
                          ?.color, // Use a subtle color
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
