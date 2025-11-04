import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Widget? leading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.leading,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = AppDimensions.d30,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _isWeb => kIsWeb;
  bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Device type detection for adaptive sizing
    final isDesktop = screenWidth > 1200; // Desktop/Web breakpoint
    final isTablet = screenWidth > 600 && screenWidth <= 1200; // Tablet breakpoint
    final isMobile = screenWidth <= 600;

    // Adaptive config based on device type - FIXED OVER-SCALING ON DESKTOP
    final config = _getAdaptiveConfig(
      screenWidth,
      textScaleFactor,
      isDesktop,
      isTablet,
      isMobile,
    );

    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: MouseRegion(
        cursor: widget.isLoading ? SystemMouseCursors.wait : SystemMouseCursors.click,
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: config.width,
              height: config.height,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _handlePress,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.disabled)) {
                      return (widget.backgroundColor ?? AppColors.primaryRed).withOpacity(0.5);
                    }
                    return widget.backgroundColor ?? AppColors.primaryRed;
                  }),
                  foregroundColor: MaterialStateProperty.all(widget.textColor ?? AppColors.white),
                  overlayColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return (widget.backgroundColor ?? AppColors.primaryRed).withOpacity(0.1);
                    }
                    if (states.contains(MaterialState.pressed)) {
                      return (widget.backgroundColor ?? AppColors.primaryRed).withOpacity(0.2);
                    }
                    return null;
                  }),
                  padding: MaterialStateProperty.all(config.padding),
                  elevation: MaterialStateProperty.all(_isPressed ? config.elevation / 2 : config.elevation),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(config.borderRadius),
                  )),
                ),
                child: widget.isLoading ? _buildLoading(config) : _buildContent(config),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ResponsiveButtonConfig _getAdaptiveConfig(
      double screenWidth,
      double textScaleFactor,
      bool isDesktop,
      bool isTablet,
      bool isMobile,
      ) {
    // Width/Height: On mobile/tablet, use ScreenUtil scaling; on desktop, use fixed logical pixels to prevent over-sizing
    // (Your existing logic is already good here—no changes needed)
    final double baseWidth;
    final double baseHeight;
    if (isDesktop) {
      // Fixed sizes on desktop/web to avoid over-scaling (e.g., no .w multiplier)
      baseWidth = widget.width ?? 400.0; // Constrained width
      baseHeight = widget.height ?? 50.0; // Constrained height
    } else {
      // Mobile/Tablet: Scale with ScreenUtil
      final double tempWidth = widget.width ?? (isTablet ? 200.0 : 160.0);
      final double tempHeight = widget.height ?? (isTablet ? 52.0 : 48.0);
      baseWidth = tempWidth.clamp(120.0, 300.0).w; // Scale but clamp
      baseHeight = tempHeight.clamp(40.0, 60.0).h;
    }

    // Font: Fixed logical pixels on desktop (no .sp to avoid over-scaling); scaled on mobile/tablet
    final double baseFontSize = isDesktop ? 13.0 : isTablet ? 13.0 : 13.0; // Slightly smaller base on desktop
    double fontSize;
    if (isDesktop) {
      // Fixed: No .sp; respect textScaleFactor for accessibility, but clamp tightly
      final scaledFontSize = baseFontSize * textScaleFactor;
      fontSize = scaledFontSize.clamp(18.0, 20.0); // Tighter clamp for desktop (smaller max)
    } else {
      // Mobile/Tablet: Use .sp for responsive scaling
      final scaledFontSize = baseFontSize * textScaleFactor; // Multiplier fixed to 1.0 (was buggy 0.01)
      fontSize = scaledFontSize.clamp(12.0, 18.0).sp;
    }

    // Icon size: Fixed on desktop (no .sp); scaled on mobile/tablet
    final double baseIconSize = isDesktop ? 18.0 : isTablet ? 22.0 : 20.0; // Slightly smaller base on desktop
    double iconSize;
    if (isDesktop) {
      iconSize = (baseIconSize * textScaleFactor).clamp(16.0, 20.0); // Fixed pixels, respect textScaleFactor
    } else {
      iconSize = baseIconSize.clamp(16.0, 24.0).sp;
    }

    // Border radius: Fixed on desktop (no .r); scaled on mobile/tablet
    double responsiveBorderRadius;
    if (isDesktop) {
      responsiveBorderRadius = widget.borderRadius != AppDimensions.d30
          ? widget.borderRadius
          : 8.0; // Fixed smaller radius on desktop for modern look
    } else {
      responsiveBorderRadius = (widget.borderRadius != AppDimensions.d30
          ? widget.borderRadius
          : (isTablet ? 16.0 : 24.0)).r;
    }

    // Padding: Already fixed on desktop (your existing logic is good—no changes)
    final double horizontalPadding;
    final double verticalPadding;
    if (isDesktop) {
      horizontalPadding = 20.0; // Fixed on desktop
      verticalPadding = 12.0;
    } else {
      horizontalPadding = (isTablet ? 24.0 : 20.0).w;
      verticalPadding = (isTablet ? 14.0 : 12.0).h;
    }
    final padding = EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding);

    // Spacing: Fixed on desktop (no .w); scaled on mobile/tablet
    double spacing;
    if (isDesktop) {
      spacing = (isTablet ? 10.0 : 8.0).clamp(6.0, 10.0); // Fixed, tighter clamp
    } else {
      spacing = (isTablet ? 10.0 : 8.0).w.clamp(6.0, 12.0);
    }

    // Elevation and other properties - Subtle on desktop (your existing logic is good)
    final elevation = isDesktop ? 2.0 : isTablet ? 4.0 : 3.0; // Lower on desktop
    final letterSpacing = isDesktop ? 0.2 : isTablet ? 0.2 : 0.1;
    final fontWeight = isDesktop ? FontWeight.w500 : FontWeight.w500; // Consistent weight
    final lineHeight = isDesktop ? 1.15 : 1.1;

    return ResponsiveButtonConfig(
      width: baseWidth,
      height: baseHeight,
      fontSize: fontSize,
      iconSize: iconSize,
      borderRadius: responsiveBorderRadius,
      padding: padding,
      spacing: spacing,
      elevation: elevation,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      lineHeight: lineHeight,
    );
  }

  Widget _buildLoading(ResponsiveButtonConfig config) => SizedBox(
    width: config.iconSize,
    height: config.iconSize,
    child: CircularProgressIndicator(
      color: widget.textColor ?? AppColors.white,
      strokeWidth: (config.iconSize * 0.15).clamp(1.5, 3.0),
      backgroundColor: (widget.textColor ?? AppColors.white).withOpacity(0.2),
    ),
  );

  Widget _buildContent(ResponsiveButtonConfig config) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (widget.icon != null) ...[
        Icon(
          widget.icon,
          color: widget.textColor ?? AppColors.white,
          size: config.iconSize,
        ),
        SizedBox(width: config.spacing),
      ],
      if (widget.leading != null) ...[
        SizedBox(
          height: config.iconSize,
          child: Transform.scale(
            scale: config.iconSize / 20.0, // Adaptive scaling for leading widget
            child: widget.leading,
          ),
        ),
        SizedBox(width: config.spacing),
      ],
      Flexible(
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.textColor ?? AppColors.white,
            fontSize: config.fontSize,
            fontWeight: config.fontWeight,
            letterSpacing: config.letterSpacing,
            height: config.lineHeight, // FIXED: Use config.lineHeight instead of isDesktop
            fontFamily: 'GothamBold',
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );

  void _handlePress() {
    if (_isMobile) HapticFeedback.lightImpact();
    widget.onPressed();
  }

  void _onTapDown() {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onHover(bool hover) {
    if (!widget.isLoading) {
      setState(() => _isHovered = hover);
    }
  }
}

class ResponsiveButtonConfig {
  final double width;
  final double height;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final EdgeInsets padding;
  final double spacing;
  final double elevation;
  final double letterSpacing;
  final FontWeight fontWeight;
  final double lineHeight; // FIXED: Added lineHeight property

  const ResponsiveButtonConfig({
    required this.width,
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    required this.padding,
    required this.spacing,
    required this.elevation,
    required this.letterSpacing,
    required this.fontWeight,
    required this.lineHeight, // Include in constructor
  });
}