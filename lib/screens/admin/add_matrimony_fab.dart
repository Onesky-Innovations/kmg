// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;

// class AddMatrimonyFAB extends StatefulWidget {
//   final String userId;
//   final String? existingProfileId;
//   final Map<String, dynamic>? existingData;

//   const AddMatrimonyFAB({
//     super.key,
//     required this.userId,
//     this.existingProfileId,
//     this.existingData,
//   });

//   @override
//   State<AddMatrimonyFAB> createState() => _AddMatrimonyFABState();
// }

// class _AddMatrimonyFABState extends State<AddMatrimonyFAB> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   // Controllers
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController ageController = TextEditingController();
//   final TextEditingController genderController = TextEditingController();
//   final TextEditingController religionController = TextEditingController();
//   final TextEditingController casteController = TextEditingController();
//   final TextEditingController starController = TextEditingController();
//   final TextEditingController educationController = TextEditingController();
//   final TextEditingController jobController = TextEditingController();
//   final TextEditingController incomeController = TextEditingController();
//   final TextEditingController placeController = TextEditingController();
//   final TextEditingController contactController = TextEditingController();
//   final TextEditingController heightController = TextEditingController();
//   final TextEditingController weightController = TextEditingController();
//   final TextEditingController profilecreatedByController = TextEditingController();
//   final TextEditingController durationController = TextEditingController();
//   final TextEditingController userViewCountController = TextEditingController();
//   final TextEditingController accessibleProfilesController =
//       TextEditingController();

//   // New Controllers
//   final TextEditingController demandController = TextEditingController();
//   final TextEditingController aboutController = TextEditingController();
//   final TextEditingController interestsController = TextEditingController();

//   bool isFeatured = false;
//   File? selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   double _uploadProgress = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.existingData != null && widget.existingData!.isNotEmpty) {
//       final data = widget.existingData!;
//       nameController.text = data["name"] ?? "";
//       ageController.text = data["age"] ?? "";
//       genderController.text = data["gender"] ?? "";
//       religionController.text = data["religion"] ?? "";
//       casteController.text = data["caste"] ?? "";
//       starController.text = data["star"] ?? "";
//       educationController.text = data["education"] ?? "";
//       jobController.text = data["job"] ?? "";
//       incomeController.text = data["income"] ?? "";
//       placeController.text = data["place"] ?? "";
//       contactController.text = data["contact"] ?? "";
//       heightController.text = data["height"] ?? "";
//       weightController.text = data["weight"] ?? "";
//       profilecreatedByController.text = data["createdBy"] ?? "";
//       isFeatured = data["isFeatured"] ?? false;
//       durationController.text = data["durationDays"]?.toString() ?? "90";
//       userViewCountController.text = data["viewCount"]?.toString() ?? "0";

//       // Load new fields
//       demandController.text = data["demand"] ?? "";
//       aboutController.text = data["about"] ?? "";
//       interestsController.text = data["interests"] ?? "";
//     }

//     if (widget.existingData != null) {
//       accessibleProfilesController.text =
//           widget.existingData!["accessibleProfiles"]?.toString() ?? "20";
//       userViewCountController.text =
//           widget.existingData!["viewCount"]?.toString() ?? "0";
//     }
//   }

//   Future<File?> _compressImage(File file) async {
//     try {
//       Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
//         file.absolute.path,
//         minWidth: 800,
//         minHeight: 800,
//         quality: 80,
//       );

//       final dir = await getTemporaryDirectory();
//       final targetPath = path.join(
//         dir.path,
//         "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
//       );
//       final compressedFile = File(targetPath);
//       await compressedFile.writeAsBytes(
//         compressedBytes!,
//       ); //????-----------------------------------------------------------
//       return compressedFile;
//     } catch (e) {
//       debugPrint("Image compression failed: $e");
//       return null;
//     }
//   }

//   Future<void> _pickImage() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       File original = File(picked.path);

//       if (await original.length() > 1024 * 1024) {
//         File? compressed = await _compressImage(original);
//         if (compressed != null) {
//           setState(() => selectedImage = compressed);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Image compression failed")),
//           );
//         }
//       } else {
//         setState(() => selectedImage = original);
//       }
//     }
//   }

//   Future<String?> _uploadImage(File file) async {
//     try {
//       final ref = _storage
//           .ref()
//           .child("matrimony_photos")
//           .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

//       UploadTask task = ref.putFile(
//         file,
//         SettableMetadata(contentType: "image/jpeg"),
//       );

//       task.snapshotEvents.listen((event) {
//         setState(() {
//           _uploadProgress =
//               event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
//         });
//       });

