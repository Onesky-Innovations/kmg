import 'package:flutter/material.dart';
import 'package:kmg/screens/legal/contact_support_screen.dart';
import 'package:kmg/screens/matrimony/widgets/info_message_button.dart';

class MatrimonyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, dynamic>? loggedInUser;
  final VoidCallback onLogout;
  final Future<void> Function() requireLogin;
  final VoidCallback onProfileTap;

  const MatrimonyAppBar({
    super.key,
    required this.loggedInUser,
    required this.onLogout,
    required this.requireLogin,
    required this.onProfileTap,
  });

  @override
  State<MatrimonyAppBar> createState() => _MatrimonyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MatrimonyAppBarState extends State<MatrimonyAppBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // auto-show message logic here if needed
      // e.g., call a method in InfoMessageButton via a key
    });
  }

  /// Displays a confirmation dialog before logging out.
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Confirm Logout'),
          content: const Text(
            'Are you sure you want to log out of your account?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black54),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                widget.onLogout(); // Perform the logout action
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text("KMG Matrimony"),
      centerTitle: false,
      actions: [
        // Contact Support Button (Always visible)
        IconButton(
          icon: Icon(
            Icons.headphones_outlined,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactSupportScreen(
                  // widget.loggedInUser?['id']?.toString() ?? 'guest',
                ),
              ),
            );
          },
        ),

        // --- Logged-In State Widgets ---
        if (widget.loggedInUser != null) ...[
          // Profile Icon Button
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: theme.colorScheme.onPrimary,
            ),
            onPressed: widget.onProfileTap, // Use the new callback
          ),

          // User Name Display
          Center(
            child: GestureDetector(
              onTap: widget.onProfileTap,
              child: Text(
                widget.loggedInUser!['name']?.toString() ?? 'User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                  decoration:
                      TextDecoration.underline, // optional, indicates tappable
                ),
              ),
            ),
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            // Call the confirmation method instead of direct logout
            onPressed: _confirmLogout,
          ),
        ]
        // --- Logged-Out State Widgets ---
        else ...[
          // Info Message Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InfoMessageButton(
              message: "Login to see more personalized features",
            ),
          ),

          // Login Icon Button
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => widget.requireLogin(),
          ),
        ],
      ],
    );
  }
}
