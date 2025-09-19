import 'package:flutter/material.dart';
import '../widgets/app_logo_name.dart';
import '../widgets/search_bar.dart';
import '../screens/settings/profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appName;
  final String logoPath;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const CustomAppBar({
    super.key,
    required this.appName,
    required this.logoPath,
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Logo + Search+Filter + Profile Icon
          Row(
            children: [
              // App logo + name
              AppLogoName(
                logoPath: logoPath,
                appName: appName,
                logoSize: 40,
                nameStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              // Search bar + Filter button (takes available width)
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: SearchBarWidget(
                        hintText: "Search products...",
                        onTap: onSearchTap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: onFilterTap,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.filter_list, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Profile icon
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
