import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';
class CustomInitiativeInput extends StatelessWidget {
  final String numberText;
  final TextEditingController titleController;
  final TextEditingController descController;
  final String mode; // 'solo' or 'team'

  const CustomInitiativeInput({
    super.key,
    required this.numberText,
    required this.titleController,
    required this.descController,
    this.mode = 'solo',
  });

  // Platform detection
  bool get _isWeb => kIsWeb;
  bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // Responsive breakpoints
  bool _isLargeScreen(double width) => width > 1440;
  bool _isMediumScreen(double width) => width > 1024 && width <= 1440;
  bool _isTabletScreen(double width) => width > 768 && width <= 1024;
  bool _isSmallScreen(double width) => width <= 768;

  EdgeInsets _getContainerPadding(double screenWidth, Orientation orientation) {
    double horizontalPadding;
    double verticalPadding;

    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) {
        horizontalPadding = screenWidth * 0.015;
        verticalPadding = 24;
      } else if (_isMediumScreen(screenWidth)) {
        horizontalPadding = screenWidth * 0.012;
        verticalPadding = 20;
      } else if (_isTabletScreen(screenWidth)) {
        horizontalPadding = screenWidth * 0.08;
        verticalPadding = 16;
      } else {
        horizontalPadding = screenWidth * 0.05;
        verticalPadding = 12;
      }
    } else {
      horizontalPadding = orientation == Orientation.portrait
          ? screenWidth * 0.05
          : screenWidth * 0.1;
      verticalPadding = screenWidth * 0.01;
    }

    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }

  EdgeInsets _getInnerPadding(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return EdgeInsets.all(24);
      if (_isMediumScreen(screenWidth)) return EdgeInsets.all(20);
      if (_isTabletScreen(screenWidth)) return EdgeInsets.all(18);
      return EdgeInsets.all(16);
    } else {
      return EdgeInsets.all(_isTabletScreen(screenWidth) ? 18.w : AppDimensions.d16.w);
    }
  }

  double _getBorderRadius(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 20;
      if (_isMediumScreen(screenWidth)) return 18;
      return 16;
    } else {
      return _isTabletScreen(screenWidth) ? 18.r : AppDimensions.d16.r;
    }
  }

  double _getFieldBorderRadius(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 12;
      if (_isMediumScreen(screenWidth)) return 10;
      return 8;
    } else {
      return _isTabletScreen(screenWidth) ? 12.r : AppDimensions.d10.r;
    }
  }

  double _getNumberTextSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 20;
      if (_isMediumScreen(screenWidth)) return 18;
      if (_isTabletScreen(screenWidth)) return 17;
      return 16;
    } else {
      return _isTabletScreen(screenWidth) ? 17.sp : AppDimensions.d16.sp;
    }
  }

  double _getHintTextSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 16;
      if (_isMediumScreen(screenWidth)) return 15;
      if (_isTabletScreen(screenWidth)) return 14;
      return 13;
    } else {
      return _isTabletScreen(screenWidth) ? 14.sp : (screenWidth * 0.035);
    }
  }

  double _getSpacing(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 16;
      if (_isMediumScreen(screenWidth)) return 14;
      return 12;
    } else {
      return _isTabletScreen(screenWidth) ? 12.h : AppDimensions.d10.h;
    }
  }

  double _getFieldSpacing(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 18;
      if (_isMediumScreen(screenWidth)) return 16;
      return 14;
    } else {
      return _isTabletScreen(screenWidth) ? 14.h : AppDimensions.d12.h;
    }
  }

  EdgeInsets _getFieldPadding(double screenWidth, double screenHeight) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      } else if (_isMediumScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: 18, vertical: 14);
      } else if (_isTabletScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      } else {
        return EdgeInsets.symmetric(horizontal: 14, vertical: 10);
      }
    } else {
      return EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * (_isTabletScreen(screenWidth) ? 0.018 : 0.015),
      );
    }
  }

  EdgeInsets _getDescFieldPadding(double screenWidth, double screenHeight) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: 20, vertical: 20);
      } else if (_isMediumScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: 18, vertical: 18);
      } else if (_isTabletScreen(screenWidth)) {
        return EdgeInsets.symmetric(horizontal: 16, vertical: 16);
      } else {
        return EdgeInsets.symmetric(horizontal: 14, vertical: 14);
      }
    } else {
      return EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * (_isTabletScreen(screenWidth) ? 0.025 : 0.02),
      );
    }
  }

  List<BoxShadow> _getBoxShadow(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: _isLargeScreen(screenWidth) ? 12 : 8,
          offset: Offset(0, _isLargeScreen(screenWidth) ? 6 : 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: _isLargeScreen(screenWidth) ? 6 : 4,
          offset: Offset(0, _isLargeScreen(screenWidth) ? 2 : 1),
          spreadRadius: 0,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
    }
  }

  int _getDescriptionMaxLines(double screenWidth) {
    if (_isWeb || _isDesktop) {
      if (_isLargeScreen(screenWidth)) return 4;
      if (_isMediumScreen(screenWidth)) return 4;
      return 3;
    } else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final orientation = MediaQuery.of(context).orientation;

    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: _getContainerPadding(width, orientation),
        child: Container(
          width: double.infinity,
          constraints: _isWeb || _isDesktop
              ? BoxConstraints(maxWidth: _isLargeScreen(width) ? 800 : 600)
              : null,
          padding: _getInnerPadding(width),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_getBorderRadius(width)),
            border: Border.all(
              color: AppColors.grey.withValues(alpha: 0.3),
              width: _isWeb || _isDesktop ? 1.5 : 1.0,
            ),
            boxShadow: _getBoxShadow(width),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Initiative Number
              Text(
                numberText.tr,
                style: TextStyle(
                  fontSize: _getNumberTextSize(width),
                  fontWeight: FontWeight.w900,
                  color: mode == 'team' ? AppColors.primaryBlue : AppColors.primaryRed,
                  fontFamily: 'GothamBold',
                  letterSpacing: _isWeb || _isDesktop ? -0.25 : null,
                ),
              ),
              SizedBox(height: _getSpacing(width)),

              /// Title Field
              TextField(
                controller: titleController,
                style: TextStyle(
                  fontSize: _getHintTextSize(width),
                  fontFamily: 'Gotham',
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'enter_initiative_name'.tr,
                  hintStyle: TextStyle(
                    fontSize: _getHintTextSize(width),
                    fontFamily: 'Gotham',
                    fontWeight: FontWeight.w900,
                    color: AppColors.grey,
                  ),
                  contentPadding: _getFieldPadding(width, height),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_getFieldBorderRadius(width)),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      width: _isWeb || _isDesktop ? 1.5 : 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_getFieldBorderRadius(width)),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      width: _isWeb || _isDesktop ? 1.5 : 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_getFieldBorderRadius(width)),
                    borderSide: BorderSide(
                      color: mode == 'team' ? AppColors.primaryBlue : AppColors.primaryRed,
                      width: _isWeb || _isDesktop ? 2.0 : 1.5,
                    ),
                  ),
                  filled: _isWeb || _isDesktop,
                  fillColor: _isWeb || _isDesktop ? Colors.grey.withValues(alpha: 0.05) : null,
                ),
              ),
              SizedBox(height: _getFieldSpacing(width)),

              /// Description Field
              TextField(
                controller: descController,
                maxLines: _getDescriptionMaxLines(width),
                style: TextStyle(
                  fontSize: _getHintTextSize(width),
                  fontFamily: 'Gotham',
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'describe_initiative_help'.tr,
                  hintStyle: TextStyle(
                    fontSize: _getHintTextSize(width),
                    fontFamily: 'Gotham',
                    fontWeight: FontWeight.w900,
                    color: AppColors.grey,
                  ),
                  contentPadding: _getDescFieldPadding(width, height),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_getFieldBorderRadius(width)),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      width: _isWeb || _isDesktop ? 1.5 : 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_getFieldBorderRadius(width)),
                    borderSide: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      width: _isWeb || _isDesktop ? 1.5 : 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_getFieldBorderRadius(width)),
                    borderSide: BorderSide(
                      color: mode == 'team' ? AppColors.primaryBlue : AppColors.primaryRed,
                      width: _isWeb || _isDesktop ? 2.0 : 1.5,
                    ),
                  ),
                  filled: _isWeb || _isDesktop,
                  fillColor: _isWeb || _isDesktop ? Colors.grey.withValues(alpha: 0.05) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// RESPONSIVE EXTENSIONS
// =============================================================================

extension ResponsiveHelpers on BuildContext {
  bool get isWeb => kIsWeb;
  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isLargeScreen => MediaQuery.of(this).size.width > 1440;
  bool get isMediumScreen => MediaQuery.of(this).size.width > 1024 && MediaQuery.of(this).size.width <= 1440;
  bool get isTabletScreen => MediaQuery.of(this).size.width > 768 && MediaQuery.of(this).size.width <= 1024;
  bool get isSmallScreen => MediaQuery.of(this).size.width <= 768;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  Orientation get orientation => MediaQuery.of(this).orientation;

  // Helper method for responsive values
  T responsive<T>({
    required T mobile,
    required T tablet,
    required T desktop,
    required T web,
  }) {
    if (isMobile && isSmallScreen) return mobile;
    if (isTabletScreen) return tablet;
    if (isMediumScreen) return desktop;
    return web;
  }
}