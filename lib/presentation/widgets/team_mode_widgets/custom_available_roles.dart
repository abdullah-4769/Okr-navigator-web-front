// lib/presentation/widgets/team_mode_widgets/custom_available_roles.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomAvailableRoles extends StatelessWidget {
  const CustomAvailableRoles({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 768;

    final roles = [
      {'name': 'You', 'level': 'Level 5', 'role': 'CEO'},
      {'name': 'Mike Chen', 'level': 'Level 3', 'role': 'Strategist'},
      {'name': '-', 'level': '', 'role': 'HR Manager'},
      {'name': '-', 'level': '', 'role': 'Analyst'},
      {'name': '-', 'level': '', 'role': 'Team Lead'},
      {'name': '-', 'level': '', 'role': 'Manager'},
    ];

    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : AppDimensions.d16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : AppDimensions.d24.r),
        border: Border.all(color: AppColors.primaryRed),
        boxShadow: isDesktop
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: AppColors.primaryRed,
                  radius: isDesktop ? 18 : 20,
                  child: Icon(Icons.groups, color: AppColors.white, size: isDesktop ? 18 : 22),
                ),
              ),
              SizedBox(width: isDesktop ? 8 : 8.w),
              Text(
                'available_roles'.tr,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isDesktop ? 15 : null,
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 4 : 3.h),

          // Roles list — 2-column grid on wide desktop, single column otherwise
          sw > 1100
              ? _buildTwoColumnRoles(roles, textTheme)
              : _buildSingleColumnRoles(roles, textTheme, isDesktop),
        ],
      ),
    );
  }

  Widget _buildSingleColumnRoles(
      List<Map<String, String>> roles,
      TextTheme textTheme,
      bool isDesktop,
      ) {
    return Column(
      children: roles.map((r) => Column(
        children: [
          _buildRoleRow(r, textTheme, isDesktop),
          if (r != roles.last)
            Padding(
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 8.h),
              child: Divider(color: AppColors.grey.withOpacity(.2), height: 1),
            ),
        ],
      )).toList(),
    );
  }

  Widget _buildTwoColumnRoles(
      List<Map<String, String>> roles,
      TextTheme textTheme,
      ) {
    final rows = <Widget>[];
    for (int i = 0; i < roles.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _buildRoleRow(roles[i], textTheme, true)),
            const SizedBox(width: 8),
            if (i + 1 < roles.length)
              Expanded(child: _buildRoleRow(roles[i + 1], textTheme, true))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < roles.length) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Divider(color: AppColors.grey.withOpacity(.2), height: 1),
          ),
        );
      }
    }
    return Column(children: rows);
  }

  Widget _buildRoleRow(Map<String, String> r, TextTheme textTheme, bool isDesktop) {
    return Row(
      children: [
        CircleAvatar(
          radius: isDesktop ? 14 : 16,
          backgroundColor: AppColors.primaryRed.withOpacity(0.08),
          child: SvgPicture.asset(
            'assets/images/solo.svg',
            height: isDesktop ? 18 : 32.h,
            width: isDesktop ? 18 : 32.w,
          ),
        ),
        SizedBox(width: isDesktop ? 10 : 12.w),
        Expanded(
          child: Text(
            '${r['name']}  ${r['level']}',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.black,
              fontSize: isDesktop ? 13 : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          r['role']!,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.grey,
            fontSize: isDesktop ? 13 : null,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}