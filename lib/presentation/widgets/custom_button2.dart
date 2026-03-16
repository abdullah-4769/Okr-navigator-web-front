import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final bool isLoading;

  final Widget? leading;
  final Widget? trailing;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final Color? customShadowColor;

  final double? width;
  final double? height;
  final double borderRadius;
  final double? borderWidth;
  final Color? borderColor;

  final bool fullWidth;
  final bool hasShadow;
  final bool enablePressAnimation;
  final bool disableSplash;

  final TextStyle? textStyle;
  final MainAxisAlignment alignment;

  final double? minWidth;
  final double? minHeight;

  const CustomButton2({
    super.key,
    required this.text,
    required this.onPressed,

    this.isLoading = false,

    this.leading,
    this.trailing,

    this.backgroundColor,
    this.textColor,
    this.disabledColor,
    this.disabledTextColor,
    this.customShadowColor,

    this.width,
    this.height,
    this.borderRadius = AppDimensions.d30,
    this.borderWidth,
    this.borderColor,

    this.fullWidth = true,
    this.hasShadow = true,
    this.enablePressAnimation = true,
    this.disableSplash = false,

    this.textStyle,
    this.alignment = MainAxisAlignment.center,

    this.minWidth,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    // ── CRITICAL: use SCREEN width, not LayoutBuilder constraint width. ──────
    // LayoutBuilder gives the card/container width (e.g. 620 px on desktop),
    // which causes the "wide screen" branch to fire everywhere and bloat text.
    final double screenWidth = MediaQuery.of(context).size.width;

    final bool isDesktop = screenWidth >= 1024;
    final bool isTablet  = screenWidth >= 768 && screenWidth < 1024;
    // isMobile is implied by neither flag being true

    // ── Dimensions ────────────────────────────────────────────────────────────
    // Height: fixed logical pixels on desktop/tablet; ScreenUtil on mobile.
    final double buttonHeight = height ??
        (isDesktop ? 48.0 : isTablet ? 46.0 : 48.0.h);

    // Width: on desktop/tablet use a comfortable fixed width inside cards.
    // Mobile stays full-width unless caller overrides.
    final double buttonWidth = width ??
        (isDesktop ? 240.0 : isTablet ? 220.0 : double.infinity);

    // ── Font ──────────────────────────────────────────────────────────────────
    // NO .sp on desktop/tablet — ScreenUtil multiplier causes over-scaling
    // inside fixed-size card containers.
    final double fontSize = isDesktop
        ? 14.0
        : isTablet
        ? 13.5
        : 14.0.sp;

    // ── Icon ──────────────────────────────────────────────────────────────────
    final double iconSize = isDesktop ? 18.0 : isTablet ? 18.0 : 18.0.sp;
    final double iconSpacing = isDesktop ? 10.0 : isTablet ? 10.0 : 10.0.w;

    // ── Padding ───────────────────────────────────────────────────────────────
    final EdgeInsets buttonPadding = EdgeInsets.symmetric(
      horizontal: isDesktop ? 22.0 : isTablet ? 20.0 : 20.0.w,
      vertical:   isDesktop ? 11.0 : isTablet ? 11.0 : 12.0.h,
    );

    // ── Border radius ─────────────────────────────────────────────────────────
    final double effectiveRadius = isDesktop
        ? 12.0
        : isTablet
        ? 13.0
        : borderRadius.r;

    // ── Typography ────────────────────────────────────────────────────────────
    final FontWeight fontWeight = isDesktop || isTablet
        ? FontWeight.w600
        : FontWeight.w500;
    final double letterSpacing =
    isDesktop ? 0.25 : isTablet ? 0.2 : 0.1;

    // ── Shadow ────────────────────────────────────────────────────────────────
    final double elevation =
    hasShadow ? (isDesktop ? 3.0 : isTablet ? 3.0 : 2.0) : 0.0;

    final bool isDisabled = isLoading || onPressed == null;

    // ── Child ─────────────────────────────────────────────────────────────────
    final Widget buttonContent = isLoading
        ? SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor:
        AlwaysStoppedAnimation(textColor ?? AppColors.white),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        if (leading != null) ...[
          IconTheme(
            data: IconThemeData(
              size: iconSize,
              color: textColor ?? AppColors.white,
            ),
            child: leading!,
          ),
          SizedBox(width: iconSpacing),
        ],
        Flexible(
          child: Text(
            text,
            style: textStyle ??
                TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  fontFamily: 'GothamBold',
                  letterSpacing: letterSpacing,
                  height: 1.25,
                  color: textColor ?? AppColors.white,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: iconSpacing),
          IconTheme(
            data: IconThemeData(
              size: iconSize,
              color: textColor ?? AppColors.white,
            ),
            child: trailing!,
          ),
        ],
      ],
    );

    final Widget button = SizedBox(
      // Mobile + fullWidth → stretch. Desktop/Tablet → fixed width.
      width: (fullWidth && !isDesktop && !isTablet) ? double.infinity : buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryRed,
          foregroundColor: textColor ?? AppColors.white,
          disabledBackgroundColor:
          disabledColor ?? AppColors.grey.withOpacity(0.6),
          disabledForegroundColor:
          disabledTextColor ?? AppColors.white.withOpacity(0.7),
          elevation: elevation,
          shadowColor:
          (customShadowColor ?? Colors.black).withOpacity(0.16),
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveRadius),
            side: borderColor != null
                ? BorderSide(
              color: borderColor!,
              width: borderWidth ?? (isDesktop ? 1.5 : 1.2),
            )
                : BorderSide.none,
          ),
        ).copyWith(
          overlayColor: disableSplash
              ? const MaterialStatePropertyAll(Colors.transparent)
              : MaterialStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(MaterialState.hovered)) {
                return (backgroundColor ?? AppColors.primaryRed)
                    .withOpacity(0.1);
              }
              if (states.contains(MaterialState.pressed)) {
                return (backgroundColor ?? AppColors.primaryRed)
                    .withOpacity(0.2);
              }
              return null;
            },
          ),
        ),
        child: buttonContent,
      ),
    );

    if (!enablePressAnimation) return button;

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 120),
      child: button,
    );
  }
}


