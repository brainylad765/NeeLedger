import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),

      // Typography
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: FontSizes.xxxxl,
          fontWeight: FontWeights.bold,
          color: AppColors.textPrimary,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: FontSizes.xxxl,
          fontWeight: FontWeights.bold,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: FontSizes.xxl,
          fontWeight: FontWeights.semiBold,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: FontSizes.xxxl,
          fontWeight: FontWeights.semiBold,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: FontSizes.xxl,
          fontWeight: FontWeights.semiBold,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: FontSizes.xl,
          fontWeight: FontWeights.medium,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: FontSizes.lg,
          fontWeight: FontWeights.medium,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: FontSizes.base,
          fontWeight: FontWeights.medium,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: FontSizes.sm,
          fontWeight: FontWeights.medium,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: FontSizes.base,
          fontWeight: FontWeights.regular,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: FontSizes.sm,
          fontWeight: FontWeights.regular,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: FontSizes.xs,
          fontWeight: FontWeights.regular,
          color: AppColors.textMuted,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: FontSizes.sm,
          fontWeight: FontWeights.medium,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: FontSizes.xs,
          fontWeight: FontWeights.medium,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: FontSizes.xs,
          fontWeight: FontWeights.medium,
          color: AppColors.textMuted,
          height: 1.4,
        ),
      ),

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: FontSizes.xl,
          fontWeight: FontWeights.semiBold,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingLG,
            vertical: kSpacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMD),
          ),
          textStyle: TextStyle(
            fontSize: FontSizes.sm,
            fontWeight: FontWeights.medium,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceLight),
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingLG,
            vertical: kSpacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMD),
          ),
          textStyle: TextStyle(
            fontSize: FontSizes.sm,
            fontWeight: FontWeights.medium,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMD),
          borderSide: const BorderSide(color: AppColors.surfaceLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMD),
          borderSide: const BorderSide(color: AppColors.surfaceLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMD),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kSpacingMD,
          vertical: kSpacingMD,
        ),
        hintStyle: TextStyle(
          color: AppColors.textMuted,
          fontSize: FontSizes.sm,
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: FontSizes.sm,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceLight,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: FontSizes.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBorderRadiusXL),
          ),
        ),
      ),

      // Custom extensions
      extensions: const [],
    );
  }

  // Light theme for future use
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // Light theme implementation can be added later
    );
  }
}
