// lib/presentation/widgets/custom_strategic_icons_show.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class StrategicIconsShow extends StatelessWidget {
  const StrategicIconsShow({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for adaptive sizing (mobile, tablet, web/desktop)
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200; // Desktop breakpoint
    final isTablet = screenWidth > 600 && screenWidth <= 1200; // Tablet breakpoint
    final isMobile = screenWidth <= 600;

    // Adaptive dimensions based on screen size
    // Base on ScreenUtil for scaling, but adjust multipliers for larger screens
    final containerPadding = isDesktop ? AppDimensions.d16.w : (isTablet ? AppDimensions.d14.w : AppDimensions.d12.w);
    final containerHeight = isDesktop ? 280.h : (isTablet ? 250.h : 220.h); // Increased height on larger screens for better spacing
    final borderRadius = isDesktop ? AppDimensions.d24.r : AppDimensions.d18.r;
    final shadowBlur = isDesktop ? 10.0 : (isTablet ? 8.0 : 6.0);
    final shadowOffsetY = isDesktop ? 4.0 : (isTablet ? 3.5 : 3.0);

    // Central flash icon adaptive sizes
    final centralSize = isDesktop ? 90.w : (isTablet ? 80.w : 70.w);
    final centralIconSize = isDesktop ? 42.sp : (isTablet ? 38.sp : 34.sp);

    // Peripheral icons adaptive sizes
    final peripheralSize = isDesktop ? 75.w : (isTablet ? 68.w : 60.w);
    final peripheralIconSize = isDesktop ? 36.sp : (isTablet ? 32.sp : 28.sp);

    // Positions: Increase offsets on larger screens for wider spread
    final topLeftTop = isDesktop ? 30.h : (isTablet ? 25.h : 20.h);
    final topLeftLeft = isDesktop ? 60.w : (isTablet ? 50.w : 40.w);
    final topRightTop = isDesktop ? 40.h : (isTablet ? 35.h : 30.h);
    final topRightRight = isDesktop ? 60.w : (isTablet ? 50.w : 40.w);
    final bottomLeftBottom = isDesktop ? 40.h : (isTablet ? 35.h : 30.h);
    final bottomLeftLeft = isDesktop ? 70.w : (isTablet ? 60.w : 50.w);
    final bottomRightBottom = isDesktop ? 30.h : (isTablet ? 25.h : 20.h);
    final bottomRightRight = isDesktop ? 70.w : (isTablet ? 60.w : 50.w);

    // Adaptive container width: full width on mobile, constrained on larger screens
    final containerWidth = isMobile
        ? double.infinity
        : (isTablet ? screenWidth * 0.85 : screenWidth * 0.6); // Cap at ~60% on desktop for centering

    final List<IconData> icons = [
      Icons.leaderboard,
      Icons.group,
      Icons.star,
      Icons.trending_up,
    ];

    return Container(
      width: containerWidth,
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: shadowBlur,
            offset: Offset(0, shadowOffsetY),
          ),
          // Add a subtle inner shadow or secondary shadow on larger screens for depth
          if (isDesktop || isTablet)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: SizedBox(
        height: containerHeight, // Adaptive height
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// ⚡ Flash in center (red circle) - Adaptive size
            Container(
              width: centralSize,
              height: centralSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
              child: Icon(
                Icons.flash_on,
                color: Colors.white,
                size: centralIconSize,
              ),
            ),

            /// top-left - Adaptive position
            Positioned(
              top: topLeftTop,
              left: topLeftLeft,
              child: _buildIconCircle(
                icons[0],
                size: peripheralSize,
                iconSize: peripheralIconSize,
              ),
            ),

            /// top-right - Adaptive position
            Positioned(
              top: topRightTop,
              right: topRightRight,
              child: _buildIconCircle(
                icons[1],
                size: peripheralSize,
                iconSize: peripheralIconSize,
              ),
            ),

            /// bottom-left - Adaptive position
            Positioned(
              bottom: bottomLeftBottom,
              left: bottomLeftLeft,
              child: _buildIconCircle(
                icons[2],
                size: peripheralSize,
                iconSize: peripheralIconSize,
              ),
            ),

            /// bottom-right - Adaptive position
            Positioned(
              bottom: bottomRightBottom,
              right: bottomRightRight,
              child: _buildIconCircle(
                icons[3],
                size: peripheralSize,
                iconSize: peripheralIconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔵 Blue circle with white icon - Now adaptive
  Widget _buildIconCircle(IconData icon, {required double size, required double iconSize}) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.primaryBlue,
    ),
    child: Icon(
      icon,
      color: Colors.white,
      size: iconSize,
    ),
  );
}