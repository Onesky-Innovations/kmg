// import 'package:flutter/material.dart';
// import 'dart:async';

// // 1. AppLogoName (Top Left)
// class AppLogoName extends StatelessWidget {
//   final double logoSize;
//   final TextStyle nameStyle;

//   const AppLogoName({super.key, this.logoSize = 28, required this.nameStyle});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Top Left Icon/Logo
//         const Icon(Icons.layers, size: 28, color: Colors.white),
//         const SizedBox(width: 8),
//         // Top Left Name (kmg)
//         Text('kmg', style: nameStyle),
//       ],
//     );
//   }
// }

// // 2. AnimatedSearchBarHint (Bottom of Header)
// class AnimatedSearchBarHint extends StatefulWidget {
//   final VoidCallback? onFilterTap;

//   const AnimatedSearchBarHint({super.key, this.onFilterTap});

//   @override
//   State<AnimatedSearchBarHint> createState() => _AnimatedSearchBarHintState();
// }

// class _AnimatedSearchBarHintState extends State<AnimatedSearchBarHint> {
//   // Animated hints
//   final List<String> _hints = [
//     'used bikes',
//     'land for sale',
//     'apartments for rent',
//     'mobile phones',
//   ];
//   int _currentHintIndex = 0;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startHintAnimation();
//   }

//   void _startHintAnimation() {
//     // Cycles the hint text every 3 seconds
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (mounted) {
//         setState(() {
//           _currentHintIndex = (_currentHintIndex + 1) % _hints.length;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String hintText = 'Search ${_hints[_currentHintIndex]}';

//     return Container(
//       height: 48,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       padding: const EdgeInsets.only(left: 16, right: 8),
//       child: Row(
//         children: [
//           // Search icon
//           const Icon(Icons.search, color: Colors.grey),
//           const SizedBox(width: 8),

//           // Animated hint text area
//           Expanded(
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 500),
//               // Swiping animation
//               transitionBuilder: (Widget child, Animation<double> animation) {
//                 const begin = Offset(1.0, 0.0);
//                 const end = Offset.zero;
//                 final offsetAnimation = Tween(
//                   begin: begin,
//                   end: end,
//                 ).animate(animation);
//                 return ClipRect(
//                   child: SlideTransition(
//                     position: offsetAnimation,
//                     child: child,
//                   ),
//                 );
//               },
//               child: Text(
//                 hintText,
//                 key: ValueKey<int>(
//                   _currentHintIndex,
//                 ), // Key enables the animation
//                 style: TextStyle(color: Colors.grey[600]),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),

//           // Filter icon
//           IconButton(
//             icon: const Icon(Icons.filter_list, color: Colors.blueAccent),
//             onPressed: widget.onFilterTap,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // 3. HomeHeader (The full header structure)
// // NOTE: This widget does NOT implement PreferredSizeWidget, it's for the body.
// class HomeHeader extends StatelessWidget {
//   final VoidCallback? onNotificationTap;
//   final VoidCallback? onPlaceSelectTap;
//   final VoidCallback? onFilterTap;

//   const HomeHeader({
//     super.key,
//     this.onNotificationTap,
//     this.onPlaceSelectTap,
//     this.onFilterTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // Padding to account for the status bar (top: 40)
//       padding: const EdgeInsets.only(top: 40, bottom: 12, left: 16, right: 16),
//       decoration: const BoxDecoration(
//         color: Colors.blueAccent,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Row 1: Logo/Name, Place Selector, Notification Bell
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Top Left: Logo/Name (kmg)
//               const AppLogoName(
//                 nameStyle: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),

//               const Spacer(),

//               // Right Side: Place Selector (with 'All' default and 3-dot icon)
//               GestureDetector(
//                 onTap: onPlaceSelectTap,
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'All',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                     SizedBox(width: 4),
//                     Icon(Icons.more_vert, size: 24, color: Colors.white),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 16),

//               // Right Side: Notification Bell
//               IconButton(
//                 icon: const Icon(
//                   Icons.notifications_none,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//                 onPressed: onNotificationTap,
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Row 2 (Bottom): Animated Search Bar with Filter
//           AnimatedSearchBarHint(onFilterTap: onFilterTap),
//         ],
//       ),
//     );
//   }
// }
