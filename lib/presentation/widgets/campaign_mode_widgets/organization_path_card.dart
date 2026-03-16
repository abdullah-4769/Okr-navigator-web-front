import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../widgets/custom_circular_avatar.dart';

class OrganizationPathCard extends StatelessWidget {
  final String orgName;
  final String orgSubtitle;
  final int stars;
  final List<OrgNode> nodes;
  final int currentNodeIndex;

  const OrganizationPathCard({
    super.key,
    required this.orgName,
    required this.orgSubtitle,
    required this.stars,
    required this.nodes,
    this.currentNodeIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 768;

    final double pad    = isDesktop ? 16 : 14.w;
    final double radius = isDesktop ? 16 : 16.r;
    // ✅ Much smaller avatar on desktop — was 60 which still renders huge
    final double nodeSize = isDesktop ? 38 : 55;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(width: 1.5, color: AppColors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Section label ──────────────────────────────────────────────────
          Text(
            orgName,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
            ),
          ),
          if (orgSubtitle.isNotEmpty) ...[
            SizedBox(height: isDesktop ? 2 : 3.h),
            Text(
              orgSubtitle,
              style: TextStyle(
                fontSize: isDesktop ? 11 : 12.sp,
                color: AppColors.grey,
              ),
            ),
          ],
          SizedBox(height: isDesktop ? 14 : 16.h),

          // ── Node path — vertical column, no Stack, no overflow ────────────
          ...List.generate(nodes.length, (i) {
            final node = nodes[i];
            final bool isCurrent = currentNodeIndex == i;
            final bool isDisabled = i > currentNodeIndex;
            final bool isLast = i == nodes.length - 1;

            return Column(
              children: [
                _buildNodeRow(
                  node: node,
                  isCurrent: isCurrent,
                  isDisabled: isDisabled,
                  nodeSize: nodeSize,
                  isDesktop: isDesktop,
                  index: i,
                ),
                // Connector line between nodes
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.only(left: isDesktop ? (nodeSize / 2) + 12 : (nodeSize / 2) + 16.w),
                    child: Container(
                      width: 2,
                      height: isDesktop ? 20 : 22.h,
                      color: isDisabled
                          ? AppColors.grey.withOpacity(0.25)
                          : AppColors.primaryRed.withOpacity(0.4),
                    ),
                  ),
              ],
            );
          }),

          SizedBox(height: isDesktop ? 12 : 14.h),

          // ── Stars ─────────────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                    (i) => Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: i < stars ? AppColors.primaryRed : AppColors.grey,
                  size: isDesktop ? 16 : 18.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeRow({
    required OrgNode node,
    required bool isCurrent,
    required bool isDisabled,
    required double nodeSize,
    required bool isDesktop,
    required int index,
  }) {
    final double labelSize  = isDesktop ? 12 : 13.sp;
    final double subSize    = isDesktop ? 10 : 11.sp;
    final double badgeSize  = isDesktop ? 9  : 9.sp;

    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar + "You" badge stacked
          SizedBox(
            width: nodeSize + (isDesktop ? 24 : 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrent)
                  Container(
                    margin: EdgeInsets.only(bottom: isDesktop ? 3 : 3.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 6 : 6.w,
                      vertical: isDesktop ? 1 : 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(isDesktop ? 8 : 8.r),
                    ),
                    child: Text(
                      'You'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: badgeSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                CustomCircularAvatar(
                  imagePath: node.imagePath,
                  innerColors: node.innerColors,
                  borderGradient: isCurrent ? node.borderGradient : null,
                  size: nodeSize,
                ),
              ],
            ),
          ),

          SizedBox(width: isDesktop ? 12 : 14.w),

          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.title.tr,
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? AppColors.black : AppColors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  node.subtitle.tr,
                  style: TextStyle(
                    fontSize: subSize,
                    color: isCurrent
                        ? AppColors.black.withOpacity(0.7)
                        : AppColors.grey.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Current indicator dot
          if (isCurrent)
            Container(
              width: isDesktop ? 8 : 8.w,
              height: isDesktop ? 8 : 8.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class OrgNode {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> innerColors;
  final List<Color>? borderGradient;
  final bool isYou;

  const OrgNode({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.innerColors,
    this.borderGradient,
    this.isYou = false,
  });
}