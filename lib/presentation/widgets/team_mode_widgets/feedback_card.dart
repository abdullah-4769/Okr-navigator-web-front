// lib/presentation/widgets/game_complete_widgets/feedback_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';

class FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const FeedbackCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw >= 768;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isDesktop ? 6.0 : 6.h),
      padding: EdgeInsets.all(isDesktop ? 16.0 : 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 14.0 : 14.r),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Name + Role Row
          Row(
            children: [
              CircleAvatar(
                radius: isDesktop ? 20.0 : 20.r,
                backgroundImage: AssetImage(
                    data['avatar'] ?? 'assets/images/default_avatar.png'),
              ),
              SizedBox(width: isDesktop ? 12.0 : 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data['name']}',
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16.0 : 16.sp,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 2.0 : 2.h),
                    Text(
                      '${data['role']} | ${'level'.tr} ${data['level']}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isDesktop ? 12.0 : 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isDesktop ? 12.0 : 12.h),

          // Message
          Text(
            data['message'],
            style: TextStyle(
              color: AppColors.black,
              fontSize: isDesktop ? 14.0 : 14.sp,
              height: 1.4,
            ),
          ),

          SizedBox(height: isDesktop ? 12.0 : 12.h),

          // Rating
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    Icons.star,
                    size: isDesktop ? 18.0 : 18.sp,
                    color: i < data['rating'] ? Colors.orange : Colors.grey,
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 8.0 : 8.w),
              Text(
                '${data['rating']}/5',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isDesktop ? 12.0 : 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}