import 'package:circle_bottom_navigation/circle_bottom_navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kmg/screens/ads/BannerDetailScreen.dart';
import 'package:kmg/screens/ads/Pre_add_submit_screen.dart';
import 'package:kmg/screens/settings/profile_screen.dart';
import 'package:kmg/screens/settings/sign_in_screen.dart';
// import 'package:kmg/theme/app_theme.dart';
import 'package:kmg/widgets/custom_app_bar.dart';
import 'package:kmg/widgets/category_chips.dart';
import 'package:kmg/widgets/auto_scroll_ad.dart';

import '../ads_feed_screen.dart';
import '../featured.dart';
import '../../matrimony/matri_screens/matrimony_screen.dart';
import 'package:circle_bottom_navigation/widgets/tab_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? _selectedCategory;
  String _searchQuery = "";
  String _selectedPlace = "All Places"; // <-- added place

  final List<TabData> _tabs = [
    TabData(icon: Icons.home, title: "Home", iconSize: 28),
    TabData(icon: Icons.people, title: "Matrimony", iconSize: 28),
    TabData(icon: Icons.star, title: "Featured", iconSize: 28),
    TabData(icon: Icons.person, title: "Profile", iconSize: 28),
  ];

  void _onTabChanged(int index) => setState(() => _currentIndex = index);

  void _onFabPressed() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PreAddSubmitScreen()),
      );
    } else {
      // Show a friendly dialog to sign up
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Sign in required"),
          content: const Text(
            "You need to sign up or log in to submit your ad.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignInScreen(fromFab: true),
                    ),
                  );
                });
              },
              child: const Text("Sign In/Sign Up"),
            ),
          ],
        ),
      );
    }
  }

  void _onSearchChanged(String query) => setState(() => _searchQuery = query);

  void _onPlaceSelected(String place) => setState(() => _selectedPlace = place);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _currentIndex == 0
          ? CustomAppBar(
              selectedPlace: _selectedPlace,
              onSearch: _onSearchChanged,
              onPlaceSelect: _onPlaceSelected, // <-- place updates here
            )
          : null,
      body: _currentIndex == 0
          ? NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  const SliverToBoxAdapter(child: SizedBox(height: 5)),

                  // Category Chips
                  SliverToBoxAdapter(
                    child: CategoryChips(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) =>
                          setState(() => _selectedCategory = category),
                    ),
                  ),

                  // Auto scrolling ads
                  SliverToBoxAdapter(
                    child: StreamBuilder<QuerySnapshot>(
                      // V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V V
                      // ✅ FIX: Use the new root collection 'banners'
                      stream: FirebaseFirestore.instance
                          .collection(
                            'banners',
                          ) // <-- CHANGED from classifieds/baners/baner
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      // ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final bannerDocs = snapshot.data!.docs;
                        if (bannerDocs.isEmpty) {
                          return const SizedBox(
                            height: 150,
                            child: Center(child: Text("No banners found")),
                          );
                        }

                        // NOTE: You are passing the raw bannerDocs to AutoScrollAd
                        // The actual image filtering and UI logic is done inside
                        // the AutoScrollAd widget itself, which is correct.
                        return AutoScrollAd(
                          height: 150,
                          ads: bannerDocs,
                          onTap: (index) {
                            final data =
                                bannerDocs[index].data()
                                    as Map<String, dynamic>;
                            final images =
                                data['images'] as List<dynamic>? ?? [];
                            final imageUrl = images.isNotEmpty ? images[0] : '';

                            final description = data['description'] ?? '';
                            final phone = data['phone'] ?? '';

                            if (imageUrl.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BannerDetailScreen(
                                    imageUrl: imageUrl,
                                    description: description,
                                    phone: phone,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                ];
              },

              body: AdsFeedScreen(
                selectedCategory: _selectedCategory,
                searchQuery: _searchQuery,
                selectedPlace: _selectedPlace,
                currentUserId: '', // <-- pass to feed
              ),
            )
          : _getPage(_currentIndex),
      floatingActionButton: _currentIndex == 0
          ? _buildFab()
          : const SizedBox.shrink(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFab() {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: offset * 50,
          child: Opacity(opacity: 1.0, child: child),
        );
      },
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          // FIX: Replace static AppTheme.primaryGradient with a dynamic LinearGradient
          gradient: LinearGradient(
            // Define the direction of the gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Use the theme's dynamic colors for the stops
            colors: [
              Theme.of(context).colorScheme.primary, // Start color
              Theme.of(
                context,
              ).colorScheme.secondary, // End color (or use primary.withOpacity)
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: RawMaterialButton(
          onPressed: _onFabPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        // FIX 1: Replace static AppTheme.primaryGradient with a dynamic LinearGradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // Use the theme's dynamic primary color
            Theme.of(context).colorScheme.primary,
            // Use the theme's dynamic secondary color for a nice gradient transition
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            // FIX 2: Use the dynamic primary color for the shadow
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: CircleBottomNavigation(
          tabs: _tabs,
          initialSelection: _currentIndex,
          onTabChangedListener: _onTabChanged,
          barBackgroundColor: Colors.transparent,
          circleColor: Colors.white,
          // FIX: Replaced static AppTheme color with dynamic theme primary color
          activeIconColor: Theme.of(context).colorScheme.primary,
          inactiveIconColor: Colors.white70,
          textColor: Colors.white,
          hasElevationShadows: true,
          blurShadowRadius: 12,
          circleSize: 60,
          arcHeight: 70,
          arcWidth: 90,
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const SizedBox.shrink();
      case 1:
        return const MatrimonyScreen();
      case 2:
        return const FeaturedScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
