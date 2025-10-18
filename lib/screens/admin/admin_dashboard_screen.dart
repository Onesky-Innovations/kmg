import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --------------------------------------------------------------------------
// ADMIN DASHBOARD SCREEN (Refactored)
// --------------------------------------------------------------------------

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Data fetching functions (Kept unchanged, as they are backend logic)
  Future<int> _getClassifiedsCount() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .get();
    int totalClassifieds = 0;
    for (var userDoc in usersSnapshot.docs) {
      final classifiedsSnapshot = await userDoc.reference
          .collection('classifieds')
          .get();
      totalClassifieds += classifiedsSnapshot.size;
    }
    return totalClassifieds;
  }

  Future<int> _getMatrimonyCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("matrimony")
        .get();
    return snapshot.size;
  }

  Future<int> _getUsersCount() async {
    final snapshot = await FirebaseFirestore.instance.collection("users").get();
    return snapshot.size;
  }

  Future<int> _getMessagesCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("messages")
        .get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The default AppBarTheme is now used, so we remove manual colors
        title: const Text("Admin Dashboard"),
      ),
      body: SingleChildScrollView(
        // Changed to SingleChildScrollView for safety
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------
            // QUICK STATS SECTION
            // ------------------
            Text(
              "Quick Stats 📊",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // Row 1 of Stats Cards
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getUsersCount(), // Moved Users to the top
                    builder: (context, snapshot) {
                      return _StatsCard(
                        title: "Total Users",
                        icon: Icons.groups_rounded,
                        count: snapshot.data ?? 0,
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
                        error: snapshot.hasError,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getClassifiedsCount(),
                    builder: (context, snapshot) {
                      return _StatsCard(
                        title: "Classifieds",
                        icon: Icons.gavel_rounded,
                        count: snapshot.data ?? 0,
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
                        error: snapshot.hasError,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2 of Stats Cards
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getMatrimonyCount(),
                    builder: (context, snapshot) {
                      return _StatsCard(
                        title: "Matrimony Profiles",
                        icon: Icons.favorite_rounded,
                        count: snapshot.data ?? 0,
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
                        error: snapshot.hasError,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getMessagesCount(),
                    builder: (context, snapshot) {
                      return _StatsCard(
                        title: "Total Messages",
                        icon: Icons.mail_outline_rounded,
                        count: snapshot.data ?? 0,
                        isLoading:
                            snapshot.connectionState == ConnectionState.waiting,
                        error: snapshot.hasError,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ------------------
            // QUICK ACTIONS SECTION
            // ------------------
            Text(
              "Quick Actions ✨",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // Action Tiles Grid
            GridView.count(
              shrinkWrap:
                  true, // Important for a GridView inside a Column/SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Disable grid scrolling
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2, // Taller tiles look better
              children: [
                _DashboardTile(
                  icon: Icons.shopping_bag_outlined,
                  title: "Manage Classifieds",
                  onTap: () =>
                      Navigator.pushNamed(context, "/manageClassifieds"),
                ),
                _DashboardTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: "Manage Matrimony",
                  onTap: () => Navigator.pushNamed(context, "/manageMatrimony"),
                ),
                _DashboardTile(
                  icon: Icons.people_outline_rounded,
                  title: "Manage Users",
                  onTap: () =>
                      Navigator.pushNamed(context, "/ManageUsersScreen"),
                ),
                _DashboardTile(
                  icon: Icons.notifications_none_rounded,
                  title: "Send Notifications",
                  onTap: () => Navigator.pushNamed(context, "/notifications"),
                ),
                _DashboardTile(
                  icon: Icons.delete_outline_rounded,
                  title: "Deletion Requests", // Renamed for clarity
                  onTap: () => Navigator.pushNamed(context, "/deleteRequests"),
                ),
                _DashboardTile(
                  icon: Icons.article_outlined,
                  title: "FAQ", // Renamed for clarity
                  onTap: () => Navigator.pushNamed(context, "/faqscreen"),
                ),
                _DashboardTile(
                  icon: Icons.settings_outlined,
                  title: "App Settings", // Renamed for clarity
                  onTap: () => Navigator.pushNamed(context, "/settingsscreen"),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// REFACTORED STATS CARD (More professional look)
// --------------------------------------------------------------------------
class _StatsCard extends StatelessWidget {
  final String title;
  final int count;
  final bool isLoading;
  final bool error;
  final IconData icon;

  const _StatsCard({
    required this.title,
    required this.count,
    this.isLoading = false,
    this.error = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return Card(
      elevation: 4, // Higher elevation for prominence
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: primaryColor),
                // Display count or loading indicator
                error
                    ? Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      )
                    : isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      )
                    : Text(
                        "$count",
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: onSurfaceColor,
                            ),
                      ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              error ? "Error loading data" : "Total count",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// REFACTORED DASHBOARD TILE (Cleaner look with subtle hover effect)
// --------------------------------------------------------------------------
class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Slight elevation
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Match Card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(
                  context,
                ).colorScheme.primary, // Use primary color
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
