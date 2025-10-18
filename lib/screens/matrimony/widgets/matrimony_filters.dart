import 'dart:async';
import 'package:flutter/material.dart';

class MatrimonyFilters extends StatefulWidget {
  final TextEditingController searchController;
  final RangeValues currentRange;
  final double minSliderAge;
  final double maxSliderAge;
  final ValueChanged<RangeValues> onRangeChanged;
  final ValueChanged<String> onSearchChanged;
  final int divisions; // optional slider divisions

  const MatrimonyFilters({
    super.key,
    required this.searchController,
    required this.currentRange,
    required this.minSliderAge,
    required this.maxSliderAge,
    required this.onRangeChanged,
    required this.onSearchChanged,
    this.divisions = 52,
  });

  @override
  State<MatrimonyFilters> createState() => _MatrimonyFiltersState();
}

class _MatrimonyFiltersState extends State<MatrimonyFilters> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Listen to the provided controller and debounce the input
    widget.searchController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant MatrimonyFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController.removeListener(_onTextChanged);
      widget.searchController.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final text = widget.searchController.text.trim().toLowerCase();
      widget.onSearchChanged(text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.searchController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = widget.currentRange.start.round();
    final end = widget.currentRange.end.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
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

        // Age Range row + Slider
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                onChanged: (values) {
                  widget.onRangeChanged(values);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
