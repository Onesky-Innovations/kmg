import 'package:flutter/material.dart';
import 'package:kmg/theme/app_theme.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Electronics', 'icon': Icons.devices},
    {'name': 'Vehicles', 'icon': Icons.directions_car},
    {'name': 'Real Estate', 'icon': Icons.home},
    {'name': 'Jobs', 'icon': Icons.work},
    {'name': 'Home & Garden', 'icon': Icons.home_outlined},
    {'name': 'Services', 'icon': Icons.build},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Sports', 'icon': Icons.sports_soccer},
    {'name': 'Books', 'icon': Icons.book},
  ];

  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // enough height for icon + text
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = _selectedCategory == category['name'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = isSelected ? null : category['name'];
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(
                    category['icon'],
                    color: isSelected
                        ? AppTheme.ActiveIconOnPrimary
                        : Colors.grey[700],
                    size: 30,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category['name'],
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.ActiveIconOnPrimary
                        : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 16.0),
      ),
    );
  }
}
