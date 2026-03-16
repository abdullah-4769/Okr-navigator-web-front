// lib/presentation/widgets/section_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

/// Reusable SectionCard used to match the red/yellow bordered boxes
/// Accepts an icon, a color for border, a title, optional "back home" overlay,
/// and a list of items (title, subtitle, success).
class SectionCard extends StatelessWidget {
  final IconData icon;
  final Color borderColor;
  final String title;
  final List<Map<String, dynamic>> items;
  final bool showBackHome;
  final VoidCallback? onBackHome;

  const SectionCard({
    super.key,
    required this.icon,
    required this.borderColor,
    required this.title,
    required this.items,
    this.showBackHome = false,
    this.onBackHome,
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

    // Responsive container properties
    double containerVerticalMargin = getResponsiveDimension(8.0, 12.0, 10.0);
    double containerPadding = getResponsiveDimension(16.0, 20.0, 18.0);
    double borderRadius = getResponsiveDimension(18.0, 22.0, 20.0);
    double borderWidth = getResponsiveDimension(1.5, 2.0, 1.8);
    double shadowBlur = getResponsiveDimension(8.0, 10.0, 9.0);
    double shadowOffsetY = getResponsiveDimension(3.0, 4.0, 3.5);

    // Header responsive sizes
    double avatarRadius = getResponsiveDimension(18.0, 22.0, 20.0);
    double headerIconSize = getResponsiveDimension(18.0, 22.0, 20.0);
    double headerSizedBoxWidth = getResponsiveDimension(12.0, 16.0, 14.0);
    double titleFontSize = getResponsiveDimension(
        isLandscape ? 16.0 : 18.0, // Mobile (smaller in landscape)
        20.0, // Tablet
        18.0  // Desktop
    );
    double headerSizedBoxHeight = getResponsiveDimension(12.0, 16.0, 14.0);

    // Items responsive sizes
    double itemVerticalPadding = getResponsiveDimension(8.0, 10.0, 9.0);
    double itemTitleFontSize = getResponsiveDimension(
        isLandscape ? 13.0 : 14.0, // Mobile (smaller in landscape)
        16.0, // Tablet
        15.0  // Desktop
    );
    double subtitleSizedBoxHeight = getResponsiveDimension(6.0, 8.0, 7.0);
    double subtitleFontSize = getResponsiveDimension(
        isLandscape ? 11.0 : 12.0, // Mobile (smaller in landscape)
        14.0, // Tablet
        13.0  // Desktop
    );
    double textToIconSpacing = getResponsiveDimension(8.0, 10.0, 9.0);
    double successContainerSize = getResponsiveDimension(28.0, 32.0, 30.0);
    double checkIconSize = getResponsiveDimension(18.0, 20.0, 19.0);
    int subtitleMaxLines = isMobile ? (isLandscape ? 2 : 3) : 3;

    // Back home pill responsive sizes
    double backHomeRight = getResponsiveDimension(-10.0, -15.0, -12.0);
    double backHomeTop = getResponsiveDimension(6.0, 8.0, 7.0);
    double pillHorizontalPadding = getResponsiveDimension(12.0, 16.0, 14.0);
    double pillVerticalPadding = getResponsiveDimension(8.0, 10.0, 9.0);
    double pillRadius = getResponsiveDimension(28.0, 32.0, 30.0);
    double pillShadowBlur = getResponsiveDimension(6.0, 8.0, 7.0);
    double houseIconSize = getResponsiveDimension(16.0, 18.0, 17.0);
    double pillSizedBoxWidth = getResponsiveDimension(8.0, 10.0, 9.0);
    double backHomeFontSize = getResponsiveDimension(
        isLandscape ? 11.0 : 12.0, // Mobile (smaller in landscape)
        14.0, // Tablet
        13.0  // Desktop
    );

    // Responsive max width for the card (full on mobile/tablet, constrained on desktop)
    double maxCardWidth = isDesktop ? 800.0 : double.infinity;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxCardWidth),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: containerVerticalMargin),
            padding: EdgeInsets.all(containerPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor.withOpacity(0.9),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: shadowBlur,
                  offset: Offset(0, shadowOffsetY),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: borderColor,
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: headerIconSize,
                      ),
                    ),
                    SizedBox(width: headerSizedBoxWidth),
                    Expanded(
                      child: Text(
                        title.tr,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: headerSizedBoxHeight),

                // items list
                Column(
                  children: items.map((m) {
                    final String t = (m['title'] ?? '').toString().tr;
                    final String s = (m['subtitle'] ?? '').toString().tr;
                    final bool success = (m['success'] ?? false) as bool;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: itemVerticalPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // text column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: itemTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                SizedBox(height: subtitleSizedBoxHeight),
                                Text(
                                  s,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: subtitleFontSize,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: subtitleMaxLines,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // success icon
                          SizedBox(width: textToIconSpacing),
                          if (success)
                            Container(
                              width: successContainerSize,
                              height: successContainerSize,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: checkIconSize,
                              ),
                            )
                          else
                            SizedBox(
                              width: successContainerSize,
                              height: successContainerSize,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        // Back home floating pill (overlapping right edge)
        if (showBackHome)
          Positioned(
            right: backHomeRight,
            top: backHomeTop,
            child: GestureDetector(
              onTap: onBackHome,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: pillHorizontalPadding,
                  vertical: pillVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(pillRadius),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.25),
                      blurRadius: pillShadowBlur,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.house_outlined,
                      color: Colors.white,
                      size: houseIconSize,
                    ),
                    SizedBox(width: pillSizedBoxWidth),
                    Text(
                      "back_home".tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: backHomeFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}