import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({super.key});

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool isSaving = false;
  String? editingId; // null means creating new, otherwise editing

  Future<void> _saveNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) return;

    setState(() => isSaving = true);

    try {
      if (editingId == null) {
        // Create new
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': _titleController.text,
          'body': _bodyController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(editingId)
            .update({
              'title': _titleController.text,
              'body': _bodyController.text,
            });
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _editNotification(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    _titleController.text = data['title'] ?? '';
    _bodyController.text = data['body'] ?? '';
    setState(() => editingId = doc.id);
  }

  Future<void> _deleteNotification(String id) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .delete();
  }

  void _clearForm() {
    _titleController.clear();
    _bodyController.clear();
    setState(() => editingId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: "Body"),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isSaving ? null : _saveNotification,
                  child: isSaving
                      ? const CircularProgressIndicator()
                      : Text(editingId == null ? "Add Notification" : "Update"),
                ),
                const SizedBox(width: 12),
                if (editingId != null)
                  TextButton(
                    onPressed: _clearForm,
                    child: const Text("Cancel Edit"),
                  ),
              ],
            ),
            const Divider(height: 24),

            // List of notifications
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No notifications found"));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(data['title'] ?? "No title"),
                          subtitle: Text(data['body'] ?? ""),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editNotification(doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteNotification(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
