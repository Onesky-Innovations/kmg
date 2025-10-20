// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:kmg/screens/admin/admin_dashboard_screen.dart';
// import 'package:kmg/screens/admin/delete_requests_admin_page.dart';
// import 'package:kmg/screens/admin/manageMatrimony.dart';
// import 'package:kmg/screens/admin/notifications_screen.dart';
// import 'firebase_options.dart';

// import 'screens/landing/landing_screen.dart';
// import 'screens/dashboard/dashboard_screen.dart';
// import 'screens/know_more/know_more_screen.dart';
// import 'screens/ads/Pre_add_submit_screen.dart';
// import 'screens/matrimony/matri_submit_screen.dart';
// import 'screens/settings/profile_screen.dart';
// import 'screens/admin/manage_Classifieds_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const FirebaseAppWrapper());
// }

// class FirebaseAppWrapper extends StatelessWidget {
//   const FirebaseAppWrapper({super.key});

//   Future<FirebaseApp> _initFirebase() async {
//     return await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<FirebaseApp>(
//       future: _initFirebase(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return const MyApp();
//         }
//         return const MaterialApp(
//           home: Scaffold(body: Center(child: CircularProgressIndicator())),
//         );
//       },
//     );
//   }
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
//         "/preadsubmit": (context) => const PreAddSubmitScreen(),
//         "/home": (context) => const DashboardScreen(),
//         "/matrimony": (context) => const MatriSubmitScreen(),
//         "/profile": (context) => const ProfileScreen(),
//         "/manageClassifieds": (context) => const ManageClassifiedsScreen(),
//         "/manageMatrimony": (context) => const ManageMatrimonyScreen(),
//         "/adminDashboard": (context) => const AdminDashboardScreen(),
//         "/notifications": (context) => const AddNotificationScreen(),
//         "/delete_request": (context) => const DeleteRequestsAdminPage(),
//       },
//     );
//   }
// }

// lib/main.dart (Refactored)

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:kmg/providers/theme_provider.dart';
// import 'package:provider/provider.dart'; // Import Provider
// import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPrefs

// import 'firebase_options.dart';
// import 'app_routes.dart'; // Importing AppRoutes (Assume this exists)

// void main() async {
//   // 1. Core initialization
//   WidgetsFlutterBinding.ensureInitialized();

//   // 2. Guarantee SharedPrefs is ready
//   await SharedPreferences.getInstance();

//   // 3. Launch App Root
//   runApp(const FirebaseAppWrapper());
// }

// // ----------------------------------------------------
// // WIDGET 1: FIREBASE INITIALIZATION WRAPPER
// // ----------------------------------------------------
// class FirebaseAppWrapper extends StatelessWidget {
//   const FirebaseAppWrapper({super.key});

//   Future<FirebaseApp> _initFirebase() async {
//     return await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<FirebaseApp>(
//       future: _initFirebase(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           // Firebase is ready -> Launch the main app with Providers
//           return const MyAppWrapper();
//         }
//         // Show a loading screen while Firebase is initializing
//         return const MaterialApp(
//           // debugShowCheckedModeBanner: false,
//           home: Scaffold(body: Center(child: CircularProgressIndicator())),
//         );
//       },
//     );
//   }
// }

// // ----------------------------------------------------
// // WIDGET 2: MAIN APP WRAPPER (Handles Theme/State)
// // ----------------------------------------------------
// class MyAppWrapper extends StatelessWidget {
//   const MyAppWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Attach ThemeProvider here as the root state manager
//     return ChangeNotifierProvider(
//       create: (context) => ThemeProvider(),
//       child: const MyApp(),
//     );
//   }
// }

// // ----------------------------------------------------
// // WIDGET 3: MYAPP (APPLIES THEME AND ROUTES)
// // ----------------------------------------------------
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Consume the ThemeProvider to get the current state
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "KMG",

//       // Theme Application: Uses dynamic themes from theme_provider.dart
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       // 💡 FIX: Use the state from the provider to set themeMode
//       themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

//       // Routing Application: Uses the centralized routes from app_routes.dart
//       initialRoute: AppRoutes.landing,
//       routes: AppRoutes.routes,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:kmg/providers/theme_provider.dart';
// import 'package:kmg/splash_zoom_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'firebase_options.dart';
// import 'app_routes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SharedPreferences.getInstance();
//   runApp(const FirebaseAppWrapper());
// }

// class FirebaseAppWrapper extends StatelessWidget {
//   const FirebaseAppWrapper({super.key});

//   Future<FirebaseApp> _initFirebase() async {
//     return await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<FirebaseApp>(
//       future: _initFirebase(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return const MyAppWrapper();
//         }
//         return const MaterialApp(
//           home: Scaffold(body: Center(child: CircularProgressIndicator())),
//         );
//       },
//     );
//   }
// }

// class MyAppWrapper extends StatelessWidget {
//   const MyAppWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: const MyApp(),
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "KMG",
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       home: const SplashZoomScreen(), // 👈 Start here
//       routes: AppRoutes.routes,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kmg/notifiers/matrimony_notifier.dart';
import 'package:kmg/notifiers/saved_ads_notifier.dart';
import 'package:kmg/providers/theme_provider.dart';
import 'package:kmg/splash_zoom_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We keep SharedPreferences initialized here as it's quick and generally needed early
  await SharedPreferences.getInstance();
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
          // Firebase is initialized, now we provide the state managers
          return const MyAppWrapper();
        }
        // Show a loading indicator while Firebase initializes
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐️ FIX: MatrimonyNotifier must be added here.
    return MultiProvider(
      providers: [
        // 1. Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // 2. Saved Ads Provider
        ChangeNotifierProvider(create: (_) => SavedAdsNotifier()),

        // ⭐️ 3. Matrimony Notifier (The Missing Provider)
        ChangeNotifierProvider(create: (_) => MatrimonyNotifier()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Assuming lightTheme and darkTheme are defined somewhere accessible
    // For this example, I'll use simple defaults if they are missing.
    final lightTheme = ThemeData.light(); // Placeholder
    final darkTheme = ThemeData.dark(); // Placeholder

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "KMG",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashZoomScreen(),
      routes: AppRoutes.routes,
    );
  }
}
