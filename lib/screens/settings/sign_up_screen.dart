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
      // 1️⃣ Create Firebase Auth user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // 2️⃣ Save user data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'place': place,
        'email': email,
        'whatsappNumber': whatsapp,
        'profilePhoto': '', // Default empty, can upload later
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );

      Navigator.pop(context, true); // Return success to ProfileScreen
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Signup failed")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      onSaved: (val) => name = val!.trim(),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter name' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Place'),
                      onSaved: (val) => place = val!.trim(),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter place' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) => email = val!.trim(),
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Enter valid email'
                          : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp Number',
                      ),
                      keyboardType: TextInputType.phone,
                      onSaved: (val) => whatsapp = val!.trim(),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter WhatsApp' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (val) => password = val!.trim(),
                      validator: (val) =>
                          val == null || val.length < 6 ? 'Min 6 chars' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Re-enter Password',
                      ),
                      obscureText: true,
                      onSaved: (val) => rePassword = val!.trim(),
                      validator: (val) =>
                          val == null || val.length < 6 ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
