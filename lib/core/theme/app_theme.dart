import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(bool isDarkMode) {
    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
      scaffoldBackgroundColor: isDarkMode ? AppColors.softBlack : AppColors.softWhite,
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary),
        bodyMedium: TextStyle(color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary),
      ),
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
        secondary: isDarkMode ? AppColors.darkSecondary : AppColors.secondary,
        background: isDarkMode ? AppColors.softBlack : AppColors.softWhite,
        surface: isDarkMode ? AppColors.softBlack : AppColors.softWhite,
        onPrimary: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
        onSecondary: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
        onBackground: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
        onSurface: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
        error: AppColors.accent,
        onError: AppColors.softWhite,
      ),
      cardColor: isDarkMode ? AppColors.darkBackground : AppColors.softWhite,
      iconTheme: IconThemeData(
        color: isDarkMode ? AppColors.darkAccent : AppColors.accent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? AppColors.darkAccent : AppColors.accent,
          foregroundColor: AppColors.softWhite,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkMode ? AppColors.softBlack : AppColors.softWhite,
        selectedItemColor: isDarkMode ? AppColors.darkAccent : AppColors.accent,
        unselectedItemColor: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
    );
  }
}