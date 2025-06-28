import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';

/// Kingdom Theme Customization System
/// Provides color schemes and architectural style variations
/// Allows users to personalize their kingdom appearance
/// 
/// From /mobile/styles.json:
/// - Extends colorPalette with theme variations
/// - Maintains consistent typography and spacing
/// - Provides architectural style options

enum KingdomThemeStyle {
  classic,
  medieval,
  fantasy,
  modern,
  desert,
  winter,
  tropical,
}

enum KingdomColorScheme {
  duolingo,
  forest,
  ocean,
  sunset,
  royal,
  pastel,
  monochrome,
}

class KingdomThemeConfig {
  final KingdomColorScheme colorScheme;
  final KingdomThemeStyle architecturalStyle;
  final Map<String, Color> colors;
  final Map<String, dynamic> styleProperties;

  const KingdomThemeConfig({
    required this.colorScheme,
    required this.architecturalStyle,
    required this.colors,
    required this.styleProperties,
  });

  static const KingdomThemeConfig defaultTheme = KingdomThemeConfig(
    colorScheme: KingdomColorScheme.duolingo,
    architecturalStyle: KingdomThemeStyle.classic,
    colors: {
      'primary': DuolingoTheme.duoGreen,
      'secondary': DuolingoTheme.duoBlue,
      'accent': DuolingoTheme.duoYellow,
      'background': DuolingoTheme.white,
    },
    styleProperties: {
      'borderRadius': 12.0,
      'elevation': 4.0,
      'textureIntensity': 0.3,
    },
  );

  KingdomThemeConfig copyWith({
    KingdomColorScheme? colorScheme,
    KingdomThemeStyle? architecturalStyle,
    Map<String, Color>? colors,
    Map<String, dynamic>? styleProperties,
  }) {
    return KingdomThemeConfig(
      colorScheme: colorScheme ?? this.colorScheme,
      architecturalStyle: architecturalStyle ?? this.architecturalStyle,
      colors: colors ?? this.colors,
      styleProperties: styleProperties ?? this.styleProperties,
    );
  }
}

/// Theme customization widget for kingdom appearance
class KingdomThemeCustomizer extends StatefulWidget {
  final KingdomThemeConfig currentTheme;
  final Function(KingdomThemeConfig) onThemeChanged;
  final bool isUnlocked;

  const KingdomThemeCustomizer({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    this.isUnlocked = true,
  });

  @override
  State<KingdomThemeCustomizer> createState() => _KingdomThemeCustomizerState();
}

class _KingdomThemeCustomizerState extends State<KingdomThemeCustomizer> {
  late KingdomColorScheme _selectedColorScheme;
  late KingdomThemeStyle _selectedStyle;

