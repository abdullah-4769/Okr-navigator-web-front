import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomJourneyMap extends StatelessWidget {
  final double progress;
  final List<String>? steps;
  final List<bool>? completedSteps;
  final VoidCallback onToggle;
  final bool showDetails;

  const CustomJourneyMap({
    super.key,
    required this.progress,
    required this.steps,
    required this.completedSteps,
    required this.onToggle,
    required this.showDetails,
  });

  // Platform detection helpers
  bool get _isWeb => kIsWeb;
  bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // Responsive breakpoints
  bool _isLargeScreen(double width) => width > 1200;
  bool _isMediumScreen(double width) => width > 800 && width <= 1200;
  bool _isSmallScreen(double width) => width <= 800;

  // Journey step icons mapping
  List<IconData> _getJourneyIcons() {
    return [
      Icons.lightbulb_outline,     // Strategy Selection
      Icons.rocket_launch_outlined, // Objective Selection
      Icons.flash_on_outlined,     // Key Result Selection
      Icons.tune_outlined,         // Initiatives Suggestion
      Icons.emoji_events_outlined, // Result Performance
    ];
  }

  // Platform-specific margins
  EdgeInsets _getContainerMargin(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return EdgeInsets.symmetric(horizontal: 16.0);
    } else {
      return EdgeInsets.symmetric(horizontal: AppDimensions.d16.w);
    }
  }

  // Platform-specific padding
  EdgeInsets _getContainerPadding() {
    if (_isWeb || _isDesktop) {
      return EdgeInsets.all(20.0);
    } else {
      return EdgeInsets.all(AppDimensions.d16.w);
    }
  }

  // Platform-specific border radius
  double _getBorderRadius() {
    if (_isWeb || _isDesktop) {
      return 16.0;
    } else {
      return AppDimensions.d12.r;
    }
  }

  // Responsive font sizes
  double _getTitleFontSize(double screenWidth, bool isSecondLine) {
    if (_isWeb || _isDesktop) {
      return isSecondLine ? 28.0 : 22.0;
    } else {
      return isSecondLine ? AppDimensions.d24.sp : AppDimensions.d20.sp;
    }
  }

  double _getToggleFontSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return 14.0;
    } else {
      return AppDimensions.d14.sp;
    }
  }

  double _getProgressFontSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return 18.0;
    } else {
      return AppDimensions.d16.sp;
    }
  }

  double _getStepFontSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return 10.0;
    } else {
      return 9.0.sp;
    }
  }

  double _getSubtitleFontSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return 8.0;
    } else {
      return 7.0.sp;
    }
  }

  // Platform-specific icon sizes
  double _getStepIconSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return 20.0;
    } else {
      return 18.0.sp;
    }
  }

  double _getStepCircleSize(double screenWidth) {
    if (_isWeb || _isDesktop) {
      return 40.0;
    } else {
      return 35.0.w;
    }
  }

  // Platform-specific progress bar height
  double _getProgressBarHeight() {
    if (_isWeb || _isDesktop) {
      return 8.0;
    } else {
      return AppDimensions.d6.h;
    }
  }

  // Platform-specific spacing
  double _getSpacing(double mobileValue) {
    if (_isWeb || _isDesktop) {
      return mobileValue * 1.2;
    } else {
      return mobileValue;
    }
  }

  // Platform-specific shadow
  List<BoxShadow> _getBoxShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: double.infinity,
        constraints: _isWeb || _isDesktop
            ? BoxConstraints(maxWidth: min(800, width * 0.9))
            : null,
        margin: _getContainerMargin(width),
        padding: _getContainerPadding(),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: _getBoxShadow(),
        ),
        child: Column(
          children: [
            /// Title
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'journey'.tr ,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: _getTitleFontSize(width, false),
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '\nMap'.tr,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: _getTitleFontSize(width, true),
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _getSpacing(8.0)),

            /// Show Progress / Show Less Toggle
            GestureDetector(
              onTap: onToggle,
              child: Text(
                showDetails ? 'show_less'.tr : 'show_progress'.tr,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: _getToggleFontSize(width),
                  color: AppColors.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            SizedBox(height: _getSpacing(16.0)),

            /// Expandable Section
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: showDetails
                  ? Column(
                children: [
                  SizedBox(height: _getSpacing(12.0)),

                  /// Progress %
                  Text(
                    '${progress.toInt()}% ' + 'complete'.tr,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: _getProgressFontSize(width),
                      color: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(height: _getSpacing(8.0)),

                  /// Progress bar
                  Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: LinearProgressIndicator(
                      value: (progress.clamp(0, 100)) / 100,
                      backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryRed,
                      ),
                      minHeight: _getProgressBarHeight(),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  SizedBox(height: _getSpacing(24.0)),

                  /// Horizontal Journey Steps
                  _buildHorizontalJourneySteps(context, width),
                  SizedBox(height: _getSpacing(16.0)),
                ],
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalJourneySteps(BuildContext context, double screenWidth) {
    final safeSteps = steps ?? [];
    final safeCompleted = completedSteps ?? List.filled(safeSteps.length, false);
    final icons = _getJourneyIcons();

    return Column(
      children: [
        // Icons and connecting line
        SizedBox(
          height: _getStepCircleSize(screenWidth) + 20,
          child: Stack(
            children: [
              // Connecting line
              if (safeSteps.length > 1)
                Positioned(
                  top: _getStepCircleSize(screenWidth) / 2 - 1,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 2,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                ),

              // Icons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(safeSteps.length, (index) {
                  final isActive = index < safeCompleted.length && safeCompleted[index];
                  final isCurrentStep = index == safeCompleted.where((e) => e).length && !isActive;

                  return _buildStepIcon(
                    context,
                    screenWidth,
                    index,
                    icons[index % icons.length],
                    isActive,
                    isCurrentStep,
                  );
                }),
              ),
            ],
          ),
        ),

        SizedBox(height: 8.0),

        // Step labels - FIXED: Properly aligned below icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(safeSteps.length, (index) {
            final isActive = index < safeCompleted.length && safeCompleted[index];
            return _buildStepLabel(
              context,
              screenWidth,
              safeSteps[index],
              _getStepSubtitle(index),
              isActive,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepIcon(
      BuildContext context,
      double screenWidth,
      int index,
      IconData icon,
      bool isActive,
      bool isCurrentStep,
      ) {
    final circleSize = _getStepCircleSize(screenWidth);
    final iconSize = _getStepIconSize(screenWidth);

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppColors.primaryRed
            : isCurrentStep
            ? AppColors.primaryRed.withOpacity(0.2)
            : AppColors.textSecondary.withOpacity(0.2),
        border: isCurrentStep
            ? Border.all(color: AppColors.primaryRed, width: 2)
            : null,
      ),
      child: Icon(
        isActive ? Icons.check : icon,
        color: isActive
            ? Colors.white
            : isCurrentStep
            ? AppColors.primaryRed
            : AppColors.textSecondary.withOpacity(0.6),
        size: iconSize,
      ),
    );
  }

  Widget _buildStepLabel(
      BuildContext context,
      double screenWidth,
      String title,
      String subtitle,
      bool isActive,
      ) {
    return SizedBox(
      width: _getStepCircleSize(screenWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.tr,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: _getStepFontSize(screenWidth),
              color: isActive
                  ? AppColors.primaryRed
                  : AppColors.textSecondary.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle.tr,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: _getSubtitleFontSize(screenWidth),
              color: isActive
                  ? AppColors.primaryRed.withOpacity(0.8)
                  : AppColors.textSecondary.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepSubtitle(int index) {
    const subtitles = [
      'Selection',
      'Selection',
      'Selection',
      'Suggestion',
      'Performance',
    ];
    return subtitles[index % subtitles.length];
  }
}