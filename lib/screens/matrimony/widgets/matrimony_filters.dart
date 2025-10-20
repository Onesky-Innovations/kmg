// import 'dart:async';
// import 'package:flutter/material.dart';

// class MatrimonyFilters extends StatefulWidget {
//   final TextEditingController searchController;
//   final RangeValues currentRange;
//   final double minSliderAge;
//   final double maxSliderAge;
//   final ValueChanged<RangeValues> onRangeChanged;
//   final ValueChanged<String> onSearchChanged;
//   final int divisions; // optional slider divisions

//   const MatrimonyFilters({
//     super.key,
//     required this.searchController,
//     required this.currentRange,
//     required this.minSliderAge,
//     required this.maxSliderAge,
//     required this.onRangeChanged,
//     required this.onSearchChanged,
//     this.divisions = 52,
//   });

//   @override
//   State<MatrimonyFilters> createState() => _MatrimonyFiltersState();
// }

// class _MatrimonyFiltersState extends State<MatrimonyFilters> {
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     // Listen to the provided controller and debounce the input
//     widget.searchController.addListener(_onTextChanged);
//   }

//   @override
//   void didUpdateWidget(covariant MatrimonyFilters oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.searchController != widget.searchController) {
//       oldWidget.searchController.removeListener(_onTextChanged);
//       widget.searchController.addListener(_onTextChanged);
//     }
//   }

