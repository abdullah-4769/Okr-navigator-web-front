// lib/presentation/widgets/game_complete_widgets/success_rate_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';

class SuccessRateBar extends StatelessWidget {
  final int successRate;
  final double progressValue;

  const SuccessRateBar({
    super.key,
    required this.successRate,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw >= 768;

    return Column(
      children: [
        Text(
          '$successRate% ${'success_rate'.tr}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 18.0 : null,
          ),
        ),
        SizedBox(height: isDesktop ? 8.0 : 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(isDesktop ? 10.0 : 10.r),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: isDesktop ? 8.0 : 8.h,
            color: AppColors.primaryRed,
            backgroundColor: AppColors.textSecondary.withOpacity(0.12),
          ),
        ),
      ],
    );
  }
}