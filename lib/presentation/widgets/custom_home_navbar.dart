import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/home_navbar_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomHomeNavBar extends StatelessWidget {
  const CustomHomeNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeNavBarController(), permanent: true);

    return Obx(() {
      final isExpanded = controller.isExpanded.value;
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

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

      // Responsive navbar dimensions
      double collapsedWidth = getResponsiveDimension(
          60.0,  // Mobile
          65.0,  // Tablet
          55.0   // Desktop (smaller for web)
      );

      double expandedWidth = getResponsiveDimension(
          180.0, // Mobile
          200.0, // Tablet
          160.0  // Desktop (more compact)
      );

      // Icon container size
      double iconContainerSize = getResponsiveDimension(
          50.0,  // Mobile
          55.0,  // Tablet
          45.0   // Desktop
      );

      // Icon size
      double iconSize = getResponsiveDimension(
          30.0,  // Mobile
          32.0,  // Tablet
          26.0   // Desktop
      );

      // Text font size
      double textFontSize = getResponsiveDimension(
          14.0,  // Mobile
          16.0,  // Tablet
          13.0   // Desktop
      );

      // Horizontal padding
      double horizontalPadding = getResponsiveDimension(
          8.0,   // Mobile
          10.0,  // Tablet
          8.0    // Desktop
      );

      // Vertical padding
      double verticalPadding = getResponsiveDimension(
          6.0,   // Mobile
          8.0,   // Tablet
          6.0    // Desktop
      );

      // Border radius
      double borderRadius = getResponsiveDimension(
          30.0,  // Mobile
          35.0,  // Tablet
          25.0   // Desktop
      );

      // Max width constraint (responsive)
      double maxWidthConstraint = isMobile
          ? screenWidth * 0.7
          : isTablet
          ? screenWidth * 0.4
          : 220.0; // Fixed max for desktop

      // Shadow blur radius
      double shadowBlur = getResponsiveDimension(8.0, 10.0, 6.0);

      // Text spacing from icon
      double textSpacing = getResponsiveDimension(12.0, 14.0, 10.0);

      return LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            alignment: Alignment.centerRight,
            curve: Curves.easeInOut,
            child: GestureDetector(
              // Swipe logic (disabled for desktop/web for better UX)
              onHorizontalDragUpdate: isMobile ? (details) {
                if (details.delta.dx < -5) {
                  // Swipe Left → Expand
                  controller.showNavBar();
                } else if (details.delta.dx > 5) {
                  // Swipe Right → Collapse
                  controller.hideNavBar();
                }
              } : null,

              onHorizontalDragEnd: isMobile ? (_) {
                controller.startAutoHideTimer(); // Restart auto-hide after interaction
              } : null,

              // Tap behavior - always available
              onTap: isExpanded ? controller.navigateHome : controller.showNavBar,

              // Hover behavior for desktop/web
              onTapDown: isDesktop ? (_) => controller.showNavBar() : null,

              child: MouseRegion(
                onEnter: isDesktop ? (_) => controller.showNavBar() : null,
                onExit: isDesktop ? (_) => controller.startAutoHideTimer() : null,
                cursor: SystemMouseCursors.click,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidthConstraint,
                    minWidth: collapsedWidth,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    width: isExpanded ? expandedWidth : collapsedWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(borderRadius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDesktop ? 0.15 : 0.2),
                          blurRadius: shadowBlur,
                          offset: Offset(
                              isDesktop ? 1 : 2,
                              isDesktop ? 2 : 3
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Home Icon Container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: iconContainerSize,
                          height: iconContainerSize,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: isDesktop ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ] : null,
                          ),
                          child: Icon(
                            Icons.home_sharp,
                            color: AppColors.reddish,
                            size: iconSize,
                          ),
                        ),

                        // Animated Text (shows when expanded)
                        // Animated Text (shows when expanded)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isExpanded
                              ? (expandedWidth - iconContainerSize - (horizontalPadding * 2) - textSpacing)
                              : 0,
                          child: isExpanded
                              ? Padding(
                            padding: EdgeInsets.only(left: textSpacing),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 400),
                              opacity: isExpanded ? 1.0 : 0.0,
                              child: Text(
                                'Back Home'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textFontSize,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Gotham',
                                  letterSpacing: isDesktop ? 0.5 : 0.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}