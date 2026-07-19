import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Single dark theme used by every app in the workspace.
abstract final class AppTheme {
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      surface: AppColors.base,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      onSurface: AppColors.text,
      onPrimary: AppColors.crust,
      onSecondary: AppColors.crust,
      onError: AppColors.crust,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.base,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mantle,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.mantle,
        elevation: AppSpacing.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surface0,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.crust,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface0,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surface1,
        contentTextStyle: TextStyle(color: AppColors.text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
