import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

class CustomIndustryContainer extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  // ✅ NEW
  final bool showSelectionCircle;

  // Dynamic Bottom Tags
  final bool showTag1;
  final IconData? tag1Icon;
  final String? tag1Text;

  final bool showTag2;
  final IconData? tag2Icon;
  final String? tag2Text;

  final bool showTag3;
  final IconData? tag3Icon;
  final String? tag3Text;

  // ✅ NEW OPTIONAL small container
  final String? extraNote; // if provided, shows the small box
  final Color? extraNoteColor; // optional background color

  const CustomIndustryContainer({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.auto_graph_sharp,
    required this.isSelected,
    required this.onTap,
    this.showSelectionCircle = true,
    this.showTag1 = false,
    this.tag1Icon,
    this.tag1Text,
    this.showTag2 = false,
    this.tag2Icon,
    this.tag2Text,
    this.showTag3 = false,
    this.tag3Icon,
    this.tag3Text,
    this.extraNote, // ✅ default null
    this.extraNoteColor, // ✅ default null
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
    isSelected ? AppColors.primaryRed : AppColors.textSecondary;

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

    // Responsive font sizes
    double titleFontSize = getResponsiveDimension(
        isLandscape ? 14.0 : 16.0, // Mobile
        18.0, // Tablet
        16.0  // Desktop (smaller for web)
    );

    double descriptionFontSize = getResponsiveDimension(
        12.0, // Mobile
        14.0, // Tablet
        12.0  // Desktop
    );

    double tagFontSize = getResponsiveDimension(
        10.0, // Mobile
        12.0, // Tablet
        11.0  // Desktop
    );

    // Responsive icon sizes
    double iconSize = getResponsiveDimension(
        20.0, // Mobile
        24.0, // Tablet
        22.0  // Desktop
    );

    double selectionCircleSize = getResponsiveDimension(
        16.0, // Mobile
        18.0, // Tablet
        16.0  // Desktop
    );

    // Responsive padding and margins
    double horizontalPadding = getResponsiveDimension(
        12.0, // Mobile
        16.0, // Tablet
        14.0  // Desktop
    );

    double verticalPadding = getResponsiveDimension(
        14.0, // Mobile
        18.0, // Tablet
        16.0  // Desktop
    );

    double bottomMargin = getResponsiveDimension(
        6.0,  // Mobile
        8.0,  // Tablet
        8.0   // Desktop
    );

    // Responsive container constraints
    double maxWidth = isMobile
        ? screenWidth * 0.95
        : isTablet
        ? screenWidth * 0.8
        : 450.0; // Fixed max width for desktop

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(bottom: bottomMargin),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minWidth: isMobile ? screenWidth * 0.85 : maxWidth * 0.9,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(
                  getResponsiveDimension(12.0, 16.0, 14.0)
              ),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryRed
                    : AppColors.grey.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryRed.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: getResponsiveDimension(4.0, 6.0, 5.0),
                  offset: Offset(0, getResponsiveDimension(2.0, 3.0, 2.5)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Icon + Title + Selection Circle Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          getResponsiveDimension(8.0, 10.0, 9.0)
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryRed : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: getResponsiveDimension(12.0, 14.0, 13.0)),

                    /// Title Text
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: activeColor,
                          fontFamily: 'GothamBold',
                          height: 1.2, // Better line height for readability
                        ),
                        maxLines: isMobile ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    /// Selection Circle (optional)
                    if (showSelectionCircle)
                      Container(
                        height: selectionCircleSize,
                        width: selectionCircleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primaryRed
                              : Colors.transparent,
                          border: Border.all(
                              color: AppColors.primaryRed,
                              width: isDesktop ? 1.5 : 2
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                          Icons.check,
                          size: selectionCircleSize * 0.6,
                          color: Colors.white,
                        )
                            : null,
                      ),
                  ],
                ),
                SizedBox(height: getResponsiveDimension(8.0, 10.0, 9.0)),

                /// Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: AppColors.textSecondary,
                    fontFamily: 'Gotham',
                    height: 1.4,
                  ),
                  maxLines: isMobile
                      ? (isLandscape ? 2 : 3)
                      : isTablet
                      ? 3
                      : 2, // Desktop: 2 lines max
                  overflow: TextOverflow.ellipsis,
                ),

                /// Extra Note Container (optional)
                if (extraNote != null) ...[
                  SizedBox(height: getResponsiveDimension(8.0, 12.0, 10.0)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: getResponsiveDimension(8.0, 10.0, 9.0),
                      vertical: getResponsiveDimension(6.0, 8.0, 7.0),
                    ),
                    decoration: BoxDecoration(
                      color: extraNoteColor ?? AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          getResponsiveDimension(6.0, 8.0, 7.0)
                      ),
                      border: Border.all(
                        color: extraNoteColor ?? AppColors.primaryBlue,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      extraNote!,
                      style: TextStyle(
                        fontSize: getResponsiveDimension(10.0, 12.0, 11.0),
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Gotham',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                /// Bottom Tags
                if (showTag1 || showTag2 || showTag3) ...[
                  SizedBox(height: getResponsiveDimension(8.0, 12.0, 10.0)),
                  Wrap(
                    spacing: getResponsiveDimension(12.0, 16.0, 14.0),
                    runSpacing: getResponsiveDimension(4.0, 6.0, 5.0),
                    children: [
                      if (showTag1 && tag1Icon != null && tag1Text != null)
                        _buildTag(tag1Icon!, tag1Text!, activeColor, tagFontSize, isMobile),
                      if (showTag2 && tag2Icon != null && tag2Text != null)
                        _buildTag(tag2Icon!, tag2Text!, activeColor, tagFontSize, isMobile),
                      if (showTag3 && tag3Icon != null && tag3Text != null)
                        _buildTag(tag3Icon!, tag3Text!, activeColor, tagFontSize, isMobile),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper Method for Small Tags
  Widget _buildTag(IconData icon, String text, Color color, double fontSize, bool isMobile) =>
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6.0 : 8.0,
          vertical: isMobile ? 3.0 : 4.0,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(isMobile ? 6.0 : 8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: fontSize + 2, // Icon slightly larger than text
            ),
            SizedBox(width: isMobile ? 3.0 : 4.0),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: color,
                  fontFamily: 'Gotham',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
}