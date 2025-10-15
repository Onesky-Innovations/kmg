import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  // Store all users fetched from Firebase
  List<DocumentSnapshot> _allUsers = [];
  // Store the list of users currently displayed (after search/filter)
  List<DocumentSnapshot> _displayedUsers = [];
  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  // --- Firebase Fetch Function ---
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .get();

      setState(() {
        _allUsers = usersSnapshot.docs;
        _displayedUsers = _allUsers; // Initially display all users
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Search Functionality ---
  void _filterUsers() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _displayedUsers = _allUsers;
      });
    } else {
      setState(() {
        _displayedUsers = _allUsers.where((user) {
          final userData = user.data() as Map<String, dynamic>;
          final name = userData['name']?.toLowerCase() ?? '';
          final email = userData['email']?.toLowerCase() ?? '';

          // Search by name or email
          return name.contains(query) || email.contains(query);
        }).toList();
      });
    }
  }

  // --- Delete Functionality ---
  Future<void> _deleteUser(String userId, String userEmail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the user: $userEmail? This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 1. Delete Firestore Document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        // Note: You must manually delete the user account from Firebase Authentication
        // using the Firebase Admin SDK on your server side, as direct client-side
        // deletion of *other* users is not allowed for security reasons.

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully from Firestore!'),
            ),
          );
        }
        // Refresh the list
        _fetchUsers();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error deleting user: $e\n(Authentication account must be deleted on server.)',
              ),
            ),
          );
        }
      }
    }
  }

  // --- Edit/View Details Functionality ---
  void _editUser(DocumentSnapshot userDoc) {
    // Navigate to a separate screen to view/edit user details
    // You'll need to create this screen: UserDetailScreen
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('User Details')),
              body: Center(
                child: Text(
                  'Details for User ID: ${userDoc.id}\n'
                  'Email: ${(userDoc.data() as Map<String, dynamic>)['email']}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // If you had a dedicated screen, it would look like this:
            // builder: (context) => UserDetailScreen(userId: userDoc.id),
          ),
        )
        .then((_) {
          // Refresh the user list when returning from the detail screen
          _fetchUsers();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          // Refresh Button
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchUsers),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or Email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedUsers.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'No users found.'
                          : 'No users matching "${_searchController.text}"',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _displayedUsers.length,
                    itemBuilder: (context, index) {
                      final userDoc = _displayedUsers[index];
                      final userData = userDoc.data() as Map<String, dynamic>?;

                      // Safely extract data
                      final name = userData?['name'] ?? 'N/A';
                      final email = userData?['email'] ?? 'No Email';
                      final isAdmin = userData?['admin'] == true
                          ? ' (Admin)'
                          : '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(name[0].toUpperCase()),
                          ),
                          title: Text('$name$isAdmin'),
                          subtitle: Text(email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit Button
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _editUser(userDoc),
                                tooltip: 'Edit User',
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteUser(userDoc.id, email),
                                tooltip: 'Delete User',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
