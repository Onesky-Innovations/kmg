import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddClassifiedFAB extends StatefulWidget {
  final String userId;
  final String? adId; // If null → Add, else → Edit
  // NEW: Must provide the owner ID if adId is being passed for editing
  final String? adOwnerId;
  final String type;

  const AddClassifiedFAB({
    super.key,
    required this.userId,
    this.adId,
    this.adOwnerId, // <-- NEW PARAMETER
    required this.type,
  }) : assert(
         adId == null || adOwnerId != null,
         'adOwnerId must be provided if adId is provided for editing.',
       );

  @override
  State<AddClassifiedFAB> createState() => _AddClassifiedFABState();
}

class _AddClassifiedFABState extends State<AddClassifiedFAB> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Admin Search Controllers and State
  final TextEditingController _searchController = TextEditingController();
  // Holds the fetched user's UID (Critical) - Initialized with adOwnerId/userId
  String _adOwnerUserId = '';
  String _adOwnerName = 'N/A'; // Holds the fetched user's name for display

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _condition = "Used";
  // NEW STATE VARIABLE: Sold Status
  String _soldStatus = "unsold"; // Default to 'unsold'
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
    // Initialize with the adOwnerId (if editing) or the current user's ID
    _adOwnerUserId = widget.adOwnerId ?? widget.userId;

    if (widget.adId != null && widget.adOwnerId != null) {
      _loadAdData(widget.adOwnerId!); // Pass the required Ad Owner ID
    }
  }

  // Dispose the controllers
  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _placeController.dispose();
    _contactController.dispose();
    _priceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // UPDATED: Now requires the adOwnerId to locate the ad
  Future<void> _loadAdData(String adOwnerId) async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch the classified document from the new subcollection path
      final doc = await FirebaseFirestore.instance
          .collection('users') // collection('users')
          .doc(adOwnerId) // doc(adOwnerId)
          .collection('classifieds') // collection('classifieds') - RENAMED
          .doc(widget.adId)
          .get();

      if (!doc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Classified Ad not found.")),
        );
        return;
      }

      final data = doc.data()!;

      // 2. Fetch user name for display (still necessary if ownerId came from outside)
      final adOwnerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(
            data['userId'] ?? adOwnerId,
          ) // Use stored ID or fallback to passed ID
          .get();

      setState(() {
        _titleController.text = data['title'] ?? '';
        _descController.text = data['description'] ?? '';
        _categoryController.text = data['category'] ?? '';
        _placeController.text = data['place'] ?? '';
        _contactController.text = data['contact'] ?? '';
        _priceController.text = data['price']?.toString() ?? '';
        _condition = data['condition'] ?? 'Used';
        // LOAD NEW FIELD
        _soldStatus = data['soldStatus'] ?? 'unsold';
        _durationDays = data['durationDays'] ?? 30;
        _isFeatured = data['isFeatured'] ?? false;
        _existingImages = List<String>.from(data['images'] ?? []);
        _existingExpiryDate = data['expiryDate'] != null
            ? (data['expiryDate'] as Timestamp).toDate()
            : null;
        _existingCreatedAt = data['createdAt'];

        // Load user details for editing
        _adOwnerUserId = data['userId'] ?? adOwnerId;
        _adOwnerName = adOwnerDoc.exists
            ? adOwnerDoc.data()!['name'] ?? 'User Found'
            : 'N/A';
      });

      // ensure loaded category is in dropdown
      if (_categoryController.text.isNotEmpty &&
          !categories.contains(_categoryController.text)) {
        categories.add(_categoryController.text);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading ad: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // User search logic remains the same as it finds the user document in 'users'
  Future<void> _searchUser() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      QuerySnapshot userSnapshot;

      // 1. Search by email
      userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: query)
          .limit(1)
          .get();

      // 2. If no result, search by contact/phone
      if (userSnapshot.docs.isEmpty) {
        userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('contact', isEqualTo: query)
            .limit(1)
            .get();
      }

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        final fetchedUserId = userSnapshot.docs.first.id;
        final fetchedUserName = userData['name'] ?? 'User Found';

        if (!mounted) return;
        setState(() {
          _adOwnerUserId = fetchedUserId;
          _adOwnerName = fetchedUserName;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User found: $fetchedUserName")));
      } else {
        if (!mounted) return;
        setState(() {
          _adOwnerUserId = '';
          _adOwnerName = 'N/A';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found by email/phone.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error searching user: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
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

  // In _AddClassifiedFABState
  Future<List<String>> _uploadImages(String adId) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [..._existingImages];

    // 🎯 CHANGE THIS LINE: Use the ad owner's UID in the path
    // Path: users/{_adOwnerUserId}/classifieds/{adId}/{fileName}
    final folderPath = 'users/$_adOwnerUserId/classifieds';

    for (var img in _images) {
      final file = File(img.path);
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

      // 🎯 CHANGE THIS LINE: Use the full path
      final ref = storage.ref().child('$folderPath/$adId/$fileName');

      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  // UPDATED: All Firebase writes now target the user's subcollection.
  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if a user has been successfully linked
    if (_adOwnerUserId.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please find and link a user first.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Define the full reference path using the user's ID and the new subcollection name
      final classifiedsSubCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_adOwnerUserId) // Linked user's ID
          .collection(
            'classifieds',
          ); // RENAMED: from 'user_ads' to 'classifieds'

      final adRef = widget.adId != null
          ? classifiedsSubCollectionRef.doc(widget.adId) // Existing ad
          : classifiedsSubCollectionRef.doc(); // New ad

      final adId = adRef.id;
      final imageUrls = await _uploadImages(adId);

      final adData = {
        "id": adId,
        "userId": _adOwnerUserId,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "category": _categoryController.text.trim(),
        "place": _placeController.text.trim(),
        "condition": _condition,
        // SAVE NEW FIELD
        "soldStatus": _soldStatus,
        "contact": _contactController.text.trim(),
        "price": _priceController.text.trim().isNotEmpty
            ? double.tryParse(_priceController.text.trim())
            : null,
        "durationDays": _durationDays,
        "expiryDate": Timestamp.fromDate(
          widget.adId != null
              ? _existingExpiryDate ??
                    DateTime.now().add(Duration(days: _durationDays))
              : DateTime.now().add(Duration(days: _durationDays)),
        ),
        "isFeatured": _isFeatured,
        "images": imageUrls,
        "status": "Active",
        "createdAt": widget.adId != null
            ? _existingCreatedAt ?? FieldValue.serverTimestamp()
            : FieldValue.serverTimestamp(),
      };

      // Write the classified document to the user's subcollection
      await adRef.set(adData, SetOptions(merge: true));

      // REMOVED: The second write to the now-removed top-level "classifieds" collection.

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

  /// show dialog to add new category (No changes needed here)
  void _addNewCategory() {
    // ... (existing code for adding new category)
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of the widget build method, no changes needed)
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
                    // <--- NEW USER SEARCH WIDGETS START HERE --->
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: "User Email or Phone",
                              hintText: "Search user to link ad",
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _searchUser,
                          child: const Text("Search"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Display the selected/fetched User ID and Name
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _adOwnerUserId.isNotEmpty
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _adOwnerUserId.isNotEmpty
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ad Owner Status:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _adOwnerUserId.isNotEmpty
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                            ),
                          ),
                          Text("Name: $_adOwnerName"),
                          Text(
                            "UID: ${_adOwnerUserId.isNotEmpty ? _adOwnerUserId : 'NOT SET'}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // <--- NEW USER SEARCH WIDGETS END HERE --->

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
                            initialValue: _categoryController.text.isNotEmpty
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

                    // NEW FIELD: Sold Status Dropdown
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
