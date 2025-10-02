import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearch;

  const AnimatedSearchBar({super.key, this.onFilterTap, this.onSearch});

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
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Rotate hint text every 3 seconds if input is empty
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && _controller.text.isEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _categories.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch?.call('');
    setState(() {}); // refresh UI to remove clear button
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _controller.text.isNotEmpty;

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
            child: TextField(
              controller: _controller,
              onChanged: (val) {
                widget.onSearch?.call(val);
                setState(() {}); // update clear button visibility
              },
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: _controller.text.isEmpty
                    ? "Search ${_categories[_currentIndex]}"
                    : null,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isSearching)
            GestureDetector(
              onTap: _clearSearch,
              child: const Icon(Icons.clear, color: Colors.grey, size: 20),
            ),
          // IconButton(
          //   icon: const Icon(
          //     Icons.filter_list,
          //     color: Colors.blueAccent,
          //     size: 20,
          //   ),
          //   onPressed: widget.onFilterTap,
          //   padding: EdgeInsets.zero,
          //   constraints: const BoxConstraints(minWidth: 35),
          // ),
        ],
      ),
    );
  }
}



 // IconButton(
          //   icon: const Icon(
          //     Icons.filter_list,
          //     color: Colors.blueAccent,
          //     size: 20,
          //   ),
          //   onPressed: widget.onFilterTap,
          //   padding: EdgeInsets.zero,
          //   constraints: const BoxConstraints(minWidth: 35),
          // ),