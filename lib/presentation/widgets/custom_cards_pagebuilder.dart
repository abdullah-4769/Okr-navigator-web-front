import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomCardPagerBuilder extends StatelessWidget {
  final dynamic controller;
  final bool buildActionButton;

  const CustomCardPagerBuilder({
    super.key,
    required this.controller,
    this.buildActionButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return _ResponsiveCardPager(
              controller: controller,
              constraints: constraints,
              orientation: orientation,
              buildActionButton: buildActionButton,
            );
          },
        );
      },
    );
  }
}

class _ResponsiveCardPager extends StatelessWidget {
  final dynamic controller;
  final BoxConstraints constraints;
  final Orientation orientation;
  final bool buildActionButton;

  const _ResponsiveCardPager({
    required this.controller,
    required this.constraints,
    required this.orientation,
    required this.buildActionButton,
  });

  // --- ENHANCED DEVICE DETECTION ---
  double get screenWidth => constraints.maxWidth;

  double get screenHeight => constraints.maxHeight;

  DeviceType get deviceType {
    if (screenWidth < 600) return DeviceType.mobile;
    if (screenWidth >= 600 && screenWidth < 900) return DeviceType.tablet;
    if (screenWidth >= 900 && screenWidth < 1200) return DeviceType.desktop;
    if (screenWidth >= 1200 && screenWidth < 1920)
      return DeviceType.largeDesktop;
    return DeviceType.ultraWide;
  }

  bool get isPortrait => orientation == Orientation.portrait;

  bool get isLandscape => orientation == Orientation.landscape;

  bool get isMobile => deviceType == DeviceType.mobile;

  bool get isTablet => deviceType == DeviceType.tablet;

  bool get isDesktop =>
      deviceType == DeviceType.desktop ||
          deviceType == DeviceType.largeDesktop ||
          deviceType == DeviceType.ultraWide;

  bool get isWeb => screenWidth >= 1200;

  // --- RESPONSIVE HELPERS ---