  @override
  void initState() {
    super.initState();
    _selectedColorScheme = widget.currentTheme.colorScheme;
    _selectedStyle = widget.currentTheme.architecturalStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.charcoal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Customize Your Kingdom',
            style: DuolingoTheme.h3.copyWith(
              fontWeight: FontWeight.w800,
              color: DuolingoTheme.charcoal,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Color Scheme Selection
          _buildColorSchemeSection(),
          const SizedBox(height: DuolingoTheme.spacingXl),
          
          // Architectural Style Selection
          _buildArchitecturalStyleSection(),
          const SizedBox(height: DuolingoTheme.spacingXl),
          
          // Preview
          _buildThemePreview(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isUnlocked ? _applyTheme : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DuolingoTheme.duoGreen,
                foregroundColor: DuolingoTheme.white,
                padding: const EdgeInsets.symmetric(vertical: DuolingoTheme.spacingMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                ),
              ),
              child: Text(
                'Apply Theme',
                style: DuolingoTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Scheme',
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: DuolingoTheme.charcoal,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingMd),
        
        Wrap(
          spacing: DuolingoTheme.spacingMd,
          runSpacing: DuolingoTheme.spacingMd,
          children: KingdomColorScheme.values.map((scheme) {
            final isSelected = _selectedColorScheme == scheme;
            final colors = _getColorSchemeColors(scheme);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColorScheme = scheme;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected ? DuolingoTheme.duoGreen : DuolingoTheme.lightGray,
                    width: isSelected ? 3 : 1,
                  ),
                  color: isSelected ? DuolingoTheme.duoGreen.withValues(alpha: 0.1) : DuolingoTheme.white,
                ),
                child: Column(
                  children: [
                    // Color preview
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ColorSwatch(color: colors['primary']!),
                        const SizedBox(width: 4),
                        _ColorSwatch(color: colors['secondary']!),
                        const SizedBox(width: 4),
                        _ColorSwatch(color: colors['accent']!),
                      ],
                    ),
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    
                    // Name
                    Text(
                      _getColorSchemeName(scheme),
                      style: DuolingoTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildArchitecturalStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Architectural Style',
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: DuolingoTheme.charcoal,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingMd),
        
        Wrap(
          spacing: DuolingoTheme.spacingMd,
          runSpacing: DuolingoTheme.spacingMd,
          children: KingdomThemeStyle.values.map((style) {
            final isSelected = _selectedStyle == style;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStyle = style;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected ? DuolingoTheme.duoBlue : DuolingoTheme.lightGray,
                    width: isSelected ? 3 : 1,
                  ),
                  color: isSelected ? DuolingoTheme.duoBlue.withValues(alpha: 0.1) : DuolingoTheme.white,
                ),
                child: Column(
                  children: [
                    // Style icon/preview
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DuolingoTheme.lightGray,
                        borderRadius: BorderRadius.circular(_getStyleBorderRadius(style)),
                      ),
                      child: Icon(
                        _getStyleIcon(style),
                        color: DuolingoTheme.charcoal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    
                    // Name
                    Text(
                      _getStyleName(style),
                      style: DuolingoTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemePreview() {
    final colors = _getColorSchemeColors(_selectedColorScheme);
    final borderRadius = _getStyleBorderRadius(_selectedStyle);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: DuolingoTheme.charcoal,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingMd),
        
        Container(
          padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
          decoration: BoxDecoration(
            color: colors['background'],
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: DuolingoTheme.lightGray),
          ),
          child: Row(
            children: [
              // Sample building 1
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors['primary'],
                    borderRadius: BorderRadius.circular(borderRadius * 0.7),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.castle,
                      color: DuolingoTheme.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              
              // Sample building 2
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors['secondary'],
                    borderRadius: BorderRadius.circular(borderRadius * 0.7),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.library_books,
                      color: DuolingoTheme.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              
              // Sample building 3
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: colors['accent'],
                    borderRadius: BorderRadius.circular(borderRadius * 0.7),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.store,
                      color: DuolingoTheme.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _applyTheme() {
    final colors = _getColorSchemeColors(_selectedColorScheme);
    final styleProperties = _getStyleProperties(_selectedStyle);
    
    final newTheme = KingdomThemeConfig(
      colorScheme: _selectedColorScheme,
      architecturalStyle: _selectedStyle,
      colors: colors,
      styleProperties: styleProperties,
    );
    
    widget.onThemeChanged(newTheme);
  }

  Map<String, Color> _getColorSchemeColors(KingdomColorScheme scheme) {
    switch (scheme) {
      case KingdomColorScheme.duolingo:
        return {
          'primary': DuolingoTheme.duoGreen,
          'secondary': DuolingoTheme.duoBlue,
          'accent': DuolingoTheme.duoYellow,
          'background': DuolingoTheme.white,
        };
      case KingdomColorScheme.forest:
        return {
          'primary': const Color(0xFF2E7D32),
          'secondary': const Color(0xFF388E3C),
          'accent': const Color(0xFF8BC34A),
          'background': const Color(0xFFF1F8E9),
        };
      case KingdomColorScheme.ocean:
        return {
          'primary': const Color(0xFF0277BD),
          'secondary': const Color(0xFF0288D1),
          'accent': const Color(0xFF29B6F6),
          'background': const Color(0xFFE1F5FE),
        };
      case KingdomColorScheme.sunset:
        return {
          'primary': const Color(0xFFFF6F00),
          'secondary': const Color(0xFFFF8F00),
          'accent': const Color(0xFFFFAB00),
          'background': const Color(0xFFFFF3E0),
        };
      case KingdomColorScheme.royal:
        return {
          'primary': const Color(0xFF4A148C),
          'secondary': const Color(0xFF6A1B9A),
          'accent': const Color(0xFF9C27B0),
          'background': const Color(0xFFF3E5F5),
        };
      case KingdomColorScheme.pastel:
        return {
          'primary': const Color(0xFFAED581),
          'secondary': const Color(0xFF81C784),
          'accent': const Color(0xFFFFB74D),
          'background': const Color(0xFFFAFAFA),
        };
      case KingdomColorScheme.monochrome:
        return {
          'primary': const Color(0xFF424242),
          'secondary': const Color(0xFF616161),
          'accent': const Color(0xFF9E9E9E),
          'background': const Color(0xFFFAFAFA),
        };
    }
  }

  Map<String, dynamic> _getStyleProperties(KingdomThemeStyle style) {
    switch (style) {
      case KingdomThemeStyle.classic:
        return {
          'borderRadius': 12.0,
          'elevation': 4.0,
          'textureIntensity': 0.3,
        };
      case KingdomThemeStyle.medieval:
        return {
          'borderRadius': 6.0,
          'elevation': 8.0,
          'textureIntensity': 0.7,
        };
      case KingdomThemeStyle.fantasy:
        return {
          'borderRadius': 20.0,
          'elevation': 12.0,
          'textureIntensity': 0.5,
        };
      case KingdomThemeStyle.modern:
        return {
          'borderRadius': 2.0,
          'elevation': 2.0,
          'textureIntensity': 0.1,
        };
      case KingdomThemeStyle.desert:
        return {
          'borderRadius': 8.0,
          'elevation': 3.0,
          'textureIntensity': 0.6,
        };
      case KingdomThemeStyle.winter:
        return {
          'borderRadius': 16.0,
          'elevation': 6.0,
          'textureIntensity': 0.4,
        };
      case KingdomThemeStyle.tropical:
        return {
          'borderRadius': 24.0,
          'elevation': 5.0,
          'textureIntensity': 0.8,
        };
    }
  }

  String _getColorSchemeName(KingdomColorScheme scheme) {
    switch (scheme) {
      case KingdomColorScheme.duolingo:
        return 'Duolingo';
      case KingdomColorScheme.forest:
        return 'Forest';
      case KingdomColorScheme.ocean:
        return 'Ocean';
      case KingdomColorScheme.sunset:
        return 'Sunset';
      case KingdomColorScheme.royal:
        return 'Royal';
      case KingdomColorScheme.pastel:
        return 'Pastel';
      case KingdomColorScheme.monochrome:
        return 'Mono';
    }
  }

  String _getStyleName(KingdomThemeStyle style) {
    switch (style) {
      case KingdomThemeStyle.classic:
        return 'Classic';
      case KingdomThemeStyle.medieval:
        return 'Medieval';
      case KingdomThemeStyle.fantasy:
        return 'Fantasy';
      case KingdomThemeStyle.modern:
        return 'Modern';
      case KingdomThemeStyle.desert:
        return 'Desert';
      case KingdomThemeStyle.winter:
        return 'Winter';
      case KingdomThemeStyle.tropical:
        return 'Tropical';
    }
  }

  IconData _getStyleIcon(KingdomThemeStyle style) {
    switch (style) {
      case KingdomThemeStyle.classic:
        return Icons.home;
      case KingdomThemeStyle.medieval:
        return Icons.castle;
      case KingdomThemeStyle.fantasy:
        return Icons.auto_awesome;
      case KingdomThemeStyle.modern:
        return Icons.apartment;
      case KingdomThemeStyle.desert:
        return Icons.wb_sunny;
      case KingdomThemeStyle.winter:
        return Icons.ac_unit;
      case KingdomThemeStyle.tropical:
        return Icons.local_florist;
    }
  }

  double _getStyleBorderRadius(KingdomThemeStyle style) {
    final properties = _getStyleProperties(style);
    return properties['borderRadius'] as double;
  }
}

/// Small color swatch widget for color scheme previews
class _ColorSwatch extends StatelessWidget {
  final Color color;

  const _ColorSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: DuolingoTheme.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.charcoal.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}