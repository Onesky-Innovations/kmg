// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:kmg/theme/app_theme.dart';

// class DeleteAccountScreen extends StatefulWidget {
//   const DeleteAccountScreen({super.key});

//   @override
//   State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
// }

// class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
//   String? selectedReason;
//   final TextEditingController _otherReasonController = TextEditingController();
//   final int maxChars = 200;

//   final List<String> reasons = [
//     "I have privacy concerns",
//     "I receive too many notifications",
//     "I have another account",
//     "I no longer use this app",
//     "Other",
//   ];

//   bool _isSubmitting = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: AppTheme.primary,
//         title: const Text(
//           "Delete Account",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         foregroundColor: AppTheme.iconOnPrimary,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "We’re sorry to see you go!",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               "Please let us know why you want to delete your account. "
//               "Your feedback helps us improve.",
//               style: TextStyle(fontSize: 15, color: Colors.black54),
//             ),
//             const SizedBox(height: 20),

//             // Radio buttons
//             ...reasons.map((reason) {
//               return RadioListTile<String>(
//                 title: Text(reason),
//                 value: reason,
//                 groupValue: selectedReason,
//                 onChanged: (value) {
//                   setState(() => selectedReason = value);
//                 },
//                 activeColor: AppTheme.primary,
//               );
//             }),

//             // "Other" text box
//             if (selectedReason == "Other") ...[
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _otherReasonController,
//                 maxLength: maxChars,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: "Please specify your reason",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ],

//             const SizedBox(height: 30),

//             Center(
//               child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 30,
//                     vertical: 14,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 icon: const Icon(Icons.delete_forever),
//                 label: Text(
//                   _isSubmitting ? "Submitting..." : "Request Account Deletion",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 onPressed: _isSubmitting ? null : _submitDeleteRequest,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _submitDeleteRequest() async {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("You must be signed in to delete your account."),
//         ),
//       );
//       return;
//     }

//     if (selectedReason == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a reason first.")),
//       );
//       return;
//     }

//     String reason = selectedReason!;
//     if (reason == "Other") {
//       if (_otherReasonController.text.trim().isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please enter your reason.")),
//         );
//         return;
//       }
//       reason = _otherReasonController.text.trim();
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       // Fetch user name (if stored in Firestore 'users' collection)
//       String? userName;
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       if (userDoc.exists) {
//         userName = userDoc.data()?['name'];
//       }

//       // Save delete request
//       await FirebaseFirestore.instance.collection('delete_requests').add({
//         'userId': user.uid,
//         'email': user.email ?? 'Unknown',
//         'name': userName ?? 'Unknown User',
//         'reason': reason,
//         'requestedAt': FieldValue.serverTimestamp(),
//         'status': 'Pending', // Optional: admin can mark as Done after deletion
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Your deletion request has been submitted."),
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       debugPrint("Error submitting delete request: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Failed to send request. Please try again."),
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   void dispose() {
//     _otherReasonController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String? selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  final int maxChars = 200;

  final List<String> reasons = [
    "I have privacy concerns",
    "I receive too many notifications",
    "I have another account",
    "I no longer use this app",
    "Other",
  ];

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Delete Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We’re sorry to see you go! 👋",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please let us know why you want to delete your account. "
              "Your feedback helps us improve.",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Radio buttons
            ...reasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) {
                  setState(() => selectedReason = value);
                },
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }),

            // "Other" text box
            if (selectedReason == "Other") ...[
              const SizedBox(height: 10),
              TextField(
                controller: _otherReasonController,
                maxLength: maxChars,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Please specify your reason",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.delete_forever),
                label: Text(
                  _isSubmitting ? "Submitting..." : "Request Account Deletion",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitDeleteRequest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitDeleteRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You must be signed in to delete your account."),
          ),
        );
      }
      return;
    }

    if (selectedReason == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a reason first.")),
        );
      }
      return;
    }

    String reason = selectedReason!;
    if (reason == "Other") {
      if (_otherReasonController.text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter your reason.")),
          );
        }
        return;
      }
      reason = _otherReasonController.text.trim();
    }

    // 1. Show Confirmation Dialog
    final bool confirm = await _showConfirmationDialog(context);

    if (!confirm) return;

    setState(() => _isSubmitting = true);

    try {
      // Fetch user name (if stored in Firestore 'users' collection)
      String? userName;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        userName = userDoc.data()?['name'];
      }

      // Save delete request
      await FirebaseFirestore.instance.collection('delete_requests').add({
        'userId': user.uid,
        'email': user.email ?? 'Unknown',
        'name': userName ?? 'Unknown User',
        'reason': reason,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'Pending',
      });

      if (mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Your deletion request has been submitted. We will process it shortly.",
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error submitting delete request: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send request. Please try again."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Shows a dialog to confirm the account deletion request.
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 10),
                Text("Confirm Deletion Request"),
              ],
            ),
            content: const Text(
              "Are you sure you want to request account deletion?\n\n"
              "This action is irreversible and will lead to the deletion of your profile, saved items, and all related data (ads, messages, etc.).",
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false), // Dismiss
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true), // Confirm
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Yes, Delete My Account"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }
}
