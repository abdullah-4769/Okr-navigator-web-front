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
    // Get screen width for adaptive sizing (mobile, tablet, web/desktop)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final isDesktop = screenWidth > 1200; // Desktop/Web breakpoint
    final isTablet = screenWidth > 600 && screenWidth <= 1200; // Tablet breakpoint
    final isMobile = screenWidth <= 600;

    final bool isDisabled = isLoading || onPressed == null;

    // Width/Height: Fixed logical pixels on desktop (no .w/.h); scaled on mobile/tablet
    double buttonWidth;
    double buttonHeight;
    if (isDesktop) {
      // Fixed: No scaling to prevent over-sizing
      final double baseButtonWidth = width ?? 220.0;
      final double baseButtonHeight = height ?? 60.0;
      buttonWidth = baseButtonWidth.clamp(140.0, 500.0); // Tighter clamp for desktop
      buttonHeight = baseButtonHeight.clamp(44.0, 72.0);
    } else {
      // Mobile/Tablet: Scale with ScreenUtil
      final double baseButtonWidth = width ?? (isTablet ? 200.0 : 160.0);
      final double baseButtonHeight = height ?? (isTablet ? 52.0 : 48.0);
      buttonWidth = baseButtonWidth.clamp(isMobile ? 120.0 : 140.0, 400.0).w;
      buttonHeight = baseButtonHeight.clamp(isMobile ? 40.0 : 44.0, 64.0).h;
    }

    // Font and text: Fixed on desktop (no .sp); scaled on mobile/tablet
    // To increase text size on desktop: Raise baseFontSize (e.g., to 16.0) or the upper clamp (e.g., to 20.0)
    final double baseFontSize = isDesktop ? 14.0 : isTablet ? 15.0 : 14.0; // Slightly smaller base on desktop
    double fontSize;
    if (isDesktop) {
      // Fixed: No .sp; respect textScaleFactor for accessibility
      final scaledFontSize = baseFontSize * 1.0 * textScaleFactor; // Multiplier kept at 1.0 (adjust if needed, e.g., 1.2 for larger)
      fontSize = scaledFontSize.clamp(12.0, 16.0); // Tighter clamp for desktop (smaller max)
    } else {
      // Mobile/Tablet: Use .sp for responsive scaling
      final scaledFontSize = baseFontSize * 1.0 * textScaleFactor;
      fontSize = scaledFontSize.clamp(12.0, 18.0).sp;
    }
    final FontWeight fontWeight = isDesktop ? FontWeight.w600 : FontWeight.w500;
    final double letterSpacing = isDesktop ? 0.3 : isTablet ? 0.2 : 0.1;
    final double lineHeight = isDesktop ? 1.2 : 1.1;

    // Spacing and padding: Fixed on desktop (no .w/.h); scaled on mobile/tablet
    double iconSpacing;
    EdgeInsets buttonPadding;
    if (isDesktop) {
      // Fixed: No scaling
      iconSpacing = (isTablet ? 10.0 : 8.0).clamp(6.0, 12.0); // Tighter clamp
      buttonPadding = EdgeInsets.symmetric(
        horizontal: (isTablet ? 24.0 : 20.0).clamp(16.0, 32.0),
        vertical: (isTablet ? 14.0 : 12.0).clamp(8.0, 20.0),
      );
    } else {
      // Mobile/Tablet: Scale with ScreenUtil
      iconSpacing = (isTablet ? 10.0 : 8.0).w;
      buttonPadding = EdgeInsets.symmetric(
        horizontal: (isTablet ? 24.0 : 20.0).w,
        vertical: (isTablet ? 14.0 : 12.0).h,
      );
    }

    // Border and radius: Fixed on desktop (no .r/.w); scaled on mobile/tablet
    double responsiveBorderRadius;
    double borderWidth;
    if (isDesktop) {
      // Fixed: No scaling; smaller radius for modern desktop look
      responsiveBorderRadius = borderRadius != AppDimensions.d30 ? borderRadius : 12.0; // Adjust base if needed (e.g., 16.0 for rounder)
      borderWidth = (isTablet ? 1.5 : 1.2).clamp(1.0, 2.0); // Fixed, clamped
    } else {
      // Mobile/Tablet: Scale with ScreenUtil
      responsiveBorderRadius = (borderRadius != AppDimensions.d30 ? borderRadius : (isTablet ? 36.0 : 32.0)).r;
      borderWidth = (isTablet ? 1.5 : 1.2).w;
    }

    // Shadow and loading: Fixed on desktop (no .w); scaled on mobile/tablet
    final double elevation = hasShadow ? (isDesktop ? 6.0 : isTablet ? 4.0 : 2.0) : 0.0;
    final double shadowOpacity = isDesktop ? 0.3 : isTablet ? 0.2 : 0.15;
    double loadingIndicatorSize;
    if (isDesktop) {
      // Fixed: No .w; slightly smaller base for desktop
      final double baseLoadingSize = 24.0; // Adjust here if you want larger (e.g., 28.0)
      loadingIndicatorSize = (baseLoadingSize * textScaleFactor).clamp(20.0, 28.0);
    } else {
      // Mobile/Tablet: Scale with ScreenUtil
      loadingIndicatorSize = (isTablet ? 24.0 : 20.0).w;
    }

    // Icon scaling for leading: Unchanged (multiplier only, no scaling issue)
    final double iconScale = isDesktop ? 1.2 : isTablet ? 1.1 : 1.0;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              side: borderColor != null
                  ? BorderSide(color: borderColor!, width: borderWidth)
                  : BorderSide.none,
            ),
          ),
          elevation: MaterialStateProperty.all(elevation),
          shadowColor: MaterialStateProperty.all(
            hasShadow ? Colors.black.withOpacity(shadowOpacity) : Colors.transparent,
          ),
          padding: MaterialStateProperty.all(buttonPadding),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.grey.withOpacity(0.6);
              }
              return backgroundColor ?? AppColors.primaryRed;
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.white.withOpacity(0.7);
              }
              return textColor ?? AppColors.white;
            },
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(MaterialState.hovered)) {
                return (backgroundColor ?? AppColors.primaryRed).withOpacity(0.1);
              }
              if (states.contains(MaterialState.pressed)) {
                return (backgroundColor ?? AppColors.primaryRed).withOpacity(0.2);
              }
              return null;
            },
          ),
        ),
        child: isLoading
            ? _buildLoadingIndicator(loadingIndicatorSize, textColor ?? AppColors.white)
            : _buildButtonContent(
          fontSize,
          iconSpacing,
          iconScale,
          fontWeight,
          letterSpacing,
          lineHeight,
          textColor ?? AppColors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(double size, Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: (size / 10).clamp(1.5, 3.0),
        backgroundColor: color.withOpacity(0.2),
      ),
    );
  }

  Widget _buildButtonContent(
      double fontSize,
      double iconSpacing,
      double iconScale,
      FontWeight fontWeight,
      double letterSpacing,
      double lineHeight,
      Color textColor,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          Transform.scale(
            scale: iconScale,
            child: leading!,
          ),
          SizedBox(width: iconSpacing),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontWeight: fontWeight,
              fontFamily: 'GothamBold',
              letterSpacing: letterSpacing,
              height: lineHeight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}