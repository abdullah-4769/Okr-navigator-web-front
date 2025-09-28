import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';


// Platform-specific font size multiplier
double get _platformMultiplier {
  if (kIsWeb) {
    // Web needs larger fonts for better readability
    return 1.15;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux) {
    // Desktop platforms
    return 1.1;
  } else {
    // Mobile platforms (iOS, Android)
    return 1.0;
  }
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  fontFamily: 'Gotham',
  useMaterial3: true, // ✅ modern Material
  textTheme: TextTheme(
    // ---------------------- DISPLAY ----------------------
    displayLarge: TextStyle(
      fontFamily: 'GothamUltra',
      fontWeight: FontWeight.w500, // Extra bold / Black
      fontSize: (30 * _platformMultiplier).sp, // Large hero text
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: 'GothamExtraBold',
      fontWeight: FontWeight.w800,
      fontSize: (26 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: 'GothamBold',
      fontWeight: FontWeight.w700,
      fontSize: (22 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),

    // ---------------------- HEADLINE ----------------------
    headlineLarge: TextStyle(
      fontFamily: 'GothamBold',
      fontWeight: FontWeight.w700, // Bold
      fontSize: (22 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'GothamBold',
      fontWeight: FontWeight.w600,
      fontSize: (20 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'GothamBold',
      fontWeight: FontWeight.w400,
      fontSize: (18 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),

    // ---------------------- TITLE ----------------------
    titleLarge: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w500,
      fontSize: (18 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w400,
      fontSize: (16 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w400,
      fontSize: (14 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),

    // ---------------------- BODY ----------------------
    bodyLarge: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w400,
      fontSize: (16 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w400,
      fontSize: (14 * _platformMultiplier).sp,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w400,
      fontSize: (12 * _platformMultiplier).sp,
      color: AppColors.textSecondary,
    ),

    // ---------------------- LABEL (Buttons, Chips, etc.) ----------------------
    labelLarge: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w600,
      fontSize: (14 * _platformMultiplier).sp,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w500,
      fontSize: (12 * _platformMultiplier).sp,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Gotham',
      fontWeight: FontWeight.w500,
      fontSize: (11 * _platformMultiplier).sp,
      color: AppColors.textSecondary.withOpacity(0.8),
    ),
  ),
);