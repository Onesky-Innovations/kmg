import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required bool fromFab});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String name = '';
  String place = '';
  String email = '';
  String whatsapp = '';
  String password = '';
  String rePassword = '';
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isRePasswordVisible = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (password != rePassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'place': place,
        'email': email,
        'whatsappNumber': whatsapp,
        'profilePhoto': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'admin': false,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome, $name! Account created successfully."),
        ),
      );

      // Pop and return success flag (true) to indicate successful sign-up
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Signup failed")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Join the Community!",
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fill in your details to create your profile.",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // --- Name ---
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: primaryColor,
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          onSaved: (val) => name = val!.trim(),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Please enter your name'
                              : null,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),

                        // --- Place ---
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Your Place/City',
                            prefixIcon: Icon(
                              Icons.location_city_outlined,
                              color: primaryColor,
                            ),
                          ),
                          onSaved: (val) => place = val!.trim(),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Please enter your location'
                              : null,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),

                        // --- Email ---
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: primaryColor,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => email = val!.trim(),
                          validator: (val) => val == null || !val.contains('@')
                              ? 'Enter a valid email address'
                              : null,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),

                        // --- WhatsApp Number ---
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'WhatsApp Number',
                            prefixIcon: Icon(
                              Icons.phone_android,
                              color: primaryColor,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          onSaved: (val) => whatsapp = val!.trim(),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Enter WhatsApp number'
                              : null,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),

                        // --- Password ---
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
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
                          validator: (val) => val == null || val.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),

                        // --- Re-enter Password ---
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(
                              Icons.lock_open_outlined,
                              color: primaryColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isRePasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: theme.textTheme.bodyMedium!.color,
                              ),
                              onPressed: () {
                                setState(
                                  () => isRePasswordVisible =
                                      !isRePasswordVisible,
                                );
                              },
                            ),
                          ),
                          obscureText: !isRePasswordVisible,
                          onSaved: (val) => rePassword = val!.trim(),
                          validator: (val) => val == null || val.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 40),

                        // --- Sign Up Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _signUp,
                            // Styles are inherited from the theme's ElevatedButtonThemeData
                            child: const Text("SIGN UP"),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- Back to Sign In Link ---
                        TextButton(
                          onPressed: () {
                            // Pop the current SignUpScreen to go back to the SignInScreen
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Already have an account? Sign In",
                            style: TextStyle(color: primaryColor),
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
