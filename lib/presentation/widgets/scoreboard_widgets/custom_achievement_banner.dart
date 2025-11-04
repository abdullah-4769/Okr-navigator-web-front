// widgets/custom_achievement_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomAchievementBanner extends StatelessWidget {
  final int rank;
  final String category;

  const CustomAchievementBanner({
    super.key,
    required this.rank,
    required this.category,
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

    // Container responsive properties
    double padding = getResponsiveDimension(12.0, 16.0, 20.0);
    double borderRadius = getResponsiveDimension(12.0, 16.0, 20.0);
    bool showShadow = isTablet || isDesktop; // Subtle shadow on larger screens
    double shadowBlur = getResponsiveDimension(4.0, 8.0, 12.0);
    double shadowOffsetY = getResponsiveDimension(2.0, 3.0, 4.0);

    // Icon and spacing responsive
    double iconSize = getResponsiveDimension(
        isLandscape ? 18.0 : 24.0, // Mobile (smaller in landscape)
        28.0, // Tablet
        32.0  // Desktop
    );
    double iconTextSpacing = getResponsiveDimension(8.0, 12.0, 16.0);

    // Text responsive
    double textFontSize = getResponsiveDimension(
        isLandscape ? 14.0 : 16.0, // Mobile (smaller in landscape)
        18.0, // Tablet
        20.0  // Desktop
    );
    int textMaxLines = isMobile ? (isLandscape ? 1 : 2) : 3;

    // Responsive max width for the banner
    double maxBannerWidth = isDesktop ? 600.0 : double.infinity;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxBannerWidth),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue.withOpacity(0.8),
              AppColors.primaryRed.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: shadowBlur,
              offset: Offset(0, shadowOffsetY),
              spreadRadius: 1.0,
            ),
          ] : [],
        ),
        child: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: iconSize,
            ),
            SizedBox(width: iconTextSpacing),
            Expanded(
              child: Text(
                "I'm ranked #$rank in $category this week!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textFontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  letterSpacing: isDesktop ? 0.5 : 0.0,
                ),
                maxLines: textMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}