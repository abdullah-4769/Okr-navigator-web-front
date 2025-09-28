import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';

class RewardsUnlocked extends StatelessWidget {
  final String badgeImage;
  final String badgeName;

  final String titleImage;
  final String titleName;

  final String trophyImage;
  final String trophyName;

  const RewardsUnlocked({
    super.key,
    required this.badgeImage,
    required this.badgeName,
    required this.titleImage,
    required this.titleName,
    required this.trophyImage,
    required this.trophyName,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for adaptive sizing (mobile, tablet, web/desktop)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isDesktop = screenWidth > 1200; // Desktop/Web breakpoint (standardized)
    final isTablet = screenWidth > 600 && screenWidth <= 1200; // Tablet breakpoint
    final isMobile = screenWidth <= 600;

    // Adaptive dimensions: Base values scaled with ScreenUtil for proper adaptation
    // Container properties
    final double horizontalMargin = (isDesktop ? screenWidth * 0.010 : isTablet ? screenWidth * 0.008 : screenWidth * 0.05).w.clamp(10.0, 40.0);
    final double padding = (isDesktop ? screenWidth * 0.0095 : isTablet ? screenWidth * 0.004 : screenWidth * 0.005).w.clamp(5.0, 30.0);
    final double borderRadius = (isDesktop ? 20.0 : isTablet ? 18.0 : 16.0).r;
    final double borderWidth = (isDesktop ? 1.8 : isTablet ? 1.5 : 1.2).w.clamp(1.0, 3.0);
    final bool showShadow = isTablet || isDesktop;
    final double shadowBlur = (isDesktop ? 12.0 : isTablet ? 8.0 : 4.0).r;
    final double shadowOffsetY = (isDesktop ? 4.0 : isTablet ? 3.0 : 2.0).h;

    // Header responsive sizes - Fixed small values for tablet/desktop; now properly scaled
    final double avatarRadius = ((isMobile ? (isLandscape ? screenWidth * 0.04 : screenWidth * 0.05) : screenWidth * 0.06) * (isDesktop ? 1.2 : 1.1)).w.clamp(16.0, 32.0);
    final double headerIconSize = ((isMobile ? (isLandscape ? screenWidth * 0.04 : screenWidth * 0.05) : screenWidth * 0.06) * (isDesktop ? 1.2 : 1.1)).sp.clamp(20.0, 36.0);
    final double headerSizedBoxWidth = (isDesktop ? screenWidth * 0.045 : isTablet ? screenWidth * 0.04 : screenWidth * 0.03).w.clamp(8.0, 24.0);
    final double headerTitleFontSize = ((isMobile ? (isLandscape ? 14.0 : 16.0) : 18.0) * (isDesktop ? 1.11 : 1.0)).sp.clamp(14.0, 20.0);
    final double headerSizedBoxHeight = (isDesktop ? screenHeight * 0.015 : isTablet ? screenHeight * 0.012 : screenHeight * 0.01).h.clamp(4.0, 16.0);

    // Reward items responsive sizes - Images/Icons now properly scaled and clamped for desktop/web
    final double defaultImageSize = ((isMobile ? (isLandscape ? 50.0 : 60.0) : 70.0) * (isDesktop ? 1.14 : isTablet ? 1.0 : 0.9)).w.clamp(40.0, 90.0); // Reasonable max on desktop
    final double trophyImageSize = ((isMobile ? (isLandscape ? screenWidth * 0.15 : screenWidth * 0.20) : screenWidth * 0.22) * (isDesktop ? 1.0 : isTablet ? 0.95 : 0.9)).w.clamp(50.0, 180.0); // Prevent oversized on wide screens
    final double rowBetweenSpacing = (isDesktop ? screenWidth * 0.06 : isTablet ? screenWidth * 0.05 : screenWidth * 0.03).w.clamp(12.0, 40.0);
    final double rewardTitleSizedBoxHeight = (isDesktop ? 8.0 : isTablet ? 6.0 : 4.0).h;
    final double rewardTypeSizedBoxHeight = (isDesktop ? 4.0 : isTablet ? 3.0 : 2.0).h;
    final double rewardTitleFontSize = ((isMobile ? (isLandscape ? 12.0 : 14.0) : 16.0) * (isDesktop ? 1.125 : 1.0)).sp.clamp(12.0, 18.0);
    final double rewardTypeFontSize = ((isMobile ? (isLandscape ? 10.0 : 12.0) : 13.0) * (isDesktop ? 1.08 : 1.0)).sp.clamp(10.0, 14.0);
    final double trophySizedBoxHeight = (isDesktop ? screenHeight * 0.025 : isTablet ? screenHeight * 0.02 : screenHeight * 0.015).h.clamp(8.0, 24.0);
    final double trophyMaxWidthMultiplier = isDesktop ? 0.5 : isTablet ? 0.55 : 0.6;

    // Responsive max width for the container
    final double maxContainerWidth = isDesktop ? 900.0.w : double.infinity;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContainerWidth),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.softRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.primaryRed,
                width: borderWidth,
              ),
              boxShadow: showShadow
                  ? [
                BoxShadow(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  blurRadius: shadowBlur,
                  offset: Offset(0, shadowOffsetY),
                ),
              ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header Row - Flexible to prevent overflow
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryRed,
                      radius: avatarRadius,
                      child: Icon(
                        Icons.emoji_events,
                        color: AppColors.white,
                        size: headerIconSize, // Now properly scaled for desktop
                      ),
                    ),
                    SizedBox(width: headerSizedBoxWidth),
                    Flexible(  // Use Flexible to handle long text without overflow
                      child: Text(
                        "rewards_unlocked".tr,
                        style: TextStyle(
                          fontSize: headerTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: headerSizedBoxHeight),

                /// Badge + Title Row - Flexible children to adapt space
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: _rewardItem(
                        imagePath: badgeImage,
                        title: badgeName.tr,
                        type: "badge".tr,
                        imageSize: defaultImageSize, // Scaled image
                        titleFontSize: rewardTitleFontSize,
                        typeFontSize: rewardTypeFontSize,
                        titleSizedBoxHeight: rewardTitleSizedBoxHeight,
                        typeSizedBoxHeight: rewardTypeSizedBoxHeight,
                      ),
                    ),
                    SizedBox(width: rowBetweenSpacing),
                    Flexible(
                      child: _rewardItem(
                        imagePath: titleImage,
                        title: titleName.tr,
                        type: "title".tr,
                        imageSize: defaultImageSize, // Scaled image
                        titleFontSize: rewardTitleFontSize,
                        typeFontSize: rewardTypeFontSize,
                        titleSizedBoxHeight: rewardTitleSizedBoxHeight,
                        typeSizedBoxHeight: rewardTypeSizedBoxHeight,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: trophySizedBoxHeight),

                /// Trophy Centered - Constrained for better adaptation
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxW * trophyMaxWidthMultiplier,
                      maxHeight: trophyImageSize * 1.5, // Limit height to prevent excess
                    ),
                    child: _rewardItem(
                      imagePath: trophyImage,
                      title: trophyName.tr,
                      type: "trophy".tr,
                      imageSize: trophyImageSize, // Scaled trophy image
                      titleFontSize: rewardTitleFontSize,
                      typeFontSize: rewardTypeFontSize,
                      titleSizedBoxHeight: rewardTitleSizedBoxHeight,
                      typeSizedBoxHeight: rewardTypeSizedBoxHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _rewardItem({
    required String imagePath,
    required String title,
    required String type,
    required double imageSize,
    required double titleFontSize,
    required double typeFontSize,
    required double titleSizedBoxHeight,
    required double typeSizedBoxHeight,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image with proper scaling and error handling
        ConstrainedBox(  // Constrain to prevent overflow
          constraints: BoxConstraints(
            maxWidth: imageSize,
            maxHeight: imageSize,
          ),
          child: Image.asset(
            imagePath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain, // Ensures images scale without distortion
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.image_not_supported,
              size: imageSize * 0.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: titleSizedBoxHeight),
        Flexible(  // Flexible for text overflow prevention
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: typeSizedBoxHeight),
        Flexible(
          child: Text(
            type,
            style: TextStyle(
              fontSize: typeFontSize,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}