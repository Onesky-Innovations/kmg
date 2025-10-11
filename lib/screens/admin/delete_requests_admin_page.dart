import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteRequestsAdminPage extends StatefulWidget {
  const DeleteRequestsAdminPage({super.key});

  @override
  State<DeleteRequestsAdminPage> createState() =>
      _DeleteRequestsAdminPageState();
}

class _DeleteRequestsAdminPageState extends State<DeleteRequestsAdminPage> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account Deletion Requests",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('delete_requests')
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No deletion requests found."));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              final userId = data['userId'] ?? 'N/A';
              final email = data['email'] ?? 'N/A';
              final name = data['name'] ?? 'Unknown';
              final reason = data['reason'] ?? 'No reason provided';
              final status = data['status'] ?? 'Pending';
              final timestamp = (data['requestedAt'] != null)
                  ? (data['requestedAt'] as Timestamp).toDate()
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: $email"),
                      Text("User ID: $userId"),
                      Text("Reason: $reason"),
                      if (timestamp != null)
                        Text(
                          "Requested At: ${timestamp.toString().split(' ').first}",
                        ),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          color: status == "Pending"
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == "mark_deleted") {
                        _markAsDeleted(doc.id);
                      } else if (value == "delete_user") {
                        _deleteUserData(userId, doc.id);
                      }
                    },
                    itemBuilder: (context) => [
                      if (status == "Pending")
                        const PopupMenuItem(
                          value: "mark_deleted",
                          child: Text("Mark as Deleted"),
                        ),
                      const PopupMenuItem(
                        value: "delete_user",
                        child: Text("Delete User Account"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ✅ Mark the request as processed in Firestore
  Future<void> _markAsDeleted(String docId) async {
    try {
      await _firestore.collection('delete_requests').doc(docId).update({
        'status': 'Deleted',
        'processedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Marked as Deleted ✅")));
    } catch (e) {
      debugPrint("Error updating request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update request.")),
      );
    }
  }

  /// ⚠️ Optional: Delete user data (Firestore + Auth)
  Future<void> _deleteUserData(String userId, String requestId) async {
    try {
      // Delete user's Firestore profile (if exists)
      await _firestore.collection('users').doc(userId).delete();

      // Optionally mark delete request as completed
      await _firestore.collection('delete_requests').doc(requestId).update({
        'status': 'Deleted',
        'processedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User $userId data deleted.")));
    } catch (e) {
      debugPrint("Error deleting user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete user data.")),
      );
    }
  }
}
