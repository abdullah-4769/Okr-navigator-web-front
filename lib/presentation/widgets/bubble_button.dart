import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/core/app_colors.dart';
import 'package:get/get.dart';

class CustomBubbleButton extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool? isFullWidth;

  const CustomBubbleButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isFullWidth = false,
  });

  @override
  State<CustomBubbleButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomBubbleButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  // Device type detection
  DeviceType get _deviceType {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) return DeviceType.mobile;
    if (screenWidth >= 600 && screenWidth < 900) return DeviceType.tablet;
    if (screenWidth >= 900 && screenWidth < 1200) return DeviceType.desktop;
    if (screenWidth >= 1200 && screenWidth < 1920) return DeviceType.largeDesktop;
    return DeviceType.ultraWide;
  }

  // Platform-specific font sizes
  double get _fontSize {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 14.sp;
      case DeviceType.tablet:
        return 16.sp;
      case DeviceType.desktop:
        return 18.sp;
      case DeviceType.largeDesktop:
        return 20.sp;
      case DeviceType.ultraWide:
        return 22.sp;
    }
  }

  // Platform-specific button height
  double get _responsiveHeight {
    switch (_deviceType) {
      case DeviceType.mobile:
        return widget.height > 48.h ? 48.h : widget.height;
      case DeviceType.tablet:
        return widget.height > 52.h ? 52.h : widget.height;
      case DeviceType.desktop:
        return widget.height > 56.h ? 56.h : widget.height;
      case DeviceType.largeDesktop:
        return widget.height > 60.h ? 60.h : widget.height;
      case DeviceType.ultraWide:
        return widget.height > 64.h ? 64.h : widget.height;
    }
  }

  // Platform-specific button width
  double get _responsiveWidth {
    final screenWidth = MediaQuery.of(context).size.width;

    if (widget.isFullWidth == true) {
      switch (_deviceType) {
        case DeviceType.mobile:
          return screenWidth * 0.9;
        case DeviceType.tablet:
          return screenWidth * 0.8;
        case DeviceType.desktop:
          return screenWidth * 0.7;
        case DeviceType.largeDesktop:
          return screenWidth * 0.6;
        case DeviceType.ultraWide:
          return screenWidth * 0.5;
      }
    }

    // For fixed width, ensure it doesn't exceed reasonable limits
    double maxWidth;
    switch (_deviceType) {
      case DeviceType.mobile:
        maxWidth = screenWidth * 0.9;
        break;
      case DeviceType.tablet:
        maxWidth = screenWidth * 0.8;
        break;
      case DeviceType.desktop:
        maxWidth = screenWidth * 0.7;
        break;
      case DeviceType.largeDesktop:
        maxWidth = screenWidth * 0.6;
        break;
      case DeviceType.ultraWide:
        maxWidth = screenWidth * 0.5;
        break;
    }

    return widget.width > maxWidth ? maxWidth : widget.width;
  }

  // Platform-specific border radius
  double get _borderRadius {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 25.r;
      case DeviceType.tablet:
        return 28.r;
      case DeviceType.desktop:
        return 30.r;
      case DeviceType.largeDesktop:
        return 32.r;
      case DeviceType.ultraWide:
        return 35.r;
    }
  }

  // Platform-specific border width
  double get _borderWidth {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 1.5;
      case DeviceType.tablet:
        return 1.75;
      case DeviceType.desktop:
        return 2.0;
      case DeviceType.largeDesktop:
        return 2.25;
      case DeviceType.ultraWide:
        return 2.5;
    }
  }

  // Platform-specific shadow
  List<BoxShadow> get _boxShadow {
    switch (_deviceType) {
      case DeviceType.mobile:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ];
      case DeviceType.tablet:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case DeviceType.desktop:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ];
      case DeviceType.largeDesktop:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case DeviceType.ultraWide:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ];
    }
  }

  // Platform-specific padding
  EdgeInsets get _padding {
    switch (_deviceType) {
      case DeviceType.mobile:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
      case DeviceType.tablet:
        return EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h);
      case DeviceType.desktop:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);
      case DeviceType.largeDesktop:
        return EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h);
      case DeviceType.ultraWide:
        return EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h);
    }
  }

  // Platform-specific font weight
  FontWeight get _fontWeight {
    switch (_deviceType) {
      case DeviceType.mobile:
        return FontWeight.w600;
      case DeviceType.tablet:
        return FontWeight.w600;
      case DeviceType.desktop:
        return FontWeight.w700;
      case DeviceType.largeDesktop:
        return FontWeight.w700;
      case DeviceType.ultraWide:
        return FontWeight.w800;
    }
  }

  // Platform-specific letter spacing
  double? get _letterSpacing {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 0.0;
      case DeviceType.tablet:
        return 0.1;
      case DeviceType.desktop:
        return 0.2;
      case DeviceType.largeDesktop:
        return 0.3;
      case DeviceType.ultraWide:
        return 0.4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: _responsiveWidth,
            height: _responsiveHeight,
            padding: _padding,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.borderColor ?? Colors.blue,
                width: _borderWidth,
              ),
              color: widget.backgroundColor ?? AppColors.lightSkyBlue,
              borderRadius: BorderRadius.circular(_borderRadius),
              boxShadow: _boxShadow,
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.text.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.textColor ?? Colors.blue,
                  fontWeight: _fontWeight,
                  fontSize: _fontSize,
                  letterSpacing: _letterSpacing,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced device type enumeration
enum DeviceType {
  mobile,      // < 600px
  tablet,      // 600-899px
  desktop,     // 900-1199px
  largeDesktop, // 1200-1919px
  ultraWide,   // >= 1920px
}

// Alternative simplified version for quick usage
class ResponsiveBubbleButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isFullWidth;

  const ResponsiveBubbleButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    return CustomBubbleButton(
      text: text,
      width: isFullWidth
          ? (isMobile ? screenWidth * 0.9 :
      isTablet ? screenWidth * 0.8 :
      screenWidth * 0.7)
          : (isMobile ? 200 :
      isTablet ? 240 :
      280),
      height: isMobile ? 48 : isTablet ? 52 : 56,
      onTap: onTap,
      backgroundColor: backgroundColor,
      textColor: textColor,
      isFullWidth: isFullWidth,
    );
  }
}