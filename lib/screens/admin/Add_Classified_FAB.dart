import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddClassifiedFAB extends StatefulWidget {
  final String userId;
  final String? adId; // If null → Add, else → Edit

  const AddClassifiedFAB({
    super.key,
    required this.userId,
    this.adId,
    required String type,
  });

  @override
  State<AddClassifiedFAB> createState() => _AddClassifiedFABState();
}

class _AddClassifiedFABState extends State<AddClassifiedFAB> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _condition = "Used";
  bool _isFeatured = false;
  int _durationDays = 30;
  bool _isLoading = false;
  final List<XFile> _images = [];
  List<String> _existingImages = [];

  Timestamp? _existingCreatedAt;
  DateTime? _existingExpiryDate;

  /// Predefined categories
  List<String> categories = [
    "Electronics",
    "Vehicles",
    "Real Estate",
    "Jobs",
    "Home & Garden",
    "Services",
    "Fashion",
    "Sports",
    "Books",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.adId != null) _loadAdData();
  }

  Future<void> _loadAdData() async {
    final doc = await FirebaseFirestore.instance
        .collection("classifieds")
        .doc(widget.adId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    setState(() {
      _titleController.text = data['title'] ?? '';
      _descController.text = data['description'] ?? '';
      _categoryController.text = data['category'] ?? '';
      _placeController.text = data['place'] ?? '';
      _contactController.text = data['contact'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _condition = data['condition'] ?? 'Used';
      _durationDays = data['durationDays'] ?? 30;
      _isFeatured = data['isFeatured'] ?? false;
      _existingImages = List<String>.from(data['images'] ?? []);
      _existingExpiryDate = data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null;
      _existingCreatedAt = data['createdAt'];
    });

    // ensure loaded category is in dropdown
    if (_categoryController.text.isNotEmpty &&
        !categories.contains(_categoryController.text)) {
      categories.add(_categoryController.text);
    }
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    if (_images.length + _existingImages.length + picked.length > 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maximum 3 images allowed")));
      return;
    }
    setState(() => _images.addAll(picked));
  }

  Future<List<String>> _uploadImages(String adId) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [..._existingImages];
    final folder = 'classifieds';

    for (var img in _images) {
      final file = File(img.path);
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = storage.ref().child('$folder/$adId/$fileName');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final adRef = widget.adId != null
          ? FirebaseFirestore.instance
                .collection("classifieds")
                .doc(widget.adId)
          : FirebaseFirestore.instance.collection("classifieds").doc();

      final adId = adRef.id;
      final imageUrls = await _uploadImages(adId);

      final adData = {
        "id": adId,
        "userId": widget.userId,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "category": _categoryController.text.trim(),
        "place": _placeController.text.trim(),
        "condition": _condition,
        "contact": _contactController.text.trim(),
        "price": _priceController.text.trim().isNotEmpty
            ? double.tryParse(_priceController.text.trim())
            : null,
        "durationDays": _durationDays,
        "expiryDate": widget.adId != null
            ? _existingExpiryDate ??
                  DateTime.now().add(Duration(days: _durationDays))
            : DateTime.now().add(Duration(days: _durationDays)),
        "isFeatured": _isFeatured,
        "images": imageUrls,
        "status": "Active",
        "createdAt": widget.adId != null
            ? _existingCreatedAt ?? FieldValue.serverTimestamp()
            : FieldValue.serverTimestamp(),
      };

      await adRef.set(adData, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.adId != null ? "Ad updated!" : "Ad submitted!"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving ad: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// show dialog to add new category
  void _addNewCategory() {
    final newCatController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: newCatController,
          decoration: const InputDecoration(hintText: "Enter category name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newCat = newCatController.text.trim();
              if (newCat.isNotEmpty) {
                setState(() {
                  if (!categories.contains(newCat)) {
                    categories.add(newCat);
                  }
                  _categoryController.text = newCat;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _placeController.dispose();
    _contactController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.adId != null ? "Edit Classified Ad" : "Add Classified Ad",
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // User ID
                    TextFormField(
                      initialValue: widget.userId,
                      decoration: const InputDecoration(labelText: "User ID"),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Title *"),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Title required"
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: "Description *",
                      ),
                      maxLines: 4,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Description required"
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Category Dropdown + add new button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _categoryController.text.isNotEmpty
                                ? _categoryController.text
                                : null,
                            decoration: const InputDecoration(
                              labelText: "Category *",
                            ),
                            items: categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _categoryController.text = val ?? "";
                              });
                            },
                            validator: (val) => val == null || val.isEmpty
                                ? "Please select a category"
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addNewCategory,
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: "Add new category",
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Place
                    TextFormField(
                      controller: _placeController,
                      decoration: const InputDecoration(labelText: "Place"),
                    ),
                    const SizedBox(height: 12),

                    // Contact
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: "Contact"),
                    ),
                    const SizedBox(height: 12),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Condition Dropdown
                    DropdownButtonFormField<String>(
                      value: _condition,
                      items: ["New", "Used"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _condition = val!),
                      decoration: const InputDecoration(labelText: "Condition"),
                    ),
                    const SizedBox(height: 12),

                    // Featured toggle
                    SwitchListTile(
                      value: _isFeatured,
                      onChanged: (val) => setState(() => _isFeatured = val),
                      title: const Text("Featured"),
                    ),
                    const SizedBox(height: 12),

                    // Duration
                    TextFormField(
                      initialValue: _durationDays.toString(),
                      decoration: const InputDecoration(
                        labelText: "Duration Days",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) =>
                          _durationDays = int.tryParse(val) ?? 30,
                    ),
                    const SizedBox(height: 12),

                    // Image picker
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text("Pick Images"),
                    ),
                    const SizedBox(height: 12),

                    // Image preview
                    if (_existingImages.isNotEmpty || _images.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._existingImages.map(
                              (url) => Padding(
                                padding: const EdgeInsets.all(4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            ..._images.map(
                              (file) => Padding(
                                padding: const EdgeInsets.all(4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(file.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitAd,
                        child: Text(
                          widget.adId != null ? "Update Ad" : "Submit Ad",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
