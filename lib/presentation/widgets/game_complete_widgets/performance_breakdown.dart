import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';

/// Performance Breakdown
class PerformanceBreakdown extends StatelessWidget {
  final int points;
  final int totalPoints;
  final List<BreakdownItem> items;
  const PerformanceBreakdown({
    super.key,
    required this.points,
    required this.totalPoints,
    required this.items,
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
    double horizontalMargin = getResponsiveDimension(16.0, 20.0, 24.0);
    double padding = getResponsiveDimension(12.0, 16.0, 18.0);
    double borderRadius = getResponsiveDimension(12.0, 16.0, 18.0);
    double borderWidth = getResponsiveDimension(1.5, 1.8, 2.0);
    bool showShadow = isTablet || isDesktop; // Subtle shadow on larger screens

    // Header responsive sizes
    double avatarRadius = getResponsiveDimension(12.0, 14.0, 15.0);
    double headerIconSize = getResponsiveDimension(
        isLandscape ? 18.0 : 22.0, // Mobile (smaller in landscape)
        24.0, // Tablet
        26.0  // Desktop
    );
    double headerSizedBoxWidth = getResponsiveDimension(6.0, 8.0, 10.0);
    double headerTitleFontSize = getResponsiveDimension(
        isLandscape ? 14.0 : 16.0, // Mobile (smaller in landscape)
        18.0, // Tablet
        20.0  // Desktop
    );
    double headerSizedBoxHeight = getResponsiveDimension(8.0, 12.0, 14.0);

    // Items responsive sizes
    double itemVerticalPadding = getResponsiveDimension(4.0, 6.0, 7.0);
    double itemTitleFontSize = getResponsiveDimension(
        isLandscape ? 12.0 : 14.0, // Mobile (smaller in landscape)
        15.0, // Tablet
        16.0  // Desktop
    );
    double itemScoreFontSize = getResponsiveDimension(
        isLandscape ? 13.0 : 14.0, // Mobile (smaller in landscape)
        16.0, // Tablet
        17.0  // Desktop
    );
    double scoreIconSpacing = getResponsiveDimension(6.0, 8.0, 9.0);
    double successIconSize = getResponsiveDimension(
        isLandscape ? 16.0 : 20.0, // Mobile (smaller in landscape)
        22.0, // Tablet
        24.0  // Desktop
    );

    // Divider responsive sizes
    double dividerThickness = getResponsiveDimension(0.8, 1.0, 1.2);
    double dividerHeight = getResponsiveDimension(8.0, 10.0, 12.0);

    // Total points responsive sizes
    double totalPointsSizedBoxHeight = getResponsiveDimension(12.0, 16.0, 18.0);
    double totalPointsFontSize = getResponsiveDimension(
        isLandscape ? 15.0 : 16.0, // Mobile (smaller in landscape)
        18.0, // Tablet
        20.0  // Desktop
    );

    // Responsive max width for the container
    double maxContainerWidth = isDesktop ? 700.0 : double.infinity;

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
            width: borderWidth,
          ),
          boxShadow: showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: getResponsiveDimension(4.0, 8.0, 12.0),
              offset: Offset(0, getResponsiveDimension(2.0, 3.0, 4.0)),
            ),
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Row
            Row(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: AppColors.primaryRed,
                  child: Icon(
                    Icons.bar_chart,
                    color: AppColors.white,
                    size: headerIconSize,
                  ),
                ),
                SizedBox(width: headerSizedBoxWidth),
                Expanded(
                  child: Text(
                    "performance_breakdown".tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: headerTitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: headerSizedBoxHeight),

            /// Items with divider
            ...List.generate(items.length, (index) {
              final e = items[index];
              return Column(
                children: [
                  _buildItem(e, context, itemVerticalPadding, itemTitleFontSize, itemScoreFontSize, scoreIconSpacing, successIconSize),
                  if (index < items.length - 1) // divider except last item
                    Divider(
                      color: AppColors.grey.withOpacity(0.3),
                      thickness: dividerThickness,
                      height: dividerHeight,
                    ),
                ],
              );
            }),

            SizedBox(height: totalPointsSizedBoxHeight),
            Center(
              child: Text(
                "${"total_points".tr} $points/$totalPoints",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: totalPointsFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
      BreakdownItem e,
      BuildContext context,
      double itemVerticalPadding,
      double itemTitleFontSize,
      double itemScoreFontSize,
      double scoreIconSpacing,
      double successIconSize,
      ) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: itemVerticalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                e.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: itemTitleFontSize,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  e.score,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: itemScoreFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
                SizedBox(width: scoreIconSpacing),
                Icon(
                  e.success ? Icons.check_circle : Icons.remove_circle,
                  color: e.success ? Colors.green : Colors.orange,
                  size: successIconSize,
                ),
              ],
            ),
          ],
        ),
      );
}

class BreakdownItem {
  final String title;
  final String score;
  final bool success;
  BreakdownItem(this.title, this.score, this.success);
}