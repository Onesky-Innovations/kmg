// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class AddClassifiedFAB extends StatefulWidget {
//   final String type; // "classified" or "banner"
//   final String userId;
//   final String? adId; // If null → Add, else → Edit

//   const AddClassifiedFAB({
//     super.key,
//     required this.type,
//     required this.userId,
//     this.adId,
//   });

//   @override
//   State<AddClassifiedFAB> createState() => _AddClassifiedFABState();
// }

// class _AddClassifiedFABState extends State<AddClassifiedFAB> {
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();

//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _descController = TextEditingController();
//   final TextEditingController _categoryController = TextEditingController();
//   final TextEditingController _placeController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();

//   String _condition = "Used";
//   int _durationDays = 30;
//   bool _isFeatured = false;
//   bool _isLoading = false;
//   final List<XFile> _images = [];
//   List<String> _existingImages = [];

//   DateTime? _existingExpiryDate;
//   Timestamp? _existingCreatedAt;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.adId != null) _loadAdData();
//   }

//   Future<void> _loadAdData() async {
//     DocumentSnapshot<Map<String, dynamic>> doc;

//     if (widget.type == "banner") {
//       doc = await FirebaseFirestore.instance
//           .collection("classifieds")
//           .doc("baners")
//           .collection("baner")
//           .doc(widget.adId)
//           .get();
//     } else {
//       doc = await FirebaseFirestore.instance
//           .collection("classifieds")
//           .doc(widget.adId)
//           .get();
//     }

//     if (!doc.exists) return;

//     final data = doc.data()!;
//     setState(() {
//       _titleController.text = data['title'] ?? '';
//       _descController.text = data['description'] ?? '';
//       _categoryController.text = data['category'] ?? '';
//       _placeController.text = data['place'] ?? '';
//       _contactController.text = data['contact'] ?? '';
//       _priceController.text = data['price']?.toString() ?? '';
//       _condition = data['condition'] ?? 'Used';
//       _durationDays = data['durationDays'] ?? 30;
//       _isFeatured = data['isFeatured'] ?? false;
//       _existingImages = List<String>.from(data['images'] ?? []);
//       _existingExpiryDate = data['expiryDate'] != null
//           ? (data['expiryDate'] as Timestamp).toDate()
//           : null;
//       _existingCreatedAt = data['createdAt'];
//     });
//   }

//   Future<void> _pickImages() async {
//     final picked = await _picker.pickMultiImage(imageQuality: 80);
//     if (picked.isEmpty) return;
//     if (_images.length + _existingImages.length + picked.length > 3) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Maximum 3 images allowed")));
//       return;
//     }
//     setState(() => _images.addAll(picked));
//   }

//   Future<List<String>> _uploadImages(String adId) async {
//     final storage = FirebaseStorage.instance;
//     List<String> urls = [..._existingImages];

//     final folder = widget.type == "banner"
//         ? 'classifieds/baners/baner'
//         : 'classifieds';

//     for (var img in _images) {
//       final file = File(img.path);
//       final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
//       final ref = storage.ref().child('$folder/$adId/$fileName');
//       final uploadTask = await ref.putFile(file);
//       final url = await uploadTask.ref.getDownloadURL();
//       urls.add(url);
//     }
//     return urls;
//   }

//   Future<void> _submitAd() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);
//     try {
//       DocumentReference adRef;

//       if (widget.type == "banner") {
//         adRef = widget.adId != null
//             ? FirebaseFirestore.instance
//                   .collection("classifieds")
//                   .doc("baners")
//                   .collection("baner")
//                   .doc(widget.adId)
//             : FirebaseFirestore.instance
//                   .collection("classifieds")
//                   .doc("baners")
//                   .collection("baner")
//                   .doc();
//       } else {
//         adRef = widget.adId != null
//             ? FirebaseFirestore.instance
//                   .collection("classifieds")
//                   .doc(widget.adId)
//             : FirebaseFirestore.instance.collection("classifieds").doc();
//       }

//       final adId = adRef.id;
//       final imageUrls = await _uploadImages(adId);