  /// Font size helper with orientation consideration
  double getResponsiveFont({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    double baseFontSize;

    switch (deviceType) {
      case DeviceType.mobile:
        baseFontSize = mobile;
        break;
      case DeviceType.tablet:
        baseFontSize = tablet;
        break;
      case DeviceType.desktop:
        baseFontSize = desktop;
        break;
      case DeviceType.largeDesktop:
        baseFontSize = largeDesktop;
        break;
      case DeviceType.ultraWide:
        baseFontSize = ultraWide;
        break;
    }

    // Adjust for landscape if needed
    if (isLandscape && landscapeAdjustment != null) {
      baseFontSize *= landscapeAdjustment;
    }

    return baseFontSize.sp;
  }

  /// Spacing helper with orientation consideration
  double getResponsiveSpacing({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    double baseSpacing;

    switch (deviceType) {
      case DeviceType.mobile:
        baseSpacing = mobile;
        break;
      case DeviceType.tablet:
        baseSpacing = tablet;
        break;
      case DeviceType.desktop:
        baseSpacing = desktop;
        break;
      case DeviceType.largeDesktop:
        baseSpacing = largeDesktop;
        break;
      case DeviceType.ultraWide:
        baseSpacing = ultraWide;
        break;
    }

    // Adjust for landscape if specified
    if (isLandscape && landscapeAdjustment != null) {
      baseSpacing *= landscapeAdjustment;
    }

    return baseSpacing.h;
  }

  /// Width helper with orientation support
  double getResponsiveWidth({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    double baseWidth;

    switch (deviceType) {
      case DeviceType.mobile:
        baseWidth = mobile;
        break;
      case DeviceType.tablet:
        baseWidth = tablet;
        break;
      case DeviceType.desktop:
        baseWidth = desktop;
        break;
      case DeviceType.largeDesktop:
        baseWidth = largeDesktop;
        break;
      case DeviceType.ultraWide:
        baseWidth = ultraWide;
        break;
    }

    // Adjust for landscape if needed
    if (isLandscape && landscapeAdjustment != null) {
      baseWidth *= landscapeAdjustment;
    }

    return baseWidth.w;
  }

  /// Height helper with orientation support
  double getResponsiveHeight({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
    double? landscapeAdjustment,
  }) {
    double baseHeight;

    switch (deviceType) {
      case DeviceType.mobile:
        baseHeight = mobile;
        break;
      case DeviceType.tablet:
        baseHeight = tablet;
        break;
      case DeviceType.desktop:
        baseHeight = desktop;
        break;
      case DeviceType.largeDesktop:
        baseHeight = largeDesktop;
        break;
      case DeviceType.ultraWide:
        baseHeight = ultraWide;
        break;
    }

    // Adjust for landscape if specified
    if (isLandscape && landscapeAdjustment != null) {
      baseHeight *= landscapeAdjustment;
    }

    return baseHeight.h;
  }

  /// Border radius helper
  double getResponsiveBorderRadius({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile.r;
      case DeviceType.tablet:
        return tablet.r;
      case DeviceType.desktop:
        return desktop.r;
      case DeviceType.largeDesktop:
        return largeDesktop.r;
      case DeviceType.ultraWide:
        return ultraWide.r;
    }
  }

  /// Stroke width helper for borders
  double getResponsiveStrokeWidth({
    required double mobile,
    required double tablet,
    required double desktop,
    required double largeDesktop,
    required double ultraWide,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.largeDesktop:
        return largeDesktop;
      case DeviceType.ultraWide:
        return ultraWide;
    }
  }

  /// Container max width for better web/desktop experience
  double? get maxContainerWidth {
    if (isMobile) return null;
    if (isTablet) return 600;
    if (deviceType == DeviceType.desktop) return 700;
    if (deviceType == DeviceType.largeDesktop) return 800;
    return 900; // ultraWide
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () =>
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxContainerWidth ?? double.infinity,
              ),
              child: Column(
                children: [

                  /// 🔹 Gradient Border Card Container
                  _buildCardContainer(),

                  // 🔹 Conditionally show spacing and button
                  if (buildActionButton) ...[
                    SizedBox(
                      height: getResponsiveSpacing(
                        mobile: 20,
                        tablet: 24,
                        desktop: 32,
                        largeDesktop: 36,
                        ultraWide: 40,
                        landscapeAdjustment: 0.8,
                      ),
                    ),

                    /// 🔹 Bubble Button Below Card (only if buildActionButton is true)
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 30.w),
                      child: Center(child: _buildActionButton()),
                    ),
                  ],
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildCardContainer() {
    final containerBorderRadius = getResponsiveBorderRadius(
      mobile: 20,
      tablet: 24,
      desktop: 28,
      largeDesktop: 32,
      ultraWide: 36,
    );

    final strokeWidth = getResponsiveStrokeWidth(
      mobile: 4,
      tablet: 5,
      desktop: 6,
      largeDesktop: 7,
      ultraWide: 8,
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: getResponsiveWidth(
          mobile: 24,
          tablet: 32,
          desktop: 40,
          largeDesktop: 48,
          ultraWide: 56,
          landscapeAdjustment: 0.8,
        ),
      ),
      child: CustomPaint(
        painter: _GradientBorderPainter(
          borderRadius: containerBorderRadius,
          strokeWidth: strokeWidth,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryRed,
              AppColors.primaryRed.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: Container(
          height: getResponsiveHeight(
            mobile: 400,
            tablet: 480,
            desktop: 560,
            largeDesktop: 620,
            ultraWide: 680,
            landscapeAdjustment: 0.75,
          ),
          width: double.infinity,
          // Add padding to create space between gradient border and inner container
          padding: EdgeInsets.all(strokeWidth + 4),
          // Border width + extra spacing
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(containerBorderRadius),
          ),
          child: Container(
            padding: EdgeInsets.all(
              getResponsiveWidth(
                mobile: 16,
                tablet: 20,
                desktop: 24,
                largeDesktop: 28,
                ultraWide: 32,
                landscapeAdjustment: 0.8,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(
                containerBorderRadius -
                    (strokeWidth + 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                      alpha: isDesktop ? 0.12 : 0.08),
                  blurRadius: isDesktop ? 12 : 8,
                  offset: Offset(0, isDesktop ? 6 : 4),
                  spreadRadius: isDesktop ? 1 : 0,
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: isDesktop ? 600 : 500),
                transitionBuilder: (child, animation) =>
                    FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.15),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    ),
                child: controller.selectedCardIndex.value == -1
                    ? Image.asset(
                  'assets/images/backcard_img.png',
                  key: const ValueKey<String>('backcard'),
                  height: getResponsiveHeight(
                    mobile: 350,
                    tablet: 420,
                    desktop: 480,
                    largeDesktop: 540,
                    ultraWide: 600,
                    landscapeAdjustment: 0.7,
                  ),
                  fit: BoxFit.contain,
                )
                    : Image.asset(
                  // ✅ CRITICAL FIX: Use strategyCardAssets directly (0-based, no backcard)
                  controller.strategyCardAssets[controller.selectedCardIndex.value],
                  key: ValueKey<int>(controller.selectedCardIndex.value),
                  height: getResponsiveHeight(
                    mobile: 350,
                    tablet: 420,
                    desktop: 480,
                    largeDesktop: 540,
                    ultraWide: 600,
                    landscapeAdjustment: 0.7,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Obx(() {
      // Disable button if card is already revealed or loading
      bool isDisabled = controller.isCardRevealed.value || controller.loading.value;

      return GestureDetector(
        onTap: isDisabled
            ? null
            : () {
          controller.revealRandomCard();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: getResponsiveHeight(
            mobile: 46,
            tablet: 48,
            desktop: 50,
            largeDesktop: 52,
            ultraWide: 54,
            landscapeAdjustment: 0.9,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: getResponsiveWidth(
              mobile: 50,
              tablet: 60,
              desktop: 62,
              largeDesktop: 64,
              ultraWide: 66,
              landscapeAdjustment: 0.8,
            ),
          ),
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.lightSkyBlue.withOpacity(0.5)
                : AppColors.lightSkyBlue,
            borderRadius: BorderRadius.circular(
              getResponsiveBorderRadius(
                mobile: 50,
                tablet: 55,
                desktop: 58,
                largeDesktop: 60,
                ultraWide: 62,
              ),
            ),
            boxShadow: isDisabled
                ? []
                : [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(
                  alpha: isDesktop ? 0.3 : 0.2,
                ),
                blurRadius: isDesktop ? 10 : 8,
                offset: Offset(0, isDesktop ? 5 : 4),
                spreadRadius: isDesktop ? 1 : 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: controller.loading.value
              ? SizedBox(
            width: getResponsiveFont(
              mobile: 20,
              tablet: 22,
              desktop: 24,
              largeDesktop: 26,
              ultraWide: 28,
              landscapeAdjustment: 0.9,
            ),
            height: getResponsiveFont(
              mobile: 20,
              tablet: 22,
              desktop: 24,
              largeDesktop: 26,
              ultraWide: 28,
              landscapeAdjustment: 0.9,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          )
              : _buildButtonTextContent(), // Extract text content to separate method
        ),
      );
    });
  }

// New method for button text content only
  Widget _buildButtonTextContent() {
    return Obx(() {
      if (controller.isCardRevealed.value) {
        // Strategy Revealed state
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // First line with celebration emoji
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎉 ',
                  style: TextStyle(
                    fontSize: getResponsiveFont(
                      mobile: 16,
                      tablet: 13,
                      desktop: 14,
                      largeDesktop: 15,
                      ultraWide: 16,
                      landscapeAdjustment: 0.9,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'strategy_revealed'.tr,
                    style: TextStyle(
                      fontFamily: 'GothamBold',
                      fontSize: getResponsiveFont(
                        mobile: 14,
                        tablet: 11,
                        desktop: 12,
                        largeDesktop: 13,
                        ultraWide: 14,
                        landscapeAdjustment: 0.9,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      letterSpacing: isDesktop ? 0.5 : 0.4,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  ' 🎉',
                  style: TextStyle(
                    fontSize: getResponsiveFont(
                      mobile: 16,
                      tablet: 13,
                      desktop: 14,
                      largeDesktop: 15,
                      ultraWide: 16,
                      landscapeAdjustment: 0.9,
                    ),
                  ),
                ),
              ],
            ),

            // Second line
            Text(
              'lets_start_mission'.tr,
              style: TextStyle(
                fontFamily: 'Gotham',
                fontSize: getResponsiveFont(
                  mobile: 12,
                  tablet: 9,
                  desktop: 10,
                  largeDesktop: 11,
                  ultraWide: 12,
                  landscapeAdjustment: 0.9,
                ),
                fontWeight: FontWeight.w600,
                color: Colors.blue.withOpacity(0.9),
                letterSpacing: isDesktop ? 0.3 : 0.2,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      } else {
        // Tap to Reveal state
        return Text(
          'tap_to_reveal_strategy'.tr,
          style: TextStyle(
            fontFamily: 'GothamBold',
            fontSize: getResponsiveFont(
              mobile: 16,
              tablet: 10,
              desktop: 11,
              largeDesktop: 12,
              ultraWide: 13,
              landscapeAdjustment: 0.9,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            letterSpacing: isDesktop ? 0.6 : 0.5,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        );
      }
    });
  }
}

/// 🔹 Enhanced Gradient Border Painter
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
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Enhanced device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
  ultraWide,
}





// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../../../core/app_colors.dart';
// import '../../../core/app_dimensions.dart';
//
// class CustomCardPagerBuilder extends StatelessWidget {
//   final dynamic controller;
//
//   const CustomCardPagerBuilder({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return OrientationBuilder(
//           builder: (context, orientation) {
//             return _ResponsiveCardPager(
//               controller: controller,
//               constraints: constraints,
//               orientation: orientation,
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// class _ResponsiveCardPager extends StatelessWidget {
//   final dynamic controller;
//   final BoxConstraints constraints;
//   final Orientation orientation;
//
//   const _ResponsiveCardPager({
//     required this.controller,
//     required this.constraints,
//     required this.orientation,
//   });
//
//   // ── Device detection ──────────────────────────────────────────────────────
//   double get screenWidth => constraints.maxWidth;
//   double get screenHeight => constraints.maxHeight;
//
//   DeviceType get deviceType {
//     if (screenWidth < 600) return DeviceType.mobile;
//     if (screenWidth < 900) return DeviceType.tablet;
//     if (screenWidth < 1200) return DeviceType.desktop;
//     if (screenWidth < 1920) return DeviceType.largeDesktop;
//     return DeviceType.ultraWide;
//   }
//
//   bool get isPortrait => orientation == Orientation.portrait;
//   bool get isLandscape => orientation == Orientation.landscape;
//   bool get isMobile => deviceType == DeviceType.mobile;
//   bool get isTablet => deviceType == DeviceType.tablet;
//   bool get isDesktop =>
//       deviceType == DeviceType.desktop ||
//           deviceType == DeviceType.largeDesktop ||
//           deviceType == DeviceType.ultraWide;
//
//   // ── FIXED font helper ─────────────────────────────────────────────────────
//   // On desktop/tablet we return plain logical pixels (no .sp) to prevent
//   // ScreenUtil from multiplying an already-large value inside fixed cards.
//   double getResponsiveFont({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//     double? landscapeAdjustment,
//   }) {
//     double base;
//     switch (deviceType) {
//       case DeviceType.mobile:
//         base = mobile;
//         break;
//       case DeviceType.tablet:
//         base = tablet;
//         break;
//       case DeviceType.desktop:
//         base = desktop;
//         break;
//       case DeviceType.largeDesktop:
//         base = largeDesktop;
//         break;
//       case DeviceType.ultraWide:
//         base = ultraWide;
//         break;
//     }
//     if (isLandscape && landscapeAdjustment != null) base *= landscapeAdjustment;
//
//     // ✅ Mobile only → ScreenUtil scaling. Desktop/tablet → logical px.
//     return isMobile ? base.sp : base;
//   }
//
//   // ── Spacing / Width / Height helpers (unchanged) ──────────────────────────
//   double getResponsiveSpacing({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//     double? landscapeAdjustment,
//   }) {
//     double base;
//     switch (deviceType) {
//       case DeviceType.mobile: base = mobile; break;
//       case DeviceType.tablet: base = tablet; break;
//       case DeviceType.desktop: base = desktop; break;
//       case DeviceType.largeDesktop: base = largeDesktop; break;
//       case DeviceType.ultraWide: base = ultraWide; break;
//     }
//     if (isLandscape && landscapeAdjustment != null) base *= landscapeAdjustment;
//     return base.h;
//   }
//
//   double getResponsiveWidth({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//     double? landscapeAdjustment,
//   }) {
//     double base;
//     switch (deviceType) {
//       case DeviceType.mobile: base = mobile; break;
//       case DeviceType.tablet: base = tablet; break;
//       case DeviceType.desktop: base = desktop; break;
//       case DeviceType.largeDesktop: base = largeDesktop; break;
//       case DeviceType.ultraWide: base = ultraWide; break;
//     }
//     if (isLandscape && landscapeAdjustment != null) base *= landscapeAdjustment;
//     return base.w;
//   }
//
//   double getResponsiveHeight({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//     double? landscapeAdjustment,
//   }) {
//     double base;
//     switch (deviceType) {
//       case DeviceType.mobile: base = mobile; break;
//       case DeviceType.tablet: base = tablet; break;
//       case DeviceType.desktop: base = desktop; break;
//       case DeviceType.largeDesktop: base = largeDesktop; break;
//       case DeviceType.ultraWide: base = ultraWide; break;
//     }
//     if (isLandscape && landscapeAdjustment != null) base *= landscapeAdjustment;
//     return base.h;
//   }
//
//   double getResponsiveBorderRadius({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//   }) {
//     switch (deviceType) {
//       case DeviceType.mobile: return mobile.r;
//       case DeviceType.tablet: return tablet.r;
//       case DeviceType.desktop: return desktop.r;
//       case DeviceType.largeDesktop: return largeDesktop.r;
//       case DeviceType.ultraWide: return ultraWide.r;
//     }
//   }
//
//   double getResponsiveStrokeWidth({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//     required double largeDesktop,
//     required double ultraWide,
//   }) {
//     switch (deviceType) {
//       case DeviceType.mobile: return mobile;
//       case DeviceType.tablet: return tablet;
//       case DeviceType.desktop: return desktop;
//       case DeviceType.largeDesktop: return largeDesktop;
//       case DeviceType.ultraWide: return ultraWide;
//     }
//   }
//
//   double? get maxContainerWidth {
//     if (isMobile) return null;
//     if (isTablet) return 600;
//     if (deviceType == DeviceType.desktop) return 700;
//     if (deviceType == DeviceType.largeDesktop) return 800;
//     return 900;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Center(
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: maxContainerWidth ?? double.infinity,
//         ),
//         child: Column(
//           children: [
//             _buildCardContainer(),
//             SizedBox(
//               height: getResponsiveSpacing(
//                 mobile: 20,
//                 tablet: 24,
//                 desktop: 28,
//                 largeDesktop: 32,
//                 ultraWide: 36,
//                 landscapeAdjustment: 0.8,
//               ),
//             ),
//             _buildActionButton(),
//           ],
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildCardContainer() {
//     final containerBorderRadius = getResponsiveBorderRadius(
//       mobile: 20, tablet: 24, desktop: 28, largeDesktop: 32, ultraWide: 36,
//     );
//     final strokeWidth = getResponsiveStrokeWidth(
//       mobile: 4, tablet: 5, desktop: 6, largeDesktop: 7, ultraWide: 8,
//     );
//
//     return Container(
//       margin: EdgeInsets.symmetric(
//         horizontal: getResponsiveWidth(
//           mobile: 24, tablet: 32, desktop: 40, largeDesktop: 48, ultraWide: 56,
//           landscapeAdjustment: 0.8,
//         ),
//       ),
//       child: CustomPaint(
//         painter: _GradientBorderPainter(
//           borderRadius: containerBorderRadius,
//           strokeWidth: strokeWidth,
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.primaryRed,
//               AppColors.primaryRed.withValues(alpha: 0.15),
//             ],
//           ),
//         ),
//         child: Container(
//           height: getResponsiveHeight(
//             mobile: 400, tablet: 480, desktop: 520,
//             largeDesktop: 560, ultraWide: 600,
//             landscapeAdjustment: 0.75,
//           ),
//           width: double.infinity,
//           padding: EdgeInsets.all(strokeWidth + 4),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(containerBorderRadius),
//           ),
//           child: Container(
//             padding: EdgeInsets.all(
//               getResponsiveWidth(
//                 mobile: 16, tablet: 20, desktop: 24,
//                 largeDesktop: 28, ultraWide: 32,
//                 landscapeAdjustment: 0.8,
//               ),
//             ),
//             decoration: BoxDecoration(
//               color: AppColors.primaryRed.withValues(alpha: 0.08),
//               borderRadius: BorderRadius.circular(
//                 containerBorderRadius - (strokeWidth + 2),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(
//                     alpha: isDesktop ? 0.12 : 0.08,
//                   ),
//                   blurRadius: isDesktop ? 12 : 8,
//                   offset: Offset(0, isDesktop ? 6 : 4),
//                   spreadRadius: isDesktop ? 1 : 0,
//                 ),
//               ],
//             ),
//             child: Center(
//               child: AnimatedSwitcher(
//                 duration: Duration(milliseconds: isDesktop ? 600 : 500),
//                 transitionBuilder: (child, animation) => FadeTransition(
//                   opacity: animation,
//                   child: SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(0.0, 0.15),
//                       end: Offset.zero,
//                     ).animate(CurvedAnimation(
//                       parent: animation,
//                       curve: Curves.easeOutCubic,
//                     )),
//                     child: child,
//                   ),
//                 ),
//                 child: controller.selectedCardIndex.value == -1
//                     ? Image.asset(
//                   'assets/images/backcard_img.png',
//                   key: const ValueKey<String>('backcard'),
//                   height: getResponsiveHeight(
//                     mobile: 350, tablet: 420, desktop: 460,
//                     largeDesktop: 500, ultraWide: 540,
//                     landscapeAdjustment: 0.7,
//                   ),
//                   fit: BoxFit.contain,
//                 )
//                     : Image.asset(
//                   controller.cardAssets[controller.selectedCardIndex.value],
//                   key: ValueKey<int>(controller.selectedCardIndex.value),
//                   height: getResponsiveHeight(
//                     mobile: 350, tablet: 420, desktop: 460,
//                     largeDesktop: 500, ultraWide: 540,
//                     landscapeAdjustment: 0.7,
//                   ),
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton() {
//     // ── Font: scales with actual container width, not device category ─────────
//     // screenWidth here is the LayoutBuilder constraint (card/container width),
//     // so it naturally adapts whether you're in a narrow mobile or wide desktop card.
//     final double fontSize = (screenWidth * 0.038).clamp(
//       12.0, // never smaller than 12 logical px
//       16.0, // never larger than 16 logical px
//     );
//
//     // ── Height: fixed logical px — no .h on desktop ───────────────────────────
//     final double btnHeight = isMobile ? 48.h : 48.0;
//
//     // ── Horizontal padding: proportional to container width ───────────────────
//     final double hPad = (screenWidth * 0.08).clamp(20.0, 56.0);
//
//     return GestureDetector(
//       onTap: () {
//         if (controller.isCardRevealed.value) {
//           controller.resetAndDrawNewCard();
//         } else {
//           controller.revealRandomCard();
//         }
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeInOut,
//         height: btnHeight,
//         padding: EdgeInsets.symmetric(horizontal: hPad),
//         decoration: BoxDecoration(
//           color: AppColors.lightSkyBlue,
//           borderRadius: BorderRadius.circular(50),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primaryBlue.withValues(
//                 alpha: isDesktop ? 0.3 : 0.2,
//               ),
//               blurRadius: isDesktop ? 10 : 8,
//               offset: Offset(0, isDesktop ? 5 : 4),
//             ),
//           ],
//         ),
//         alignment: Alignment.center,
//         child: FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             controller.isCardRevealed.value
//                 ? 'draw_new_strategy'.tr
//                 : 'tap_to_reveal_strategy'.tr,
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             style: TextStyle(
//               fontFamily: 'GothamBold',
//               fontSize: fontSize,
//               fontWeight: FontWeight.normal,
//               color: Colors.blue,
//               letterSpacing: 0.3,
//               height: 1.2,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   //
//   // Widget _buildActionButton() {
//   //   // ✅ Button font: plain logical px on desktop/tablet, .sp on mobile only
//   //   final double fontSize = getResponsiveFont(
//   //     mobile: 13,      // .sp applied automatically for mobile
//   //     tablet: 14,      // plain px on tablet
//   //     desktop: 14,     // plain px on desktop
//   //     largeDesktop: 15,
//   //     ultraWide: 15,
//   //     landscapeAdjustment: 0.9,
//   //   );
//   //
//   //   // ✅ Button height: plain logical px everywhere (no .h on desktop)
//   //   final double btnHeight = isMobile
//   //       ? getResponsiveHeight(
//   //     mobile: 46, tablet: 48, desktop: 48,
//   //     largeDesktop: 50, ultraWide: 52,
//   //     landscapeAdjustment: 0.9,
//   //   )
//   //       : (isTablet ? 46.0 : 48.0); // fixed px on desktop/tablet
//   //
//   //   return GestureDetector(
//   //     onTap: () {
//   //       if (controller.isCardRevealed.value) {
//   //         controller.resetAndDrawNewCard();
//   //       } else {
//   //         controller.revealRandomCard();
//   //       }
//   //     },
//   //     child: AnimatedContainer(
//   //       duration: const Duration(milliseconds: 200),
//   //       curve: Curves.easeInOut,
//   //       height: btnHeight,
//   //       constraints: BoxConstraints(
//   //         minHeight: isMobile ? 44 : 44,
//   //       ),
//   //       padding: EdgeInsets.symmetric(
//   //         horizontal: getResponsiveWidth(
//   //           mobile: 40, tablet: 48, desktop: 52,
//   //           largeDesktop: 56, ultraWide: 60,
//   //           landscapeAdjustment: 0.8,
//   //         ),
//   //       ),
//   //       decoration: BoxDecoration(
//   //         color: AppColors.lightSkyBlue,
//   //         borderRadius: BorderRadius.circular(
//   //           getResponsiveBorderRadius(
//   //             mobile: 50, tablet: 50, desktop: 50,
//   //             largeDesktop: 50, ultraWide: 50,
//   //           ),
//   //         ),
//   //         boxShadow: [
//   //           BoxShadow(
//   //             color: AppColors.primaryBlue.withValues(
//   //               alpha: isDesktop ? 0.3 : 0.2,
//   //             ),
//   //             blurRadius: isDesktop ? 10 : 8,
//   //             offset: Offset(0, isDesktop ? 5 : 4),
//   //           ),
//   //         ],
//   //       ),
//   //       alignment: Alignment.center,
//   //       child: Text(
//   //         controller.isCardRevealed.value
//   //             ? 'draw_new_strategy'.tr
//   //             : 'tap_to_reveal_strategy'.tr,
//   //         textAlign: TextAlign.center,
//   //         style: TextStyle(
//   //           fontFamily: 'GothamBold',
//   //           fontSize: fontSize,
//   //           fontWeight: FontWeight.normal,
//   //           color: Colors.blue,
//   //           letterSpacing: isDesktop ? 0.4 : 0.3,
//   //           height: 1.2,
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
// }
//
// class _GradientBorderPainter extends CustomPainter {
//   final double borderRadius;
//   final double strokeWidth;
//   final Gradient gradient;
//
//   _GradientBorderPainter({
//     required this.borderRadius,
//     required this.strokeWidth,
//     required this.gradient,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(
//       strokeWidth / 2,
//       strokeWidth / 2,
//       size.width - strokeWidth,
//       size.height - strokeWidth,
//     );
//     final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
//     final paint = Paint()
//       ..shader = gradient.createShader(
//         Rect.fromLTWH(0, 0, size.width, size.height),
//       )
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;
//
//     canvas.drawRRect(rRect, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// enum DeviceType {
//   mobile,
//   tablet,
//   desktop,
//   largeDesktop,
//   ultraWide,
// }
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:get/get.dart';
// // import '../../../core/app_colors.dart';
// // import '../../../core/app_dimensions.dart';
// //
// // class CustomCardPagerBuilder extends StatelessWidget {
// //   final dynamic controller; // Accept ANY Getx controller that has the same API
// //
// //   const CustomCardPagerBuilder({super.key, required this.controller});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         return OrientationBuilder(
// //           builder: (context, orientation) {
// //             return _ResponsiveCardPager(
// //               controller: controller,
// //               constraints: constraints,
// //               orientation: orientation,
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // class _ResponsiveCardPager extends StatelessWidget {
// //   final dynamic controller;
// //   final BoxConstraints constraints;
// //   final Orientation orientation;
// //
// //   const _ResponsiveCardPager({
// //     required this.controller,
// //     required this.constraints,
// //     required this.orientation,
// //   });
// //
// //   // --- ENHANCED DEVICE DETECTION ---
// //   double get screenWidth => constraints.maxWidth;
// //   double get screenHeight => constraints.maxHeight;
// //
// //   DeviceType get deviceType {
// //     if (screenWidth < 600) return DeviceType.mobile;
// //     if (screenWidth >= 600 && screenWidth < 900) return DeviceType.tablet;
// //     if (screenWidth >= 900 && screenWidth < 1200) return DeviceType.desktop;
// //     if (screenWidth >= 1200 && screenWidth < 1920) return DeviceType.largeDesktop;
// //     return DeviceType.ultraWide;
// //   }
// //
// //   bool get isPortrait => orientation == Orientation.portrait;
// //   bool get isLandscape => orientation == Orientation.landscape;
// //   bool get isMobile => deviceType == DeviceType.mobile;
// //   bool get isTablet => deviceType == DeviceType.tablet;
// //   bool get isDesktop =>
// //       deviceType == DeviceType.desktop ||
// //           deviceType == DeviceType.largeDesktop ||
// //           deviceType == DeviceType.ultraWide;
// //   bool get isWeb => screenWidth >= 1200;
// //
// //   // --- RESPONSIVE HELPERS ---
// //   double getResponsiveFont({
// //     required double mobile,
// //     required double tablet,
// //     required double desktop,
// //     required double largeDesktop,
// //     required double ultraWide,
// //     double? landscapeAdjustment,
// //   }) {
// //     double baseFontSize;
// //
// //     switch (deviceType) {
// //       case DeviceType.mobile:
// //         baseFontSize = mobile;
// //         break;
// //       case DeviceType.tablet:
// //         baseFontSize = tablet;
// //         break;
// //       case DeviceType.desktop:
// //         baseFontSize = desktop;
// //         break;
// //       case DeviceType.largeDesktop:
// //         baseFontSize = largeDesktop;
// //         break;
// //       case DeviceType.ultraWide:
// //         baseFontSize = ultraWide;
// //         break;
// //     }
// //
// //     if (isLandscape && landscapeAdjustment != null) {
// //       baseFontSize *= landscapeAdjustment;
// //     }
// //
// //     return baseFontSize.sp;
// //   }
// //
// //   double getResponsiveSpacing({
// //     required double mobile,
// //     required double tablet,
// //     required double desktop,
// //     required double largeDesktop,
// //     required double ultraWide,
// //     double? landscapeAdjustment,
// //   }) {
// //     double baseSpacing;
// //
// //     switch (deviceType) {
// //       case DeviceType.mobile:
// //         baseSpacing = mobile;
// //         break;
// //       case DeviceType.tablet:
// //         baseSpacing = tablet;
// //         break;
// //       case DeviceType.desktop:
// //         baseSpacing = desktop;
// //         break;
// //       case DeviceType.largeDesktop:
// //         baseSpacing = largeDesktop;
// //         break;
// //       case DeviceType.ultraWide:
// //         baseSpacing = ultraWide;
// //         break;
// //     }
// //
// //     if (isLandscape && landscapeAdjustment != null) {
// //       baseSpacing *= landscapeAdjustment;
// //     }
// //
// //     return baseSpacing.h;
// //   }
// //
// //   double getResponsiveWidth({
// //     required double mobile,
// //     required double tablet,
// //     required double desktop,
// //     required double largeDesktop,
// //     required double ultraWide,
// //     double? landscapeAdjustment,
// //   }) {
// //     double baseWidth;
// //
// //     switch (deviceType) {
// //       case DeviceType.mobile:
// //         baseWidth = mobile;
// //         break;
// //       case DeviceType.tablet:
// //         baseWidth = tablet;
// //         break;
// //       case DeviceType.desktop:
// //         baseWidth = desktop;
// //         break;
// //       case DeviceType.largeDesktop:
// //         baseWidth = largeDesktop;
// //         break;
// //       case DeviceType.ultraWide:
// //         baseWidth = ultraWide;
// //         break;
// //     }
// //
// //     if (isLandscape && landscapeAdjustment != null) {
// //       baseWidth *= landscapeAdjustment;
// //     }
// //
// //     return baseWidth.w;
// //   }
// //
// //   double getResponsiveHeight({
// //     required double mobile,
// //     required double tablet,
// //     required double desktop,
// //     required double largeDesktop,
// //     required double ultraWide,
// //     double? landscapeAdjustment,
// //   }) {
// //     double baseHeight;
// //
// //     switch (deviceType) {
// //       case DeviceType.mobile:
// //         baseHeight = mobile;
// //         break;
// //       case DeviceType.tablet:
// //         baseHeight = tablet;
// //         break;
// //       case DeviceType.desktop:
// //         baseHeight = desktop;
// //         break;
// //       case DeviceType.largeDesktop:
// //         baseHeight = largeDesktop;
// //         break;
// //       case DeviceType.ultraWide:
// //         baseHeight = ultraWide;
// //         break;
// //     }
// //
// //     if (isLandscape && landscapeAdjustment != null) {
// //       baseHeight *= landscapeAdjustment;
// //     }
// //
// //     return baseHeight.h;
// //   }
// //
// //   double getResponsiveBorderRadius({
// //     required double mobile,
// //     required double tablet,
// //     required double desktop,
// //     required double largeDesktop,
// //     required double ultraWide,
// //   }) {
// //     switch (deviceType) {
// //       case DeviceType.mobile:
// //         return mobile.r;
// //       case DeviceType.tablet:
// //         return tablet.r;
// //       case DeviceType.desktop:
// //         return desktop.r;
// //       case DeviceType.largeDesktop:
// //         return largeDesktop.r;
// //       case DeviceType.ultraWide:
// //         return ultraWide.r;
// //     }
// //   }
// //
// //   double getResponsiveStrokeWidth({
// //     required double mobile,
// //     required double tablet,
// //     required double desktop,
// //     required double largeDesktop,
// //     required double ultraWide,
// //   }) {
// //     switch (deviceType) {
// //       case DeviceType.mobile:
// //         return mobile;
// //       case DeviceType.tablet:
// //         return tablet;
// //       case DeviceType.desktop:
// //         return desktop;
// //       case DeviceType.largeDesktop:
// //         return largeDesktop;
// //       case DeviceType.ultraWide:
// //         return ultraWide;
// //     }
// //   }
// //
// //   double? get maxContainerWidth {
// //     if (isMobile) return null;
// //     if (isTablet) return 600;
// //     if (deviceType == DeviceType.desktop) return 700;
// //     if (deviceType == DeviceType.largeDesktop) return 800;
// //     return 900; // ultraWide
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Obx(() => Center(
// //       child: Container(
// //         constraints: BoxConstraints(maxWidth: maxContainerWidth ?? double.infinity),
// //         child: Column(
// //           children: [
// //             _buildCardContainer(),
// //             SizedBox(
// //               height: getResponsiveSpacing(
// //                 mobile: 20,
// //                 tablet: 24,
// //                 desktop: 32,
// //                 largeDesktop: 36,
// //                 ultraWide: 40,
// //                 landscapeAdjustment: 0.8,
// //               ),
// //             ),
// //             _buildActionButton(), // Fixed button
// //           ],
// //         ),
// //       ),
// //     ));
// //   }
// //
// //   Widget _buildCardContainer() {
// //     final containerBorderRadius = getResponsiveBorderRadius(
// //       mobile: 20,
// //       tablet: 24,
// //       desktop: 28,
// //       largeDesktop: 32,
// //       ultraWide: 36,
// //     );
// //
// //     final strokeWidth = getResponsiveStrokeWidth(
// //       mobile: 4,
// //       tablet: 5,
// //       desktop: 6,
// //       largeDesktop: 7,
// //       ultraWide: 8,
// //     );
// //
// //     return Container(
// //       margin: EdgeInsets.symmetric(
// //         horizontal: getResponsiveWidth(
// //           mobile: 24,
// //           tablet: 32,
// //           desktop: 40,
// //           largeDesktop: 48,
// //           ultraWide: 56,
// //           landscapeAdjustment: 0.8,
// //         ),
// //       ),
// //       child: CustomPaint(
// //         painter: _GradientBorderPainter(
// //           borderRadius: containerBorderRadius,
// //           strokeWidth: strokeWidth,
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               AppColors.primaryRed,
// //               AppColors.primaryRed.withValues(alpha: 0.15),
// //             ],
// //           ),
// //         ),
// //         child: Container(
// //           height: getResponsiveHeight(
// //             mobile: 400,
// //             tablet: 480,
// //             desktop: 560,
// //             largeDesktop: 620,
// //             ultraWide: 680,
// //             landscapeAdjustment: 0.75,
// //           ),
// //           width: double.infinity,
// //           padding: EdgeInsets.all(strokeWidth + 4),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(containerBorderRadius),
// //           ),
// //           child: Container(
// //             padding: EdgeInsets.all(
// //               getResponsiveWidth(
// //                 mobile: 16,
// //                 tablet: 20,
// //                 desktop: 24,
// //                 largeDesktop: 28,
// //                 ultraWide: 32,
// //                 landscapeAdjustment: 0.8,
// //               ),
// //             ),
// //             decoration: BoxDecoration(
// //               color: AppColors.primaryRed.withValues(alpha: 0.08),
// //               borderRadius: BorderRadius.circular(containerBorderRadius - (strokeWidth + 2)),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withValues(alpha: isDesktop ? 0.12 : 0.08),
// //                   blurRadius: isDesktop ? 12 : 8,
// //                   offset: Offset(0, isDesktop ? 6 : 4),
// //                   spreadRadius: isDesktop ? 1 : 0,
// //                 ),
// //               ],
// //             ),
// //             child: Center(
// //               child: AnimatedSwitcher(
// //                 duration: Duration(milliseconds: isDesktop ? 600 : 500),
// //                 transitionBuilder: (child, animation) => FadeTransition(
// //                   opacity: animation,
// //                   child: SlideTransition(
// //                     position: Tween<Offset>(
// //                       begin: const Offset(0.0, 0.15),
// //                       end: Offset.zero,
// //                     ).animate(CurvedAnimation(
// //                       parent: animation,
// //                       curve: Curves.easeOutCubic,
// //                     )),
// //                     child: child,
// //                   ),
// //                 ),
// //                 child: controller.selectedCardIndex.value == -1
// //                     ? Image.asset(
// //                   'assets/images/backcard_img.png',
// //                   key: const ValueKey<String>('backcard'),
// //                   height: getResponsiveHeight(
// //                     mobile: 350,
// //                     tablet: 420,
// //                     desktop: 480,
// //                     largeDesktop: 540,
// //                     ultraWide: 600,
// //                     landscapeAdjustment: 0.7,
// //                   ),
// //                   fit: BoxFit.contain,
// //                 )
// //                     : Image.asset(
// //                   controller.cardAssets[controller.selectedCardIndex.value],
// //                   key: ValueKey<int>(controller.selectedCardIndex.value),
// //                   height: getResponsiveHeight(
// //                     mobile: 350,
// //                     tablet: 420,
// //                     desktop: 480,
// //                     largeDesktop: 540,
// //                     ultraWide: 600,
// //                     landscapeAdjustment: 0.7,
// //                   ),
// //                   fit: BoxFit.contain,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   /// ✅ Fixed button: auto-expand height + reduced padding for small screens
// //   Widget _buildActionButton() {
// //     return GestureDetector(
// //       onTap: () {
// //         if (controller.isCardRevealed.value) {
// //           controller.resetAndDrawNewCard();
// //         } else {
// //           controller.revealRandomCard();
// //         }
// //       },
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         curve: Curves.easeInOut,
// //         constraints: BoxConstraints(
// //           minHeight: getResponsiveHeight(
// //             mobile: 10, // reduced padding for small screens
// //             tablet: 20,
// //             desktop: 30,
// //             largeDesktop: 40,
// //             ultraWide: 50,
// //           ),
// //         ),
// //         padding: EdgeInsets.symmetric(horizontal: 0.02),
// //         // padding: EdgeInsets.symmetric(
// //         //   horizontal: getResponsiveWidth(
// //         //     mobile: 5, // reduced padding for small screens
// //         //     tablet: 1,
// //         //     desktop: 1,
// //         //     largeDesktop: 2,
// //         //     ultraWide: 2,
// //         //   ),
// //         //   vertical: 8, // allows text wrap
// //         // ),
// //         decoration: BoxDecoration(
// //           color: AppColors.lightSkyBlue,
// //           borderRadius: BorderRadius.circular(
// //             getResponsiveBorderRadius(
// //               mobile: 50,
// //               tablet: 55,
// //               desktop: 58,
// //               largeDesktop: 60,
// //               ultraWide: 62,
// //             ),
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: AppColors.primaryBlue.withValues(alpha: isDesktop ? 0.3 : 0.2),
// //               blurRadius: isDesktop ? 10 : 8,
// //               offset: Offset(0, isDesktop ? 5 : 4),
// //             ),
// //           ],
// //         ),
// //         alignment: Alignment.center,
// //         child: Text(
// //           controller.isCardRevealed.value
// //               ? 'draw_new_strategy'.tr
// //               : 'tap_to_reveal_strategy'.tr,
// //           textAlign: TextAlign.center,
// //           style: TextStyle(
// //             fontFamily: 'GothamBold',
// //             fontSize: getResponsiveFont(
// //               mobile: 10,
// //               tablet: 16,
// //               desktop: 20,
// //               largeDesktop: 24,
// //               ultraWide: 28,
// //               landscapeAdjustment: 0.9,
// //             ),
// //             fontWeight: FontWeight.normal,
// //             color: Colors.blue,
// //             letterSpacing: isDesktop ? 0.6 : 0.5,
// //             height: 1.2,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // /// 🔹 Enhanced Gradient Border Painter
// // class _GradientBorderPainter extends CustomPainter {
// //   final double borderRadius;
// //   final double strokeWidth;
// //   final Gradient gradient;
// //
// //   _GradientBorderPainter({
// //     required this.borderRadius,
// //     required this.strokeWidth,
// //     required this.gradient,
// //   });
// //
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final rect = Rect.fromLTWH(
// //       strokeWidth / 2,
// //       strokeWidth / 2,
// //       size.width - strokeWidth,
// //       size.height - strokeWidth,
// //     );
// //     final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
// //     final paint = Paint()
// //       ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
// //       ..style = PaintingStyle.stroke
// //       ..strokeWidth = strokeWidth
// //       ..strokeCap = StrokeCap.round
// //       ..strokeJoin = StrokeJoin.round;
// //
// //     canvas.drawRRect(rRect, paint);
// //   }
// //
// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// // }
// //
// // enum DeviceType {
// //   mobile,      // < 600px
// //   tablet,      // 600-899px
// //   desktop,     // 900-1199px
// //   largeDesktop, // 1200-1919px
// //   ultraWide,   // >= 1920px
// // }
// //
// //
