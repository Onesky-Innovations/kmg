import 'package:circle_bottom_navigation/circle_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:kmg/screens/settings/profile_screen.dart';
import 'package:kmg/theme/app_theme.dart';
import 'package:kmg/widgets/custom_app_bar.dart';
import 'package:kmg/widgets/category_chips.dart';
import 'package:kmg/widgets/auto_scroll_ad.dart';

import '../ads/ads_feed_screen.dart';
import '../saved/featured.dart';
import '../matrimony/matrimony_screen.dart';
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

  void _onFabPressed() => Navigator.pushNamed(context, "/submitAd");

  void _onSearchChanged(String query) => setState(() => _searchQuery = query);

  void _onPlaceSelected(String place) => setState(() => _selectedPlace = place);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _currentIndex == 0
          ? CustomAppBar(
              selectedPlace: _selectedPlace,
              onSearch: _onSearchChanged,
              onPlaceSelect: _onPlaceSelected, // <-- place updates here
            )
          : null,
      body: _currentIndex == 0
          ? NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
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
                      SliverToBoxAdapter(child: AutoScrollAd(height: 150)),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    ];
                  },

              body: AdsFeedScreen(
                selectedCategory: _selectedCategory,
                searchQuery: _searchQuery,
                selectedPlace: _selectedPlace, // <-- pass to feed
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
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: RawMaterialButton(
          onPressed: _onFabPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 32, color: AppTheme.iconOnPrimary),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
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
          activeIconColor: AppTheme.activeIconOnPrimary,
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
