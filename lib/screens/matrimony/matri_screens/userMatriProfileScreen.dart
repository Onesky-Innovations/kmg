// import 'package:flutter/material.dart';

// class MatriProfileScreen extends StatefulWidget {
//   final Map<String, dynamic> userData;

//   const MatriProfileScreen({super.key, required this.userData});

//   @override
//   State<MatriProfileScreen> createState() => _MatriProfileScreenState();
// }

// class _MatriProfileScreenState extends State<MatriProfileScreen> {
//   bool _showHiddenInfo = false; // Renamed for clarity

//   // --- Field Definitions for Grouping ---

//   // Fields to completely hide (as requested: viewCount, accessibleProfiles)
//   static const List<String> _hiddenFields = [
//     'viewCount',
//     'accessibleProfiles',
//     'photo', // Handled in the header
//     'name', // Handled in the header
//   ];

//   // Fields to show under the hidden info card (as requested)
//   static const List<String> _infoFields = [
//     'expiryDate',
//     'createdAt',
//     'isFeatured',
//     'userId',
//   ];

//   // Group fields for standard sections
//   static const Map<String, List<String>> _fieldSections = {
//     'Personal Info': [
//       'age',
//       'gender',
//       'maritalStatus',
//       'dob',
//       'education', // Moved from 'other' for better grouping
//       'occupation', // Moved from 'other' for better grouping
//     ],
//     'Location': ['place', 'city', 'state', 'country'],
//     'Other Details': ['hobbies', 'about'],
//   };

//   // Combine all special/excluded fields for filtering the general sections
//   List<String> get _allExcludedFields {
//     // Ensure all fields that are NOT part of the standard display sections are excluded
//     // This includes fields in _hiddenFields, _infoFields, and 'name', 'photo'.
//     return [..._hiddenFields, ..._infoFields];
//   }

//   // --- Helper Methods ---

//   String _formatKey(String key) {
//     final formatted = key.replaceAllMapped(
//       RegExp(r'(_)|([A-Z])'),
//       (match) => match[1] != null ? ' ' : ' ${match[2]}',
//     );
//     return formatted[0].toUpperCase() + formatted.substring(1);
//   }

//   Widget _buildRow(String key, dynamic value) {
//     // Format bool values for better UI
//     String displayValue = value.toString();
//     if (value is bool) {
//       displayValue = value ? 'Yes' : 'No';
//     } else if (value.toString().isEmpty) {
//       displayValue = 'N/A';
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 130, // Fixed width for key alignment
//             child: Text(
//               '${_formatKey(key)}: ',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(displayValue, style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection(String title, List<String> keys) {
//     final entries = keys
//         .where(
//           (k) =>
//               widget.userData[k] != null &&
//               !_allExcludedFields.contains(
//                 k,
//               ), // <-- Crucial check: Exclude fields meant for the info section
//         )
//         .map((k) => _buildRow(k, widget.userData[k]))
//         .toList();

//     if (entries.isEmpty) return const SizedBox.shrink();

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: Theme.of(context).colorScheme.primary, // Use theme color
//               ),
//             ),
//             const Divider(height: 16),
//             ...entries,
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userData = widget.userData;
//     final theme = Theme.of(context);

//     // Filter the final list of keys for the Info section based on data availability
//     final availableInfoFields = _infoFields
//         .where((f) => userData[f] != null)
//         .toList();

//     return Scaffold(
//       appBar: AppBar(title: Text('${userData['name'] ?? "Profile"}')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // --- Header: Avatar & Name ---
//             Center(
//               child: CircleAvatar(
//                 radius: 60,
//                 backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                 backgroundImage:
//                     userData['photo'] != null &&
//                         userData['photo'].toString().isNotEmpty
//                     ? NetworkImage(userData['photo'])
//                     : null,
//                 child: userData['photo'] == null || userData['photo'].isEmpty
//                     ? Icon(
//                         Icons.account_circle,
//                         size: 80,
//                         color: theme.colorScheme.primary,
//                       )
//                     : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               userData['name'] ?? 'Unknown',
//               style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),

