import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../widgets/common_image.dart';

class DesktopAppBar extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String title; // New: Customizable title (e.g., 'choose')
  final String subtitle; // New: Customizable subtitle (e.g., 'objective')

  const DesktopAppBar({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.title, // Required parameter
    required this.subtitle, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    // Determine device type
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // Responsive font helpers
    double headerFont(double mobile, double tablet, double desktop) =>
        isMobile ? mobile : isTablet ? tablet : desktop;
    double bodyFont(double mobile, double tablet, double desktop) =>
        isMobile ? mobile : isTablet ? tablet : desktop;

    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: isMobile
          ? screenWidth * 0.04
          : isTablet
          ? screenWidth * 0.05
          : 40), // desktop fixed padding
      color: Colors.white.withOpacity(0.95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Align(
            alignment: Alignment.bottomLeft,
            child: Image.asset(
              'assets/images/okr_logo.png',
              height: 100,
              width: 110,
            ),
          ),

          // Title Column: Wrapped in Expanded for flexible width; texts with overflow handling
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title with overflow handling to fit screen
                Flexible(
                  child: Text(
                    title.tr, // Dynamic: Uses passed title key and translates
                    style: TextStyle(
                      fontSize: headerFont(22, 26, 32),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                      fontFamily: 'GothamUltra',
                    ),
                    maxLines: 1, // Limit to 1 line (adjust to 2 if multi-line needed)
                    overflow: TextOverflow.ellipsis, // Truncate with "..." if too long
                    textAlign: TextAlign.center, // Center for better app bar look
                  ),
                ),
                // Subtitle with overflow handling to fit screen
                Flexible(
                  child: Text(
                    subtitle.tr, // Dynamic: Uses passed subtitle key and translates
                    style: TextStyle(
                      fontSize: bodyFont(14, 16, 18),
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GothamBold',
                    ),
                    maxLines: 1, // Limit to 1 line (adjust to 2 if multi-line needed)
                    overflow: TextOverflow.ellipsis, // Truncate with "..." if too long
                    textAlign: TextAlign.center, // Center for better app bar look
                  ),
                ),
              ],
            ),
          ),

          // Profile Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryRed.withOpacity(0.1),
            child: CommonImage(
              assetPath: 'assets/images/solo2.png',
            ),
          ),
        ],
      ),
    );
  }
}