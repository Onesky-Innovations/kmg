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
//       MaterialPageRoute(builder: (_) => const SignInScreen()),
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
//       MaterialPageRoute(builder: (_) => const SignUpScreen()),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kmg/screens/legal/contact_support_screen.dart';
import 'package:kmg/screens/legal/privacy_screen.dart';
import 'package:kmg/screens/legal/terms_screen.dart';

import 'EditProfileScreen.dart';
import 'settings_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'package:kmg/screens/legal/faq_screen.dart';

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
  bool isPrivate = false;
  bool notificationsEnabled = true;
  bool isLoading = true;
  bool hasInternet = true;

  late StreamSubscription _connSub;

  @override
  void initState() {
    super.initState();
    _fetchUser();

    // 🔌 Listen to internet changes
    _connSub = Connectivity().onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      if (!mounted) return;
      setState(() => hasInternet = online);

      if (!online) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ No Internet Connection")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Back Online")));
        _fetchUser(); // refresh when back online
      }
    });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Error loading profile: $e")));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _login() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );

    if (result != null && result['signedIn'] == true) {
      await _fetchUser();
      setState(() {
        isAdmin = result['isAdmin'] ?? false;
      });

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
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
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
      isPrivate = false;
      notificationsEnabled = true;
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
    _connSub.cancel(); // 🔴 stop internet listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔴 Internet Banner
          if (!hasInternet)
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.all(8),
              child: const Text(
                "No Internet Connection",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profilePic != null
                                ? NetworkImage(profilePic!)
                                : null,
                            child: profilePic == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!isLoggedIn)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _login,
                                  child: const Text("Sign In"),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _signup,
                                  child: const Text("Sign Up"),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isLoggedIn && isAdmin)
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: const Text("Admin Panel"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminDashboardScreen(),
                            ),
                          );
                        },
                      ),

                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text("FAQ"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FAQScreen()),
                        );
                      },

                      // onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.support_agent),
                      title: const Text("Contact Support"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ContactSupportScreen(),
                          ),
                        );
                      },

                      // onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text("Terms & Conditions"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ),
                        );
                      },
                      // onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text("Privacy Policy"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      // onTap: () {},
                    ),
                    // ListTile(
                    //   leading: const Icon(Icons.star_rate),
                    //   title: const Text("Rate the App"),
                    //   onTap: () {},
                    // ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    const Divider(),
                    if (isLoggedIn)
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          "Log Out",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: _logout,
                      ),
                  ],
                ),

                if (isLoggedIn)
                  Positioned(
                    right: 2,
                    top: 20,
                    child: PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 24),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: const [
                              Icon(Icons.edit),
                              SizedBox(width: 10),
                              Text('Edit Profile'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') _editProfile();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
