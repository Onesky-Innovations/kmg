// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class AddBannerFAB extends StatefulWidget {
//   final String userId; // Admin user id
//   final String? bannerId; // null → add, else → edit

//   const AddBannerFAB({
//     super.key,
//     required this.userId,
//     this.bannerId,
//     required String adId,
//     // required String adId,
//   });

//   @override
//   State<AddBannerFAB> createState() => _AddBannerFABState();
// }

// class _AddBannerFABState extends State<AddBannerFAB> {
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();

//   final TextEditingController _titleController = TextEditingController();
//   int _durationDays = 30;
//   bool _isActive = true;
//   bool _isFeatured = false;
//   bool _isLoading = false;

//   final List<XFile> _images = [];
//   List<String> _existingImages = [];
//   Timestamp? _existingCreatedAt;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.bannerId != null) _loadBannerData();
//   }

//   Future<void> _loadBannerData() async {
//     final doc = await FirebaseFirestore.instance
//         .collection("classifieds")
//         .doc("baners")
//         .collection("baner")
//         .doc(widget.bannerId)
//         .get();

//     if (!doc.exists) return;

//     final data = doc.data()!;
//     setState(() {
//       _titleController.text = data['title'] ?? '';
//       _durationDays = data['durationDays'] ?? 30;
//       _isActive = data['status'] == 'Active';
//       _isFeatured = data['isFeatured'] ?? false;
//       _existingImages = List<String>.from(data['images'] ?? []);
//       _existingCreatedAt = data['createdAt'];
//     });
//   }

//   Future<void> _pickImages() async {
//     final picked = await _picker.pickMultiImage(imageQuality: 80);
//     if (picked.isEmpty) return;

//     if (_images.length + _existingImages.length + picked.length > 3) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "Maximum 3 images allowed. Recommended size: 1080×200px",
//           ),
//         ),
//       );
//       return;
//     }

//     setState(() => _images.addAll(picked));
//   }

//   Future<List<String>> _uploadImages(String bannerId) async {
//     final storage = FirebaseStorage.instance;
//     List<String> urls = [..._existingImages];
//     final folder = 'classifieds/baners/baner';

//     for (var img in _images) {
//       final file = File(img.path);
//       final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
//       final ref = storage.ref().child('$folder/$bannerId/$fileName');
//       final uploadTask = await ref.putFile(file);
//       final url = await uploadTask.ref.getDownloadURL();
//       urls.add(url);
//     }
//     return urls;
//   }

//   Future<void> _submitBanner() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);
//     try {
//       final bannerRef = widget.bannerId != null
//           ? FirebaseFirestore.instance
//                 .collection("classifieds")
//                 .doc("baners")
//                 .collection("baner")
//                 .doc(widget.bannerId)
//           : FirebaseFirestore.instance
//                 .collection("classifieds")
//                 .doc("baners")
//                 .collection("baner")
//                 .doc();

//       final bannerId = bannerRef.id;
//       final imageUrls = await _uploadImages(bannerId);

//       final bannerData = {
//         "id": bannerId,
//         "title": _titleController.text.trim(),
//         "durationDays": _durationDays,
//         "images": imageUrls,
//         "status": _isActive ? "Active" : "Inactive",
//         "isFeatured": _isFeatured,
//         "createdAt": widget.bannerId != null
//             ? _existingCreatedAt ?? FieldValue.serverTimestamp()
//             : FieldValue.serverTimestamp(),
//         "userId": widget.userId,
//       };

//       await bannerRef.set(bannerData, SetOptions(merge: true));

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             widget.bannerId != null ? "Banner updated!" : "Banner submitted!",
//           ),
//         ),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error saving banner: $e")));
//     } finally {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.yellow,
//       appBar: AppBar(
//         title: Text(widget.bannerId != null ? "Edit Banner" : "Add Banner"),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Title
//                     TextFormField(
//                       controller: _titleController,
//                       decoration: const InputDecoration(
//                         labelText: "Title *",
//                         hintText: "Enter banner title",
//                       ),
//                       validator: (v) => v == null || v.trim().isEmpty
//                           ? "Title required"
//                           : null,
//                     ),
//                     const SizedBox(height: 12),