//       await task;
//       return await ref.getDownloadURL();
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
//       return null;
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     String? photoUrl;
//     if (selectedImage != null) {
//       photoUrl = await _uploadImage(selectedImage!);
//       if (photoUrl == null) return;
//     } else if (widget.existingData != null) {
//       photoUrl = widget.existingData!["photo"];
//     }

//     int durationDays = int.tryParse(durationController.text.trim()) ?? 90;
//     DateTime expiryDate = DateTime.now().add(Duration(days: durationDays));

//     final data = {
//       "userId": widget.userId,
//       "name": nameController.text.trim(),
//       "age": ageController.text.trim(),
//       "gender": genderController.text.trim(),
//       "religion": religionController.text.trim(),
//       "caste": casteController.text.trim(),
//       "star": starController.text.trim(),
//       "education": educationController.text.trim(),
//       "job": jobController.text.trim(),
//       "income": incomeController.text.trim(),
//       "place": placeController.text.trim(),
//       "contact": contactController.text.trim(),
//       "height": heightController.text.trim(),
//       "weight": weightController.text.trim(),
//       "profilecreatedBy": profilecreatedByController.text.trim(),
//       "photo": photoUrl,
//       "isFeatured": isFeatured,
//       "status": "Active",
//       "durationDays": durationDays,
//       "createdAt":
//           (widget.existingProfileId != null && widget.existingData != null)
//           ? widget.existingData!["createdAt"]
//           : DateTime.now(),
//       // "createdAt": widget.existingData?["createdAt"] ?? DateTime.now(),
//       "expiryDate": expiryDate,
//       "demand": demandController.text.trim(),
//       "about": aboutController.text.trim(),
//       "interests": interestsController.text.trim(),
//       "accessibleProfiles":
//           int.tryParse(accessibleProfilesController.text.trim()) ?? 20,
//       "viewCount": int.tryParse(userViewCountController.text.trim()) ?? 0,
//     };

//     try {
//       if (widget.existingProfileId != null &&
//           widget.existingProfileId!.isNotEmpty) {
//         await _firestore
//             .collection("matrimony")
//             .doc(widget.existingProfileId)
//             .update(data);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile updated successfully")),
//         );
//       } else {
//         await _firestore.collection("matrimony").add(data);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile added successfully")),
//         );
//       }
//       if (!mounted) return;
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error saving profile: $e")));
//     }
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//     TextInputType type = TextInputType.text,
//     bool required = false,
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: type,
//         maxLines: maxLines,
//         decoration: InputDecoration(labelText: label),
//         validator: required
//             ? (val) => val == null || val.isEmpty ? "Enter $label" : null
//             : null,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditMode =
//         widget.existingProfileId != null &&
//         widget.existingProfileId!.isNotEmpty;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           isEditMode ? "Edit Matrimony Profile" : "Add Matrimony Profile",
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 _buildTextField(nameController, "Full Name", required: true),
//                 _buildTextField(
//                   ageController,
//                   "Age",
//                   type: TextInputType.number,
//                 ),
//                 _buildTextField(genderController, "Gender"),
//                 _buildTextField(religionController, "Religion"),
//                 _buildTextField(casteController, "Caste"),
//                 _buildTextField(starController, "Star"),
//                 _buildTextField(educationController, "Education"),
//                 _buildTextField(jobController, "Job"),
//                 _buildTextField(
//                   incomeController,
//                   "Income",
//                   type: TextInputType.number,
//                 ),
//                 _buildTextField(placeController, "Place"),
//                 _buildTextField(
//                   contactController,
//                   "Contact Number",
//                   type: TextInputType.phone,
//                   required: true,
//                 ),
//                 _buildTextField(heightController, "Height"),
//                 _buildTextField(weightController, "Weight"),
//                 _buildTextField(profilecreatedByController, "Profile Created By"),
//                 _buildTextField(demandController, "Demand"),
//                 _buildTextField(aboutController, "About", maxLines: 3),
//                 _buildTextField(interestsController, "Interests", maxLines: 2),

//                 const SizedBox(height: 12),

//                 // Image Picker
//                 Row(
//                   children: [
//                     selectedImage != null
//                         ? CircleAvatar(
//                             radius: 35,
//                             backgroundImage: FileImage(selectedImage!),
//                           )
//                         : (widget.existingData != null &&
//                                   widget.existingData!["photo"] != null
//                               ? CircleAvatar(
//                                   radius: 35,
//                                   backgroundImage: NetworkImage(
//                                     widget.existingData!["photo"],
//                                   ),
//                                 )
//                               : const CircleAvatar(
//                                   radius: 35,
//                                   child: Icon(Icons.person),
//                                 )),
//                     const SizedBox(width: 12),
//                     ElevatedButton.icon(
//                       onPressed: _pickImage,
//                       icon: const Icon(Icons.image),
//                       label: const Text("Upload Photo"),
//                     ),
//                   ],
//                 ),

