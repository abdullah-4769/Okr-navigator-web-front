import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_app/presentation/widgets/custom_svg.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomRankContainer extends StatelessWidget {
  final int rank;
  final String name;
  final int level;
  final int points;
  final int score;
  final bool isHighlighted;

  const CustomRankContainer({
    super.key,
    required this.rank,
    required this.name,
    required this.level,
    required this.points,
    required this.score,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for adaptive sizing (mobile, tablet, web/desktop)
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200; // Desktop breakpoint
    final isTablet = screenWidth > 600 && screenWidth <= 1200; // Tablet breakpoint
    final isMobile = screenWidth <= 600;

    // Adaptive dimensions based on screen size
    // Base on ScreenUtil for scaling, but adjust multipliers for larger screens
    final paddingVertical = isDesktop ? AppDimensions.d6.h : AppDimensions.d4.h;
    final paddingHorizontal = isDesktop ? AppDimensions.d20.w : (isTablet ? AppDimensions.d16.w : AppDimensions.d14.w);
    final marginBottom = isDesktop ? AppDimensions.d12.h : AppDimensions.d10.h;
    final borderRadius = isDesktop ? AppDimensions.d56.r : AppDimensions.d48.r;
    final fontSizeRank = isDesktop ? AppDimensions.d20.sp : AppDimensions.d16.sp;
    final fontSizeName = isDesktop ? AppDimensions.d20.sp : AppDimensions.d16.sp;
    final fontSizeSubtext = isDesktop ? AppDimensions.d14.sp : AppDimensions.d12.sp;
    final fontSizeScore = isDesktop ? AppDimensions.d20.sp : AppDimensions.d18.sp;
    final avatarSize = isDesktop ? AppDimensions.d36.w : (isTablet ? AppDimensions.d32.w : AppDimensions.d28.w);
    final iconSize = isDesktop ? AppDimensions.d22.sp : AppDimensions.d18.sp;
    final spacingSmall = isDesktop ? AppDimensions.d6.w : AppDimensions.d4.w;
    final spacingMedium = isDesktop ? AppDimensions.d16.w : AppDimensions.d12.w;
    final spacingLarge = isDesktop ? AppDimensions.d20.w : AppDimensions.d8.w;

    // Adaptive container width: full width on mobile, constrained on larger screens
    final containerWidth = isMobile
        ? double.infinity
        : (isTablet ? screenWidth * 0.85 : screenWidth * 0.6); // Cap at ~60% on desktop for centering

    return Container(
      width: containerWidth,
      padding: EdgeInsets.symmetric(vertical: paddingVertical, horizontal: paddingHorizontal),
      margin: EdgeInsets.only(bottom: marginBottom),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primaryRed : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primaryRed,
          width: isDesktop ? 1.5 : 1, // Slightly thicker border on desktop
        ),
        // Add subtle shadow for depth on larger screens
        boxShadow: isDesktop || isTablet
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          // Rank Number - Adaptive font and spacing
          Text(
            "$rank.",
            style: TextStyle(
              fontSize: fontSizeRank,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(width: spacingMedium),

          // Avatar with red border + soft red background - Adaptive size
          Container(
            padding: EdgeInsets.all(isDesktop ? AppDimensions.d6.w : AppDimensions.d4.w),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryRed, width: isDesktop ? 3 : 2),
            ),
            child: CustomSvg(
              assetPath: 'assets/images/solo.svg',
              semanticsLabel: '',
              height: avatarSize,
              width: avatarSize,
            ),
          ),
          SizedBox(width: spacingLarge),

          // Name + level + points earned - Adaptive font and spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: fontSizeName,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? Colors.white : AppColors.textPrimary,
                  ),
                  // Prevent overflow on long names
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: isDesktop ? AppDimensions.d6.h : AppDimensions.d4.h),
                Text(
                  "Level $level | ${points} Points Earned",
                  style: TextStyle(
                    fontSize: fontSizeSubtext,
                    color: isHighlighted ? Colors.white70 : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          // Score with star - Adaptive icon and font size
          Row(
            mainAxisSize: MainAxisSize.min, // Prevent unnecessary expansion
            children: [
              Icon(
                Icons.star,
                color: AppColors.primaryRed,
                size: iconSize,
              ),
              SizedBox(width: spacingSmall),
              Text(
                "$score",
                style: TextStyle(
                  fontSize: fontSizeScore,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}