//             // --- Dynamic Sections ---
//             ..._fieldSections.entries.map(
//               (entry) => _buildSection(entry.key, entry.value),
//             ),

//             // --- Hidden/Admin Info Card ---
//             if (availableInfoFields.isNotEmpty)
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       InkWell(
//                         // Use InkWell for better tap feedback on the title row
//                         onTap: () {
//                           setState(() {
//                             _showHiddenInfo = !_showHiddenInfo;
//                           });
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.info_outline,
//                                 color: Colors.blue,
//                               ),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 "Technical/Account Details", // Clearer title
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const Spacer(),
//                               Icon(
//                                 _showHiddenInfo
//                                     ? Icons.keyboard_arrow_up
//                                     : Icons.keyboard_arrow_down,
//                                 color: Colors.blue,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (_showHiddenInfo) const Divider(height: 10),
//                       if (_showHiddenInfo)
//                         ...availableInfoFields
//                             .map((f) => _buildRow(f, userData[f]))
//                             .toList(),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatriProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MatriProfileScreen({super.key, required this.userData});

  @override
  State<MatriProfileScreen> createState() => _MatriProfileScreenState();
}

class _MatriProfileScreenState extends State<MatriProfileScreen> {
  bool _showHidden = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔹 Real-time user data stream (for self profile)
    Stream<Map<String, dynamic>> userStream() {
      final matrimonyId = widget.userData['matrimonyId'];
      if (matrimonyId != null && matrimonyId.toString().isNotEmpty) {
        return FirebaseFirestore.instance
            .collection('matrimony')
            .doc(matrimonyId)
            .snapshots()
            .map((snapshot) => snapshot.data() ?? {});
      }
      return Stream.value(widget.userData);
    }

    // 🔹 Reusable labeled row
    Widget buildRow(String label, dynamic value) {
      String display = value?.toString() ?? 'N/A';
      if (value is bool) display = value ? 'Yes' : 'No';
      if (display.isEmpty) display = 'N/A';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              child: Text(display, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
      );
    }

    // 🔹 Build the actual profile UI
    Widget buildProfile(Map<String, dynamic> data) {
      final hiddenFields = [
        {'label': 'Expiry Date', 'value': data['expiryDate'] ?? '-'},
        {'label': 'Created At', 'value': data['createdAt'] ?? '-'},
        {'label': 'Is Featured', 'value': data['isFeatured'] ?? '-'},
        {'label': 'User ID', 'value': data['userId'] ?? '-'},
        {'label': 'View Count', 'value': data['viewCount'] ?? '-'},
        {
          'label': 'Accessible Profiles',
          'value': data['accessibleProfiles'] ?? '-',
        },
      ];

      return Column(
        children: [
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
            backgroundImage:
                (data['photo'] != null && data['photo'].toString().isNotEmpty)
                ? NetworkImage(data['photo'])
                : null,
            child: (data['photo'] == null || data['photo'].toString().isEmpty)
                ? Icon(
                    Icons.account_circle,
                    size: 80,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            data['name'] ?? 'My Profile',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            data['gender'] ?? '',
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
          const Divider(height: 30),
          buildRow('Age', data['age']),
          buildRow('Place', data['place']),
          buildRow('Education', data['education']),
          buildRow('Occupation', data['occupation']),
          buildRow('Hobbies', data['hobbies']),
          buildRow('About', data['about']),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => setState(() => _showHidden = !_showHidden),
            icon: const Icon(Icons.info_outline),
            label: Text(_showHidden ? 'Hide More Info' : 'Show More Info'),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showHidden
                ? Card(
                    key: const ValueKey('hiddenInfo'),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: hiddenFields
                            .map((f) => buildRow(f['label'], f['value']))
                            .toList(),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Matrimony Profile'),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              // TODO: Add navigation to edit screen
            },
          ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: userStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: buildProfile(data),
          );
        },
      ),
    );
  }
}