//                     // Duration
//                     TextFormField(
//                       initialValue: _durationDays.toString(),
//                       decoration: const InputDecoration(
//                         labelText: "Duration Days",
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (val) =>
//                           _durationDays = int.tryParse(val) ?? 30,
//                     ),
//                     const SizedBox(height: 12),

//                     // Status toggle
//                     SwitchListTile(
//                       value: _isActive,
//                       onChanged: (val) => setState(() => _isActive = val),
//                       title: const Text("Active"),
//                     ),
//                     const SizedBox(height: 12),

//                     // Featured toggle
//                     SwitchListTile(
//                       value: _isFeatured,
//                       onChanged: (val) => setState(() => _isFeatured = val),
//                       title: const Text("Featured"),
//                     ),
//                     const SizedBox(height: 12),

//                     // Pick Images
//                     ElevatedButton.icon(
//                       onPressed: _pickImages,
//                       icon: const Icon(Icons.image),
//                       label: const Text("Pick Images (1080×200px)"),
//                     ),
//                     const SizedBox(height: 12),

//                     // Image preview
//                     if (_existingImages.isNotEmpty || _images.isNotEmpty)
//                       SizedBox(
//                         height: 100,
//                         child: ListView(
//                           scrollDirection: Axis.horizontal,
//                           children: [
//                             ..._existingImages.map(
//                               (url) => Padding(
//                                 padding: const EdgeInsets.all(4),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(
//                                     url,
//                                     width: 200,
//                                     height: 100,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             ..._images.map(
//                               (file) => Padding(
//                                 padding: const EdgeInsets.all(4),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.file(
//                                     File(file.path),
//                                     width: 200,
//                                     height: 100,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     const SizedBox(height: 20),

//                     // Submit Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _submitBanner,
//                         child: Text(
//                           widget.bannerId != null
//                               ? "Update Banner"
//                               : "Submit Banner",
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddBannerFAB extends StatefulWidget {
  // Use adId to maintain consistency with the calling screen (ManageClassifiedsScreen)
  final String? adId; // null or empty string → add, else → edit

  // NOTE: Although userId and existingData are passed from ManageClassifiedsScreen,
  // the current logic relies only on adId (now bannerId) to fetch data.
  // We keep them here to prevent compile errors from the calling screen,
  // but they are not strictly used in the current version of the state logic.
  final String userId;
  final Map<String, dynamic> existingData;

  AddBannerFAB({
    super.key,
    required this.adId, // This is the ID of the banner to edit (or '' for add)
    required this.userId,
    required this.existingData,
  }) : assert(
         adId != null || existingData.isEmpty,
         'adId must be provided for edit mode or existingData should be empty for add mode.',
       );

  @override
  State<AddBannerFAB> createState() => _AddBannerFABState();
}

