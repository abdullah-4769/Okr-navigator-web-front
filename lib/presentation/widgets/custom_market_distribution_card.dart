import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomMarketDisruptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? warningText; // optional
  final IconData? warningIcon; // optional

  const CustomMarketDisruptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.warningText,
    this.warningIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen size and platform information
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 1200;
    final isTablet = size.width > 768 && size.width <= 1200;
    final isMobile = size.width <= 768;
    final isDesktop = size.width > 1024;

    // Responsive padding based on platform
    EdgeInsets getResponsivePadding() {
      if (isWeb || isDesktop) {
        return EdgeInsets.all(AppDimensions.d24.w);
      } else if (isTablet) {
        return EdgeInsets.all(AppDimensions.d20.w);
      } else {
        return EdgeInsets.all(AppDimensions.d16.w);
      }
    }

    // Responsive border radius
    double getResponsiveBorderRadius() {
      if (isWeb || isDesktop) {
        return AppDimensions.d16.r;
      } else if (isTablet) {
        return AppDimensions.d14.r;
      } else {
        return AppDimensions.d12.r;
      }
    }

    // Responsive icon size
    double getResponsiveIconSize() {
      if (isWeb) {
        return AppDimensions.d32.w;
      } else if (isDesktop) {
        return AppDimensions.d28.w;
      } else if (isTablet) {
        return AppDimensions.d26.w;
      } else {
        return AppDimensions.d22.w;
      }
    }

    // Responsive avatar size
    double getResponsiveAvatarSize() {
      if (isWeb) {
        return AppDimensions.d56.w;
      } else if (isDesktop) {
        return AppDimensions.d50.w;
      } else if (isTablet) {
        return AppDimensions.d48.w;
      } else {
        return AppDimensions.d40.w;
      }
    }

    // Responsive spacing
    double getResponsiveSpacing({bool isVertical = false}) {
      if (isWeb || isDesktop) {
        return isVertical ? AppDimensions.d16.h : AppDimensions.d12.w;
      } else if (isTablet) {
        return isVertical ? AppDimensions.d12.h : AppDimensions.d10.w;
      } else {
        return isVertical ? AppDimensions.d8.h : AppDimensions.d8.w;
      }
    }

    // Responsive text styles
    TextStyle? getResponsiveTitleStyle() {
      final baseStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
        color: AppColors.primaryRed,
        height: 1.2,
      );

      if (isWeb) {
        return baseStyle?.copyWith(
          fontSize: baseStyle.fontSize! * 1.2,
          fontWeight: FontWeight.w600,
        );
      } else if (isDesktop) {
        return baseStyle?.copyWith(
          fontSize: baseStyle.fontSize! * 1.1,
          fontWeight: FontWeight.w600,
        );
      } else if (isTablet) {
        return baseStyle?.copyWith(
          fontSize: baseStyle.fontSize! * 1.05,
        );
      }
      return baseStyle;
    }

    TextStyle? getResponsiveBodyStyle({bool isWarning = false}) {
      final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
        color: isWarning ? AppColors.primaryRed : AppColors.grey,
        height: isWarning ? 1.3 : 1.2,
      );

      if (isWeb || isDesktop) {
        return baseStyle?.copyWith(
          fontSize: baseStyle.fontSize! * 1.1,
        );
      } else if (isTablet) {
        return baseStyle?.copyWith(
          fontSize: baseStyle.fontSize! * 1.05,
        );
      }
      return baseStyle;
    }

    // Responsive shadow
    List<BoxShadow> getResponsiveShadow() {
      if (isWeb || isDesktop) {
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ];
      } else if (isTablet) {
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.11),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: 0.5,
          ),
        ];
      } else {
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ];
      }
    }

    // Responsive border width
    double getResponsiveBorderWidth() {
      if (isWeb || isDesktop) {
        return 2.5;
      } else if (isTablet) {
        return 2.2;
      } else {
        return 2.0;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: isWeb ? 600 : double.infinity,
            minHeight: isMobile ? 140 : 160,
          ),
          padding: getResponsivePadding(),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(getResponsiveBorderRadius()),
            border: Border.all(
              color: AppColors.primaryRed.withOpacity(0.6),
              width: getResponsiveBorderWidth(),
            ),
            boxShadow: getResponsiveShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔹 Title Row (Icon + Title)
              Row(
                children: [
                  CircleAvatar(
                    radius: getResponsiveAvatarSize() / 2,
                    backgroundColor: AppColors.primaryRed,
                    child: Icon(
                      icon,
                      color: AppColors.white,
                      size: getResponsiveIconSize(),
                    ),
                  ),
                  SizedBox(width: getResponsiveSpacing()),
                  Expanded(
                    child: Text(
                      title,
                      style: getResponsiveTitleStyle(),
                      maxLines: isMobile ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: getResponsiveSpacing(isVertical: true)),

              /// 🔹 Description
              Text(
                description,
                style: getResponsiveBodyStyle(),
                maxLines: isWeb || isDesktop ? null : (isTablet ? 4 : 3),
                overflow: isWeb || isDesktop ? TextOverflow.visible : TextOverflow.ellipsis,
              ),

              /// 🔹 Optional Warning Section
              if (warningText != null) ...[
                SizedBox(height: getResponsiveSpacing(isVertical: true) * 1.5),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                      isWeb || isDesktop
                          ? AppDimensions.d16.w
                          : (isTablet ? AppDimensions.d14.w : AppDimensions.d12.w)
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(
                        isWeb || isDesktop
                            ? AppDimensions.d12.r
                            : (isTablet ? AppDimensions.d10.r : AppDimensions.d8.r)
                    ),
                    border: Border.all(
                      color: Colors.yellow.withOpacity(0.7),
                      width: getResponsiveBorderWidth() - 0.5,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Warning icon (optional)
                        if (warningIcon != null) ...[
                          Icon(
                            warningIcon!,
                            size: getResponsiveIconSize() * 0.8,
                            color: AppColors.primaryRed,
                          ),
                          SizedBox(width: getResponsiveSpacing() * 0.8),
                        ],

                        // Impact label
                        Text(
                          'Impact: ',
                          style: getResponsiveBodyStyle(isWarning: true)?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: getResponsiveSpacing() * 0.5),

                        // Warning text
                        Expanded(
                          child: Text(
                            warningText!,
                            style: getResponsiveBodyStyle(isWarning: true),
                            maxLines: isWeb || isDesktop ? null : (isTablet ? 3 : 2),
                            overflow: isWeb || isDesktop ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}