import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddClassifiedFAB extends StatefulWidget {
  final String type; // Normal / Banner
  final String userId; // Passed from admin selection dialog
  const AddClassifiedFAB({super.key, required this.type, required this.userId});

  @override
  State<AddClassifiedFAB> createState() => _AddClassifiedFABState();
}

class _AddClassifiedFABState extends State<AddClassifiedFAB> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _category;
  List<String> _categories = ["Land", "Used Vehicles", "Electronics"];
  bool _isFeatured = false;
  int _durationDays = 7;
  bool _isLoading = false;

  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  // Pick images (max 3)
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles != null) {
      if (_images.length + pickedFiles.length > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maximum 3 images allowed")),
        );
        return;
      }
      setState(() => _images.addAll(pickedFiles));
    }
  }

  // Upload images to Firebase Storage
  Future<List<String>> _uploadImages(String adId) async {
    List<String> urls = [];
    for (var img in _images) {
      File file = File(img.path);
      final ref = _storage.ref().child('classifieds/$adId/${img.name}');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  // Submit Ad
  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adRef = _firestore.collection('classifieds').doc();
      final adId = adRef.id;

      // Upload images
      List<String> imageUrls = await _uploadImages(adId);

      final adData = {
        "id": adId,
        "type": widget.type,
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "category": _category,
        "place": _placeController.text.trim(),
        "condition": _conditionController.text.trim(),
        "contact": _contactController.text.trim(),
        "price": _priceController.text.trim(),
        "durationDays": _durationDays,
        "isFeatured": _isFeatured,
        "images": imageUrls,
        "status": "Active",
        "userId": widget.userId,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await adRef.set(adData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ad submitted successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Add new category
  void _addNewCategory() {
    final _newCatController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: _newCatController,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newCat = _newCatController.text.trim();
              if (newCat.isNotEmpty) {
                setState(() {
                  _categories.add(newCat);
                  _category = newCat;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add ${widget.type} Ad")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Images
                    Row(
                      children: [
                        ..._images.map((img) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.file(
                                File(img.path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )),
                        if (_images.length < 3)
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.add_a_photo),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Title *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty ? "Title is required" : null,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description *",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (val) => val == null || val.isEmpty ? "Description is required" : null,
                    ),
                    const SizedBox(height: 12),

                    // Category
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            hint: const Text("Select Category *"),
                            items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (val) => setState(() => _category = val),
                            validator: (val) => val == null || val.isEmpty ? "Category required" : null,
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.add), onPressed: _addNewCategory),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Contact
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: "WhatsApp / Contact *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty ? "Contact required" : null,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // Optional fields
                    TextFormField(
                      controller: _placeController,
                      decoration: const InputDecoration(
                        labelText: "Place",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _conditionController,
                      decoration: const InputDecoration(
                        labelText: "Condition",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: "Price",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Duration
                    Row(
                      children: [
                        const Text("Duration (days): "),
                        DropdownButton<int>(
                          value: _durationDays,
                          items: [7, 15, 30].map((e) => DropdownMenuItem(value: e, child: Text("$e"))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _durationDays = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Featured
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Featured Ad"),
                        Switch(value: _isFeatured, onChanged: (val) => setState(() => _isFeatured = val)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitAd,
                        child: const Text("Submit Ad"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
