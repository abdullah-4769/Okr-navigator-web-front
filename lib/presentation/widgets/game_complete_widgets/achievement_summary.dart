import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';

/// Achievement Summary
class AchievementSummary extends StatelessWidget {
  final List<String> achievements;
  const AchievementSummary({super.key, required this.achievements});

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
    double horizontalMargin = getResponsiveDimension(12.0, 16.0, 20.0); // Scaled from 0.03 * width
    double padding = getResponsiveDimension(16.0, 20.0, 24.0); // Scaled from 0.05 * width
    double borderRadius = getResponsiveDimension(12.0, 16.0, 18.0);

    // Header responsive sizes
    double avatarIconSize = getResponsiveDimension(
        isLandscape ? 20.0 : 24.0, // Mobile (smaller in landscape)
        28.0, // Tablet
        26.0  // Desktop
    );
    double headerSizedBoxWidth = getResponsiveDimension(8.0, 12.0, 14.0);
    double titleFontSize = getResponsiveDimension(
        isLandscape ? 14.0 : 16.0, // Mobile (smaller in landscape)
        18.0, // Tablet
        20.0  // Desktop
    );
    double headerSizedBoxHeight = getResponsiveDimension(8.0, 12.0, 14.0);

    // Achievements list responsive sizes
    double checkIconSize = getResponsiveDimension(
        isLandscape ? 16.0 : 18.0, // Mobile (smaller in landscape)
        20.0, // Tablet
        22.0  // Desktop
    );
    double textIconSpacing = getResponsiveDimension(6.0, 8.0, 10.0);
    double achievementFontSize = getResponsiveDimension(
        isLandscape ? 12.0 : 14.0, // Mobile (smaller in landscape)
        16.0, // Tablet
        18.0  // Desktop
    );
    double dividerVerticalPadding = getResponsiveDimension(6.0, 8.0, 10.0);
    double dividerThickness = getResponsiveDimension(0.8, 1.0, 1.2);
    int achievementMaxLines = isMobile ? (isLandscape ? 2 : 3) : 4;

    // Responsive max width for the container (full on mobile/tablet, constrained on desktop)
    double maxContainerWidth = isDesktop ? 600.0 : double.infinity;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContainerWidth),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
          border: Border.all(
            color: AppColors.primaryRed,
            width: getResponsiveDimension(1.5, 2.0, 2.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Heading with icon
            Row(
              children: [
                CircleAvatar(
                  radius: getResponsiveDimension(12.0, 14.0, 15.0), // Adjusted for icon size
                  backgroundColor: AppColors.primaryRed,
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.white,
                    size: avatarIconSize,
                  ),
                ),
                SizedBox(width: headerSizedBoxWidth),
                Expanded(
                  child: Text(
                    "achievement_summary".tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: titleFontSize,
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

            /// Achievements list with divider
            ...List.generate(achievements.length, (index) {
              final a = achievements[index];
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: getResponsiveDimension(2.0, 3.0, 2.5)),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: checkIconSize,
                        ),
                      ),
                      SizedBox(width: textIconSpacing),
                      Expanded(
                        child: Text(
                          a,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: achievementFontSize,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: achievementMaxLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (index < achievements.length - 1) // divider except last
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: dividerVerticalPadding),
                      child: Divider(
                        color: AppColors.grey.withOpacity(0.3),
                        thickness: dividerThickness,
                        height: 1,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}