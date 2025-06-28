import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/duolingo_theme.dart';

/// Navigation Shell with Persistent Bottom Navigation
/// Provides consistent navigation experience across all main app screens
/// Integrates with the kingdom visual framework and maintains navigation state
/// 
/// From /mobile/styles.json:
/// - Uses exact color palette for navigation elements
/// - Applies proper spacing and border radius values
/// - Follows gamification design principles

class NavigationShell extends StatefulWidget {
  final Widget child;
  final String currentLocation;

  const NavigationShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell>
    with TickerProviderStateMixin {
  late AnimationController _navAnimationController;
  late Animation<double> _navSlideAnimation;
  late Animation<double> _navFadeAnimation;
  
  int _currentIndex = 0;
  
  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      route: '/kingdom',
      icon: Icons.castle,
      selectedIcon: Icons.castle,
      label: 'Kingdom',
    ),
    NavigationDestination(
      route: '/education',
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
      label: 'Education',
    ),
    NavigationDestination(
      route: '/trading',
      icon: Icons.trending_up_outlined,
      selectedIcon: Icons.trending_up,
      label: 'Trading',
    ),
    NavigationDestination(
      route: '/social',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Social',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _navSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _navFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeIn,
    ));
    
    _updateCurrentIndex();
    _navAnimationController.forward();
  }

  @override
  void didUpdateWidget(NavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocation != widget.currentLocation) {
      _updateCurrentIndex();
    }
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    super.dispose();
  }

  void _updateCurrentIndex() {
    final currentRoute = widget.currentLocation;
    for (int i = 0; i < _destinations.length; i++) {
      if (currentRoute.startsWith(_destinations[i].route)) {
        setState(() {
          _currentIndex = i;
        });
        break;
      }
    }
  }

  void _onDestinationSelected(int index) {
    if (index != _currentIndex) {
      // Animate navigation transition
      _navAnimationController.reset();
      _navAnimationController.forward();
      
      // Navigate to selected route
      context.go(_destinations[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _navFadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _navFadeAnimation.value,
            child: widget.child,
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _navSlideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _navSlideAnimation.value)),
            child: _buildBottomNavigationBar(),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.charcoal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(
            horizontal: DuolingoTheme.spacingMd,
            vertical: DuolingoTheme.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _destinations.asMap().entries.map((entry) {
              final index = entry.key;
              final destination = entry.value;
              final isSelected = index == _currentIndex;
              
              return _NavigationItem(
                destination: destination,
                isSelected: isSelected,
                onTap: () => _onDestinationSelected(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item with selection animation
class _NavigationItem extends StatefulWidget {
  final NavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOut,
    ));
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOut,
    ));

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(_NavigationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: 'Navigate to ${widget.destination.label} screen',
        hint: widget.isSelected ? 'Currently selected' : 'Tap to navigate',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _selectionController,
            builder: (context, child) {
              return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DuolingoTheme.spacingSm,
                vertical: DuolingoTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? DuolingoTheme.duoGreen.withValues(alpha: 0.15 * _backgroundAnimation.value)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Icon(
                      widget.isSelected
                          ? widget.destination.selectedIcon
                          : widget.destination.icon,
                      color: widget.isSelected
                          ? DuolingoTheme.duoGreen
                          : DuolingoTheme.mediumGray,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    label: widget.destination.label,
                    child: Text(
                      widget.destination.label,
                      style: DuolingoTheme.caption.copyWith(
                        color: widget.isSelected
                            ? DuolingoTheme.duoGreen
                            : DuolingoTheme.mediumGray,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
            },
          ),
        ),
      ),
    );
  }
}

/// Navigation destination configuration
class NavigationDestination {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Provider for tracking current navigation location
final navigationLocationProvider = StateProvider<String>((ref) => '/kingdom');

/// Helper extension for navigation context
extension NavigationContext on BuildContext {
  void navigateWithAnimation(String route) {
    // Add custom transition animation if needed
    go(route);
  }
}