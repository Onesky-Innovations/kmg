import 'package:flutter/material.dart';
// Importing the separate theme file (assumed to be available)
import 'package:kmg/theme/app_theme.dart';

class MatrimonyScreen extends StatefulWidget {
  const MatrimonyScreen({super.key});

  @override
  State<MatrimonyScreen> createState() => _MatrimonyScreenState();
}

class _MatrimonyScreenState extends State<MatrimonyScreen> {
  // --- LOGIC UNTOUCHED ---
  void _onFabPressed() {
    Navigator.pushNamed(context, "/matrimony");
  }

  final List<Map<String, String>> sampleProfiles = [
    {
      "name": "Anita",
      "age": "28",
      "city": "Kochi",
      "imageUrl":
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1888&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      "name": "Ravi",
      "age": "30",
      "city": "Trivandrum",
      "imageUrl":
          "https://images.unsplash.com/photo-1507003211169-0a812d80f820?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      "name": "Meera",
      "age": "25",
      "city": "Ernakulam",
      "imageUrl":
          "https://images.unsplash.com/photo-1506794778202-dfa52e1e72f5?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      "name": "Arjun",
      "age": "32",
      "city": "Alappuzha",
      "imageUrl":
          "https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?q=80&w=1902&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
  ];
  // --- END LOGIC UNTOUCHED ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, // Light background for contrast

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner / Intro - STYLED WITH GRADIENT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient, // Use AppTheme Gradient
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Find your soul mate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28, // Increased font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We help you find your perfect partner & perfect family",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search bar - STYLED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by name, city, age…",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.primary, // Primary color icon
                  ),
                  filled: true,
                  fillColor: AppTheme.background, // Use theme background color
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16, // Increased vertical padding
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: AppTheme.primary, // Primary color focus highlight
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recommended Profiles",
                  style: TextStyle(
                    fontSize: 20, // Increased font size
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal list of profiles
            SizedBox(
              height: 250, // Increased height for better card size
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sampleProfiles.length,
                itemBuilder: (context, index) {
                  return _profileCard(sampleProfiles[index]);
                },
              ),
            ),
            const SizedBox(height: 24),

            // More features placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "More features coming soon…",
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            ),
            const SizedBox(height: 80), // To avoid FAB overlay
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed, // Logic untouched
        backgroundColor:
            AppTheme.secondary, // Use AppTheme Secondary color for FAB
        foregroundColor: AppTheme.iconOnPrimary, // White text/icon
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text(
          "Add Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Helper function for profile cards - STYLED
  Widget _profileCard(Map<String, String> prof) {
    return Container(
      width: 160, // Increased width
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        color: AppTheme.background,
        elevation: 6, // Higher elevation for depth
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  prof["imageUrl"]!,
                  height: 120, // Increased image height
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Error handling for image loading
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    height: 120,
                    width: double.infinity,
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                prof["name"]!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800, // Bold name
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${prof["age"]} yrs, ${prof["city"]}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {}, // Logic untouched
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, // Primary color button
                  foregroundColor: AppTheme.iconOnPrimary, // White text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                  minimumSize: const Size(120, 36), // Increased size
                ),
                child: const Text("View Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
