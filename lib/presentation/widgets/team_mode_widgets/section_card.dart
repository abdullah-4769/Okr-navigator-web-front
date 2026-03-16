import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_colors.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color borderColor;
  final List<Map<String, dynamic>> items;
  final bool showCheck;
  final bool showScore;
  final bool showLeftIcons;
  final bool showRightIcons;
  final bool showTopButton;
  final Color? outerCircleColor;
  final Color? checkIconColor;

  const SectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.borderColor,
    required this.items,
    this.showCheck = false,
    this.showScore = false,
    this.showLeftIcons = false,
    this.showRightIcons = true,
    this.showTopButton = true,
    this.outerCircleColor,
    this.checkIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 768;

    // All sizing: fixed px on desktop, ScreenUtil on mobile
    final double pad        = isDesktop ? 14 : 12.w;
    final double radius     = isDesktop ? 16 : 18.r;
    final double vMargin    = isDesktop ? 6  : 6.h;
    final double iconSize   = isDesktop ? 18 : 18.sp;
    final double avatarR    = isDesktop ? 16 : 18.r;
    final double gap        = isDesktop ? 10 : 12.w;
    final double checkSize  = isDesktop ? 18 : 20.sp;
    final double scoreFSize = isDesktop ? 12 : 13.sp;
    final double divH       = isDesktop ? 12 : 14.h;

    return Container(
      margin: EdgeInsets.symmetric(vertical: vMargin),
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row ─────────────────────────────────────────────────────
          Row(
            children: [
              if (icon != null) ...[
                CircleAvatar(
                  radius: avatarR,
                  backgroundColor: outerCircleColor ?? borderColor,
                  child: Icon(icon, color: Colors.white, size: iconSize),
                ),
                SizedBox(width: gap),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                    fontSize: isDesktop ? 14 : null,
                  ),
                ),
              ),
              if (showTopButton)
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),

          SizedBox(height: isDesktop ? 10 : 12.h),

          // ── Items ──────────────────────────────────────────────────────────
          ...items.map((m) => Column(
            children: [
              Row(
                children: [
                  // Left icons
                  if (showLeftIcons && (showCheck || showScore)) ...[
                    if (showCheck)
                      Icon(Icons.check_circle,
                          color: checkIconColor ?? Colors.green,
                          size: checkSize),
                    if (showScore)
                      Padding(
                        padding: EdgeInsets.only(left: isDesktop ? 5 : 6.w),
                        child: Text(
                          '${m['score']}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: scoreFSize,
                          ),
                        ),
                      ),
                    SizedBox(width: isDesktop ? 8 : 10.w),
                  ],

                  // Label
                  Expanded(
                    child: Text(
                      m['key'] ?? m['title'] ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop ? 13 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Right icons
                  if (showRightIcons) ...[
                    if (showCheck)
                      Icon(Icons.check_circle,
                          color: checkIconColor ?? Colors.green,
                          size: checkSize),
                    if (showScore)
                      Text(
                        '${m['score']}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: scoreFSize,
                        ),
                      ),
                  ],
                ],
              ),
              Divider(
                color: AppColors.grey.withOpacity(0.2),
                height: divH,
              ),
            ],
          )),
        ],
      ),
    );
  }
}