//   void _onTextChanged() {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 350), () {
//       final text = widget.searchController.text.trim().toLowerCase();
//       widget.onSearchChanged(text);
//     });
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     widget.searchController.removeListener(_onTextChanged);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final start = widget.currentRange.start.round();
//     final end = widget.currentRange.end.round();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Search Bar
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: TextField(
//             controller: widget.searchController,
//             decoration: InputDecoration(
//               hintText: 'Search by name, location...',
//               prefixIcon: const Icon(Icons.search),
//               suffixIcon: widget.searchController.text.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         widget.searchController.clear();
//                         widget.onSearchChanged('');
//                       },
//                     )
//                   : null,
//               filled: true,
//               fillColor: theme.colorScheme.surface,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(30),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(vertical: 0),
//             ),
//           ),
//         ),

//         // Age Range row + Slider
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Age Range: $start - $end",
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               RangeSlider(
//                 values: widget.currentRange,
//                 min: widget.minSliderAge,
//                 max: widget.maxSliderAge,
//                 divisions: widget.divisions,
//                 labels: RangeLabels(start.toString(), end.toString()),
//                 onChanged: (values) {
//                   widget.onRangeChanged(values);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';

// --- Sample Lists for Dropdowns (Replace with your actual data) ---
const List<String> sampleReligions = [
  'Hindu',
  'Muslim',
  'Christian',
  'Sikh',
  'Jain',
];
const List<String> sampleCastes = [
  'Brahmin',
  'Kshatriya',
  'Vaishya',
  'Sudra',
  'Ezhava',
  'Nair',
];
const List<String> samplePlaces = [
  'Kochi',
  'Trivandrum',
  'Bangalore',
  'Chennai',
  'Mumbai',
  'Delhi',
];
// -----------------------------------------------------------------

// (MatrimonyFilters StatefulWidget definition remains the same)

class MatrimonyFilters extends StatefulWidget {
  final TextEditingController searchController;
  final RangeValues currentRange;
  final double minSliderAge;
  final double maxSliderAge;
  final ValueChanged<RangeValues> onRangeChanged;
  final ValueChanged<String> onSearchChanged;
  final int divisions;

  // New Properties
  final bool isLoggedIn;
  final bool showFavoritesOnly;
  final ValueChanged<bool?> onToggleFavorites;
  final String? selectedReligion;
  final ValueChanged<String?> onReligionSelected;
  final String? selectedCaste;
  final ValueChanged<String?> onCasteSelected;
  final String? selectedPlace;
  final ValueChanged<String?> onPlaceSelected;

  const MatrimonyFilters({
    super.key,
    required this.searchController,
    required this.currentRange,
    required this.minSliderAge,
    required this.maxSliderAge,
    required this.onRangeChanged,
    required this.onSearchChanged,
    this.divisions = 52,
    required this.isLoggedIn,
    required this.showFavoritesOnly,
    required this.onToggleFavorites,
    this.selectedReligion,
    required this.onReligionSelected,
    this.selectedCaste,
    required this.onCasteSelected,
    this.selectedPlace,
    required this.onPlaceSelected,
  });

  @override
  State<MatrimonyFilters> createState() => _MatrimonyFiltersState();
}

class _MatrimonyFiltersState extends State<MatrimonyFilters> {
  Timer? _debounce;
  bool _isFiltersExpanded = false;

  // Internal TextEditingControllers for the new typable fields
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _casteController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onTextChanged);

    // Initialize text field controllers with current selected value
    _religionController.text = widget.selectedReligion ?? '';
    _casteController.text = widget.selectedCaste ?? '';
    _placeController.text = widget.selectedPlace ?? '';
  }

  // (didUpdateWidget and _onTextChanged methods remain the same)
  @override
  void didUpdateWidget(covariant MatrimonyFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController.removeListener(_onTextChanged);
      widget.searchController.addListener(_onTextChanged);
    }

    // Keep internal controllers in sync with external state changes
    if (widget.selectedReligion != oldWidget.selectedReligion) {
      _religionController.text = widget.selectedReligion ?? '';
    }
    if (widget.selectedCaste != oldWidget.selectedCaste) {
      _casteController.text = widget.selectedCaste ?? '';
    }
    if (widget.selectedPlace != oldWidget.selectedPlace) {
      _placeController.text = widget.selectedPlace ?? '';
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final text = widget.searchController.text.trim().toLowerCase();
      widget.onSearchChanged(text);
    });
  }

  // (dispose method remains the same)
  @override
  void dispose() {
    _debounce?.cancel();
    widget.searchController.removeListener(_onTextChanged);
    _religionController.dispose();
    _casteController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  // --- NEW Custom Selection Dialog Widget ---
  Future<String?> _showSelectionDialog({
    required BuildContext context,
    required String title,
    required List<String> items,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        // Use a StatefulWidget inside the dialog to manage search state
        return _SearchableListDialog(title: title, items: items);
      },
    );
  }

  // --- MODIFIED Filter Field Builder ---
  Widget _buildTypableFilterField({
    required String label,
    required TextEditingController controller,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Search or Select $label',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () async {
              // Open the searchable list dialog
              final selected = await _showSelectionDialog(
                context: context,
                title: 'Select $label',
                items: items,
              );

              // Apply the selection if not null
              if (selected != null) {
                // If selected is 'All', call onChanged(null) to clear the filter
                if (selected == 'All') {
                  controller.clear();
                  onChanged(null);
                } else {
                  controller.text = selected;
                  onChanged(selected);
                }
                widget.onToggleFavorites(false);
              }
            },
          ),
          // Clear button logic
          suffix: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged(null);
                    widget.onToggleFavorites(false);
                  },
                )
              : null,
        ),
        // Use the onChanged to instantly apply the manually typed filter
        onChanged: (text) {
          onChanged(text.trim().isEmpty ? null : text.trim());
          widget.onToggleFavorites(false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = widget.currentRange.start.round();
    final end = widget.currentRange.end.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar (Remains the same)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, location...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // Favorites Toggle (Only visible if logged in)
        if (widget.isLoggedIn)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CheckboxListTile(
              title: const Text("Show My Favorites Only"),
              value: widget.showFavoritesOnly,
              onChanged: widget.onToggleFavorites,
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),

        // Expansion Tile for Advanced Filters (Only visible if logged in)
        if (widget.isLoggedIn)
          ExpansionTile(
            title: Text(
              _isFiltersExpanded
                  ? "Hide Advanced Filters"
                  : "Show Advanced Filters",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            onExpansionChanged: (expanded) {
              setState(() {
                _isFiltersExpanded = expanded;
              });
            },
            initiallyExpanded: _isFiltersExpanded,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Age Range Slider (Remains the same) ---
                    Text(
                      "Age Range: $start - $end",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RangeSlider(
                      values: widget.currentRange,
                      min: widget.minSliderAge,
                      max: widget.maxSliderAge,
                      divisions: widget.divisions,
                      labels: RangeLabels(start.toString(), end.toString()),
                      onChanged: widget.onRangeChanged,
                    ),
                    const Divider(),

                    // --- Religion Filter (Now Typable/Selectable) ---
                    _buildTypableFilterField(
                      label: 'Religion',
                      controller: _religionController,
                      items: sampleReligions,
                      onChanged: widget.onReligionSelected,
                    ),

                    // --- Caste Filter (Now Typable/Selectable) ---
                    _buildTypableFilterField(
                      label: 'Caste',
                      controller: _casteController,
                      items: sampleCastes,
                      onChanged: widget.onCasteSelected,
                    ),

                    // --- Place Filter (Now Typable/Selectable) ---
                    _buildTypableFilterField(
                      label: 'Place',
                      controller: _placeController,
                      items: samplePlaces,
                      onChanged: widget.onPlaceSelected,
                    ),
                  ],
                ),
              ),
            ],
          ),
        const Divider(height: 1), // Separator below the filters
      ],
    );
  }
}

// --- NEW Helper Widget for Searchable Dialog ---

class _SearchableListDialog extends StatefulWidget {
  final String title;
  final List<String> items;

  const _SearchableListDialog({required this.title, required this.items});

  @override
  State<_SearchableListDialog> createState() => __SearchableListDialogState();
}

class __SearchableListDialogState extends State<_SearchableListDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.only(top: 12),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredItems.length + 1, // +1 for the 'All' option
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // 'All' option
                    return ListTile(
                      title: const Text('All'),
                      onTap: () => Navigator.pop(context, 'All'),
                    );
                  }

                  final item = _filteredItems[index - 1];
                  return ListTile(
                    title: Text(item),
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
