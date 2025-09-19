// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "The Biggest",
//       theme: ThemeData(primarySwatch: Colors.green),
//       home: const LandingPage(),
//       routes: {
//         "/home": (context) => const SubmitAdScreen(),
//         "/knowmore": (context) => const KnowMorePage(),
//       },
//     );
//   }
// }

// // 🔹 Landing Page widget
// class LandingPage extends StatelessWidget {
//   const LandingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.shopping_bag,
//                   size: 100,
//                   color: Colors.green.shade700,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "The Biggest",
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const Text(
//                   "Market Palace for Common People",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16, color: Colors.black54),
//                 ),
//                 const SizedBox(height: 40),
//                 const Text(
//                   "Welcome",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, "/home");
//                   },
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 50),
//                     backgroundColor: Colors.green.shade700,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Start",
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 OutlinedButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, "/knowmore");
//                   },
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 50),
//                     side: BorderSide(color: Colors.green.shade700, width: 2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     "Know More",
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.green.shade700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // 🔹 Submit Ad Screen
// class SubmitAdScreen extends StatefulWidget {
//   const SubmitAdScreen({super.key});

//   @override
//   _SubmitAdScreenState createState() => _SubmitAdScreenState();
// }

// class _SubmitAdScreenState extends State<SubmitAdScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _categoryController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   // WhatsApp admin number
//   final String adminPhone = "917907708822";

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _locationController.dispose();
//     _categoryController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitAd() async {
//     if (!_formKey.currentState!.validate()) return;

//     final String message = Uri.encodeComponent(
//       "📢 New Ad Submission\n"
//       "📝 Title: ${_titleController.text}\n"
//       "💰 Price: ₹${_priceController.text}\n"
//       "📍 Location: ${_locationController.text}\n"
//       "📂 Category: ${_categoryController.text}\n"
//       "ℹ️ Description: ${_descriptionController.text}",
//     );

//     final Uri whatsappUri = Uri.parse("https://wa.me/$adminPhone?text=$message");
//     final Uri smsUri = Uri.parse("sms:$adminPhone?body=$message");

//     try {
//       if (await canLaunchUrl(whatsappUri)) {
//         await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
//       } else {
//         // WhatsApp not installed → fallback to SMS
//         if (await canLaunchUrl(smsUri)) {
//           await launchUrl(smsUri, mode: LaunchMode.externalApplication);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("No app available to send the message."),
//             ),
//           );
//         }
//       }

//       // Clear form after sending
//       _titleController.clear();
//       _priceController.clear();
//       _locationController.clear();
//       _categoryController.clear();
//       _descriptionController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text(
//           "Submit Your Ad",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.blueAccent,
//         elevation: 4.0,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Text(
//                     "You can upload photos, videos of your product on WhatsApp after clicking submit button.",
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _titleController,
//                     labelText: "Ad Title",
//                     icon: Icons.title,
//                     validator: (value) =>
//                         value!.isEmpty ? "Please enter a title" : null,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _priceController,
//                     labelText: "Price (₹)",
//                     icon: Icons.currency_rupee,
//                     keyboardType: TextInputType.number,
//                     validator: (value) =>
//                         value!.isEmpty ? "Please enter a price" : null,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _locationController,
//                     labelText: "Location",
//                     icon: Icons.location_on,
//                     validator: (value) =>
//                         value!.isEmpty ? "Please enter a location" : null,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _categoryController,
//                     labelText: "Category",
//                     icon: Icons.category,
//                     validator: (value) =>
//                         value!.isEmpty ? "Please enter a category" : null,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _descriptionController,
//                     labelText: "Description",
//                     icon: Icons.description,
//                     maxLines: 4,
//                   ),
//                   const SizedBox(height: 40),
//                   Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Colors.blue, Color(0xFF2196F3)],
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                       ),
//                       borderRadius: BorderRadius.circular(30),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.withOpacity(0.3),
//                           spreadRadius: 2,
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.transparent,
//                         shadowColor: Colors.transparent,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       onPressed: _submitAd,
//                       icon: const Icon(Icons.chat, color: Colors.white),
//                       label: const Text(
//                         "Submit via WhatsApp",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     int? maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return Card(
//       elevation: 4.0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           decoration: InputDecoration(
//             labelText: labelText,
//             prefixIcon: Icon(icon, color: Colors.blueAccent),
//             border: InputBorder.none,
//           ),
//           validator: validator,
//         ),
//       ),
//     );
//   }
// }

// // 🔹 Know More Page
// class KnowMorePage extends StatelessWidget {
//   const KnowMorePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           "ℹ️ This app helps common people to buy, sell & promote products easily.",
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/know_more/know_more_screen.dart';
import 'screens/ads/add_submit_screen.dart'; // ✅ Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "The Biggest",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LandingPage(),
      routes: {
        "/dashboard": (context) => const DashboardScreen(),
        "/knowmore": (context) => const KnowMoreScreen(),
        "/submitAd": (context) => const AddSubmitScreen(),
        "/home": (context) => const DashboardScreen(),
      },
    );
  }
}
