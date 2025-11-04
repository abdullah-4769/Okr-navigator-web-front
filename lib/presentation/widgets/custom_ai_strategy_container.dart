import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';

class CustomAIStrategyContainer extends StatelessWidget {
  final String mode; // 'solo' or 'team'
  const CustomAIStrategyContainer({super.key, this.mode = 'solo'});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        final bool isMobile = screenWidth < 768;
        final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
        final bool isDesktop = screenWidth >= 1024;

        // Responsive font helpers
        double headerFont(double mobile, double tablet, double desktop) =>
            isMobile ? mobile : isTablet ? tablet : desktop;
        double bodyFont(double mobile, double tablet, double desktop) =>
            isMobile ? mobile : isTablet ? tablet : desktop;
        double buttonFont(double mobile, double tablet, double desktop) =>
            isMobile ? mobile : isTablet ? tablet : desktop;

        double containerPadding() => isMobile ? 20 : isTablet ? 30 : 40;
        double containerWidth() => isMobile
            ? screenWidth * 0.9
            : isTablet
            ? screenWidth * 0.7
            : 600;

        final bool isTeam = mode == 'team';
        final Color color = isTeam ? AppColors.primaryBlue : AppColors.primaryRed;

        return Center(
          child: Container(
            width: containerWidth(),
            padding: EdgeInsets.all(containerPadding()),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Robot Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/robort11.png',
                    height: isMobile ? 60 : isTablet ? 70 : 90,
                    width: isMobile ? 60 : isTablet ? 70 : 90,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Text(
                  'ai_strategic_analysis'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Gotham-Bold',
                    fontSize: headerFont(12, 14, 14).sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Inner white container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(containerPadding() * 0.4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: color.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          size: isMobile ? 28 : isTablet ? 34 : 40,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'submit_initiatives_ai_analysis'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: bodyFont(12, 12, 13).sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFamily: 'Gotham',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'feedback_will_appear_here'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: bodyFont(10, 11, 12).sp,
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontFamily: 'Gotham',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
