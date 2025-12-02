// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../core/app_colors.dart';
// import '../../core/app_dimensions.dart';
//
// class CustomButton2 extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//   final Widget? leading;
//   final Color? backgroundColor;
//   final Color? textColor;
//   final double? width;
//   final double? height;
//   final double borderRadius;
//   final bool hasShadow;
//   final Color? borderColor;
//
//   const CustomButton2({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//     this.leading,
//     this.backgroundColor,
//     this.textColor,
//     this.width,
//     this.height,
//     this.borderRadius = AppDimensions.d30,
//     this.hasShadow = true,
//     this.borderColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Get screen width for adaptive sizing (mobile, tablet, web/desktop)
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final textScaleFactor = MediaQuery.of(context).textScaleFactor;
//     final isDesktop = screenWidth > 1200; // Desktop/Web breakpoint
//     final isTablet = screenWidth > 600 && screenWidth <= 1200; // Tablet breakpoint
//     final isMobile = screenWidth <= 600;
//
//     final bool isDisabled = isLoading || onPressed == null;
//
//     // Width/Height: Fixed logical pixels on desktop (no .w/.h); scaled on mobile/tablet
//     double buttonWidth;
//     double buttonHeight;
//     if (isDesktop) {
//       // Increased height for desktop/web
//       final double baseButtonWidth = width ?? 240.0; // Slightly wider for desktop
//       final double baseButtonHeight = height ?? 85.0; // Increased from 70.0 to 85.0
//       buttonWidth = baseButtonWidth.clamp(160.0, 600.0); // Wider range for desktop
//       buttonHeight = baseButtonHeight.clamp(65.0, 100.0); // Increased height range
//     } else {
//       // Mobile/Tablet: Scale with ScreenUtil
//       final double baseButtonWidth = width ?? (isTablet ? 200.0 : 160.0);
//       final double baseButtonHeight = height ?? (isTablet ? 52.0 : 48.0);
//       buttonWidth = baseButtonWidth.clamp(isMobile ? 120.0 : 140.0, 400.0).w;
//       buttonHeight = baseButtonHeight.clamp(isMobile ? 40.0 : 44.0, 64.0).h;
//     }
//
//     // Font and text: Fixed on desktop (no .sp); scaled on mobile/tablet
//     // Increased font size for desktop
//     final double baseFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0; // Increased desktop base
//     double fontSize;
//     if (isDesktop) {
//       // Fixed: No .sp; respect textScaleFactor for accessibility
//       final scaledFontSize = baseFontSize * 1.1 * textScaleFactor; // Increased multiplier for desktop
//       fontSize = scaledFontSize.clamp(14.0, 20.0); // Increased clamp range for desktop
//     } else {
//       // Mobile/Tablet: Use .sp for responsive scaling
//       final scaledFontSize = baseFontSize * 1.0 * textScaleFactor;
//       fontSize = scaledFontSize.clamp(12.0, 18.0).sp;
//     }
//     final FontWeight fontWeight = isDesktop ? FontWeight.w600 : FontWeight.w500;
//     final double letterSpacing = isDesktop ? 0.3 : isTablet ? 0.2 : 0.1;
//     final double lineHeight = isDesktop ? 1.3 : 1.1; // Increased line height for desktop
//
//     // Spacing and padding: Fixed on desktop (no .w/.h); scaled on mobile/tablet
//     double iconSpacing;
//     EdgeInsets buttonPadding;
//     if (isDesktop) {
//       // Increased padding for desktop
//       iconSpacing = (isTablet ? 12.0 : 10.0).clamp(8.0, 16.0); // Increased spacing
//       buttonPadding = EdgeInsets.symmetric(
//         horizontal: (isTablet ? 28.0 : 24.0).clamp(20.0, 40.0), // Increased horizontal padding
//         vertical: (isTablet ? 18.0 : 16.0).clamp(12.0, 24.0), // Increased vertical padding
//       );
//     } else {
//       // Mobile/Tablet: Scale with ScreenUtil
//       iconSpacing = (isTablet ? 10.0 : 8.0).w;
//       buttonPadding = EdgeInsets.symmetric(
//         horizontal: (isTablet ? 24.0 : 20.0).w,
//         vertical: (isTablet ? 14.0 : 12.0).h,
//       );
//     }
//
//     // Border and radius: Fixed on desktop (no .r/.w); scaled on mobile/tablet
//     double responsiveBorderRadius;
//     double borderWidth;
//     if (isDesktop) {
//       // Slightly larger radius for desktop
//       responsiveBorderRadius = borderRadius != AppDimensions.d30 ? borderRadius : 14.0; // Increased from 12.0
//       borderWidth = (isTablet ? 1.8 : 1.5).clamp(1.2, 2.5); // Slightly thicker border
//     } else {
//       // Mobile/Tablet: Scale with ScreenUtil
//       responsiveBorderRadius = (borderRadius != AppDimensions.d30 ? borderRadius : (isTablet ? 36.0 : 32.0)).r;
//       borderWidth = (isTablet ? 1.5 : 1.2).w;
//     }
//
//     // Shadow and loading: Fixed on desktop (no .w); scaled on mobile/tablet
//     final double elevation = hasShadow ? (isDesktop ? 8.0 : isTablet ? 4.0 : 2.0) : 0.0; // Increased desktop elevation
//     final double shadowOpacity = isDesktop ? 0.25 : isTablet ? 0.2 : 0.15;
//     double loadingIndicatorSize;
//     if (isDesktop) {
//       // Larger loading indicator for desktop
//       final double baseLoadingSize = 28.0; // Increased from 24.0
//       loadingIndicatorSize = (baseLoadingSize * textScaleFactor).clamp(24.0, 32.0);
//     } else {
//       // Mobile/Tablet: Scale with ScreenUtil
//       loadingIndicatorSize = (isTablet ? 24.0 : 20.0).w;
//     }
//
//     // Icon scaling for leading: Increased for desktop
//     final double iconScale = isDesktop ? 1.4 : isTablet ? 1.1 : 1.0; // Increased desktop scale
//
//     return SizedBox(
//       width: buttonWidth,
//       height: buttonHeight,
//       child: ElevatedButton(
//         onPressed: isDisabled ? null : onPressed,
//         style: ButtonStyle(
//           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//             RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(responsiveBorderRadius),
//               side: borderColor != null
//                   ? BorderSide(color: borderColor!, width: borderWidth)
//                   : BorderSide.none,
//             ),
//           ),
//           elevation: MaterialStateProperty.all(elevation),
//           shadowColor: MaterialStateProperty.all(
//             hasShadow ? Colors.black.withOpacity(shadowOpacity) : Colors.transparent,
//           ),
//           padding: MaterialStateProperty.all(buttonPadding),
//           backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                 (states) {
//               if (states.contains(MaterialState.disabled)) {
//                 return AppColors.grey.withOpacity(0.6);
//               }
//               return backgroundColor ?? AppColors.primaryRed;
//             },
//           ),
//           foregroundColor: MaterialStateProperty.resolveWith<Color?>(
//                 (states) {
//               if (states.contains(MaterialState.disabled)) {
//                 return AppColors.white.withOpacity(0.7);
//               }
//               return textColor ?? AppColors.white;
//             },
//           ),
//           overlayColor: MaterialStateProperty.resolveWith<Color?>(
//                 (states) {
//               if (states.contains(MaterialState.hovered)) {
//                 return (backgroundColor ?? AppColors.primaryRed).withOpacity(0.1);
//               }
//               if (states.contains(MaterialState.pressed)) {
//                 return (backgroundColor ?? AppColors.primaryRed).withOpacity(0.2);
//               }
//               return null;
//             },
//           ),
//         ),
//         child: isLoading
//             ? _buildLoadingIndicator(loadingIndicatorSize, textColor ?? AppColors.white)
//             : _buildButtonContent(
//           fontSize,
//           iconSpacing,
//           iconScale,
//           fontWeight,
//           letterSpacing,
//           lineHeight,
//           textColor ?? AppColors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingIndicator(double size, Color color) {
//     return SizedBox(
//       width: size,
//       height: size,
//       child: CircularProgressIndicator(
//         color: color,
//         strokeWidth: (size / 10).clamp(1.5, 3.0),
//         backgroundColor: color.withOpacity(0.2),
//       ),
//     );
//   }
//
//   Widget _buildButtonContent(
//       double fontSize,
//       double iconSpacing,
//       double iconScale,
//       FontWeight fontWeight,
//       double letterSpacing,
//       double lineHeight,
//       Color textColor,
//       ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (leading != null) ...[
//           Transform.scale(
//             scale: iconScale,
//             child: leading!,
//           ),
//           SizedBox(width: iconSpacing),
//         ],
//         Flexible(
//           child: Text(
//             text,
//             style: TextStyle(
//               fontSize: fontSize,
//               color: textColor,
//               fontWeight: fontWeight,
//               fontFamily: 'GothamBold',
//               letterSpacing: letterSpacing,
//               height: lineHeight,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool hasShadow;
  final Color? borderColor;

  const CustomButton2({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.leading,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = AppDimensions.d30,
    this.hasShadow = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to react to parent constraints (perfect for resizable windows)
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic values based on available width
        final double maxWidth = constraints.maxWidth;
        final bool isWideScreen = maxWidth > 600; // Treat >600 as "large" (tablet+ / desktop)

        // Adaptive values
        final double buttonHeight = height ??
            (isWideScreen
                ? 72.0    // Taller on desktop/web
                : 56.0.h); // Scaled on mobile/tablet

        final double buttonWidth = width ?? (isWideScreen ? 280.0 : double.infinity);

        final double fontSize = isWideScreen
            ? 17.0.spMin   // Use .spMin to respect user font scaling but cap growth
            : 15.0.sp;

        final double iconSize = isWideScreen ? 28.0 : 24.0;
        final double horizontalPadding = isWideScreen ? 32.0 : 24.0.w;
        final double verticalPadding = isWideScreen ? 20.0 : 16.0.h;
        final double effectiveBorderRadius = isWideScreen ? 16.0 : borderRadius.r;

        final bool isDisabled = isLoading || onPressed == null;

        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primaryRed,
              foregroundColor: textColor ?? AppColors.white,
              disabledBackgroundColor: AppColors.grey.withOpacity(0.6),
              disabledForegroundColor: AppColors.white.withOpacity(0.7),
              elevation: hasShadow ? (isWideScreen ? 8.0 : 4.0) : 0,
              shadowColor: Colors.black.withOpacity(isWideScreen ? 0.25 : 0.18),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                side: borderColor != null
                    ? BorderSide(color: borderColor!, width: isWideScreen ? 2.0 : 1.5.w)
                    : BorderSide.none,
              ),
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.hovered)) {
                  return (backgroundColor ?? AppColors.primaryRed).withOpacity(0.1);
                }
                if (states.contains(MaterialState.pressed)) {
                  return (backgroundColor ?? AppColors.primaryRed).withOpacity(0.2);
                }
                return null;
              }),
            ),
            child: isLoading
                ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: isWideScreen ? 3.5 : 3.0,
                valueColor: AlwaysStoppedAnimation(textColor ?? AppColors.white),
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  IconTheme(
                    data: IconThemeData(size: iconSize, color: textColor ?? AppColors.white),
                    child: leading!,
                  ),
                  SizedBox(width: isWideScreen ? 14 : 10.w),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isWideScreen ? FontWeight.w600 : FontWeight.w500,
                      fontFamily: 'GothamBold',
                      letterSpacing: isWideScreen ? 0.4 : 0.2,
                      height: 1.3,
                      color: textColor ?? AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}