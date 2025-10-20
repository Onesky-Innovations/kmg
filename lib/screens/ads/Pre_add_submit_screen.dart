import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PreAddSubmitScreen extends StatefulWidget {
  const PreAddSubmitScreen({super.key});

  @override
  State<PreAddSubmitScreen> createState() => _AddSubmitScreenState();
}

class _AddSubmitScreenState extends State<PreAddSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Admin WhatsApp number
  final String adminPhone = "919744422238";

  bool showMalayalam = false;

  @override
  void initState() {
    super.initState();
    // Toggle text every 3 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() => showMalayalam = !showMalayalam);
      return true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    final String message = Uri.encodeComponent(
      "📢 New Ad Submission\n"
      "📝 Title: ${_titleController.text}\n"
      "💰 Price: ₹${_priceController.text}\n"
      "📍 Location: ${_locationController.text}\n"
      "📂 Category: ${_categoryController.text}\n"
      "ℹ️ Description: ${_descriptionController.text}",
    );

    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$adminPhone?text=$message",
    );
    final Uri smsUri = Uri.parse("sms:$adminPhone?body=$message");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No app available to send the message."),
          ),
        );
      }

      _titleController.clear();
      _priceController.clear();
      _locationController.clear();
      _categoryController.clear();
      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Submit Your Ad",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Animated English ↔ Malayalam text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    showMalayalam
                        ? "✨ “സബ്മിറ്റ് അമർത്തിയതിന് ശേഷം, നിങ്ങളുടെ ഉൽപ്പന്നത്തിന്റെ ഫോട്ടോകളും വീഡിയോകളും വാട്സ്ആപ്പിൽ പങ്കിടാം!”"
                        : "✨ “Once you hit submit, easily share your product photos & videos with us on WhatsApp!”",
                    key: ValueKey(showMalayalam),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _titleController,
                  labelText: "Ad Title",
                  icon: Icons.title,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a title" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _priceController,
                  labelText: "Price (₹)",
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a price" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  labelText: "Location",
                  icon: Icons.location_on,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a location" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _categoryController,
                  labelText: "Category",
                  icon: Icons.category,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a category" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  labelText: "Description",
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 30),
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Color(0xFF2196F3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 243, 33, 68).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: _submitAd,
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text(
          "Submit via WhatsApp",
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
