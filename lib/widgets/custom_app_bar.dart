import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';

import 'package:kmg/theme/app_theme.dart';
import 'package:kmg/widgets/search_bar.dart';

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
class PlaceSelector extends StatefulWidget {
  final String selectedPlace;
  final ValueChanged<String>? onPlaceSelected;

  const PlaceSelector({
    super.key,
    this.selectedPlace = 'All Places',
    this.onPlaceSelected,
  });

  @override
  State<PlaceSelector> createState() => _PlaceSelectorState();
}

class _PlaceSelectorState extends State<PlaceSelector> {
  final List<String> _prefixPlaces = [
    "All Places",
    "Kannur",
    "Kozhikode",
    "Malappuram",
    "Thrissur",
  ]; // default prefix places

  List<String> _allPlaces = [];
  List<String> _filteredPlaces = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _allPlaces = [..._prefixPlaces];
    _filteredPlaces = _prefixPlaces; // start with only prefix
    _fetchPlacesFromFirestore();
  }

  // Fetch all places from Firestore
  Future<void> _fetchPlacesFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('classifieds')
        .get();

    if (!mounted) return; // ✅ Prevent setState after dispose

    final firestorePlaces = snapshot.docs
        .map((doc) => (doc.data())['place'] as String?)
        .where((place) => place != null && place.isNotEmpty)
        .cast<String>()
        .toList();

    if (!mounted) return; // double safety

    setState(() {
      // ignore: prefer_collection_literals
      _allPlaces = LinkedHashSet<String>.from([
        ..._prefixPlaces,
        ...firestorePlaces,
      ]).toList();

      _filteredPlaces = _prefixPlaces; // still show only prefix until search
    });
  }

  // Filter places
  void _filterPlaces(String query) {
    final lowerQuery = query.toLowerCase();

    if (query.isEmpty) {
      // show only prefix places when nothing typed
      _filteredPlaces = _prefixPlaces;
    } else {
      // show all (prefix + firestore) when searching
      _filteredPlaces = _allPlaces
          .where((place) => place.toLowerCase().contains(lowerQuery))
          .toList();
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _filterPlaces(val);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Select Place"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: "Search place...",
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: _filteredPlaces.isEmpty
                          ? const Center(child: Text("No matching places"))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredPlaces.length,
                              itemBuilder: (context, index) {
                                if (index >= _filteredPlaces.length) {
                                  return const SizedBox.shrink();
                                }
                                final place = _filteredPlaces[index];
                                return ListTile(
                                  title: Text(place),
                                  onTap: () => Navigator.pop(context, place),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (selected != null && widget.onPlaceSelected != null) {
          widget.onPlaceSelected!(selected);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.selectedPlace,
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

// --- Custom App Bar ---
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onPlaceSelect;
  final VoidCallback? onFilterTap;
  final VoidCallback? onNotificationTap;
  final ValueChanged<String>? onSearch;
  final String selectedPlace;

  const CustomAppBar({
    super.key,
    this.onPlaceSelect,
    this.onFilterTap,
    this.onNotificationTap,
    this.onSearch,
    this.selectedPlace = "All Places",
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
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              // Keep PlaceSelector fixed at right side
              PlaceSelector(
                selectedPlace: selectedPlace,
                onPlaceSelected: onPlaceSelect,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: AnimatedSearchBar(
                  onSearch: onSearch,
                  onFilterTap: onFilterTap,
                ),
              ),
              const SizedBox(width: 6),
              NotificationBell(onTap: onNotificationTap),
            ],
          ),
        ],
      ),
    );
  }
}
