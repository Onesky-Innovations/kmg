// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';

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
//   final TextEditingController createdByController = TextEditingController();
//   final TextEditingController durationController = TextEditingController();

//   bool isFeatured = false;
//   File? selectedImage;
//   final ImagePicker _picker = ImagePicker();

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
//       createdByController.text = data["createdBy"] ?? "";
//       isFeatured = data["isFeatured"] ?? false;
//       durationController.text = data["durationDays"]?.toString() ?? "90";
//     }
//   }

//   Future<void> _pickImage() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => selectedImage = File(picked.path));
//     }
//   }

//   Future<String?> _uploadImage(File file) async {
//     try {
//       final ref = _storage
//           .ref()
//           .child("matrimony_photos")
//           .child("${DateTime.now().millisecondsSinceEpoch}.jpg");
//       await ref.putFile(file);
//       return await ref.getDownloadURL();
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     String? photoUrl;
//     if (selectedImage != null) {
//       photoUrl = await _uploadImage(selectedImage!);
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
//       "createdBy": createdByController.text.trim(),
//       "photo": photoUrl,
//       "isFeatured": isFeatured,
//       "status": "Active",
//       "durationDays": durationDays,
//       "createdAt":
//           (widget.existingProfileId != null && widget.existingData != null)
//           ? widget.existingData!["createdAt"]
//           : DateTime.now(),
//       "expiryDate": expiryDate,
//     };

//     try {
//       if (widget.existingProfileId != null &&
//           widget.existingProfileId!.isNotEmpty) {
//         // Update existing
//         await _firestore
//             .collection("matrimony")
//             .doc(widget.existingProfileId)
//             .update(data);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Profile updated successfully")),
//         );
//       } else {
//         // Create new
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
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: type,
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
//                 _buildTextField(incomeController, "Income"),
//                 _buildTextField(placeController, "Place"),
//                 _buildTextField(
//                   contactController,
//                   "Contact Number",
//                   type: TextInputType.phone,
//                   required: true,
//                 ),
//                 _buildTextField(heightController, "Height"),
//                 _buildTextField(weightController, "Weight"),
//                 _buildTextField(createdByController, "Profile Created By"),
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

//                 _buildTextField(
//                   durationController,
//                   "Duration (days)",
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
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  // ✅ New Controllers
  final TextEditingController demandController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();

  bool isFeatured = false;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null && widget.existingData!.isNotEmpty) {
      final data = widget.existingData!;
      nameController.text = data["name"] ?? "";
      ageController.text = data["age"] ?? "";
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

      // ✅ Load new fields
      demandController.text = data["demand"] ?? "";
      aboutController.text = data["about"] ?? "";
      interestsController.text = data["interests"] ?? "";
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final ref = _storage
          .ref()
          .child("matrimony_photos")
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    String? photoUrl;
    if (selectedImage != null) {
      photoUrl = await _uploadImage(selectedImage!);
    } else if (widget.existingData != null) {
      photoUrl = widget.existingData!["photo"];
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
      "createdAt":
          (widget.existingProfileId != null && widget.existingData != null)
          ? widget.existingData!["createdAt"]
          : DateTime.now(),
      "expiryDate": expiryDate,

      // ✅ Save new fields
      "demand": demandController.text.trim(),
      "about": aboutController.text.trim(),
      "interests": interestsController.text.trim(),
    };

    try {
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
                _buildTextField(genderController, "Gender"),
                _buildTextField(religionController, "Religion"),
                _buildTextField(casteController, "Caste"),
                _buildTextField(starController, "Star"),
                _buildTextField(educationController, "Education"),
                _buildTextField(jobController, "Job"),
                _buildTextField(incomeController, "Income"),
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

                // ✅ New Fields
                _buildTextField(demandController, "Demand"),
                _buildTextField(
                  aboutController,
                  "About",
                  maxLines: 3,
                ), // multi-line
                _buildTextField(
                  interestsController,
                  "Interests",
                  maxLines: 2,
                ), // multi-line

                const SizedBox(height: 12),

                // Image Picker
                Row(
                  children: [
                    selectedImage != null
                        ? CircleAvatar(
                            radius: 35,
                            backgroundImage: FileImage(selectedImage!),
                          )
                        : (widget.existingData != null &&
                                  widget.existingData!["photo"] != null
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

                _buildTextField(
                  durationController,
                  "Duration (days)",
                  type: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: isFeatured,
                  onChanged: (val) => setState(() => isFeatured = val),
                  title: const Text("Featured Profile"),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check),
                  label: Text(isEditMode ? "Update Profile" : "Submit Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
