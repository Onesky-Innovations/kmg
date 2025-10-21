// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// import 'EditProfileScreen.dart';
// import 'settings_screen.dart';
// import 'sign_in_screen.dart';
// import 'sign_up_screen.dart';
// import '../admin/admin_dashboard_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool isLoggedIn = false;
//   bool isAdmin = false;
//   String userName = "Guest User";
//   String? profilePic;
//   bool isPrivate = false;
//   bool notificationsEnabled = true;
//   bool isLoading = true;
//   bool hasInternet = true;

//   late StreamSubscription _connSub;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUser();

//     // 🔌 Listen to internet changes
//     _connSub = Connectivity().onConnectivityChanged.listen((result) {
//       final online = result != ConnectivityResult.none;
//       if (!mounted) return;
//       setState(() => hasInternet = online);

//       if (!online) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("⚠️ No Internet Connection")),
//         );
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("✅ Back Online")));
//         _fetchUser(); // refresh when back online
//       }
//     });
//   }

//   Future<void> _fetchUser() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);

//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         final doc = await _firestore.collection('users').doc(user.uid).get();

//         if (doc.exists) {
//           final data = doc.data()!;
//           if (!mounted) return;
//           setState(() {
//             isLoggedIn = true;
//             isAdmin = data['admin'] == true;
//             userName = data['name'] ?? "User";
//             profilePic = (data['profilePhoto'] as String?)?.isNotEmpty == true
//                 ? data['profilePhoto']
//                 : null;
//           });
//         }
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("⚠️ Error loading profile: $e")));
//     } finally {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }

//   void _login() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const SignInScreen(fromFab: false)),
//     );

//     if (result != null && result['signedIn'] == true) {
//       await _fetchUser();
//       setState(() {
//         isAdmin = result['isAdmin'] ?? false;
//       });

//       if (isAdmin) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
//         );
//       }
//     }
//   }

//   void _signup() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const SignUpScreen(fromFab: false)),
//     );

//     if (result == true) await _fetchUser();
//   }

//   void _logout() async {
//     await _auth.signOut();
//     setState(() {
//       isLoggedIn = false;
//       isAdmin = false;
//       userName = "Guest User";
//       profilePic = null;
//       isPrivate = false;
//       notificationsEnabled = true;
//     });
//   }

//   void _editProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditProfileScreen(userId: _auth.currentUser!.uid),
//       ),
//     ).then((_) => _fetchUser());
//   }

//   @override
//   void dispose() {
//     _connSub.cancel(); // 🔴 stop internet listener
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // 🔴 Internet Banner
//           if (!hasInternet)
//             Container(
//               width: double.infinity,
//               color: Colors.red,
//               padding: const EdgeInsets.all(8),
//               child: const Text(
//                 "No Internet Connection",
//                 style: TextStyle(color: Colors.white),
//                 textAlign: TextAlign.center,
//               ),
//             ),

//           Expanded(
//             child: Stack(
//               children: [
//                 ListView(
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     Center(
//                       child: Column(
//                         children: [
//                           CircleAvatar(
//                             radius: 50,
//                             backgroundImage: profilePic != null
//                                 ? NetworkImage(profilePic!)
//                                 : null,
//                             child: profilePic == null
//                                 ? const Icon(Icons.person, size: 50)
//                                 : null,
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             userName,
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           if (!isLoggedIn)
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: _login,
//                                   child: const Text("Sign In"),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 ElevatedButton(
//                                   onPressed: _signup,
//                                   child: const Text("Sign Up"),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     if (isLoggedIn && isAdmin)
//                       ListTile(
//                         leading: const Icon(Icons.admin_panel_settings),
//                         title: const Text("Admin Panel"),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const AdminDashboardScreen(),
//                             ),
//                           );
//                         },
//                       ),

//                     const Divider(),
//                     ListTile(
//                       leading: const Icon(Icons.help_outline),
//                       title: const Text("FAQ"),
//                       onTap: () {},
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.support_agent),
//                       title: const Text("Contact Support"),
//                       onTap: () {},
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.description),
//                       title: const Text("Terms & Conditions"),
//                       onTap: () {},
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.privacy_tip),
//                       title: const Text("Privacy Policy"),
//                       onTap: () {},
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.star_rate),
//                       title: const Text("Rate the App"),
//                       onTap: () {},
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.settings),
//                       title: const Text("Settings"),
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const SettingsScreen(),
//                         ),
//                       ),
//                     ),
//                     const Divider(),
//                     if (isLoggedIn)
//                       ListTile(
//                         leading: const Icon(Icons.logout, color: Colors.red),
//                         title: const Text(
//                           "Log Out",
//                           style: TextStyle(color: Colors.red),
//                         ),
//                         onTap: _logout,
//                       ),
//                   ],
//                 ),

