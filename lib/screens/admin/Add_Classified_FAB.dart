import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddClassifiedFAB extends StatefulWidget {
  final String? adId; // null = Add, not null = Edit
  final String type; // "banner" or "normal"
  final String? adOwnerId; // if editing an existing ad

  const AddClassifiedFAB({
    super.key,
    this.adId,
    this.adOwnerId,
    required this.type,
    required userId,
  });

  @override
  State<AddClassifiedFAB> createState() => _AddClassifiedFABState();
}

class _AddClassifiedFABState extends State<AddClassifiedFAB> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _condition = "Used";
  String _soldStatus = "unsold";
  bool _isFeatured = false;
  bool _isLoading = false;
  int _durationDays = 30;

  String _adOwnerUserId = '';
  String _adOwnerName = 'Select a user';

  final List<XFile> _images = [];
  List<String> _existingImages = [];

  Timestamp? _existingCreatedAt;
  DateTime? _existingExpiryDate;

  final List<String> categories = [
    "Electronics",
    "Vehicles",
    "Real Estate",
    "Jobs",
    "Farm",
    "Services",
    "Fashion",
    "Sports",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.adId != null && widget.adOwnerId != null) {
      _adOwnerUserId = widget.adOwnerId!;
      _loadAdData();
    }
  }

  Future<void> _loadAdData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adOwnerId)
          .collection('classifieds')
          .doc(widget.adId)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Ad not found.")));
        return;
      }

      final data = doc.data()!;
      setState(() {
        _titleController.text = data['title'] ?? '';
        _descController.text = data['description'] ?? '';
        _categoryController.text = data['category'] ?? '';
        _placeController.text = data['place'] ?? '';
        _contactController.text = data['contact'] ?? '';
        _priceController.text = data['price']?.toString() ?? '';
        _condition = data['condition'] ?? 'Used';
        _soldStatus = data['soldStatus'] ?? 'unsold';
        _isFeatured = data['isFeatured'] ?? false;
        _durationDays = data['durationDays'] ?? 30;
        _existingImages = List<String>.from(data['images'] ?? []);
        _existingCreatedAt = data['createdAt'];
        _existingExpiryDate = data['expiryDate'] != null
            ? (data['expiryDate'] as Timestamp).toDate()
            : null;
        _adOwnerName = 'Existing User';
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading ad: $e")));
    }
  }

  Future<void> _searchUserByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final user = query.docs.first;
        setState(() {
          _adOwnerUserId = user.id;
          _adOwnerName = user.data()['name'] ?? 'User';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User found: $_adOwnerName")));
      } else {
        setState(() {
          _adOwnerUserId = '';
          _adOwnerName = 'User not found';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not found")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    if (_images.length + _existingImages.length + picked.length > 3) {
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

    final folderPath = 'users/$_adOwnerUserId/classifieds/$adId';
    for (var img in _images) {
      final file = File(img.path);
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = storage.ref().child('$folderPath/$fileName');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    if (_adOwnerUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a user first.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_adOwnerUserId);
      final adRef = widget.adId != null
          ? userRef.collection('classifieds').doc(widget.adId)
          : userRef.collection('classifieds').doc();
      final adId = adRef.id;

      final imageUrls = await _uploadImages(adId);

      final adData = {
        "id": adId,
        "type": widget.type,
        "userId": _adOwnerUserId,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "category": _categoryController.text.trim(),
        "place": _placeController.text.trim(),
        "contact": _contactController.text.trim(),
        "condition": _condition,
        "soldStatus": _soldStatus,
        "price": _priceController.text.trim().isNotEmpty
            ? double.tryParse(_priceController.text.trim())
            : null,
        "isFeatured": _isFeatured,
        "durationDays": _durationDays,
        "expiryDate": Timestamp.fromDate(
          widget.adId != null
              ? _existingExpiryDate ??
                    DateTime.now().add(Duration(days: _durationDays))
              : DateTime.now().add(Duration(days: _durationDays)),
        ),
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
          content: Text(
            widget.adId != null
                ? "Ad updated successfully!"
                : "Ad created successfully!",
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving ad: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.adId != null ? "Edit Classified" : "Add Classified"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email search
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Search user by email",
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _searchUserByEmail,
                      child: const Text("Load User"),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Posting as: $_adOwnerName",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 32),

                    // Title, Description
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Title *"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: "Description *",
                      ),
                      maxLines: 4,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),

                    // Category dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _categoryController.text.isNotEmpty
                          ? _categoryController.text
                          : null,
                      items: categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _categoryController.text = val ?? ""),
                      decoration: const InputDecoration(
                        labelText: "Category *",
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Select category" : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _placeController,
                      decoration: const InputDecoration(labelText: "Place"),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: "Contact"),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Condition and sold status
                    DropdownButtonFormField<String>(
                      initialValue: _condition,
                      items: ["New", "Used"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _condition = val!),
                      decoration: const InputDecoration(labelText: "Condition"),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _soldStatus,
                      items: ["unsold", "sold"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _soldStatus = val!),
                      decoration: const InputDecoration(
                        labelText: "Sold Status",
                      ),
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      value: _isFeatured,
                      onChanged: (v) => setState(() => _isFeatured = v),
                      title: const Text("Featured"),
                    ),
                    const SizedBox(height: 12),

                    // Duration
                    TextFormField(
                      initialValue: _durationDays.toString(),
                      decoration: const InputDecoration(
                        labelText: "Duration (Days)",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _durationDays = int.tryParse(v) ?? 30,
                    ),
                    const SizedBox(height: 16),

                    // Images
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text("Pick Images (Max 3)"),
                    ),
                    const SizedBox(height: 12),
                    if (_existingImages.isNotEmpty || _images.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._existingImages.map(
                              (url) => Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.network(
                                  url,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            ..._images.map(
                              (f) => Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.file(
                                  File(f.path),
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submitAd,
                      child: Text(
                        widget.adId != null ? "Update Ad" : "Submit Ad",
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
