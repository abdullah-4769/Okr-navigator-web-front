import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';
import '../../core/app_theme.dart';

class CustomObjectiveContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final Color titleColor;
  final IconData? icon;
  final Widget? child;

  const CustomObjectiveContainer({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.titleColor = AppColors.primaryRed,
    this.icon,
    this.child,
  });

  // ── Adaptive font helper ───────────────────────────────────────────────────
  // Plain logical px on desktop/tablet — .sp only on mobile.
  // Uses MediaQuery screen width — reliable even inside fixed-width cards.
  static double _fs(double sw, double mobile,
      {double? tablet, double? desktop}) {
    if (sw >= 1024) return desktop ?? tablet ?? mobile - 2;
    if (sw >= 768) return tablet ?? mobile - 1;
    return mobile.sp;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isMobile = screenWidth < 768;

    // ── Dimensions — plain px on desktop/tablet ───────────────────────────────
    final double borderRadius = isDesktop ? 14.0 : isTablet ? 13.0 : AppDimensions.d12.r;
    final double outerPadding = isDesktop ? 18.0 : isTablet ? 16.0 : AppDimensions.d14.w;
    final double innerPadding = isDesktop ? 14.0 : isTablet ? 12.0 : AppDimensions.d10.w;
    final double iconSize = isDesktop ? 18.0 : isTablet ? 18.0 : AppDimensions.d18.sp;
    final double iconPadding = isDesktop ? 10.0 : isTablet ? 10.0 : AppDimensions.d10.w;
    final double strokeWidth = isDesktop ? 2.5 : 3.0;

    // ── Font sizes ────────────────────────────────────────────────────────────
    final double titleSize = _fs(screenWidth, 16, tablet: 15, desktop: 14);
    final double subtitleSize = _fs(screenWidth, 14, tablet: 13, desktop: 13);
    final double descSize = _fs(screenWidth, 12, tablet: 12, desktop: 12);

    // ── Spacing ───────────────────────────────────────────────────────────────
    final double iconSpacing =
    isDesktop ? 10.0 : isTablet ? 9.0 : AppDimensions.d10.h;
    final double subtitleSpacing =
    isDesktop ? 5.0 : isTablet ? 4.0 : AppDimensions.d4.h;
    final double descSpacing =
    isDesktop ? 6.0 : isTablet ? 6.0 : AppDimensions.d6.h;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // ── Background ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(outerPadding),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: isDesktop || isTablet
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
                  : null,
            ),
          ),

          // ── Gradient border ─────────────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _GradientBorderPainter(
                borderRadius: borderRadius,
                strokeWidth: strokeWidth,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryRed,
                    AppColors.primaryRed.withOpacity(0.15),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(innerPadding),
            child: child ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    if (icon != null) ...[
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: isDesktop ? 8 : 6,
                              offset: Offset(0, isDesktop ? 4 : 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: iconSize, // ✅ plain px on desktop
                        ),
                      ),
                      SizedBox(height: iconSpacing),
                    ],

                    // Title
                    Text(
                      title.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: titleSize, // ✅ adaptive
                        fontWeight: FontWeight.w600,
                        letterSpacing: isDesktop ? -0.3 : 0,
                        fontFamily: 'GothamBold',
                      ),
                    ),

                    // Subtitle
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      SizedBox(height: subtitleSpacing),
                      Text(
                        subtitle!.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: subtitleSize, // ✅ adaptive
                          height: 1.4,
                          fontFamily: 'Gotham',
                        ),
                      ),
                    ],

                    // Description
                    if (description != null &&
                        description!.trim().isNotEmpty) ...[
                      SizedBox(height: descSpacing),
                      Text(
                        description!.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black.withOpacity(0.7),
                          fontSize: descSize, // ✅ adaptive
                          height: 1.5,
                          fontFamily: 'Gotham',
                        ),
                      ),
                    ],
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientBorderPainter({
    required this.borderRadius,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




// import 'dart:io' show Platform;
// import 'dart:math';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../../core/app_colors.dart';
// import '../../core/app_dimensions.dart';
// import '../../core/app_theme.dart';
//
// class CustomObjectiveContainer extends StatelessWidget {
//   final String title;
//   final String? subtitle;
//   final String? description;
//   final Color titleColor;
//   final IconData? icon;
//   final Widget? child;
//
//   const CustomObjectiveContainer({
//     super.key,
//     required this.title,
//     this.subtitle,
//     this.description,
//     this.titleColor = AppColors.primaryRed,
//     this.icon,
//     this.child,
//   });
//
//   // Platform detection helpers
//   bool get _isWeb => kIsWeb;
//   bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
//   bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
//
//   // Responsive sizing based on screen size and platform
//   double _getContainerWidth(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     if (_isWeb || _isDesktop) {
//       // For larger screens, use fixed max width with constraints
//       if (screenWidth > 1200) return min(500, screenWidth * 0.4);
//       if (screenWidth > 800) return min(400, screenWidth * 0.5);
//       return min(350, screenWidth * 0.8);
//     } else {
//       // Mobile: responsive percentage
//       return screenWidth * 0.85;
//     }
//   }
//
//   EdgeInsets _getPadding() {
//     if (_isWeb || _isDesktop) {
//       return EdgeInsets.all(20.0);
//     } else {
//       return EdgeInsets.all(AppDimensions.d14.w);
//     }
//   }
//
//   EdgeInsets _getContentPadding() {
//     if (_isWeb || _isDesktop) {
//       return EdgeInsets.all(16.0);
//     } else {
//       return EdgeInsets.all(AppDimensions.d10.w);
//     }
//   }
//
//   double _getBorderRadius() {
//     if (_isWeb || _isDesktop) {
//       return 16.0;
//     } else {
//       return AppDimensions.d12.r;
//     }
//   }
//
//   double _getIconSize() {
//     if (_isWeb || _isDesktop) {
//       return 20.0;
//     } else {
//       return AppDimensions.d18.sp;
//     }
//   }
//
//   double _getIconPadding() {
//     if (_isWeb || _isDesktop) {
//       return 12.0;
//     } else {
//       return AppDimensions.d10.w;
//     }
//   }
//
//   double _getTitleFontSize(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     if (_isWeb || _isDesktop) {
//       if (screenWidth > 1200) return 24.0;
//       if (screenWidth > 800) return 22.0;
//       return 20.0;
//     } else {
//       // Mobile with ScreenUtil
//       return 18.sp;
//     }
//   }
//
//   double _getSubtitleFontSize(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     if (_isWeb || _isDesktop) {
//       if (screenWidth > 1200) return 16.0;
//       if (screenWidth > 800) return 15.0;
//       return 14.0;
//     } else {
//       return 14.sp;
//     }
//   }
//
//   double _getDescriptionFontSize(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     if (_isWeb || _isDesktop) {
//       if (screenWidth > 1200) return 14.0;
//       if (screenWidth > 800) return 13.0;
//       return 12.0;
//     } else {
//       return 12.sp;
//     }
//   }
//
//   double _getSpacing(double mobileValue) {
//     if (_isWeb || _isDesktop) {
//       return mobileValue * 1.5; // Increase spacing for larger screens
//     } else {
//       return mobileValue;
//     }
//   }
//
//   // Platform-specific interaction feedback
//   Widget _buildInteractiveContainer({required Widget child}) {
//     if (_isWeb || _isDesktop) {
//       return MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           child: child,
//         ),
//       );
//     } else {
//       return child;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _buildInteractiveContainer(
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(_getBorderRadius()),
//         child: Stack(
//           children: [
//             /// Background
//             Container(
//               width: _getContainerWidth(context),
//               padding: _getPadding(),
//               decoration: BoxDecoration(
//                 color: AppColors.lightGrey.withValues(alpha: 0.2),
//                 borderRadius: BorderRadius.circular(_getBorderRadius()),
//                 // Platform-specific shadows
//                 boxShadow: _isWeb || _isDesktop
//                     ? [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                     spreadRadius: 0,
//                   ),
//                 ]
//                     : null,
//               ),
//             ),
//
//             /// Gradient border
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(_getBorderRadius()),
//                 ),
//                 child: CustomPaint(
//                   painter: _ResponsiveGradientBorderPainter(
//                     borderRadius: _getBorderRadius(),
//                     strokeWidth: _isWeb || _isDesktop ? 3.0 : 4.0,
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         AppColors.primaryRed,
//                         AppColors.primaryRed.withValues(alpha: 0.15),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             /// Content
//             Container(
//               width: _getContainerWidth(context),
//               padding: _getContentPadding(),
//               child: child ??
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (icon != null) ...[
//                         Container(
//                           padding: EdgeInsets.all(_getIconPadding()),
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryRed,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withValues(alpha: 0.15),
//                                 blurRadius: _isWeb || _isDesktop ? 8 : 6,
//                                 offset: Offset(0, _isWeb || _isDesktop ? 4 : 3),
//                               ),
//                             ],
//                           ),
//                           child: Icon(
//                             icon,
//                             color: Colors.white,
//                             size: _getIconSize(),
//                           ),
//                         ),
//                         SizedBox(height: _getSpacing(_isMobile ? AppDimensions.d10.h : 12.0)),
//                       ],
//
//                       // Title with responsive typography
//                       Text(
//                         title.tr,
//                         textAlign: TextAlign.center,
//                         style: (_isWeb || _isDesktop
//                             ? Theme.of(context).textTheme.displayLarge?.copyWith(
//                           color: titleColor,
//                           fontSize: _getTitleFontSize(context),
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: -0.5,
//                         )
//                             : appTheme.textTheme.displayLarge?.copyWith(
//                           color: titleColor,
//                           fontSize: _getTitleFontSize(context),
//                         )),
//                       ),
//
//                       if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
//                         SizedBox(height: _getSpacing(_isMobile ? AppDimensions.d4.h : 6.0)),
//                         Text(
//                           subtitle!.tr,
//                           textAlign: TextAlign.center,
//                           style: (_isWeb || _isDesktop
//                               ? Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: AppColors.grey,
//                             fontSize: _getSubtitleFontSize(context),
//                             height: 1.4,
//                           )
//                               : appTheme.textTheme.bodySmall?.copyWith(
//                             color: AppColors.grey,
//                             fontSize: _getSubtitleFontSize(context),
//                           )),
//                         ),
//                       ],
//
//                       if (description != null && description!.trim().isNotEmpty) ...[
//                         SizedBox(height: _getSpacing(_isMobile ? AppDimensions.d6.h : 8.0)),
//                         Text(
//                           description!.tr,
//                           textAlign: TextAlign.center,
//                           style: (_isWeb || _isDesktop
//                               ? Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: AppColors.black.withValues(alpha: 0.7),
//                             fontSize: _getDescriptionFontSize(context),
//                             height: 1.5,
//                           )
//                               : appTheme.textTheme.bodySmall?.copyWith(
//                             color: AppColors.black.withValues(alpha: 0.7),
//                             fontSize: _getDescriptionFontSize(context),
//                           )),
//                         ),
//                       ],
//                     ],
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ResponsiveGradientBorderPainter extends CustomPainter {
//   final double borderRadius;
//   final double strokeWidth;
//   final Gradient gradient;
//
//   _ResponsiveGradientBorderPainter({
//     required this.borderRadius,
//     required this.strokeWidth,
//     required this.gradient,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
//     final paint = Paint()
//       ..shader = gradient.createShader(rect)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round;
//
//     canvas.drawRRect(rRect, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// // Extension for easier platform checks throughout your app
// extension PlatformExtensions on BuildContext {
//   bool get isWeb => kIsWeb;
//   bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
//   bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
//   bool get isLargeScreen => MediaQuery.of(this).size.width > 800;
//   bool get isExtraLargeScreen => MediaQuery.of(this).size.width > 1200;
// }