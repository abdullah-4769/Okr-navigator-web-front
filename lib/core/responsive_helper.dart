// lib/core/responsive_helper.dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveHelper {
  final double screenWidth;
  final double screenHeight;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  ResponsiveHelper(this.screenWidth, this.screenHeight)
      : isMobile = screenWidth < 768,
        isTablet = screenWidth >= 768 && screenWidth < 1024,
        isDesktop = screenWidth >= 1024;

  /// Font helpers
  double headerFont(double mobile, double tablet, double desktop) =>
      isMobile ? mobile : isTablet ? tablet : desktop;

  double bodyFont(double mobile, double tablet, double desktop) =>
      isMobile ? mobile : isTablet ? tablet : desktop;

  double buttonFont(double mobile, double tablet, double desktop) =>
      isMobile ? mobile : isTablet ? tablet : desktop;

  /// Container paddings & widths
  double containerPadding() => isMobile ? 20 : isTablet ? 30 : 40;

  double containerWidth() =>
      isMobile ? screenWidth * 0.9 : isTablet ? screenWidth * 0.7 : 600;

  /// Spacing helpers
  double responsiveSpacing(double factor) => screenHeight * factor;

  double horizontalPadding() {
    if (screenWidth > 1200) return screenWidth * 0.08;
    if (screenWidth > 900) return screenWidth * 0.06;
    if (screenWidth > 600) return screenWidth * 0.05;
    return screenWidth * 0.04;
  }

  double contentPadding() => isTablet ? screenWidth * 0.07 : screenWidth * 0.03;

  /// Font sizes (with .sp scaling)
  double titleFontSize() {
    if (isDesktop) return (screenWidth * 0.005).sp;
    if (isTablet) return (screenWidth * 0.004).sp;
    return (screenWidth * 0.045).sp;
  }

  double subtitleFontSize() {
    if (isDesktop) return (screenWidth * 0.0022).sp;
    if (isTablet) return (screenWidth * 0.0026).sp;
    return (screenWidth * 0.028).sp;
  }

  /// Button paddings
  double buttonPadding() {
    if (isDesktop) return screenWidth * 0.025;
    if (isTablet) return screenWidth * 0.015;
    return screenWidth * 0.1;
  }
}
