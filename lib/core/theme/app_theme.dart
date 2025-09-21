// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(bool isDarkMode) {
    if (isDarkMode) {
      return _darkTheme;
    }
    return _lightTheme;
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.softWhite,
    fontFamily: 'YourFontFamily',

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.softWhite,
      surface: AppColors.softWhite,
      error: AppColors.accent,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.softWhite,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),

    // THAY ĐỔI: Phải là TabBarThemeData
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: Color(0xAA264653),
      indicatorColor: AppColors.secondary,
    ),

    // THAY ĐỔI: Phải là CardThemeData
    cardTheme: CardThemeData(
      color: AppColors.softWhite,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.softWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        )
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.softWhite,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'YourFontFamily',

    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      background: AppColors.darkBackground,
      surface: AppColors.darkBackground,
      error: AppColors.accent,
      onPrimary: AppColors.darkTextPrimary,
      onSecondary: AppColors.textPrimary,
      onBackground: AppColors.darkTextPrimary,
      onSurface: AppColors.darkTextPrimary,
      onError: AppColors.softWhite,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
    ),

    // THAY ĐỔI: Phải là TabBarThemeData
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.darkTextPrimary,
      unselectedLabelColor: Colors.white70,
      indicatorColor: AppColors.darkSecondary,
    ),

    // THAY ĐỔI: Phải là CardThemeData
    cardTheme: CardThemeData(
      color: const Color(0xFF2A313C),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkAccent,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkSecondary,
        )
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
      selectedItemColor: AppColors.darkSecondary,
      unselectedItemColor: Colors.white70,
    ),
  );
}