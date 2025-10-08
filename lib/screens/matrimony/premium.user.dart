// lib/screens/ads/premium.user.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumUserScreen extends StatefulWidget {
  const PremiumUserScreen({super.key});

  @override
  State<PremiumUserScreen> createState() => _PremiumUserScreenState();
}

class _PremiumUserScreenState extends State<PremiumUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  bool _isSubmitting = false;

  // Added: Icon tap action
  void _onInfoTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap to view premium benefits! (Feature coming soon)'),
      ),
    );
  }

  Future<void> _submitPremium() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String userId = _userIdController.text.trim();
      final String name = _nameController.text.trim();

      // 1. Check if the user exists in the 'matrimony' listings
      final matrimonyQuerySnapshot = await FirebaseFirestore.instance
          .collection('matrimony') // Assuming 'matrimony' is the collection name for listings
          .where('userId', isEqualTo: userId)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (matrimonyQuerySnapshot.docs.isEmpty) {
        // User does not exist in matrimony profiles
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: User ID and Name combination not found in matrimony profiles.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. If user exists in matrimony, proceed to enroll them as a premium user.
      // The existence in this 'premium_users' collection now implicitly means premium.
      await FirebaseFirestore.instance.collection('premium_users').doc(userId).set({
        'name': name,
        'userId': userId,
        'profileId': matrimonyQuerySnapshot.docs.first.id,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // 3. Update the local logged-in user state to reflect premium status immediately (if logged in)
      // This is a placeholder since we don't have direct access to MatrimonyScreen's logic here.
      // We rely on MatrimonyScreen's _loadLoggedInUser logic to fetch this status.
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Premium enrollment successful!')),
      );

      // Close the page after successful signup
      Navigator.pop(context, {'userId': userId, 'name': name, 'premium': true}); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Access'),
        // ADDED: Icon on top right
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_outlined), // Using a relevant icon
            onPressed: _onInfoTap,
            tooltip: 'Premium Info',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (Must match your Matrimony Profile)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID (Must match your Matrimony Profile)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter your user ID' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPremium,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Activate Premium'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}