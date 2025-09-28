import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';

/// Responsive Score Card Widget for Mobile, Web, and Desktop
class CustomScoreCard extends StatelessWidget {
  final int score;
  final String title;
  final String? description;

  const CustomScoreCard({
    super.key,
    required this.score,
    required this.title,
    this.description,
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
    double horizontalMargin = getResponsiveDimension(
        screenWidth * 0.05, // Mobile
        screenWidth * 0.10, // Tablet
        screenWidth * 0.015  // Desktop (larger margins for centering)
    );
    double padding = getResponsiveDimension(
        screenWidth * 0.04, // Mobile
        screenWidth * 0.0035, // Tablet
        screenWidth * 0.003   // Desktop
    );
    double borderRadius = getResponsiveDimension(20.0, 24.0, 26.0);
    double borderWidth = getResponsiveDimension(1.5, 1.8, 2.0);
    double shadowBlur = getResponsiveDimension(8.0, 12.0, 15.0);
    double shadowOffsetY = getResponsiveDimension(2.0, 3.0, 4.0);
    double shadowSpread = getResponsiveDimension(0.0, 1.0, 2.0);
    bool showShadow = !isMobile || screenWidth > 400; // Show shadow on larger mobile too

// Circle responsive size
    double circleSize = isMobile
        ? screenWidth * 0.45
        : (screenWidth * 0.025).clamp(180.0, 300.0); // Clamped for larger screens

// Circle inner content responsive sizes
    double scoreFontSize = getResponsiveDimension(
        isLandscape ? 22.0 : 26.0, // Mobile (smaller in landscape)
        28.0, // Tablet
        32.0  // Desktop
    );
    double labelFontSize = getResponsiveDimension(
        isLandscape ? 12.0 : 14.0, // Mobile (smaller in landscape)
        15.0, // Tablet
        16.0  // Desktop
    );
    double borderStrokeWidth = getResponsiveDimension(
        circleSize * 0.02, // Mobile
        circleSize * 0.022, // Tablet
        circleSize * 0.025  // Desktop (thicker)
    );
    double shadowBlurInPainter = getResponsiveDimension(2.0, 3.0, 4.0);

// Spacing and title/description responsive sizes
    double mainSpacing = getResponsiveDimension(12.0, 14.0, 16.0);
    double halfSpacing = mainSpacing * 0.5;
    double titleFontSize = getResponsiveDimension(
        isLandscape ? 16.0 : 18.0, // Mobile (smaller in landscape)
        19.0, // Tablet
        20.0  // Desktop
    );
    double titleLetterSpacing = getResponsiveDimension(0.0, 0.2, 0.5);
    double descriptionHorizontalPadding = getResponsiveDimension(10.0, 15.0, 20.0);
    double descriptionFontSize = getResponsiveDimension(
        isLandscape ? 12.0 : 14.0, // Mobile (smaller in landscape)
        14.0, // Tablet
        15.0  // Desktop
    );
    double descriptionLetterSpacing = getResponsiveDimension(0.0, 0.1, 0.3);
    int descriptionMaxLines = isMobile ? (isLandscape ? 1 : 2) : 3;

// Responsive max width for the card
    double maxCardWidth = isDesktop ? 600.0 : double.infinity;
    bool isLargeScreen = !isMobile;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxCardWidth),
      child: Container(
        width: double.infinity,
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: shadowBlur,
              offset: Offset(0, shadowOffsetY),
              spreadRadius: shadowSpread,
            ),
          ] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Circle with gradient border + soft red background
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryRed.withOpacity(0.15), // soft red top
                    Colors.white, // fade to white bottom
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _GradientBorderPainter(
                  circleSize: circleSize,
                  strokeWidth: borderStrokeWidth,
                  shadowBlur: shadowBlurInPainter,
                  isLargeScreen: isLargeScreen,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Score text
                      Text(
                        "$score%",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                          fontSize: scoreFontSize,
                        ),
                      ),

                      // Final score label
                      Text(
                        "final_score".tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: labelFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: mainSpacing),

            /// Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontSize: titleFontSize,
                letterSpacing: titleLetterSpacing,
              ),
              textAlign: TextAlign.center,
            ),

            if (description != null) ...[
              SizedBox(height: halfSpacing),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: descriptionHorizontalPadding),
                child: Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: descriptionFontSize,
                    height: 1.4,
                    letterSpacing: descriptionLetterSpacing,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: descriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Enhanced Custom Painter for gradient + varying thickness border
class _GradientBorderPainter extends CustomPainter {
  final double circleSize;
  final double strokeWidth;
  final double shadowBlur;
  final bool isLargeScreen;

  _GradientBorderPainter({
    required this.circleSize,
    required this.strokeWidth,
    required this.shadowBlur,
    required this.isLargeScreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

// Gradient border paint
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primaryRed.withOpacity(0.9), // dark red at top
        AppColors.primaryRed.withOpacity(0.3), // light red at bottom
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

// Draw border circle with enhanced styling for large screens
    if (isLargeScreen) {
      // Add subtle shadow effect for web/desktop
      final shadowPaint = Paint()
        ..color = AppColors.primaryRed.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.5
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);

      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        -3.14 / 2,
        3.14 * 2,
        false,
        shadowPaint,
      );
    }

// Draw main border circle
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -3.14 / 2,
      3.14 * 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}