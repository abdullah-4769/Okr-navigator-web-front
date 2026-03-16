import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_dimensions.dart';

// ─── Adaptive helpers ─────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class CustomAIStrategyContainer extends StatefulWidget {
  final String mode; // 'solo' or 'team'
  const CustomAIStrategyContainer({super.key, this.mode = 'solo'});

  @override
  State<CustomAIStrategyContainer> createState() =>
      _CustomAIStrategyContainerState();
}

class _CustomAIStrategyContainerState
    extends State<CustomAIStrategyContainer> {
  @override
  Widget build(BuildContext context) {
    final sw     = MediaQuery.of(context).size.width;
    final isTeam = widget.mode == 'team';
    final color  = isTeam ? AppColors.primaryBlue : AppColors.primaryRed;

    // ── Desktop / Web ────────────────────────────────────────────────────────
    if (sw >= 768) return _buildDesktop(sw, color);

    // ── Mobile (unchanged from original) ────────────────────────────────────
    return _buildMobile(color);
  }

  // ==========================================================================
  // MOBILE — exact original layout, only plain-px → .sp/.w/.h conversions kept
  // ==========================================================================
  Widget _buildMobile(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.d24.w,
        vertical:   AppDimensions.d16.h,
      ),
      padding:    EdgeInsets.all(AppDimensions.d20.w),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(AppDimensions.d16.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Robot image
            Center(
              child: Image.asset(
                'assets/images/robort.png',
                height: 100,
                width:  100,
              ),
            ),

            // Header row
            Center(
              child: Row(
                children: [
                  SizedBox(width: AppDimensions.d40.w),
                  Text(
                    '\n${'ai_strategic_analysis'.tr}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Gotham-Bold',
                      fontSize:   AppDimensions.d20.sp,
                      color:      Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppDimensions.d20.h),

            // Inner white box
            Container(
              width:   double.infinity,
              padding: EdgeInsets.all(AppDimensions.d16.w),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.d12.r),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined,
                      size: AppDimensions.d40.w, color: color),
                  SizedBox(height: AppDimensions.d12.h),
                  Text(
                    'submit_initiatives_ai_analysis'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:   AppDimensions.d14.sp,
                      fontWeight: FontWeight.w500,
                      color:      AppColors.textSecondary,
                      fontFamily: 'Gotham',
                    ),
                  ),
                  SizedBox(height: AppDimensions.d8.h),
                  Text(
                    'feedback_will_appear_here'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppDimensions.d12.sp,
                      color:    AppColors.textSecondary.withValues(alpha: 0.7),
                      fontFamily: 'Gotham',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // DESKTOP / WEB — same layout, all sizing in plain px (no .sp/.w/.h)
  // ==========================================================================
  Widget _buildDesktop(double sw, Color color) {
    // Clamp width so it doesn't stretch across the full white card
    final double maxW = sw > 1200 ? 560.0 : sw * 0.55;

    return Center(
      child: Container(
        width:   maxW,
        margin:  const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:        color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Robot image
            Image.asset(
              'assets/images/robort.png',
              height: 80,
              width:  80,
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              'ai_strategic_analysis'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gotham-Bold',
                fontSize:   _fs(sw, 20, desktop: 18),
                color:      Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Inner white box
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 36, color: color),
                  const SizedBox(height: 10),
                  Text(
                    'submit_initiatives_ai_analysis'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:   _fs(sw, 14, desktop: 14),
                      fontWeight: FontWeight.w500,
                      color:      AppColors.textSecondary,
                      fontFamily: 'Gotham',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'feedback_will_appear_here'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _fs(sw, 12, desktop: 12),
                      color:    AppColors.textSecondary.withValues(alpha: 0.7),
                      fontFamily: 'Gotham',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}