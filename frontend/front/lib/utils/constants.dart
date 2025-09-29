import 'package:flutter/material.dart';

// App Configuration
const String appName = 'NeeLedger';
const String apiBaseUrl = 'https://api.NeeLedger.com';

// Spacing & Dimensions
const double kSpacingXXS = 4.0;
const double kSpacingXS = 8.0;
const double kSpacingSM = 12.0;
const double kSpacingMD = 16.0;
const double kSpacingLG = 20.0;
const double kSpacingXL = 24.0;
const double kSpacingXXL = 32.0;
const double kSpacingXXXL = 48.0;

// Border Radius
const double kBorderRadiusSM = 6.0;
const double kBorderRadiusMD = 8.0;
const double kBorderRadiusLG = 12.0;
const double kBorderRadiusXL = 16.0;
const double kBorderRadiusXXL = 24.0;

// Shadows
const List<BoxShadow> kShadowSM = [
  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
];

const List<BoxShadow> kShadowMD = [
  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
];

const List<BoxShadow> kShadowLG = [
  BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 8)),
];

// Legacy constants (keeping for backward compatibility)
const double defaultPadding = kSpacingMD;
const double defaultBorderRadius = kBorderRadiusMD;

// Color Palette - Modern Dark Theme
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary Colors
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color secondaryLight = Color(0xFFF472B6);
  static const Color secondaryDark = Color(0xFFDB2777);

  // Background Colors
  static const Color background = Color(0xFF0F0F23);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252542);
  static const Color card = Color(0xFF16213E);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8C5D6);
  static const Color textMuted = Color(0xFF64748B);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Accent Colors
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFA78BFA);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Legacy color constants (keeping for backward compatibility)
const Color primaryColor = AppColors.primary;
const Color secondaryColor = AppColors.secondary;
const Color kBackground = AppColors.background;
const Color kSurface = AppColors.surface;
const Color kCard = AppColors.card;
const Color kMuted = AppColors.textMuted;
const Color kAccent = AppColors.accent;
const Color kSuccess = AppColors.success;
const Color kWarning = AppColors.warning;
const Color kDanger = AppColors.error;

// Animation Durations
const Duration kAnimationDurationFast = Duration(milliseconds: 150);
const Duration kAnimationDurationNormal = Duration(milliseconds: 300);
const Duration kAnimationDurationSlow = Duration(milliseconds: 500);

// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double desktopLarge = 1440;
}

// Typography Scale
class FontSizes {
  static const double xs = 12;
  static const double sm = 14;
  static const double base = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 48;
}

// Font Weights
class FontWeights {
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}
