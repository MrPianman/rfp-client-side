import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primary = Colors.indigo;

  // Normal text theme for regular users - compact and simple
  static TextTheme _normalTextTheme(TextTheme base) {
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 14, height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
      bodySmall: base.bodySmall?.copyWith(fontSize: 11, height: 1.3),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
      titleMedium: base.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall: base.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
      labelLarge: base.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
      labelMedium: base.labelMedium?.copyWith(fontSize: 11),
      labelSmall: base.labelSmall?.copyWith(fontSize: 10),
    );
  }

  // Enhanced text theme for better readability (Grandma Mode - 40-50+ age group)
  static TextTheme _enhancedTextTheme(TextTheme base) {
    return base.copyWith(
      // Larger body text
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
      bodySmall: base.bodySmall?.copyWith(fontSize: 14, height: 1.4),
      // Clearer headings
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 34, fontWeight: FontWeight.w600),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 26, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: base.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
      titleSmall: base.titleSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      labelLarge: base.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      labelMedium: base.labelMedium?.copyWith(fontSize: 14),
      labelSmall: base.labelSmall?.copyWith(fontSize: 13),
    );
  }

  static ThemeData light({bool grandmaMode = false}) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          // Higher contrast for better visibility
          primary: Colors.indigo.shade700,
        ),
        useMaterial3: true,
        textTheme: grandmaMode 
            ? _enhancedTextTheme(GoogleFonts.baiJamjureeTextTheme())
            : _normalTextTheme(GoogleFonts.baiJamjureeTextTheme()),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: Colors.black87, 
            fontSize: grandmaMode ? 15 : 12, 
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide.none,
          padding: EdgeInsets.symmetric(
            horizontal: grandmaMode ? 12 : 10, 
            vertical: grandmaMode ? 8 : 6,
          ),
        ),
        // Buttons - larger for grandma mode, compact for normal
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(grandmaMode ? 120 : 100, grandmaMode ? 48 : 40),
            textStyle: TextStyle(fontSize: grandmaMode ? 16 : 13, fontWeight: FontWeight.w500),
            padding: EdgeInsets.symmetric(
              horizontal: grandmaMode ? 24 : 20, 
              vertical: grandmaMode ? 14 : 10,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: Size(grandmaMode ? 120 : 100, grandmaMode ? 48 : 40),
            textStyle: TextStyle(fontSize: grandmaMode ? 16 : 13, fontWeight: FontWeight.w500),
            padding: EdgeInsets.symmetric(
              horizontal: grandmaMode ? 24 : 20, 
              vertical: grandmaMode ? 14 : 10,
            ),
          ),
        ),
        // Icons - larger for grandma mode, compact for normal
        iconTheme: IconThemeData(size: grandmaMode ? 26 : 20),
        // Card theme for light mode - clean white cards with subtle shadow
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
      );

  static ThemeData dark({bool grandmaMode = false}) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.dark,
          // Higher contrast in dark mode
          primary: Colors.indigo.shade300,
        ),
        useMaterial3: true,
        textTheme: grandmaMode 
            ? _enhancedTextTheme(GoogleFonts.baiJamjureeTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ))
            : _normalTextTheme(GoogleFonts.baiJamjureeTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              )),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade800,
          labelStyle: TextStyle(
            color: Colors.white70, 
            fontSize: grandmaMode ? 15 : 12, 
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide.none,
          padding: EdgeInsets.symmetric(
            horizontal: grandmaMode ? 12 : 10, 
            vertical: grandmaMode ? 8 : 6,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(grandmaMode ? 120 : 100, grandmaMode ? 48 : 40),
            textStyle: TextStyle(fontSize: grandmaMode ? 16 : 13, fontWeight: FontWeight.w500),
            padding: EdgeInsets.symmetric(
              horizontal: grandmaMode ? 24 : 20, 
              vertical: grandmaMode ? 14 : 10,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: Size(grandmaMode ? 120 : 100, grandmaMode ? 48 : 40),
            textStyle: TextStyle(fontSize: grandmaMode ? 16 : 13, fontWeight: FontWeight.w500),
            padding: EdgeInsets.symmetric(
              horizontal: grandmaMode ? 24 : 20, 
              vertical: grandmaMode ? 14 : 10,
            ),
          ),
        ),
        iconTheme: IconThemeData(size: grandmaMode ? 26 : 20),
        // Card theme for dark mode - subtle elevation
        cardTheme: const CardThemeData(
          elevation: 2,
        ),
      );
}
