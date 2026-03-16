// lib/presentation/widgets/game_complete_widgets/custom_market_disruption_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomMarketDisruptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? warningText;
  final IconData? warningIcon;

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
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw >= 768;
    final double pad = isDesktop ? 16.0 : AppDimensions.d16.w;
    final double r = isDesktop ? 12.0 : AppDimensions.d12.r;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryRed,
                child: Center(
                  child: Icon(icon,
                      color: AppColors.white,
                      size: isDesktop ? 22.0 : AppDimensions.d22.w),
                ),
              ),
              SizedBox(width: isDesktop ? 8.0 : AppDimensions.d8.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.primaryRed,
                    height: 1.2,
                    fontSize: isDesktop ? 16.0 : null,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isDesktop ? 8.0 : AppDimensions.d8.h),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
              height: 1.2,
              fontSize: isDesktop ? 13.0 : null,
            ),
          ),

          // Optional warning
          if (warningText != null) ...[
            SizedBox(height: isDesktop ? 12.0 : AppDimensions.d12.h),
            Container(
              padding: EdgeInsets.all(isDesktop ? 12.0 : AppDimensions.d12.w),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(
                    isDesktop ? 8.0 : AppDimensions.d8.r),
                border: Border.all(
                    color: Colors.yellow.withOpacity(0.7), width: 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${'impact'.tr}: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryRed,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: isDesktop ? 8.0 : AppDimensions.d8.w),
                  Expanded(
                    child: Text(
                      warningText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryRed,
                        height: 1.2,
                        fontSize: isDesktop ? 13.0 : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}