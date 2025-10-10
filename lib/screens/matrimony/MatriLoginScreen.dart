import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        // Return user data to previous screen
        Navigator.pop(context, userData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid name or user ID')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
    return Scaffold(
      appBar: AppBar(title: const Text("Matrimony Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your user ID'
                    : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