//                 if (isLoggedIn)
//                   Positioned(
//                     right: 2,
//                     top: 20,
//                     child: PopupMenuButton(
//                       icon: const Icon(Icons.more_vert, size: 24),
//                       itemBuilder: (_) => [
//                         PopupMenuItem(
//                           value: 'edit',
//                           child: Row(
//                             children: const [
//                               Icon(Icons.edit),
//                               SizedBox(width: 10),
//                               Text('Edit Profile'),
//                             ],
//                           ),
//                         ),
//                       ],
//                       onSelected: (value) {
//                         if (value == 'edit') _editProfile();
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:provider/provider.dart';

// import 'package:kmg/screens/ads/MyAdsScreen.dart';
// import 'package:kmg/screens/legal/contact_support_screen.dart';
// import 'package:kmg/screens/legal/privacy_screen.dart';
// import 'package:kmg/screens/legal/terms_screen.dart';
// import 'package:kmg/screens/saved/saveditems.dart';
// import 'package:kmg/screens/legal/faq_screen.dart';
// import 'package:kmg/providers/theme_provider.dart';
// import '../admin/admin_dashboard_screen.dart';
// import 'EditProfileScreen.dart';
// import 'settings_screen.dart';
// import 'sign_in_screen.dart';
// import 'sign_up_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool isLoggedIn = false;
//   bool isAdmin = false;
//   String userName = "Guest User";
//   String? profilePic;
//   bool isLoading = true;
//   bool hasInternet = true;
//   late StreamSubscription _connSub;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUser();

//     _connSub = Connectivity().onConnectivityChanged.listen((result) {
//       final online = result != ConnectivityResult.none;
//       if (!mounted) return;
//       setState(() => hasInternet = online);

//       if (!online) {
//         _showSnackbar("⚠️ No Internet Connection", Colors.red);
//       } else {
//         _showSnackbar("✅ Back Online", Colors.green);
//         _fetchUser();
//       }
//     });
//   }

//   void _showSnackbar(String message, [Color? color]) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   Future<void> _fetchUser() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);

//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         final doc = await _firestore.collection('users').doc(user.uid).get();
//         if (doc.exists) {
//           final data = doc.data()!;
//           if (!mounted) return;
//           setState(() {
//             isLoggedIn = true;
//             isAdmin = data['admin'] == true;
//             userName = data['name'] ?? "User";
//             profilePic = (data['profilePhoto'] as String?)?.isNotEmpty == true
//                 ? data['profilePhoto']
//                 : null;
//           });
//         }
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showSnackbar("Error loading profile", Colors.red);
//     } finally {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }

//   void _login() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const SignInScreen(fromFab: false)),
//     );

//     if (result != null && result['signedIn'] == true) {
//       await _fetchUser();
//       setState(() => isAdmin = result['isAdmin'] ?? false);

//       if (isAdmin) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
//         );
//       }
//     }
//   }

//   void _signup() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const SignUpScreen(fromFab: false)),
//     );

//     if (result == true) await _fetchUser();
//   }

//   void _logout() async {
//     await _auth.signOut();
//     setState(() {
//       isLoggedIn = false;
//       isAdmin = false;
//       userName = "Guest User";
//       profilePic = null;
//     });
//   }

//   void _editProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditProfileScreen(userId: _auth.currentUser!.uid),
//       ),
//     ).then((_) => _fetchUser());
//   }

//   @override
//   void dispose() {
//     _connSub.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDarkMode = themeProvider.isDarkMode;

