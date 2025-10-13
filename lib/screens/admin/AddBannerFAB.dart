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
  final String userId; // Admin user id
  final String? bannerId; // null → add, else → edit
  // Removed unused 'required String adId' from the constructor
  const AddBannerFAB({
    super.key,
    required this.userId,
    this.bannerId,
    required String adId,
  });

  @override
  State<AddBannerFAB> createState() => _AddBannerFABState();
}

class _AddBannerFABState extends State<AddBannerFAB> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  int _durationDays = 30;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isLoading = false;

  final List<XFile> _images = [];
  List<String> _existingImages = [];
  Timestamp? _existingCreatedAt;

  // Define the new, simple root collection name
  static const String _bannerCollectionName = "banners";
  // Define the new storage folder path
  static const String _storageFolderPath = 'banners';

  @override
  void initState() {
    super.initState();
    if (widget.bannerId != null) _loadBannerData();
  }

  Future<void> _loadBannerData() async {
    // ✅ FIX: Updated Firestore path to the root collection 'banners'
    final doc = await FirebaseFirestore.instance
        .collection(_bannerCollectionName)
        .doc(widget.bannerId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    setState(() {
      _titleController.text = data['title'] ?? '';
      _durationDays = data['durationDays'] ?? 30;
      _isActive = data['status'] == 'Active';
      _isFeatured = data['isFeatured'] ?? false;
      _existingImages = List<String>.from(data['images'] ?? []);
      _existingCreatedAt = data['createdAt'];
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

  Future<List<String>> _uploadImages(String bannerId) async {
    final storage = FirebaseStorage.instance;
    List<String> urls = [..._existingImages];
    // ✅ FIX: Updated Storage folder path to the simple 'banners'
    final folder = _storageFolderPath;

    for (var img in _images) {
      final file = File(img.path);
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      // ✅ FIX: Updated Storage reference path
      final ref = storage.ref().child('$folder/$bannerId/$fileName');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _submitBanner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // ✅ FIX: Updated Firestore path for both creating and editing
      final bannerRef = FirebaseFirestore.instance
          .collection(_bannerCollectionName)
          .doc(widget.bannerId);

      final newBannerRef = FirebaseFirestore.instance
          .collection(_bannerCollectionName)
          .doc();

      final targetRef = widget.bannerId != null ? bannerRef : newBannerRef;
      final bannerId = targetRef.id;

      final imageUrls = await _uploadImages(bannerId);

      final bannerData = {
        "id": bannerId,
        "title": _titleController.text.trim(),
        "durationDays": _durationDays,
        "images": imageUrls,
        "status": _isActive ? "Active" : "Inactive",
        "isFeatured": _isFeatured,
        "createdAt": widget.bannerId != null
            ? _existingCreatedAt ?? FieldValue.serverTimestamp()
            : FieldValue.serverTimestamp(),
        "userId": widget.userId,
      };

      await targetRef.set(bannerData, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.bannerId != null ? "Banner updated!" : "Banner submitted!",
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
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: Text(widget.bannerId != null ? "Edit Banner" : "Add Banner"),
      ),
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

                    // Status toggle
                    SwitchListTile(
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                      title: const Text("Active"),
                    ),
                    const SizedBox(height: 12),

                    // Featured toggle
                    SwitchListTile(
                      value: _isFeatured,
                      onChanged: (val) => setState(() => _isFeatured = val),
                      title: const Text("Featured"),
                    ),
                    const SizedBox(height: 12),

                    // Pick Images
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text("Pick Images (1080×200px)"),
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
                                    width: 200,
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
                                    width: 200,
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

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitBanner,
                        child: Text(
                          widget.bannerId != null
                              ? "Update Banner"
                              : "Submit Banner",
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
