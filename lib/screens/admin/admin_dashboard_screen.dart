// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AdminDashboardScreen extends StatelessWidget {
//   const AdminDashboardScreen({super.key});

//   Future<int> _getClassifiedsCount() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection("classifieds")
//         .get();
//     return snapshot.size; // returns total documents in "classifieds"
//   }

//   Future<int> _getMatrimonyCount() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection("matrimony")
//         .get();
//     return snapshot.size;
//   }

//   Future<int> _getUsersCount() async {
//     final snapshot = await FirebaseFirestore.instance.collection("users").get();
//     return snapshot.size;
//   }

//   Future<int> _getMessagesCount() async {
//     final snapshot = await FirebaseFirestore.instance
//         .collection("messages")
//         .get();
//     return snapshot.size;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text("Admin Dashboard"),
//         centerTitle: true,
//       ),

//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Text(
//                 "Admin Menu",
//                 style: TextStyle(color: Colors.white, fontSize: 20),
//               ),
//             ),
//             _drawerItem(
//               context,
//               Icons.dashboard,
//               "Dashboard",
//               "/adminDashboard",
//             ),
//             _drawerItem(
//               context,
//               Icons.shopping_bag,
//               "Manage Classifieds",
//               "/manageClassifieds",
//             ),
//             _drawerItem(
//               context,
//               Icons.favorite,
//               "Manage Matrimony",
//               "/manageMatrimony",
//             ),
//             _drawerItem(context, Icons.people, "Manage Users", "/manageUsers"),
//             _drawerItem(context, Icons.message, "Messages", "/messages"),
//             _drawerItem(
//               context,
//               Icons.notifications,
//               "Notifications",
//               "/notifications",
//             ),
//             _drawerItem(
//               context,
//               Icons.article,
//               "FAQ / Terms / Privacy",
//               "/contentPages",
//             ),
//             _drawerItem(context, Icons.settings, "Settings", "/adminSettings"),
//           ],
//         ),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 📊 Stats Section with FutureBuilder
//             Row(
//               children: [
//                 Expanded(
//                   child: FutureBuilder<int>(
//                     future: _getClassifiedsCount(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const _StatsCard(
//                           title: "Total Classifieds",
//                           count: 0,
//                           isLoading: true,
//                         );
//                       } else if (snapshot.hasError) {
//                         return const _StatsCard(title: "Classifieds", count: 0);
//                       } else {
//                         return _StatsCard(
//                           title: "Total Classifieds",
//                           count: snapshot.data ?? 0,
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: FutureBuilder<int>(
//                     future: _getMatrimonyCount(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const _StatsCard(
//                           title: "Matrimony",
//                           count: 0,
//                           isLoading: true,
//                         );
//                       } else if (snapshot.hasError) {
//                         return const _StatsCard(title: "Matrimony", count: 0);
//                       } else {
//                         return _StatsCard(
//                           title: "Matrimony",
//                           count: snapshot.data ?? 0,
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: FutureBuilder<int>(
//                     future: _getUsersCount(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const _StatsCard(
//                           title: "Users",
//                           count: 0,
//                           isLoading: true,
//                         );
//                       } else if (snapshot.hasError) {
//                         return const _StatsCard(title: "Users", count: 0);
//                       } else {
//                         return _StatsCard(
//                           title: "Users",
//                           count: snapshot.data ?? 0,
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: FutureBuilder<int>(
//                     future: _getMessagesCount(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const _StatsCard(
//                           title: "Messages",
//                           count: 0,
//                           isLoading: true,
//                         );
//                       } else if (snapshot.hasError) {
//                         return const _StatsCard(title: "Messages", count: 0);
//                       } else {
//                         return _StatsCard(
//                           title: "Messages",
//                           count: snapshot.data ?? 0,
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // ⚡ Quick Actions Grid
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//                 children: [
//                   _DashboardTile(
//                     icon: Icons.shopping_bag,
//                     title: "Manage Classifieds",
//                     onTap: () =>
//                         Navigator.pushNamed(context, "/manageClassifieds"),
//                   ),
//                   _DashboardTile(
//                     icon: Icons.favorite,
//                     title: "Manage Matrimony",
//                     onTap: () =>
//                         Navigator.pushNamed(context, "/manageMatrimony"),
//                   ),
//                   _DashboardTile(
//                     icon: Icons.people,
//                     title: "Manage Users",
//                     onTap: () => Navigator.pushNamed(context, "/manageUsers"),
//                   ),
//                   _DashboardTile(
//                     icon: Icons.notifications,
//                     title: "Notifications",
//                     onTap: () => Navigator.pushNamed(context, "/notifications"),
//                   ),
//                   _DashboardTile(
//                     icon: Icons.message,
//                     title: "Messages",
//                     onTap: () =>
//                         Navigator.pushNamed(context, "/delete_request"),
//                   ),
//                   _DashboardTile(
//                     icon: Icons.article,
//                     title: "FAQ / Terms / Privacy",
//                     onTap: () => Navigator.pushNamed(context, "/contentPages"),
//                   ),
//                   _DashboardTile(
//                     icon: Icons.settings,
//                     title: "Settings",
//                     onTap: () => Navigator.pushNamed(context, "/adminSettings"),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   ListTile _drawerItem(
//     BuildContext context,
//     IconData icon,
//     String title,
//     String route,
//   ) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.pushNamed(context, route);
//       },
//     );
//   }
// }

// // 🔹 Dashboard Tiles (Grid)
// class _DashboardTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;

//   const _DashboardTile({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
//             const SizedBox(height: 12),
//             Text(title, style: const TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 🔹 Stats Card (for quick numbers)
// class _StatsCard extends StatelessWidget {
//   final String title;
//   final int count;
//   final bool isLoading;

//   const _StatsCard({
//     required this.title,
//     required this.count,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             isLoading
//                 ? const CircularProgressIndicator()
//                 : Text(
//                     "$count",
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//             const SizedBox(height: 8),
//             Text(title, style: Theme.of(context).textTheme.bodyMedium),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // NEW: Function to aggregate classifieds count from ALL user subcollections
  Future<int> _getClassifiedsCount() async {
    // 1. Get a reference to all user documents
    final usersSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .get();

    int totalClassifieds = 0;

    // 2. Iterate through each user document
    for (var userDoc in usersSnapshot.docs) {
      // 3. Get the 'classifieds' subcollection for that specific user
      final classifiedsSnapshot = await userDoc.reference
          .collection('classifieds')
          .get();

      // 4. Add the count of ads for this user to the total
      totalClassifieds += classifiedsSnapshot.size;
    }

    return totalClassifieds;
  }

  // --- EXISTING FUNCTIONS (Unchanged, as they target top-level collections) ---

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

  // --- END OF EXISTING FUNCTIONS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Admin Menu",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            _drawerItem(
              context,
              Icons.dashboard,
              "Dashboard",
              "/adminDashboard",
            ),
            _drawerItem(
              context,
              Icons.shopping_bag,
              "Manage Classifieds",
              "/manageClassifieds",
            ),
            _drawerItem(
              context,
              Icons.favorite,
              "Manage Matrimony",
              "/manageMatrimony",
            ),
            _drawerItem(context, Icons.people, "Manage Users", "/manageUsers"),
            _drawerItem(context, Icons.message, "Messages", "/messages"),
            _drawerItem(
              context,
              Icons.notifications,
              "Notifications",
              "/notifications",
            ),
            _drawerItem(
              context,
              Icons.article,
              "FAQ / Terms / Privacy",
              "/contentPages",
            ),
            _drawerItem(context, Icons.settings, "Settings", "/adminSettings"),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 Stats Section with FutureBuilder
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getClassifiedsCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _StatsCard(
                          title: "Total Classifieds",
                          count: 0,
                          isLoading: true,
                        );
                      } else if (snapshot.hasError) {
                        // Print error for debugging
                        // print('Error loading classifieds count: ${snapshot.error}');
                        return const _StatsCard(title: "Classifieds", count: 0);
                      } else {
                        return _StatsCard(
                          title: "Total Classifieds",
                          count: snapshot.data ?? 0,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getMatrimonyCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _StatsCard(
                          title: "Matrimony",
                          count: 0,
                          isLoading: true,
                        );
                      } else if (snapshot.hasError) {
                        return const _StatsCard(title: "Matrimony", count: 0);
                      } else {
                        return _StatsCard(
                          title: "Matrimony",
                          count: snapshot.data ?? 0,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getUsersCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _StatsCard(
                          title: "Users",
                          count: 0,
                          isLoading: true,
                        );
                      } else if (snapshot.hasError) {
                        return const _StatsCard(title: "Users", count: 0);
                      } else {
                        return _StatsCard(
                          title: "Users",
                          count: snapshot.data ?? 0,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getMessagesCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _StatsCard(
                          title: "Messages",
                          count: 0,
                          isLoading: true,
                        );
                      } else if (snapshot.hasError) {
                        return const _StatsCard(title: "Messages", count: 0);
                      } else {
                        return _StatsCard(
                          title: "Messages",
                          count: snapshot.data ?? 0,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ⚡ Quick Actions Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _DashboardTile(
                    icon: Icons.shopping_bag,
                    title: "Manage Classifieds",
                    onTap: () =>
                        Navigator.pushNamed(context, "/manageClassifieds"),
                  ),
                  _DashboardTile(
                    icon: Icons.favorite,
                    title: "Manage Matrimony",
                    onTap: () =>
                        Navigator.pushNamed(context, "/manageMatrimony"),
                  ),
                  _DashboardTile(
                    icon: Icons.people,
                    title: "Manage Users",
                    onTap: () => Navigator.pushNamed(context, "/manageUsers"),
                  ),
                  _DashboardTile(
                    icon: Icons.notifications,
                    title: "Notifications",
                    onTap: () => Navigator.pushNamed(context, "/notifications"),
                  ),
                  _DashboardTile(
                    icon: Icons.message,
                    title: "Messages",
                    onTap: () =>
                        Navigator.pushNamed(context, "/delete_request"),
                  ),
                  _DashboardTile(
                    icon: Icons.article,
                    title: "FAQ / Terms / Privacy",
                    onTap: () => Navigator.pushNamed(context, "/contentPages"),
                  ),
                  _DashboardTile(
                    icon: Icons.settings,
                    title: "Settings",
                    onTap: () => Navigator.pushNamed(context, "/adminSettings"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}

// 🔹 Dashboard Tiles (Grid)
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// 🔹 Stats Card (for quick numbers)
class _StatsCard extends StatelessWidget {
  final String title;
  final int count;
  final bool isLoading;

  const _StatsCard({
    required this.title,
    required this.count,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            isLoading
                ? const CircularProgressIndicator()
                : Text(
                    "$count",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
