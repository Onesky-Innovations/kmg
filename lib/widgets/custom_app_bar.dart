import 'package:flutter/material.dart';
import 'dart:async';

import 'package:kmg/theme/app_theme.dart';

// --- Logo + App Name ---
class AppLogoName extends StatelessWidget {
  final String appName;
  final double logoSize;
  final TextStyle nameStyle;

  const AppLogoName({
    super.key,
    this.appName = 'kmg',
    this.logoSize = 24,
    required this.nameStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.layers, size: logoSize, color: Colors.white),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            appName,
            style: nameStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// --- Place Selector ---
class PlaceSelector extends StatelessWidget {
  final String defaultPlace;
  final VoidCallback? onTap;

  const PlaceSelector({
    super.key,
    this.defaultPlace = 'All Places',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              defaultPlace,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.location_on, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

// --- Notification Bell ---
class NotificationBell extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBell({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}

// --- Search Bar with Animated Categories ---
class AnimatedSearchBar extends StatefulWidget {
  final VoidCallback? onFilterTap;

  const AnimatedSearchBar({super.key, this.onFilterTap});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final List<String> _categories = [
    'used bikes',
    'land for sale',
    'apartments for rent',
    'mobile phones',
  ];

  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _categories.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Row(
              children: [
                const Text(
                  'Search ',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      final offsetAnim = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return ClipRect(
                        child: SlideTransition(
                          position: offsetAnim,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _categories[_currentIndex],
                      key: ValueKey<int>(_currentIndex),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.blueAccent,
              size: 20,
            ),
            onPressed: widget.onFilterTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 35),
          ),
        ],
      ),
    );
  }
}

// --- Custom App Bar ---
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onPlaceSelectTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    this.onPlaceSelectTap,
    this.onFilterTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          // Top Row: Logo + Place Selector
          Row(
            children: [
              const AppLogoName(
                logoSize: 28,
                nameStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              PlaceSelector(onTap: onPlaceSelectTap),
            ],
          ),
          const SizedBox(height: 6),

          // Search Bar with animated category text
          Row(
            children: [
              Expanded(child: AnimatedSearchBar(onFilterTap: onFilterTap)),
              const SizedBox(width: 6),
              NotificationBell(onTap: onNotificationTap),
            ],
          ),
        ],
      ),
    );
  }
}
