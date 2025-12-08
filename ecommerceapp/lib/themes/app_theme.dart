import 'package:flutter/material.dart';

/// AppTheme - Centralized theme configuration for the E-Commerce App.
/// 
/// This file contains all theme-related configurations including colors,
/// text styles, and other visual properties used throughout the application.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Main theme data for the application.
  /// 
  /// Returns a ThemeData object with grey color scheme and consistent styling.
  static ThemeData get lightTheme {
    return ThemeData(
      // Use material 3 design
      useMaterial3: true,
      
      // Grey color scheme for the entire app
      colorScheme: ColorScheme.light(
        // Primary colors
        primary: Colors.grey[700]!, // Main grey color for buttons and primary elements
        secondary: Colors.grey[600]!, // Secondary grey color
        
        // Surface and background colors
        surface: Colors.grey[50]!, // Background surface color
        background: Colors.grey[50]!, // App background color
        
        // Error color (keeping red for errors)
        error: Colors.red,
        
        // Text colors on colored backgrounds
        onPrimary: Colors.white, // Text on primary color
        onSecondary: Colors.white, // Text on secondary color
        onSurface: Colors.grey[900]!, // Text on surface
        onBackground: Colors.grey[900]!, // Text on background
        onError: Colors.white, // Text on error color
        
        // Additional color properties
        surfaceVariant: Colors.grey[100]!,
        onSurfaceVariant: Colors.grey[700]!,
      ),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        titleTextStyle: TextStyle(
          color: Colors.grey[900],
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Input decoration theme for text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  /// Dark theme (optional - for future dark mode support)
  /// 
  /// Returns a ThemeData object with dark grey color scheme.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Dark grey color scheme
      colorScheme: ColorScheme.dark(
        primary: Colors.grey[300]!,
        secondary: Colors.grey[400]!,
        surface: Colors.grey[900]!,
        background: Colors.grey[900]!,
        error: Colors.red[400]!,
        onPrimary: Colors.grey[900]!,
        onSecondary: Colors.grey[900]!,
        onSurface: Colors.grey[100]!,
        onBackground: Colors.grey[100]!,
        onError: Colors.white,
        surfaceVariant: Colors.grey[800]!,
        onSurfaceVariant: Colors.grey[300]!,
      ),
      
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.grey[200]),
        titleTextStyle: TextStyle(
          color: Colors.grey[100],
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

