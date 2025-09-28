import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/Other_screens_controllers/mini_simulation_play_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomProgressPath extends StatelessWidget {
  /// Step labels like ["1","2","3","4","5"]
  final List<String> stepLabels;

  /// If provided, it will be used. Otherwise it will try using MiniSimulationPlayController
  final int? currentStep;

  /// Show circles or just digits text
  final bool showCircles;

  const CustomProgressPath({
    super.key,
    required this.stepLabels,
    this.currentStep,
    this.showCircles = true,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    // Determine device type for responsive design
    bool isMobile = screenWidth < 768;
    bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    bool isDesktop = screenWidth >= 1024;

    // Responsive dimensions based on screen size
    double getResponsiveDimension(double mobile, double tablet, double desktop) {
      if (isMobile) return mobile;
      if (isTablet) return tablet;
      return desktop;
    }

    if (currentStep == null && Get.isRegistered<MiniSimulationPlayController>()) {
      final controller = Get.find<MiniSimulationPlayController>();
      return Obx(() {
        return _buildProgressUI(
          context,
          screenWidth,
          screenHeight,
          isLandscape,
          isMobile,
          isTablet,
          isDesktop,
          getResponsiveDimension,
          controller.currentStep.value,
        );
      });
    }

    return _buildProgressUI(
      context,
      screenWidth,
      screenHeight,
      isLandscape,
      isMobile,
      isTablet,
      isDesktop,
      getResponsiveDimension,
      currentStep ?? 0,
    );
  }

  Widget _buildProgressUI(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      bool isLandscape,
      bool isMobile,
      bool isTablet,
      bool isDesktop,
      Function getResponsiveDimension,
      int activeStep,
      ) {
    // Progress line responsive sizes
    double progressLineHeight = getResponsiveDimension(3.0, 4.0, 5.0);
    double progressLineHorizontalMargin = getResponsiveDimension(12.0, 16.0, 20.0);
    double progressLineBorderRadius = progressLineHeight / 2;
    double progressLineVerticalSpacing = getResponsiveDimension(6.0, 8.0, 10.0);

    // Step items responsive sizes
    double circleSize = getResponsiveDimension(
        isLandscape ? screenWidth * 0.10 : screenWidth * 0.12, // Mobile (smaller in landscape)
        45.0, // Tablet
        55.0  // Desktop
    );
    double circleBorderWidth = getResponsiveDimension(1.5, 2.0, 2.5);
    double stepNumberFontSize = getResponsiveDimension(
        isLandscape ? 14.0 : 16.0, // Mobile (smaller in landscape)
        18.0, // Tablet
        20.0  // Desktop
    );
    double stepTextFontSize = getResponsiveDimension(
        isLandscape ? 12.0 : 14.0, // Mobile (smaller in landscape)
        16.0, // Tablet
        18.0  // Desktop
    );
    double stepTextBoldFontSize = getResponsiveDimension(
        isLandscape ? 14.0 : 16.0, // Mobile (smaller in landscape, bold)
        18.0, // Tablet
        20.0  // Desktop
    );

    // Responsive max width for the entire component
    double maxComponentWidth = isDesktop ? 800.0 : double.infinity;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxComponentWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ======= Progress Line =======
          Stack(
            children: [
              Container(
                height: progressLineHeight,
                margin: EdgeInsets.symmetric(horizontal: progressLineHorizontalMargin),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(progressLineBorderRadius),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final progress = activeStep / (stepLabels.length - 1).clamp(0.0, 1.0);
                  final progressWidth = constraints.maxWidth * progress;

                  return Container(
                    height: progressLineHeight,
                    margin: EdgeInsets.symmetric(horizontal: progressLineHorizontalMargin),
                    width: progressWidth,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(progressLineBorderRadius),
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: progressLineVerticalSpacing),

          // ======= Step Items (Circles or Digits) =======
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(stepLabels.length, (index) {
              final isCompleted = index < activeStep;
              final isActive = index == activeStep;

              return Expanded(
                child: Center(
                  child: showCircles
                      ? Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.primaryRed
                          : AppColors.grey.withOpacity(0.3),
                      border: isActive
                          ? Border.all(
                        color: AppColors.primaryRed,
                        width: circleBorderWidth,
                      )
                          : null,
                      boxShadow: isDesktop ? [
                        BoxShadow(
                          color: isCompleted
                              ? AppColors.primaryRed.withOpacity(0.2)
                              : Colors.transparent,
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: stepNumberFontSize,
                        ),
                      ),
                    ),
                  )
                      : Text(
                    stepLabels[index],
                    style: TextStyle(
                      fontSize: isActive ? stepTextBoldFontSize : stepTextFontSize,
                      color: isCompleted
                          ? AppColors.primaryRed // Use primary red for completed text
                          : AppColors.textSecondary,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      letterSpacing: isDesktop ? 0.5 : 0.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}