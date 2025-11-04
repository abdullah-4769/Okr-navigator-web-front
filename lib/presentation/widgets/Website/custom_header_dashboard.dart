import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_assets.dart';

class HeaderWithLogo extends StatelessWidget {
  final String title;
  final String subtitle;

  const HeaderWithLogo({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizes based on screen width and height
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;
        final double logoSize = maxWidth * 0.15 > 80 ? 80 : maxWidth * 0.15; // Cap at 80px
        final double dashboardSize = maxWidth * 0.15 > 80 ? 80 : maxWidth * 0.15; // Cap at 80px
        final double padding = maxWidth * 0.02; // 2% of screen width
        final double titleFontSize = maxHeight * 0.05 > 28 ? 28 : maxHeight * 0.05; // Cap at 28px
        final double subtitleFontSize = maxHeight * 0.03 > 16 ? 16 : maxHeight * 0.03; // Cap at 16px

        return Container(
          padding: EdgeInsets.all(padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // OKR Logo on the left
              Image.asset(
                AppAssets.okrLogo, // Ensure this path is correct in app_assets.dart
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
              // Centered Title and Subtitle
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with overflow handling to fit screen
                    Flexible(
                      child: Text(
                        title.tr,
                        textAlign: TextAlign.center,
                        maxLines: 1, // Limit to 1 line (adjust to 2 if multi-line needed)
                        overflow: TextOverflow.ellipsis, // Truncate with "..." if too long
                        style: TextStyle(
                          fontFamily: 'GothamUltra',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E5BBA),
                        ),
                      ),
                    ),
                    SizedBox(height: maxHeight * 0.01),
                    // Subtitle with overflow handling to fit screen
                    Flexible(
                      child: Text(
                        subtitle.tr,
                        textAlign: TextAlign.center,
                        maxLines: 1, // Limit to 1 line (adjust to 2 if multi-line needed)
                        overflow: TextOverflow.ellipsis, // Truncate with "..." if too long
                        style: TextStyle(
                          fontFamily: 'GothamBold',
                          fontSize: subtitleFontSize,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Persondashboard on the right
              Image.asset(
                'assets/images/solo2.png', // Ensure this path is correct in pubspec.yaml
                width: dashboardSize,
                height: dashboardSize,
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
  }
}