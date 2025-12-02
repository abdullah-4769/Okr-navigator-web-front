import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomCircularTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final String label;

  const CustomCircularTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.label,
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

    // Circle responsive sizes
    double circleSize = getResponsiveDimension(
        isLandscape ? 90.0 : 120.0, // Mobile (smaller in landscape)
        140.0, // Tablet
        160.0  // Desktop
    );
    double progressStrokeWidth = getResponsiveDimension(6.0, 8.0, 10.0);
    double backgroundOpacity = getResponsiveDimension(0.1, 0.12, 0.15);
    bool showShadow = isTablet || isDesktop; // Subtle shadow on larger screens
    double shadowBlur = getResponsiveDimension(4.0, 6.0, 8.0);
    double shadowOffsetY = getResponsiveDimension(2.0, 3.0, 4.0);

    // Text responsive sizes
    double timeFontSize = getResponsiveDimension(
        isLandscape ? 18.0 : 24.0, // Mobile (smaller in landscape)
        28.0, // Tablet
        32.0  // Desktop
    );
    double labelFontSize = getResponsiveDimension(
        isLandscape ? 10.0 : 12.0, // Mobile (smaller in landscape)
        14.0, // Tablet
        16.0  // Desktop
    );
    double textLineHeight = getResponsiveDimension(1.1, 1.2, 1.3);

    // Responsive max width for the timer (optional centering on large screens)
    double maxTimerWidth = isDesktop ? 200.0 : double.infinity;

    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final formattedTime = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxTimerWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle with enhanced styling
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryRed.withOpacity(backgroundOpacity),
                  boxShadow: showShadow ? [
                    BoxShadow(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      blurRadius: shadowBlur,
                      offset: Offset(0, shadowOffsetY),
                      spreadRadius: 1.0,
                    ),
                  ] : [],
                ),
              ),

              // Progress circle with responsive stroke
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: progressStrokeWidth,
                  backgroundColor: AppColors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                ),
              ),

              // Time text with responsive styling
              Padding(
                padding: EdgeInsets.all(getResponsiveDimension(8.0, 10.0, 12.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: timeFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                        height: textLineHeight,
                        letterSpacing: isDesktop ? 0.5 : 0.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: getResponsiveDimension(2.0, 4.0, 6.0)),
                    Text(
                      label.tr,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: AppColors.textSecondary,
                        height: textLineHeight,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}