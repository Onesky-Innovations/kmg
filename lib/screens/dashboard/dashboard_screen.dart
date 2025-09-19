// import 'package:flutter/material.dart';
// import '../ads/ads_feed_screen.dart';
// import '../saved/saved_screen.dart';
// import '../ads/add_submit_screen.dart';
// import '../matrimony/matrimony_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = const [
//     AdsFeedScreen(),
//     MatrimonyScreen(),
//     SavedScreen(),
//   ];

//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   void _onFabPressed() {
//     Navigator.pushNamed(context, "/submitAd"); // ✅ use route from main.dart
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],

//       // ✅ Floating Action Button
//       floatingActionButton: Transform.translate(
//         offset: const Offset(-5, 10), // move FAB outside
//         child: FloatingActionButton(
//           onPressed: _onFabPressed,
//           backgroundColor: Colors.blueAccent,
//           child: const Icon(Icons.add),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

//       // ✅ Bottom Navigation with FAB notch
//       bottomNavigationBar: BottomAppBar(
//         // shape: const CircularNotchedRectangle(),
//         // notchMargin: 8.0,
//         child: SizedBox(
//           height: 60,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(Icons.home, "Home", 0),
//               _buildNavItem(Icons.people, "Matrimony", 1),
//               // const SizedBox(width: 20), // 👈 gap for FAB
//               _buildNavItem(Icons.bookmark, "Saved", 2),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, int index) {
//     final bool isSelected = _currentIndex == index;

//     return InkWell(
//       onTap: () => _onTabTapped(index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: isSelected ? Colors.blueAccent : Colors.grey,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:kmg/widgets/custom_app_bar.dart';
import '../ads/ads_feed_screen.dart';
import '../saved/saved_screen.dart';
import '../ads/add_submit_screen.dart';
import '../matrimony/matrimony_screen.dart';
// import '../widgets/custom_app_bar.dart'; // import custom app bar

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdsFeedScreen(),
    MatrimonyScreen(),
    SavedScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFabPressed() {
    Navigator.pushNamed(context, "/submitAd"); // ✅ route from main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 Use CustomAppBar
      appBar: CustomAppBar(
        appName: "The Biggest",
        logoPath: "assets/logo.png",
        onSearchTap: () {
          // TODO: Navigate to search screen
        },
        onFilterTap: () {
          // TODO: Open filter options
        },
      ),

      body: _pages[_currentIndex],

      // ✅ Floating Action Button
      floatingActionButton: Transform.translate(
        offset: const Offset(-5, 10), // move FAB slightly outside
        child: FloatingActionButton(
          onPressed: _onFabPressed,
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ✅ Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.people, "Matrimony", 1),
              _buildNavItem(Icons.bookmark, "Saved", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blueAccent : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
