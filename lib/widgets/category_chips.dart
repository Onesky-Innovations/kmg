import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  // A list of example categories. In a real app, this would come from a data source.
  final List<String> categories = const [
    'Electronics',
    'Vehicles',
    'Real Estate',
    'Jobs',
    'Home & Garden',
    'Services',
    'Fashion',
    'Sports',
    'Books',
  ];

  // The currently selected category.
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    // We use a SizedBox to give the ListView a specific height.
    return SizedBox(
      height: 48, // A comfortable height for a row of chips.
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          // ChoiceChip is perfect for showing a selected state.
          return ChoiceChip(
            label: Text(category),
            selected: _selectedCategory == category,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? category : null;
                // Here you would add the logic to filter your data based on the selected category.
                // print('Selected category: $_selectedCategory');
              });
            },
            selectedColor: Colors.blueAccent.withOpacity(0.8),
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: _selectedCategory == category
                  ? Colors.white
                  : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: _selectedCategory == category
                    ? Colors.blueAccent
                    : Colors.grey[300]!,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
      ),
    );
  }
}
