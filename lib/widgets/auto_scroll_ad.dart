import 'dart:async';
import 'package:flutter/material.dart';

class AutoScrollAd extends StatefulWidget {
  final List<IconData> adIcons; // list of icons
  final double height; // optional height

  const AutoScrollAd({super.key, required this.adIcons, this.height = 180});

  @override
  State<AutoScrollAd> createState() => _AutoScrollAdState();
}

class _AutoScrollAdState extends State<AutoScrollAd> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < widget.adIcons.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.adIcons.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  widget.adIcons[index],
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