//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../core/app_colors.dart';
// import '../../core/app_dimensions.dart';
//
// class CustomButton2 extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//
//   final bool isLoading;
//
//   final Widget? leading;
//   final Widget? trailing;
//
//   final Color? backgroundColor;
//   final Color? textColor;
//   final Color? disabledColor;
//   final Color? disabledTextColor;
//   final Color? customShadowColor;
//
//   final double? width;
//   final double? height;
//   final double borderRadius;
//   final double? borderWidth;
//   final Color? borderColor;
//
//   final bool fullWidth;
//   final bool hasShadow;
//   final bool enablePressAnimation;
//   final bool disableSplash;
//
//   final TextStyle? textStyle;
//   final MainAxisAlignment alignment;
//
//   final double? minWidth;
//   final double? minHeight;
//
//   const CustomButton2({
//     super.key,
//     required this.text,
//     required this.onPressed,
//
//     this.isLoading = false,
//
//     this.leading,
//     this.trailing,
//
//     this.backgroundColor,
//     this.textColor,
//     this.disabledColor,
//     this.disabledTextColor,
//     this.customShadowColor,
//
//     this.width,
//     this.height,
//     this.borderRadius = AppDimensions.d30,
//     this.borderWidth,
//     this.borderColor,
//
//     this.fullWidth = true,
//     this.hasShadow = true,
//     this.enablePressAnimation = true,
//     this.disableSplash = false,
//
//     this.textStyle,
//     this.alignment = MainAxisAlignment.center,
//
//     this.minWidth,
//     this.minHeight,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // ── CRITICAL: use SCREEN width, not LayoutBuilder constraint width. ──────
//     // LayoutBuilder gives the card/container width (e.g. 620 px on desktop),
//     // which causes the "wide screen" branch to fire everywhere and bloat text.
//     final double screenWidth = MediaQuery.of(context).size.width;
//
//     final bool isDesktop = screenWidth >= 1024;
//     final bool isTablet  = screenWidth >= 768 && screenWidth < 1024;
//     // isMobile is implied by neither flag being true
//
//     // ── Dimensions ────────────────────────────────────────────────────────────
//     // Height: fixed logical pixels on desktop/tablet; ScreenUtil on mobile.
//     final double buttonHeight = height ??
//         (isDesktop ? 48.0 : isTablet ? 46.0 : 48.0.h);
//
//     // Width: on desktop/tablet use a comfortable fixed width inside cards.
//     // Mobile stays full-width unless caller overrides.
//     final double buttonWidth = width ??
//         (isDesktop ? 240.0 : isTablet ? 220.0 : double.infinity);
//
//     // ── Font ──────────────────────────────────────────────────────────────────
//     // NO .sp on desktop/tablet — ScreenUtil multiplier causes over-scaling
//     // inside fixed-size card containers.
//     final double fontSize = isDesktop
//         ? 14.0
//         : isTablet
//         ? 13.5
//         : 14.0.sp;
//
//     // ── Icon ──────────────────────────────────────────────────────────────────
//     final double iconSize = isDesktop ? 18.0 : isTablet ? 18.0 : 18.0.sp;
//     final double iconSpacing = isDesktop ? 10.0 : isTablet ? 10.0 : 10.0.w;
//
//     // ── Padding ───────────────────────────────────────────────────────────────
//     final EdgeInsets buttonPadding = EdgeInsets.symmetric(
//       horizontal: isDesktop ? 22.0 : isTablet ? 20.0 : 20.0.w,
//       vertical:   isDesktop ? 11.0 : isTablet ? 11.0 : 12.0.h,
//     );
//
//     // ── Border radius ─────────────────────────────────────────────────────────
//     final double effectiveRadius = isDesktop
//         ? 12.0
//         : isTablet
//         ? 13.0
//         : borderRadius.r;
//
//     // ── Typography ────────────────────────────────────────────────────────────
//     final FontWeight fontWeight = isDesktop || isTablet
//         ? FontWeight.w600
//         : FontWeight.w500;
//     final double letterSpacing =
//     isDesktop ? 0.25 : isTablet ? 0.2 : 0.1;
//
//     // ── Shadow ────────────────────────────────────────────────────────────────
//     final double elevation =
//     hasShadow ? (isDesktop ? 3.0 : isTablet ? 3.0 : 2.0) : 0.0;
//
//     final bool isDisabled = isLoading || onPressed == null;
//
//     // ── Child ─────────────────────────────────────────────────────────────────
//     final Widget buttonContent = isLoading
//         ? SizedBox(
//       width: iconSize,
//       height: iconSize,
//       child: CircularProgressIndicator(
//         strokeWidth: 2.5,
//         valueColor:
//         AlwaysStoppedAnimation(textColor ?? AppColors.white),
//       ),
//     )
//         : Row(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: alignment,
//       children: [
//         if (leading != null) ...[
//           IconTheme(
//             data: IconThemeData(
//               size: iconSize,
//               color: textColor ?? AppColors.white,
//             ),
//             child: leading!,
//           ),
//           SizedBox(width: iconSpacing),
//         ],
//         Flexible(
//           child: Text(
//             text,
//             style: textStyle ??
//                 TextStyle(
//                   fontSize: fontSize,
//                   fontWeight: fontWeight,
//                   fontFamily: 'GothamBold',
//                   letterSpacing: letterSpacing,
//                   height: 1.25,
//                   color: textColor ?? AppColors.white,
//                 ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//           ),
//         ),
//         if (trailing != null) ...[
//           SizedBox(width: iconSpacing),
//           IconTheme(
//             data: IconThemeData(
//               size: iconSize,
//               color: textColor ?? AppColors.white,
//             ),
//             child: trailing!,
//           ),
//         ],
//       ],
//     );
//
//     final Widget button = SizedBox(
//       // Mobile + fullWidth → stretch. Desktop/Tablet → fixed width.
//       width: (fullWidth && !isDesktop && !isTablet) ? double.infinity : buttonWidth,
//       height: buttonHeight,
//       child: ElevatedButton(
//         onPressed: isDisabled ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor ?? AppColors.primaryRed,
//           foregroundColor: textColor ?? AppColors.white,
//           disabledBackgroundColor:
//           disabledColor ?? AppColors.grey.withOpacity(0.6),
//           disabledForegroundColor:
//           disabledTextColor ?? AppColors.white.withOpacity(0.7),
//           elevation: elevation,
//           shadowColor:
//           (customShadowColor ?? Colors.black).withOpacity(0.16),
//           padding: buttonPadding,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(effectiveRadius),
//             side: borderColor != null
//                 ? BorderSide(
//               color: borderColor!,
//               width: borderWidth ?? (isDesktop ? 1.5 : 1.2),
//             )
//                 : BorderSide.none,
//           ),
//         ).copyWith(
//           overlayColor: disableSplash
//               ? const MaterialStatePropertyAll(Colors.transparent)
//               : MaterialStateProperty.resolveWith<Color?>(
//                 (states) {
//               if (states.contains(MaterialState.hovered)) {
//                 return (backgroundColor ?? AppColors.primaryRed)
//                     .withOpacity(0.1);
//               }
//               if (states.contains(MaterialState.pressed)) {
//                 return (backgroundColor ?? AppColors.primaryRed)
//                     .withOpacity(0.2);
//               }
//               return null;
//             },
//           ),
//         ),
//         child: buttonContent,
//       ),
//     );
//
//     if (!enablePressAnimation) return button;
//
//     return AnimatedScale(
//       scale: 1.0,
//       duration: const Duration(milliseconds: 120),
//       child: button,
//     );
//   }
// }
//
//
//
