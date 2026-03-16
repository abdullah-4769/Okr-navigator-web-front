import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextInputAction inputAction;
  final int? maxLength;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;

  const CustomTextField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.inputAction = TextInputAction.next,
    this.maxLength,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    // Platform detection based on screen size and characteristics
    final size = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final isWeb = size.width > 1200;
    final isDesktop = size.width > 1024 && size.width <= 1200;
    final isTablet = size.width > 768 && size.width <= 1024;
    final isMobile = size.width <= 768;
    final isLargeMobile = size.width > 480 && size.width <= 768;
    final isSmallMobile = size.width <= 480;

    // Responsive text input font size
    double getResponsiveInputFontSize() {
      if (isWeb) {
        return AppDimensions.d18.sp;
      } else if (isDesktop) {
        return AppDimensions.d16.sp;
      } else if (isTablet) {
        return AppDimensions.d16.sp;
      } else if (isLargeMobile) {
        return AppDimensions.d16.sp;
      } else {
        return AppDimensions.d15.sp;
      }
    }

    // Responsive hint text font size
    double getResponsiveHintFontSize() {
      if (isWeb) {
        return AppDimensions.d14.sp;
      } else if (isDesktop) {
        return AppDimensions.d12.sp;
      } else if (isTablet) {
        return AppDimensions.d12.sp;
      } else if (isLargeMobile) {
        return AppDimensions.d12.sp;
      } else {
        return AppDimensions.d10.sp;
      }
    }

    // Responsive error text font size
    double getResponsiveErrorFontSize() {
      if (isWeb) {
        return AppDimensions.d12.sp;
      } else if (isDesktop) {
        return AppDimensions.d12.sp;
      } else if (isTablet) {
        return AppDimensions.d10.sp;
      } else {
        return AppDimensions.d10.sp;
      }
    }

    // Responsive content padding
    EdgeInsets getResponsiveContentPadding() {
      if (isWeb) {
        return EdgeInsets.symmetric(
          vertical: AppDimensions.d20.h,
          horizontal: AppDimensions.d20.w,
        );
      } else if (isDesktop) {
        return EdgeInsets.symmetric(
          vertical: AppDimensions.d18.h,
          horizontal: AppDimensions.d18.w,
        );
      } else if (isTablet) {
        return EdgeInsets.symmetric(
          vertical: AppDimensions.d16.h,
          horizontal: AppDimensions.d16.w,
        );
      } else if (isLargeMobile) {
        return EdgeInsets.symmetric(
          vertical: AppDimensions.d16.h,
          horizontal: AppDimensions.d16.w,
        );
      } else {
        return EdgeInsets.symmetric(
          vertical: AppDimensions.d14.h,
          horizontal: AppDimensions.d14.w,
        );
      }
    }

    // Responsive border radius
    double getResponsiveBorderRadius({bool isError = false}) {
      double baseRadius;
      if (isError) {
        baseRadius = isWeb || isDesktop ? AppDimensions.d16.r : AppDimensions.d12.r;
      } else {
        if (isWeb) {
          baseRadius = AppDimensions.d24.r;
        } else if (isDesktop) {
          baseRadius = AppDimensions.d22.r;
        } else if (isTablet) {
          baseRadius = AppDimensions.d20.r;
        } else if (isLargeMobile) {
          baseRadius = AppDimensions.d20.r;
        } else {
          baseRadius = AppDimensions.d18.r;
        }
      }
      return baseRadius;
    }

    // Responsive border width
    double getResponsiveBorderWidth({bool isFocused = false}) {
      double multiplier = isFocused ? 2.0 : 1.0;
      if (isWeb) {
        return (AppDimensions.d1.w * 1.5) * multiplier;
      } else if (isDesktop) {
        return (AppDimensions.d1.w * 1.3) * multiplier;
      } else if (isTablet) {
        return (AppDimensions.d1.w * 1.2) * multiplier;
      } else {
        return AppDimensions.d1.w * multiplier;
      }
    }

    // Responsive prefix icon padding
    EdgeInsets getResponsivePrefixIconPadding() {
      if (isWeb) {
        return EdgeInsets.all(AppDimensions.d16.w);
      } else if (isDesktop) {
        return EdgeInsets.all(AppDimensions.d14.w);
      } else if (isTablet) {
        return EdgeInsets.all(AppDimensions.d12.w);
      } else if (isLargeMobile) {
        return EdgeInsets.all(AppDimensions.d12.w);
      } else {
        return EdgeInsets.all(AppDimensions.d10.w);
      }
    }

    // Responsive icon size scaling
    Widget? getScaledPrefixIcon() {
      if (prefixIcon == null) return null;

      double iconScale;
      if (isWeb) {
        iconScale = 1.3;
      } else if (isDesktop) {
        iconScale = 1.2;
      } else if (isTablet) {
        iconScale = 1.1;
      } else if (isLargeMobile) {
        iconScale = 1.0;
      } else {
        iconScale = 0.9;
      }

      return Padding(
        padding: getResponsivePrefixIconPadding(),
        child: Transform.scale(
          scale: iconScale,
          child: prefixIcon,
        ),
      );
    }

    // Responsive suffix icon scaling
    Widget? getScaledSuffixIcon() {
      if (suffixIcon == null) return null;

      double iconScale;
      if (isWeb) {
        iconScale = 1.3;
      } else if (isDesktop) {
        iconScale = 1.2;
      } else if (isTablet) {
        iconScale = 1.1;
      } else if (isLargeMobile) {
        iconScale = 1.0;
      } else {
        iconScale = 0.9;
      }

      return Transform.scale(
        scale: iconScale,
        child: Padding(
          padding: EdgeInsets.all(isWeb ? AppDimensions.d8.w : AppDimensions.d6.w),
          child: suffixIcon,
        ),
      );
    }

    // Responsive font weight
    FontWeight getResponsiveFontWeight({bool isHint = false}) {
      if (isHint) {
        return isWeb || isDesktop ? FontWeight.w400 : FontWeight.w400;
      } else {
        if (isWeb) {
          return FontWeight.w500;
        } else if (isDesktop) {
          return FontWeight.w500;
        } else {
          return FontWeight.w400;
        }
      }
    }

    // Responsive text style
    TextStyle getResponsiveTextStyle() {
      return TextStyle(
        fontSize: getResponsiveInputFontSize(),
        color: AppColors.textPrimary,
        fontFamily: 'GothamMedium',
        fontWeight: getResponsiveFontWeight(),
        height: isWeb || isDesktop ? 1.4 : 1.3,
        letterSpacing: isWeb ? 0.3 : (isDesktop ? 0.2 : 0.1),
      );
    }

    // Responsive hint style
    TextStyle getResponsiveHintStyle() {
      return TextStyle(
        fontSize: getResponsiveHintFontSize(),
        color: AppColors.textSecondary,
        fontFamily: 'GothamMedium',
        fontWeight: getResponsiveFontWeight(isHint: true),
        height: isWeb || isDesktop ? 1.4 : 1.3,
        letterSpacing: isWeb ? 0.2 : (isDesktop ? 0.15 : 0.05),
      );
    }

    // Responsive error style
    TextStyle getResponsiveErrorStyle() {
      return TextStyle(
        fontSize: getResponsiveErrorFontSize(),
        color: AppColors.error,
        fontFamily: 'Gotham',
        fontWeight: FontWeight.w400,
        height: 1.3,
        letterSpacing: 0.1,
      );
    }

    // Responsive max lines based on platform
    int getResponsiveMaxLines() {
      if (maxLines == null) return 1;

      // Allow more lines on larger screens for better UX
      if (maxLines! > 1) {
        if (isWeb) {
          return maxLines! + 2;
        } else if (isDesktop) {
          return maxLines! + 1;
        } else if (isTablet) {
          return maxLines!;
        } else {
          return maxLines!;
        }
      }
      return maxLines!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            minHeight: isWeb ? 60 : (isDesktop ? 56 : (isTablet ? 52 : 48)),
            maxWidth: isWeb ? 500 : double.infinity,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            textInputAction: inputAction,
            maxLength: maxLength,
            maxLines: getResponsiveMaxLines(),
            enabled: enabled,
            textCapitalization: textCapitalization,
            autocorrect: autocorrect,
            enableSuggestions: enableSuggestions,
            validator: validator,
            style: getResponsiveTextStyle(),
            cursorColor: AppColors.primaryRed,
            cursorWidth: isWeb ? 2.5 : (isDesktop ? 2.2 : 2.0),
            cursorHeight: getResponsiveInputFontSize() * 1.2,
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: getResponsiveHintStyle(),
              prefixIcon: getScaledPrefixIcon(),
              suffixIcon: getScaledSuffixIcon(),
              filled: true,
              fillColor: AppColors.softRed,
              contentPadding: getResponsiveContentPadding(),

              // Default border
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getResponsiveBorderRadius()),
                borderSide: BorderSide(
                  color: AppColors.borderGrey,
                  width: getResponsiveBorderWidth(),
                ),
              ),

              // Enabled border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getResponsiveBorderRadius()),
                borderSide: BorderSide(
                  color: AppColors.borderGrey,
                  width: getResponsiveBorderWidth(),
                ),
              ),

              // Focused border
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getResponsiveBorderRadius()),
                borderSide: BorderSide(
                  color: AppColors.primaryRed,
                  width: getResponsiveBorderWidth(isFocused: true),
                ),
              ),

              // Disabled border
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getResponsiveBorderRadius()),
                borderSide: BorderSide(
                  color: AppColors.borderGrey.withOpacity(0.5),
                  width: getResponsiveBorderWidth(),
                ),
              ),

              // Error border
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getResponsiveBorderRadius(isError: true)),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: getResponsiveBorderWidth(),
                ),
              ),

              // Focused error border
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(getResponsiveBorderRadius(isError: true)),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: getResponsiveBorderWidth(isFocused: true),
                ),
              ),

              // Error text style
              errorStyle: getResponsiveErrorStyle(),
              errorMaxLines: isWeb || isDesktop ? 3 : 2,

              // Enhanced hover effects for web/desktop
              hoverColor: (isWeb || isDesktop)
                  ? AppColors.primaryRed.withOpacity(0.05)
                  : null,
            ),
          ),
        );
      },
    );
  }
}