import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';

class EducationSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;

  const EducationSearchWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  State<EducationSearchWidget> createState() => _EducationSearchWidgetState();
}

class _EducationSearchWidgetState extends State<EducationSearchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DuolingoTheme.fastAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text;
    final wasActive = _isSearchActive;
    _isSearchActive = query.isNotEmpty;

    if (_isSearchActive != wasActive) {
      if (_isSearchActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    widget.onSearchChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input field
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: DuolingoTheme.white,
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  boxShadow: _isSearchActive ? DuolingoTheme.elevatedShadow : DuolingoTheme.cardShadow,
                  border: Border.all(
                    color: _isSearchActive 
                        ? DuolingoTheme.duoGreen 
                        : DuolingoTheme.lightGray,
                    width: _isSearchActive ? 2.0 : 1.0,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  style: DuolingoTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search lessons, topics, or concepts...',
                    hintStyle: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.mediumGray,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: _isSearchActive 
                          ? DuolingoTheme.duoGreen 
                          : DuolingoTheme.mediumGray,
                    ),
                    suffixIcon: _isSearchActive
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: DuolingoTheme.mediumGray,
                            ),
                            onPressed: () {
                              widget.controller.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DuolingoTheme.spacingMd,
                      vertical: DuolingoTheme.spacingMd,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Search suggestions/filters
        if (_isSearchActive) ...[
          const SizedBox(height: DuolingoTheme.spacingMd),
          _buildSearchFilters(),
        ],
      ],
    );
  }

  Widget _buildSearchFilters() {
    return TweenAnimationBuilder<double>(
      duration: DuolingoTheme.normalAnimation,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by category:',
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          _buildCategoryChips(),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      'All',
      'Financial Literacy',
      'Cryptocurrency',
      'Risk Management',
      'Trading',
      'Portfolio Management',
    ];

    return Wrap(
      spacing: DuolingoTheme.spacingSm,
      runSpacing: DuolingoTheme.spacingSm,
      children: categories.map((category) {
        final isSelected = category == 'All'; // Default selection
        return AnimatedContainer(
          duration: DuolingoTheme.fastAnimation,
          child: FilterChip(
            label: Text(
              category,
              style: DuolingoTheme.bodySmall.copyWith(
                color: isSelected ? DuolingoTheme.white : DuolingoTheme.duoGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              // Filter logic would go here
            },
            backgroundColor: DuolingoTheme.white,
            selectedColor: DuolingoTheme.duoGreen,
            checkmarkColor: DuolingoTheme.white,
            side: BorderSide(
              color: isSelected ? DuolingoTheme.duoGreen : DuolingoTheme.lightGray,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
            ),
            elevation: isSelected ? 2.0 : 0.0,
            pressElevation: 4.0,
          ),
        );
      }).toList(),
    );
  }
}