//                 if (_uploadProgress > 0 && _uploadProgress < 1)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: LinearProgressIndicator(value: _uploadProgress),
//                   ),

//                 _buildTextField(
//                   durationController,
//                   "Duration (days)",
//                   type: TextInputType.number,
//                 ),
//                 _buildTextField(
//                   accessibleProfilesController,
//                   "Number of Accessible Profiles",
//                   type: TextInputType.number,
//                   required: true,
//                 ),
//                 _buildTextField(
//                   userViewCountController,
//                   "viewCount",
//                   type: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 SwitchListTile(
//                   value: isFeatured,
//                   onChanged: (val) => setState(() => isFeatured = val),
//                   title: const Text("Featured Profile"),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   onPressed: _submitForm,
//                   icon: const Icon(Icons.check),
//                   label: Text(isEditMode ? "Update Profile" : "Submit Profile"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AddMatrimonyFAB extends StatefulWidget {
  final String userId;
  final String? existingProfileId;
  final Map<String, dynamic>? existingData;

  const AddMatrimonyFAB({
    super.key,
    required this.userId,
    this.existingProfileId,
    this.existingData,
  });

  @override
  State<AddMatrimonyFAB> createState() => _AddMatrimonyFABState();
}

class _AddMatrimonyFABState extends State<AddMatrimonyFAB> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController casteController = TextEditingController();
  final TextEditingController starController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController createdByController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController accessibleProfilesController =
      TextEditingController();
  final TextEditingController viewCountController = TextEditingController();

  // Additional fields
  final TextEditingController demandController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();

  // State Management
  bool isFeatured = false;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  double _uploadProgress = 0.0;
  bool _isSubmitting = false; // ⚡ Added loading state
  String? _selectedGender; // ⚡ Added state for dropdown

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final data = widget.existingData!;
      nameController.text = data["name"] ?? "";
      ageController.text = data["age"] ?? "";

      // Initialize gender for dropdown
      _selectedGender = data["gender"];
      genderController.text = data["gender"] ?? "";

      religionController.text = data["religion"] ?? "";
      casteController.text = data["caste"] ?? "";
      starController.text = data["star"] ?? "";
      educationController.text = data["education"] ?? "";
      jobController.text = data["job"] ?? "";
      incomeController.text = data["income"] ?? "";
      placeController.text = data["place"] ?? "";
      contactController.text = data["contact"] ?? "";
      heightController.text = data["height"] ?? "";
      weightController.text = data["weight"] ?? "";
      createdByController.text = data["createdBy"] ?? "";
      isFeatured = data["isFeatured"] ?? false;
      durationController.text = data["durationDays"]?.toString() ?? "90";
      accessibleProfilesController.text =
          data["accessibleProfiles"]?.toString() ?? "20";
      viewCountController.text = data["viewCount"]?.toString() ?? "0";

      // Additional fields
      demandController.text = data["demand"] ?? "";
      aboutController.text = data["about"] ?? "";
      interestsController.text = data["interests"] ?? "";
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 80,
      );

      if (compressedBytes == null) return null;

      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
      debugPrint("Image compression failed: $e");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      File original = File(picked.path);

      if (await original.length() > 1024 * 1024) {
        File? compressed = await _compressImage(original);
        if (compressed != null) {
          setState(() => selectedImage = compressed);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image compression failed")),
          );
        }
      } else {
        setState(() => selectedImage = original);
      }
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final ref = _storage
          .ref()
          .child("matrimony_photos")
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

      UploadTask task = ref.putFile(
        file,
        SettableMetadata(contentType: "image/jpeg"),
      );

      task.snapshotEvents.listen((event) {
        if (mounted) {
          setState(() {
            _uploadProgress = event.bytesTransferred / event.totalBytes;
          });
        }
      });

      await task;
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
      return null;
    }
  }

  // ⚡ Dropdown widget for Gender
  Widget _buildGenderDropdown({required bool required}) {
    String? currentValue = _selectedGender;
    if (currentValue != null && currentValue.isEmpty) currentValue = null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: currentValue,
        decoration: const InputDecoration(labelText: "Gender"),
        items: const [
          DropdownMenuItem(value: "Male", child: Text("Male")),
          DropdownMenuItem(value: "Female", child: Text("Female")),
          DropdownMenuItem(value: "Other", child: Text("Other")),
        ],
        onChanged: (val) {
          setState(() {
            _selectedGender = val;
            genderController.text =
                val ?? ""; // Update controller for submission
          });
        },
        validator: (val) {
          if (required && (val == null || val.isEmpty)) {
            return "Please select Gender";
          }
          return null;
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Set loading state
    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      String? photoUrl;
      if (selectedImage != null) {
        photoUrl = await _uploadImage(selectedImage!);
        if (photoUrl == null) {
          // If image upload fails, stop submission and exit
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      } else {
        photoUrl = widget.existingData?["photo"];
      }

      int durationDays = int.tryParse(durationController.text.trim()) ?? 90;
      DateTime expiryDate = DateTime.now().add(Duration(days: durationDays));

      final data = {
        "userId": widget.userId,
        "name": nameController.text.trim(),
        "age": ageController.text.trim(),
        "gender": genderController.text.trim(),
        "religion": religionController.text.trim(),
        "caste": casteController.text.trim(),
        "star": starController.text.trim(),
        "education": educationController.text.trim(),
        "job": jobController.text.trim(),
        "income": incomeController.text.trim(),
        "place": placeController.text.trim(),
        "contact": contactController.text.trim(),
        "height": heightController.text.trim(),
        "weight": weightController.text.trim(),
        "createdBy": createdByController.text.trim(),
        "photo": photoUrl,
        "isFeatured": isFeatured,
        "status": "Active",
        "durationDays": durationDays,
        "createdAt": widget.existingData?["createdAt"] ?? DateTime.now(),
        "expiryDate": expiryDate,
        "demand": demandController.text.trim(),
        "about": aboutController.text.trim(),
        "interests": interestsController.text.trim(),
        "accessibleProfiles":
            int.tryParse(accessibleProfilesController.text.trim()) ?? 20,
        "viewCount": int.tryParse(viewCountController.text.trim()) ?? 0,
      };

      if (widget.existingProfileId != null &&
          widget.existingProfileId!.isNotEmpty) {
        await _firestore
            .collection("matrimony")
            .doc(widget.existingProfileId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      } else {
        await _firestore.collection("matrimony").add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile added successfully")),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving profile: $e")));
    } finally {
      // End loading state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (val) => val == null || val.isEmpty ? "Enter $label" : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode =
        widget.existingProfileId != null &&
        widget.existingProfileId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? "Edit Matrimony Profile" : "Add Matrimony Profile",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, "Full Name", required: true),
                _buildTextField(
                  ageController,
                  "Age",
                  type: TextInputType.number,
                ),
                _buildGenderDropdown(required: true), // ⚡ Using the dropdown
                _buildTextField(religionController, "Religion"),
                _buildTextField(casteController, "Caste"),
                _buildTextField(starController, "Star"),
                _buildTextField(educationController, "Education"),
                _buildTextField(jobController, "Job"),
                _buildTextField(
                  incomeController,
                  "Income",
                  type: TextInputType.number,
                ),
                _buildTextField(placeController, "Place"),
                _buildTextField(
                  contactController,
                  "Contact Number",
                  type: TextInputType.phone,
                  required: true,
                ),
                _buildTextField(heightController, "Height"),
                _buildTextField(weightController, "Weight"),
                _buildTextField(createdByController, "Profile Created By"),
                _buildTextField(demandController, "Demand"),
                _buildTextField(aboutController, "About", maxLines: 3),
                _buildTextField(interestsController, "Interests", maxLines: 2),
                const SizedBox(height: 12),

                // Image Picker
                Row(
                  children: [
                    selectedImage != null
                        ? CircleAvatar(
                            radius: 35,
                            backgroundImage: FileImage(selectedImage!),
                          )
                        : (widget.existingData?["photo"] != null
                              ? CircleAvatar(
                                  radius: 35,
                                  backgroundImage: NetworkImage(
                                    widget.existingData!["photo"],
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 35,
                                  child: Icon(Icons.person),
                                )),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Upload Photo"),
                    ),
                  ],
                ),

                if (_uploadProgress > 0 && _uploadProgress < 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: LinearProgressIndicator(value: _uploadProgress),
                  ),
                const SizedBox(height: 20),

                _buildTextField(
                  durationController,
                  "Duration (days)",
                  type: TextInputType.number,
                ),
                _buildTextField(
                  accessibleProfilesController,
                  "Number of Accessible Profiles",
                  type: TextInputType.number,
                  required: true,
                ),
                _buildTextField(
                  viewCountController,
                  "View Count",
                  type: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: isFeatured,
                  onChanged: (val) => setState(() => isFeatured = val),
                  title: const Text("Featured Profile"),
                ),
                const SizedBox(height: 20),

                // ⚡ Conditional Submit Button / Loading Indicator
                _isSubmitting
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepOrange,
                            ), // Colorful indicator
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.check),
                        label: Text(
                          isEditMode ? "Update Profile" : "Submit Profile",
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
