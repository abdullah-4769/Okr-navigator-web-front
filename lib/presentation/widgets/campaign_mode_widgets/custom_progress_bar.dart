import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_colors.dart';

class CustomProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const CustomProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;

    final double progress = (currentStep / totalSteps).clamp(0.0, 1.0);

    // ── Adaptive sizes — plain px on desktop/tablet, .sp/.h on mobile ────────
    final double barHeight = isDesktop ? 10.0 : isTablet ? 9.0 : 8.h;
    final double borderRadius = isDesktop ? 6.0 : isTablet ? 6.0 : 6.0;
    final double spacing = isDesktop ? 10.0 : isTablet ? 9.0 : 8.h;
    final double stepFontSize = isDesktop ? 13.0 : isTablet ? 13.0 : 14.sp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Progress bar track ────────────────────────────────────────────────
        Container(
          width: double.infinity,
          height: barHeight,
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ),

        SizedBox(height: spacing),

        // ── Step numbers row ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final int stepNumber = index + 1;
            final bool isCompleted = stepNumber <= currentStep;
            final bool isCurrent = stepNumber == currentStep + 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step dot indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isDesktop ? 10 : isTablet ? 9 : 8.0,
                  height: isDesktop ? 10 : isTablet ? 9 : 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.primaryRed
                        : isCurrent
                        ? AppColors.primaryRed.withOpacity(0.4)
                        : AppColors.grey.withOpacity(0.3),
                  ),
                ),
                SizedBox(width: isDesktop ? 6.0 : 4.0),
                // Step number
                Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: isCompleted
                        ? AppColors.primaryRed
                        : AppColors.grey,
                    fontWeight: isCompleted
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: stepFontSize, // ✅ adaptive
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../core/app_colors.dart';
//
// class CustomProgressBar extends StatelessWidget {
//   final int totalSteps;
//   final int currentStep;
//
//   const CustomProgressBar({
//     super.key,
//     required this.totalSteps,
//     required this.currentStep,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final progress = (currentStep / totalSteps).clamp(0.0, 1.0);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// 🔹 Progress bar
//         Container(
//           width: double.infinity,
//           height: 8.h,
//           decoration: BoxDecoration(
//             color: AppColors.grey, // background
//             borderRadius: BorderRadius.circular(6.r),
//           ),
//           child: FractionallySizedBox(
//             alignment: Alignment.centerLeft,
//             widthFactor: progress, // % filled
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppColors.primaryRed,
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 8.h),
//
//         /// 🔹 Digits Row (steps)
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(totalSteps, (index) {
//             final stepNumber = index + 1;
//             final isCompleted = stepNumber <= currentStep;
//
//             return Text(
//               "$stepNumber",
//               style: TextStyle(
//                 color: isCompleted ? AppColors.primaryRed : AppColors.grey,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14.sp,
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }
