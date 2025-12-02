import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/key_results_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomSelectedKeyResultsContainer extends StatelessWidget {
  const CustomSelectedKeyResultsContainer({super.key});

  // Platform detection helpers
  bool get _isWeb => kIsWeb;
  bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // Responsive breakpoints
  bool _isLargeScreen(double width) => width > 1440;
  bool _isMediumScreen(double width) => width > 1024 && width <= 1440;
  bool _isTabletScreen(double width) => width > 768 && width <= 1024;
  bool _isSmallScreen(double width) => width <= 768;

  // Platform-specific margins
  EdgeInsets _getContainerMargin(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: max(40, screenWidth * 0.08), vertical: 24);
      } else if (_isMediumScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: 32, vertical: 20);
      } else if (_isTabletScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: 24, vertical: 18);
      } else {
        return EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      }
    } else {
      return EdgeInsets.symmetric(
        horizontal: _isTabletScreen(screenWidth) ? AppDimensions.d20.w : AppDimensions.d18.w,
        vertical: _isTabletScreen(screenWidth) ? AppDimensions.d18.h : AppDimensions.d16.h,
      );
    }
  }

  // Platform-specific padding
  EdgeInsets _getContainerPadding(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return EdgeInsets.all(22);
      if (_isMediumScreen(screenWidth)) return EdgeInsets.all(18);
      if (_isTabletScreen(screenWidth)) return EdgeInsets.all(16);
      return EdgeInsets.all(16);
    } else {
      return EdgeInsets.all(_isTabletScreen(screenWidth) ? AppDimensions.d18.w : AppDimensions.d16.w);
    }
  }

  // Platform-specific border radius
  double _getBorderRadius(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 16;
      if (_isMediumScreen(screenWidth)) return 14;
      return 12;
    } else {
      return _isTabletScreen(screenWidth) ? AppDimensions.d14.r : AppDimensions.d12.r;
    }
  }

  // Platform-specific circle size
  double _getCircleSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 56;
      if (_isMediumScreen(screenWidth)) return 50;
      if (_isTabletScreen(screenWidth)) return 46;
      return 42;
    } else {
      return _isTabletScreen(screenWidth) ? 44.w : AppDimensions.d40.w;
    }
  }

  // Platform-specific spacing
  double _getHorizontalSpacing(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 18;
      if (_isMediumScreen(screenWidth)) return 14;
      if (_isTabletScreen(screenWidth)) return 12;
      return 12;
    } else {
      return _isTabletScreen(screenWidth) ? AppDimensions.d14.w : AppDimensions.d12.w;
    }
  }

  double _getVerticalSpacing(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 6;
      if (_isMediumScreen(screenWidth)) return 5;
      return 4;
    } else {
      return _isTabletScreen(screenWidth) ? AppDimensions.d4.h : AppDimensions.d4.h;
    }
  }

  // Platform-specific font sizes
  double _getCounterFontSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 26;
      if (_isMediumScreen(screenWidth)) return 24;
      if (_isTabletScreen(screenWidth)) return 22;
      return 20;
    } else {
      return _isTabletScreen(screenWidth) ? AppDimensions.d22.sp : AppDimensions.d20.sp;
    }
  }

  double _getTitleFontSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 20;
      if (_isMediumScreen(screenWidth)) return 18;
      if (_isTabletScreen(screenWidth)) return 17;
      return 16;
    } else {
      return _isTabletScreen(screenWidth) ? AppDimensions.d16.sp : AppDimensions.d16.sp;
    }
  }

  double _getSubtitleFontSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 16;
      if (_isMediumScreen(screenWidth)) return 15;
      if (_isTabletScreen(screenWidth)) return 14;
      return 13;
    } else {
      return _isTabletScreen(screenWidth) ? AppDimensions.d15.sp : AppDimensions.d14.sp;
    }
  }

  // Platform-specific shadows
  List<BoxShadow> _getBoxShadow(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: _isLargeScreen(screenWidth) ? 16 : 12,
          offset: Offset(0, _isLargeScreen(screenWidth) ? 6 : 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: _isLargeScreen(screenWidth) ? 6 : 4,
          offset: Offset(0, _isLargeScreen(screenWidth) ? 2 : 1),
          spreadRadius: 0,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 3),
          spreadRadius: 0,
        ),
      ];
    }
  }

  // Interactive wrapper for web/desktop
  Widget _buildInteractiveWrapper(Widget child) {
    if (_isWeb || _isDesktop) {
      return MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final KeyResultsController controller = Get.find<KeyResultsController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return _buildInteractiveWrapper(
      LayoutBuilder(
        builder: (context, constraints) => Container(
          width: double.infinity,
          constraints: _isWeb || _isDesktop
              ? BoxConstraints(maxWidth: min(800, screenWidth * 0.7))
              : null,
          margin: _getContainerMargin(screenWidth),
          padding: _getContainerPadding(screenWidth),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(_getBorderRadius(screenWidth)),
            boxShadow: _getBoxShadow(screenWidth),
          ),
          child: Obx(() {
            final int remaining =
                controller.requiredCount.value - controller.selectedCount.value;
            final String remainingText = remaining <= 0
                ? 'All key results selected!'.tr
                : remaining == 1
                ? '1 more needed'.tr
                : '$remaining more needed'.tr;

            return Row(
              children: [
                // Circular counter with responsive sizing
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _getCircleSize(screenWidth),
                  height: _getCircleSize(screenWidth),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: _isWeb || _isDesktop
                        ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${controller.selectedCount.value}',
                      style: (_isWeb || _isDesktop
                          ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: _getCounterFontSize(screenWidth),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        letterSpacing: -0.5,
                      )
                          : TextStyle(
                        fontSize: _getCounterFontSize(screenWidth),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                        fontFamily: 'Gotham-Bold',
                      )),
                    ),
                  ),
                ),

                SizedBox(width: _getHorizontalSpacing(screenWidth)),

                // Text content with responsive typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Key Results Selected'.tr,
                        style: (_isWeb || _isDesktop
                            ? Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: _getTitleFontSize(screenWidth),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.25,
                          height: 1.2,
                        )
                            : TextStyle(
                          fontSize: _getTitleFontSize(screenWidth),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Gotham-Bold',
                          height: 1.2,
                        )),
                      ),
                      SizedBox(height: _getVerticalSpacing(screenWidth)),
                      Text(
                        remainingText,
                        style: (_isWeb || _isDesktop
                            ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: _getSubtitleFontSize(screenWidth),
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        )
                            : TextStyle(
                          fontSize: _getSubtitleFontSize(screenWidth),
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: 'Gotham',
                          height: 1.3,
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// Extension for easier platform checks
extension PlatformUtils on BuildContext {
  bool get isWeb => kIsWeb;
  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isLargeScreen => MediaQuery.of(this).size.width > 1440;
  bool get isMediumScreen => MediaQuery.of(this).size.width > 1024 && MediaQuery.of(this).size.width <= 1440;
  bool get isTabletScreen => MediaQuery.of(this).size.width > 768 && MediaQuery.of(this).size.width <= 1024;
  bool get isSmallScreen => MediaQuery.of(this).size.width <= 768;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}