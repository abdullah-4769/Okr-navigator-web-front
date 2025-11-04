import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../core/app_colors.dart';
import '../core/app_dimensions.dart';

class SnackbarHelper {
  // Common Snackbar Method
  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final width = Get.width;

    // 🔹 Detect platform size scaling
    final bool isDesktop = width >= 1024 || kIsWeb;
    final double fontSize = isDesktop ? 12 : 12.sp; // fixed on desktop
    final double titleSize = isDesktop ? 14 : 14.sp;
    final double iconSize = isDesktop ? 18 : 22.sp;

    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: duration,
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 22 : AppDimensions.d14.w,
        vertical: isDesktop ? 14 : AppDimensions.d10.h,
      ),
      borderRadius: AppDimensions.d12.r,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 18 : AppDimensions.d14.w,
        vertical: isDesktop ? 10 : AppDimensions.d10.h,
      ),
      icon: Icon(icon, color: Colors.white, size: iconSize),
      shouldIconPulse: true,
      forwardAnimationCurve: Curves.easeOutBack,
      barBlur: 2,
    );
  }

  /// Success Snackbar
  static void success(String message, {String title = 'Success'}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.sucessColor,
      icon: Icons.check_circle_rounded,
    );
  }

  /// Error Snackbar
  static void error(String message, {String title = 'Error'}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.primaryRed,
      icon: Icons.error_rounded,
    );
  }

  /// Info Snackbar
  static void info(String message, {String title = 'Info'}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.primaryBlue,
      icon: Icons.info_outline_rounded,
    );
  }

  /// Warning Snackbar
  static void warning(String message, {String title = 'Warning'}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_rounded,
    );
  }
}
