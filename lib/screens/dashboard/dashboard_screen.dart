import 'package:circle_bottom_navigation/circle_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:kmg/screens/settings/profile_screen.dart';
import 'package:kmg/theme/app_theme.dart';
import 'package:kmg/widgets/custom_app_bar.dart';
import 'package:kmg/widgets/category_chips.dart';
// import 'package:kmg/widgets/simplebanershow.dart';
import 'package:kmg/widgets/auto_scroll_ad.dart';
import '../ads/ads_feed_screen.dart';
import '../saved/saved_screen.dart';
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

  final List<Widget> _pages = const [
    AdsFeedScreen(),
    MatrimonyScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  final List<TabData> _tabs = [
    TabData(icon: Icons.home, title: "Home", iconSize: 28),
    TabData(icon: Icons.people, title: "Matrimony", iconSize: 28),
    TabData(icon: Icons.bookmark, title: "Saved", iconSize: 28),
    TabData(icon: Icons.person, title: "Profile", iconSize: 28),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFabPressed() {
    Navigator.pushNamed(context, "/submitAd");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      // AppBar only for Home
      appBar: _currentIndex == 0
          ? CustomAppBar(
              onFilterTap: () {},
              onPlaceSelectTap: () {},
              onNotificationTap: () {},
            )
          : null,

      // Body
      body: Column(
        children: [
          const SizedBox(height: 5),

          // if (_currentIndex == 0) ...[
          //   const CategoryChips(),

          //   // Simple banner call
          //   const SimpleBanner(height: 150),

          //   const SizedBox(height: 10),
          // ],
          //--------------------------------------------------------------------------------------------
          //--------------------------------------------------------------------------------------------
          if (_currentIndex == 0) ...[
            const CategoryChips(),

            // Auto-scroll icon ad
            AutoScrollAd(
              // adIcons: [Icons.shopping_cart, Icons.local_offer, Icons.star],
              height: 150,
            ),

            const SizedBox(height: 10),
          ],
          Expanded(child: _pages[_currentIndex]),
        ],
      ),

      // FAB with slide + glow animation
      floatingActionButton: _currentIndex == 0
          ? TweenAnimationBuilder<Offset>(
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
                  child: const Icon(
                    Icons.add,
                    size: 32,
                    color: AppTheme.iconOnPrimary,
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),

      // Curved Gradient Circle Bottom Navigation
      bottomNavigationBar: Container(
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
            activeIconColor: Colors.blueAccent.shade700,
            inactiveIconColor: Colors.white70,
            textColor: Colors.white,
            hasElevationShadows: true,
            blurShadowRadius: 12,
            circleSize: 60,
            arcHeight: 70,
            arcWidth: 90,
          ),
        ),
      ),
    );
  }
}