//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 24.0,
//         backgroundColor: Colors.transparent,
//         // Set elevation to 0 to remove the shadow line
//         elevation: 0.0,
//         // title: const Text("Profile"),
//         actions: [
//           if (isLoggedIn)
//             PopupMenuButton(
//               icon: const Icon(Icons.more_vert),
//               itemBuilder: (_) => [
//                 const PopupMenuItem(
//                   value: 'edit',
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit),
//                       SizedBox(width: 10),
//                       Text('Edit Profile'),
//                     ],
//                   ),
//                 ),
//               ],
//               onSelected: (value) {
//                 if (value == 'edit') _editProfile();
//               },
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (!hasInternet)
//             Container(
//               width: double.infinity,
//               color: Colors.red,
//               padding: const EdgeInsets.all(8),
//               child: const Text(
//                 "No Internet Connection",
//                 style: TextStyle(color: Colors.white),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 Center(
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 50,
//                         backgroundImage: profilePic != null
//                             ? NetworkImage(profilePic!)
//                             : null,
//                         child: profilePic == null
//                             ? const Icon(Icons.person, size: 50)
//                             : null,
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         userName,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       if (!isLoggedIn)
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             ElevatedButton(
//                               onPressed: _login,
//                               child: const Text("Sign In"),
//                             ),
//                             const SizedBox(width: 12),
//                             ElevatedButton(
//                               onPressed: _signup,
//                               child: const Text("Sign Up"),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 if (isLoggedIn && isAdmin)
//                   ListTile(
//                     leading: const Icon(Icons.admin_panel_settings),
//                     title: const Text("Admin Panel"),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const AdminDashboardScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 const Divider(),
//                 ListTile(
//                   leading: const Icon(Icons.help_outline),
//                   title: const Text("FAQ"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const FAQScreen()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.headphones_outlined),
//                   title: const Text("Contact Support"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ContactSupportScreen('general'),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.description),
//                   title: const Text("Terms & Conditions"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const TermsScreen()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.policy),
//                   title: const Text("Privacy Policy"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const PrivacyPolicyScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.bookmark),
//                   title: const Text("Saved Items"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const SavedItemsScreen(),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.ads_click),
//                   title: const Text("My Ads"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const MyAdsScreen()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.settings),
//                   title: const Text("Settings"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SettingsScreen()),
//                     );
//                   },
//                 ),
//                 const Divider(),
//                 if (isLoggedIn)
//                   ListTile(
//                     leading: const Icon(Icons.logout, color: Colors.red),
//                     title: const Text(
//                       "Log Out",
//                       style: TextStyle(color: Colors.red),
//                     ),
//                     onTap: _logout,
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kmg/screens/know_more/know_more_screen.dart';
import 'package:provider/provider.dart';

import 'package:kmg/screens/ads/MyAdsScreen.dart';
import 'package:kmg/screens/legal/contact_support_screen.dart';
import 'package:kmg/screens/legal/privacy_screen.dart';
import 'package:kmg/screens/legal/terms_screen.dart';
import 'package:kmg/screens/ads/saved/saveditems.dart';
import 'package:kmg/screens/legal/faq_screen.dart';
import 'package:kmg/providers/theme_provider.dart'; // Keep this import
import '../admin/admin_dashboard_screen.dart';
import 'EditProfileScreen.dart';
import 'settings_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoggedIn = false;
  bool isAdmin = false;
  String userName = "Guest User";
  String? profilePic;
  bool isLoading = true;
  bool hasInternet = true;
  late StreamSubscription _connSub;

  // --- LOGIC FUNCTIONS (UNCHANGED) ---

  @override
  void initState() {
    super.initState();
    _fetchUser();

    _connSub = Connectivity().onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      if (!mounted) return;
      setState(() => hasInternet = online);

      if (!online) {
        _showSnackbar("⚠️ No Internet Connection", Colors.red);
      } else {
        _showSnackbar("✅ Back Online", Colors.green);
        _fetchUser();
      }
    });
  }

  void _showSnackbar(String message, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _fetchUser() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          if (!mounted) return;
          setState(() {
            isLoggedIn = true;
            isAdmin = data['admin'] == true;
            userName = data['name'] ?? "User";
            profilePic = (data['profilePhoto'] as String?)?.isNotEmpty == true
                ? data['profilePhoto']
                : null;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      // Using context's theme for better professional feel
      final errorColor = Theme.of(context).colorScheme.error;
      _showSnackbar("Error loading profile", errorColor);
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _login() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen(fromFab: false)),
    );

    if (result != null && result['signedIn'] == true) {
      await _fetchUser();
      setState(() => isAdmin = result['isAdmin'] ?? false);

      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
    }
  }

  void _signup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen(fromFab: false)),
    );

    if (result == true) await _fetchUser();
  }

  void _logout() async {
    await _auth.signOut();
    setState(() {
      isLoggedIn = false;
      isAdmin = false;
      userName = "Guest User";
      profilePic = null;
    });
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(userId: _auth.currentUser!.uid),
      ),
    ).then((_) => _fetchUser());
  }

  @override
  void dispose() {
    _connSub.cancel();
    super.dispose();
  }

  // ------------------------------------
  // BUILD METHOD (VISUAL REFINEMENT)
  // ------------------------------------

  @override
  Widget build(BuildContext context) {
    // Access ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      // AppBar is minimal, giving focus to the profile header
      appBar: AppBar(
        toolbarHeight: 32.0,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: [
          // Edit Profile button
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black87),
              onPressed: _editProfile,
              tooltip: 'Edit Profile',
            ),
          // Dark/Light Mode Toggle Button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.sunny,
              color: Theme.of(context).colorScheme.primary, // ✅ dynamic color
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
            tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          // Internet Connection Status Banner (Improved Design)
          if (!hasInternet)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "❌ OFFLINE MODE",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // 1. PROFILE HEADER SECTION (More prominent)
                Center(
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor,
                            width: 3, // Highlight border
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: secondaryColor.withOpacity(0.1),
                          backgroundImage: profilePic != null
                              ? NetworkImage(profilePic!)
                              : null,
                          child: profilePic == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 50,
                                  color: primaryColor,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),

                      const SizedBox(height: 16),

                      // Auth Buttons (if not logged in)
                      if (!isLoggedIn)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  // Uses the elevatedButtonTheme style
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                onPressed: _login,
                                icon: const Icon(Icons.login),
                                label: const Text("Sign In"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor),
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                onPressed: _signup,
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text("Sign Up"),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. USER ACTIONS SECTION
                const _SectionHeader(title: "Account & Activity"),
                const SizedBox(height: 8),

                if (isLoggedIn && isAdmin)
                  _ProfileTile(
                    icon: Icons.admin_panel_settings_rounded,
                    title: "Admin Dashboard",
                    color: primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardScreen(),
                        ),
                      );
                    },
                  ),

                if (isLoggedIn)
                  _ProfileTile(
                    icon: Icons.ads_click_rounded,
                    title: "My Classifieds",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyAdsScreen()),
                      );
                    },
                  ),

                _ProfileTile(
                  icon: Icons.bookmark_border_rounded,
                  title: "Saved Items",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedItemsScreen(),
                      ),
                    );
                  },
                ),

                _ProfileTile(
                  icon: Icons.settings_outlined,
                  title: "App Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 3. SUPPORT & LEGAL SECTION
                const _SectionHeader(title: "Support & Information"),
                const SizedBox(height: 8),

                _ProfileTile(
                  icon: Icons.help_outline_rounded,
                  title: "FAQ (Help Center)",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FAQScreen()),
                    );
                  },
                ),
                _ProfileTile(
                  icon: Icons.support_agent_rounded,
                  title: "Contact Support",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContactSupportScreen()),
                    );
                  },
                ),
                _ProfileTile(
                  icon: Icons.description_outlined,
                  title: "Terms & Conditions",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    );
                  },
                ),
                _ProfileTile(
                  icon: Icons.policy_outlined,
                  title: "Privacy Policy",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                _ProfileTile(
                  icon: Icons.info_outline_rounded,
                  title: "About",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KnowMoreScreen()),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 4. LOGOUT ACTION
                if (isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Logout"),
                            content: const Text(
                              "Are you sure you want to log out?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Log Out"),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          _logout(); // Call your existing logout function
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        "Log Out",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------
// Reusable Components for Professional Look
// ------------------------------------

// Professional List Tile
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0, // Flat card for a modern look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
