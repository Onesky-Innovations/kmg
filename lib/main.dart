// import 'package:flutter/material.dart';
// import 'package:kmg/screens/ads/matri_submit_screen.dart';
// import 'screens/landing/landing_screen.dart';
// import 'screens/dashboard/dashboard_screen.dart';
// import 'screens/know_more/know_more_screen.dart';
// import 'screens/ads/add_submit_screen.dart'; // ✅ Add this import

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "KMG",
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const LandingPage(),
//       routes: {
//         "/dashboard": (context) => const DashboardScreen(),
//         "/knowmore": (context) => const KnowMoreScreen(),
//         "/submitAd": (context) => const AddSubmitScreen(),
//         "/home": (context) => const DashboardScreen(),
//         "/matrimony": (context) => const MatriSubmitScreen(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/landing/landing_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/know_more/know_more_screen.dart';
import 'screens/ads/add_submit_screen.dart';
import 'screens/ads/matri_submit_screen.dart';
import 'screens/settings/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirebaseAppWrapper());
}

class FirebaseAppWrapper extends StatelessWidget {
  const FirebaseAppWrapper({super.key});

  Future<FirebaseApp> _initFirebase() async {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "KMG",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LandingPage(),
      routes: {
        "/dashboard": (context) => const DashboardScreen(),
        "/knowmore": (context) => const KnowMoreScreen(),
        "/submitAd": (context) => const AddSubmitScreen(),
        "/home": (context) => const DashboardScreen(),
        "/matrimony": (context) => const MatriSubmitScreen(),
        "/profile": (context) => const ProfileScreen(),
      },
    );
  }
}
