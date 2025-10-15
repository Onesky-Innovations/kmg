import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  final Function(String?) onCategorySelected; // callback to parent
  final String? selectedCategory; // current selection from parent

  const CategoryChips({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = widget.selectedCategory == category['name'];

          return GestureDetector(
            onTap: () {
              widget.onCategorySelected(
                isSelected ? null : category['name'],
              ); // pass back
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
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
                    size: 30,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category['name'],
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
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