class _AddBannerFABState extends State<AddBannerFAB> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(); // Added for phone/description
  final TextEditingController _descriptionController =
      TextEditingController(); // Added for phone/description

  int _durationDays = 30;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isLoading = false;

  final List<XFile> _images = [];
  List<String> _existingImages = [];
  Timestamp? _existingCreatedAt;

  static const String _bannerCollectionName = "banners";
  static const String _storageFolderPath = "banners";

  // Check if we are in edit mode
  bool get isEditMode => widget.adId != null && widget.adId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Load data if in edit mode
    if (isEditMode) _loadBannerData();
  }

  // Renamed from _loadBannerData to indicate it uses the adId from the widget
  Future<void> _loadBannerData() async {
    setState(() => _isLoading = true);

    // Fetch data using the ID passed from the ManageClassifiedsScreen
    final doc = await FirebaseFirestore.instance
        .collection(_bannerCollectionName)
        .doc(widget.adId)
        .get();

    if (!doc.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Banner document not found.")),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    final data = doc.data()!;
    setState(() {
      _titleController.text = data['title'] ?? '';
      _descriptionController.text =
          data['description'] ?? ''; // Pre-fill description
      _phoneController.text = data['phone'] ?? ''; // Pre-fill phone

      _durationDays = data['durationDays'] ?? 30;
      _isActive = data['status'] == 'Active';
      _isFeatured = data['isFeatured'] ?? false;
      _existingImages = List<String>.from(data['images'] ?? []);
      _existingCreatedAt = data['createdAt'];
      _isLoading = false;
    });
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    if (_images.length + _existingImages.length + picked.length > 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Maximum 3 images allowed. Recommended size: 1080×200px",
          ),
        ),
      );
      return;
    }

    setState(() => _images.addAll(picked));
  }

  // NOTE: This function handles both ADD and EDIT.
  // In ADD mode, bannerId is newly generated (inside _submitBanner).
  // In EDIT mode, bannerId is widget.adId.
  Future<List<String>> _uploadImages(String bannerId) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [..._existingImages];
    final folder = _storageFolderPath;

    for (var img in _images) {
      final file = File(img.path);
      // Use a unique name to prevent collisions, even if we are editing
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${img.name}";
      final ref = storage.ref().child('$folder/$bannerId/$fileName');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }

    // Clear the images list after successful upload
    _images.clear();
    return urls;
  }

  Future<void> _submitBanner() async {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImages.isEmpty && _images.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one banner image."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Determine the document reference (either existing or new)
      final bannerRef = FirebaseFirestore.instance
          .collection(_bannerCollectionName)
          .doc(
            isEditMode
                ? widget
                      .adId // Use existing ID for update
                : FirebaseFirestore.instance
                      .collection(_bannerCollectionName)
                      .doc()
                      .id, // Generate new ID for add
          );

      final bannerId = bannerRef.id;
      final imageUrls = await _uploadImages(bannerId);

      // 2. Prepare data map
      final bannerData = {
        "id": bannerId,
        "userId": widget.userId, // Include userId for both add and edit
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(), // Added
        "phone": _phoneController.text.trim(), // Added
        "durationDays": _durationDays,
        "images": imageUrls,
        "status": _isActive ? "Active" : "Inactive",
        "isFeatured": _isFeatured,
        // Preserve existing creation date on edit, set new on add
        "createdAt": isEditMode
            ? _existingCreatedAt ?? FieldValue.serverTimestamp()
            : FieldValue.serverTimestamp(),
      };

      // 3. Save/Update data using set(..., merge: true) which works for both
      await bannerRef.set(bannerData, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? "Banner updated successfully!"
                : "Banner added successfully!",
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving banner: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to remove an existing image
  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
      // NOTE: For a production app, you might want to also delete the image
      // from Firebase Storage here, but this is a complex step and optional
      // depending on your storage cleanup strategy.
    });
  }

  // Helper to remove a newly picked image
  void _removeNewImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(title: Text(isEditMode ? "Edit Banner" : "Add Banner")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Title *",
                        hintText: "Enter banner title",
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Title required"
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Phone Number (New Field)
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        hintText: "Enter contact number (e.g., +1234567890)",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // Description (New Field)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        hintText:
                            "Enter a brief description for the detail screen",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // Duration
                    TextFormField(
                      initialValue: _durationDays.toString(),
                      decoration: const InputDecoration(
                        labelText: "Duration (Days)",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) =>
                          _durationDays = int.tryParse(val) ?? 30,
                    ),
                    const SizedBox(height: 12),

                    // Active Switch
                    SwitchListTile(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      title: const Text("Active"),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Featured Switch
                    SwitchListTile(
                      value: _isFeatured,
                      onChanged: (v) => setState(() => _isFeatured = v),
                      title: const Text("Featured"),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Image Picker Button
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: Text(
                        "Pick Images (${_existingImages.length + _images.length}/3)",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Image Preview Section
                    if (_existingImages.isNotEmpty || _images.isNotEmpty)
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Existing Images
                            ..._existingImages.asMap().entries.map(
                              (entry) => _buildImageThumbnail(
                                entry.value,
                                isNetwork: true,
                                onRemove: () => _removeExistingImage(entry.key),
                              ),
                            ),

                            // New Images
                            ..._images.asMap().entries.map(
                              (entry) => _buildImageThumbnail(
                                File(entry.value.path),
                                isNetwork: false,
                                onRemove: () => _removeNewImage(entry.key),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitBanner,
                        child: Text(
                          isEditMode ? "Update Banner" : "Submit Banner",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper Widget for Image Thumbnails
  Widget _buildImageThumbnail(
    dynamic imageSource, {
    required bool isNetwork,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        children: [
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isNetwork
                  ? Image.network(
                      imageSource as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.error_outline)),
                    )
                  : Image.file(imageSource as File, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white70,
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
              ),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