//       final adData = {
//         "id": adId,
//         "type": widget.type,
//         "userId": widget.userId,
//         "title": _titleController.text.trim(),
//         "description": widget.type == "classified"
//             ? _descController.text.trim()
//             : null,
//         "category": widget.type == "classified"
//             ? _categoryController.text.trim()
//             : null,
//         "place": widget.type == "classified"
//             ? _placeController.text.trim()
//             : null,
//         "condition": widget.type == "classified" ? _condition : null,
//         "contact": widget.type == "classified"
//             ? _contactController.text.trim()
//             : null,
//         "price":
//             widget.type == "classified" &&
//                 _priceController.text.trim().isNotEmpty
//             ? double.tryParse(_priceController.text.trim())
//             : null,
//         "durationDays": _durationDays,
//         "expiryDate": widget.adId != null
//             ? _existingExpiryDate ??
//                   DateTime.now().add(Duration(days: _durationDays))
//             : DateTime.now().add(Duration(days: _durationDays)),
//         "isFeatured": widget.type == "classified" ? _isFeatured : false,
//         "images": imageUrls,
//         "status": "Active",
//         "createdAt": widget.adId != null
//             ? _existingCreatedAt ?? FieldValue.serverTimestamp()
//             : FieldValue.serverTimestamp(),
//       };

//       await adRef.set(adData, SetOptions(merge: true));

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(widget.adId != null ? "Ad updated!" : "Ad submitted!"),
//         ),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error saving ad: $e")));
//     } finally {
//       if (!mounted) return;
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     _categoryController.dispose();
//     _placeController.dispose();
//     _contactController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isBanner = widget.type == "banner";

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.adId != null
//               ? "Edit ${isBanner ? 'Banner' : 'Classified'} Ad"
//               : "Add ${isBanner ? 'Banner' : 'Classified'} Ad",
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // User ID (read-only)
//                     TextFormField(
//                       initialValue: widget.userId,
//                       decoration: const InputDecoration(labelText: "User ID"),
//                       readOnly: true,
//                     ),
//                     const SizedBox(height: 12),

//                     // Title
//                     TextFormField(
//                       controller: _titleController,
//                       decoration: const InputDecoration(labelText: "Title *"),
//                       validator: (v) => v == null || v.trim().isEmpty
//                           ? "Title required"
//                           : null,
//                     ),
//                     const SizedBox(height: 12),

//                     if (!isBanner) ...[
//                       // Description
//                       TextFormField(
//                         controller: _descController,
//                         decoration: const InputDecoration(
//                           labelText: "Description *",
//                         ),
//                         maxLines: 4,
//                         validator: (v) => v == null || v.trim().isEmpty
//                             ? "Description required"
//                             : null,
//                       ),
//                       const SizedBox(height: 12),

//                       // Category
//                       TextFormField(
//                         controller: _categoryController,
//                         decoration: const InputDecoration(
//                           labelText: "Category",
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // Place
//                       TextFormField(
//                         controller: _placeController,
//                         decoration: const InputDecoration(labelText: "Place"),
//                       ),
//                       const SizedBox(height: 12),

//                       // Contact
//                       TextFormField(
//                         controller: _contactController,
//                         decoration: const InputDecoration(labelText: "Contact"),
//                       ),
//                       const SizedBox(height: 12),

//                       // Price
//                       TextFormField(
//                         controller: _priceController,
//                         decoration: const InputDecoration(labelText: "Price"),
//                         keyboardType: TextInputType.number,
//                       ),
//                       const SizedBox(height: 12),

//                       // Condition Dropdown
//                       DropdownButtonFormField<String>(
//                         value: _condition,
//                         items: ["New", "Used"]
//                             .map(
//                               (e) => DropdownMenuItem(value: e, child: Text(e)),
//                             )
//                             .toList(),
//                         onChanged: (val) => setState(() => _condition = val!),
//                         decoration: const InputDecoration(
//                           labelText: "Condition",
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // Featured toggle
//                       SwitchListTile(
//                         value: _isFeatured,
//                         onChanged: (val) => setState(() => _isFeatured = val),
//                         title: const Text("Featured"),
//                       ),
//                       const SizedBox(height: 12),
//                     ],

//                     // Duration (shared for both classified and banner)
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

//                     // Image picker
//                     ElevatedButton.icon(
//                       onPressed: _pickImages,
//                       icon: const Icon(Icons.image),
//                       label: const Text("Pick Images"),
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
//                                     width: 100,
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
//                                     width: 100,
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

//                     // Submit button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _submitAd,
//                         child: Text(
//                           widget.adId != null ? "Update Ad" : "Submit Ad",
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

class AddClassifiedFAB extends StatefulWidget {
  final String userId;
  final String? adId; // If null → Add, else → Edit

  const AddClassifiedFAB({
    super.key,
    required this.userId,
    this.adId,
    required type,
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

                    // Category
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: "Category"),
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
