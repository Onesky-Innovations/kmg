import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await _firestore.collection('users').doc(widget.userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _placeController.text = data['place'] ?? '';
      _whatsappController.text = data['whatsappNumber'] ?? '';
    }
    setState(() => isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await _firestore.collection('users').doc(widget.userId).update({
      'name': _nameController.text.trim(),
      'place': _placeController.text.trim(),
      'whatsappNumber': _whatsappController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _placeController,
                      decoration: const InputDecoration(labelText: "Place"),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _whatsappController,
                      decoration: const InputDecoration(
                        labelText: "WhatsApp Number",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
