import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MatriSubmitScreen extends StatefulWidget {
  const MatriSubmitScreen({super.key, String? loggedInUserId});

  @override
  State<MatriSubmitScreen> createState() => _MatriSubmitScreenState();
}

class _MatriSubmitScreenState extends State<MatriSubmitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _motherTongueController = TextEditingController();
  final _mobileController = TextEditingController();

  // Dropdown value
  String? _selectedProfileFor;

  // Admin WhatsApp number
  final String adminPhone = "919744422238";

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProfileFor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select who you are creating profile for"),
        ),
      );
      return;
    }

    final String message = Uri.encodeComponent(
      "💌 Matrimony Registration\n"
      "👤 Name: ${_nameController.text}\n"
      "📝 Profile For: $_selectedProfileFor\n"
      "🗣 Mother Tongue: ${_motherTongueController.text}\n"
      "📱 Mobile: +91 ${_mobileController.text}",
    );

    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$adminPhone?text=$message",
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("WhatsApp is not available.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _motherTongueController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Register Free",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "We help you find your perfect partner and perfect family",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Name
                _buildTextField(
                  controller: _nameController,
                  labelText: "Name",
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 16),

                // Create Profile For (Dropdown)
                _buildDropdown(),

                const SizedBox(height: 16),

                // Mother Tongue
                _buildTextField(
                  controller: _motherTongueController,
                  labelText: "Mother Tongue",
                  icon: Icons.language,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter mother tongue" : null,
                ),
                const SizedBox(height: 16),

                // Mobile (prefilled +91)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("+91"),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _mobileController,
                        labelText: "Mobile Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty
                            ? "Please enter mobile number"
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Terms & Conditions text
                Text(
                  "By clicking on Register Free, you are agreeing to the Terms & Conditions",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon, color: Colors.pinkAccent),
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final options = [
      "Myself",
      "Daughter",
      "Son",
      "Sister",
      "Brother",
      "Relative",
      "Friend",
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          initialValue: _selectedProfileFor,
          decoration: const InputDecoration(
            labelText: "Create Profile For",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.group, color: Colors.pinkAccent),
          ),
          items: options
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedProfileFor = value);
          },
          validator: (value) => value == null
              ? "Please select who you are creating profile for"
              : null,
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.redAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: _submitForm,
        child: const Text(
          "Register Free & Continue >>",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
