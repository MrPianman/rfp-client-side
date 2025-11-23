import 'package:flutter/material.dart';
import 'theme_controller.dart';

List<Color> seriesColors(BuildContext context, int count) {
  final isGrandmaMode = ThemeController.instance.grandmaMode.value;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  // High contrast colors for better visibility
  final List<Color> highContrastDark = [
    const Color(0xFF00E5FF), // Bright Cyan
    const Color(0xFFFF6B9D), // Bright Pink
    const Color(0xFF76FF03), // Bright Green
    const Color(0xFFFFD600), // Bright Yellow
    const Color(0xFFFF5722), // Bright Orange
    const Color(0xFF9C27B0), // Bright Purple
    const Color(0xFF00BCD4), // Bright Teal
    const Color(0xFFFF9100), // Bright Amber
  ];
  
  final List<Color> highContrastLight = [
    const Color(0xFF0277BD), // Deep Blue
    const Color(0xFFC2185B), // Deep Pink
    const Color(0xFF2E7D32), // Deep Green
    const Color(0xFFF57C00), // Deep Orange
    const Color(0xFF6A1B9A), // Deep Purple
    const Color(0xFFD84315), // Deep Red-Orange
    const Color(0xFF00838F), // Deep Teal
    const Color(0xFF4E342E), // Deep Brown
  ];
  
  if (isGrandmaMode) {
    // Use high contrast colors in Grandma Mode
    final base = isDark ? highContrastDark : highContrastLight;
    return List<Color>.generate(count, (i) => base[i % base.length]);
  }
  
  // Normal mode - use theme colors with slight enhancement for better visibility
  final cs = Theme.of(context).colorScheme;
  final base = <Color>[
    cs.primary,
    cs.secondary,
    cs.tertiary,
    cs.error,
    isDark ? cs.primaryContainer : _darkenColor(cs.primaryContainer),
    isDark ? cs.secondaryContainer : _darkenColor(cs.secondaryContainer),
    isDark ? cs.tertiaryContainer : _darkenColor(cs.tertiaryContainer),
  ];

  // Repeat colors if more series than palette size
  return List<Color>.generate(count, (i) => base[i % base.length]);
}

// Helper function to darken container colors in light mode for better contrast
Color _darkenColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor();
}
