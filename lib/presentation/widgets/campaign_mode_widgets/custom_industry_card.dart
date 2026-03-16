import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/app_colors.dart';

class CustomIndustryCard extends StatelessWidget {
  final String orgTitle;
  final String subTitle;
  final String bottomTitle;
  final String? strategyText;
  final String? challengeText;
  final String imagePath;
  final bool isUnlocked;
  final VoidCallback? onStart;
  final bool showPlayButton;

  const CustomIndustryCard({
    super.key,
    required this.orgTitle,
    required this.subTitle,
    required this.bottomTitle,
    this.strategyText,
    this.challengeText,
    required this.imagePath,
    required this.isUnlocked,
    this.onStart,
    this.showPlayButton = true,
  });

  // ── Adaptive helpers ───────────────────────────────────────────────────────
  // Plain logical px on desktop/tablet — .sp/.w/.h only on mobile.
  static double _fs(double sw, double mobile,
      {double? tablet, double? desktop}) {
    if (sw >= 1024) return desktop ?? tablet ?? mobile - 2;
    if (sw >= 768) return tablet ?? mobile - 1;
    return mobile.sp;
  }

  static double _d(double sw, double mobile,
      {double? tablet, double? desktop}) {
    if (sw >= 1024) return desktop ?? tablet ?? mobile - 2;
    if (sw >= 768) return tablet ?? mobile - 1;
    return mobile.w; // spacing/padding uses .w on mobile
  }

  @override
  Widget build(BuildContext context) {
    // ✅ MediaQuery — reliable even inside fixed-width cards
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 1024;
    final bool isTablet = sw >= 768 && sw < 1024;
    final bool isMobile = sw < 768;

    // ── Dimensions ─────────────────────────────────────────────────────────
    final double outerPadding  = _d(sw, 14, tablet: 14, desktop: 14);
    final double outerVMargin  = isMobile ? 10.h : 8.0;
    final double outerHMargin  = isMobile ? 4.w  : 0.0; // card fills Expanded on desktop
    final double borderRadius  = isMobile ? 18.r  : isTablet ? 16.0 : 14.0;
    final double innerRadius   = isMobile ? 12.r  : isTablet ? 10.0 : 10.0;
    final double avatarRadius  = isMobile ? 18.r  : isTablet ? 16.0 : 15.0;
    final double avatarBorder  = isMobile ? 2.w   : 2.0;
    final double circleSize    = isMobile ? 22.w  : isTablet ? 20.0 : 20.0;
    final double lockIconSize  = _fs(sw, 14, tablet: 13, desktop: 12);
    final double tagIconSize   = _fs(sw, 16, tablet: 14, desktop: 13);
    final double eventIconSize = _fs(sw, 14, tablet: 13, desktop: 13);
    final double playIconSize  = _fs(sw, 18, tablet: 16, desktop: 14);
    final double playRadius    = isMobile ? 10.r  : isTablet ? 9.0 : 9.0;
    final double spacingS      = isMobile ? 4.w   : 4.0;
    final double spacingM      = isMobile ? 10.w  : 10.0;
    final double spacingL      = isMobile ? 14.w  : 12.0;
    final double spacingV      = isMobile ? 12.h  : 10.0;
    final double spacingVS     = isMobile ? 14.h  : 10.0;
    final double bottomPadH    = isMobile ? 14.w  : 12.0;
    final double bottomPadV    = isMobile ? 10.h  : 9.0;

    // ── Font sizes ──────────────────────────────────────────────────────────
    final double titleSize    = _fs(sw, 14, tablet: 13, desktop: 13);
    final double subtitleSize = _fs(sw, 12, tablet: 11, desktop: 11);
    final double tagSize      = _fs(sw, 10, tablet: 10, desktop: 10);
    final double bottomSize   = _fs(sw, 10, tablet: 10, desktop: 10);
    final double btnLabelSize = _fs(sw, 12, tablet: 11, desktop: 11);

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: outerVMargin, horizontal: outerHMargin),
      padding: EdgeInsets.all(outerPadding),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.softRed.withOpacity(0.15)
            : AppColors.grey.withOpacity(0.2),
        border: Border.all(
          color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: avatar + titles + lock circle ───────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                padding: EdgeInsets.all(avatarBorder),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
                    width: 2,
                  ),
                ),
                child: ColorFiltered(
                  colorFilter: isUnlocked
                      ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply)
                      : const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ]),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: AssetImage(imagePath),
                    backgroundColor: Colors.yellow,
                  ),
                ),
              ),

              SizedBox(width: spacingM),

              // Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgTitle,
                      style: TextStyle(
                        color: isUnlocked ? AppColors.black : AppColors.grey,
                        fontSize: titleSize, // ✅ adaptive
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subTitle,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: subtitleSize, // ✅ adaptive
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Lock / unlocked circle
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? AppColors.primaryRed
                      : Colors.transparent,
                  border: Border.all(
                    color:
                    isUnlocked ? AppColors.primaryRed : AppColors.grey,
                    width: 1.5,
                  ),
                ),
                child: isUnlocked
                    ? null
                    : Icon(Icons.lock,
                    size: lockIconSize, // ✅ adaptive
                    color: AppColors.grey),
              ),
            ],
          ),

          SizedBox(height: spacingV),

          // ── Tags row ─────────────────────────────────────────────────────
          if (strategyText != null || challengeText != null) ...[
            Row(
              children: [
                if (strategyText != null) ...[
                  Icon(
                    Icons.menu_book,
                    size: tagIconSize, // ✅ adaptive
                    color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
                  ),
                  SizedBox(width: spacingS),
                  Flexible(
                    child: Text(
                      strategyText!,
                      style: TextStyle(
                        color: isUnlocked
                            ? AppColors.primaryRed
                            : AppColors.grey,
                        fontSize: tagSize, // ✅ adaptive
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (challengeText != null &&
                    challengeText!.isNotEmpty) ...[
                  SizedBox(width: spacingL),
                  Icon(
                    Icons.flag,
                    size: tagIconSize, // ✅ adaptive
                    color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
                  ),
                  SizedBox(width: spacingS),
                  Flexible(
                    child: Text(
                      challengeText!,
                      style: TextStyle(
                        color: isUnlocked
                            ? AppColors.primaryRed
                            : AppColors.grey,
                        fontSize: tagSize, // ✅ adaptive
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: spacingVS),
          ],

          // ── Bottom container ──────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: bottomPadH, vertical: bottomPadV),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.yellow.withOpacity(0.3)
                  : AppColors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(innerRadius),
              border: Border.all(
                color: isUnlocked
                    ? Colors.yellow.withOpacity(0.5)
                    : AppColors.grey.withOpacity(0.15),
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
                  size: eventIconSize, // ✅ adaptive
                ),
                SizedBox(width: spacingM),
                Expanded(
                  child: Text(
                    bottomTitle,
                    style: TextStyle(
                      color: isUnlocked
                          ? AppColors.textSecondary
                          : AppColors.grey,
                      fontSize: bottomSize, // ✅ adaptive
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Play / Locked button
                if (showPlayButton) ...[
                  SizedBox(width: spacingS),
                  GestureDetector(
                    onTap: isUnlocked ? onStart : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isUnlocked ? 'Start' : 'Locked',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w700,
                            fontSize: btnLabelSize, // ✅ adaptive
                          ),
                        ),
                        SizedBox(width: spacingS),
                        CircleAvatar(
                          radius: playRadius,
                          backgroundColor: isUnlocked
                              ? AppColors.primaryRed
                              : AppColors.grey,
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: playIconSize, // ✅ adaptive
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../core/app_colors.dart';
//
// class CustomIndustryCard extends StatelessWidget {
//   final String orgTitle;       // Organization Name
//   final String subTitle;       // Subtitle (Phase, Level, etc.)
//   final String bottomTitle;    // Bottom text (Objectives)
//   final String? strategyText;  // Optional strategy text
//   final String? challengeText; // Optional challenge text
//   final String imagePath;      // Avatar image
//   final bool isUnlocked;       // State (locked/unlocked)
//   final VoidCallback? onStart; // Start Button callback (only if unlocked)
//   final bool showPlayButton;   // 🔹 NEW: flag to show/hide play button
//
//   const CustomIndustryCard({
//     super.key,
//     required this.orgTitle,
//     required this.subTitle,
//     required this.bottomTitle,
//     this.strategyText,
//     this.challengeText,
//     required this.imagePath,
//     required this.isUnlocked,
//     this.onStart,
//     this.showPlayButton = true, // default true (backward compatible)
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
//     padding: EdgeInsets.all(14.w),
//     decoration: BoxDecoration(
//       color: isUnlocked
//           ? AppColors.softRed.withOpacity(0.15)
//           : AppColors.grey.withOpacity(0.2),
//       border: Border.all(
//         color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
//         width: 1.5,
//       ),
//       borderRadius: BorderRadius.circular(18.r),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// 🔹 Top Row (Avatar + Titles + Circle)
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Avatar with border + greyscale when locked
//             Container(
//               padding: EdgeInsets.all(2.w),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
//                   width: 2,
//                 ),
//               ),
//               child: ColorFiltered(
//                 colorFilter: isUnlocked
//                     ? const ColorFilter.mode(
//                     Colors.transparent, BlendMode.multiply)
//                     : const ColorFilter.matrix(<double>[
//                   0.2126, 0.7152, 0.0722, 0, 0,
//                   0.2126, 0.7152, 0.0722, 0, 0,
//                   0.2126, 0.7152, 0.0722, 0, 0,
//                   0, 0, 0, 1, 0,
//                 ]),
//                 child: CircleAvatar(
//                   radius: 18.r,
//                   backgroundImage: AssetImage(imagePath),
//                   backgroundColor: Colors.yellow,
//                 ),
//               ),
//             ),
//             SizedBox(width: 10.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     orgTitle,
//                     style: TextStyle(
//                       color: isUnlocked ? AppColors.black : AppColors.grey,
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     subTitle,
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 12.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // 🔹 Right circle with lock
//             Container(
//               width: 22.w,
//               height: 22.w,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color:
//                 isUnlocked ? AppColors.primaryRed : Colors.transparent,
//                 border: Border.all(
//                   color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
//                   width: 1.5,
//                 ),
//               ),
//               child: isUnlocked
//                   ? null
//                   : Icon(Icons.lock, size: 14.sp, color: AppColors.grey),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 12.h),
//
//         /// 🔹 Tags Row (Optional)
//         if (strategyText != null || challengeText != null)
//           Row(
//             children: [
//               if (strategyText != null) ...[
//                 Icon(Icons.menu_book,
//                     size: 16.sp,
//                     color:
//                     isUnlocked ? AppColors.primaryRed : AppColors.grey),
//                 SizedBox(width: 4.w),
//                 Text(
//                   strategyText!,
//                   style: TextStyle(
//                       color: isUnlocked
//                           ? AppColors.primaryRed
//                           : AppColors.grey,
//                       fontSize: 10.sp),
//                 ),
//               ],
//               if (challengeText != null) ...[
//                 SizedBox(width: 14.w),
//                 Icon(Icons.flag,
//                     size: 16.sp,
//                     color:
//                     isUnlocked ? AppColors.primaryRed : AppColors.grey),
//                 SizedBox(width: 4.w),
//                 Text(
//                   challengeText!,
//                   style: TextStyle(
//                       color: isUnlocked
//                           ? AppColors.primaryRed
//                           : AppColors.grey,
//                       fontSize: 10.sp),
//                 ),
//               ],
//             ],
//           ),
//
//         if (strategyText != null || challengeText != null)
//           SizedBox(height: 14.h),
//
//         /// 🔹 Bottom Container (Objectives + Start/Locked Btn)
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//           decoration: BoxDecoration(
//             color: isUnlocked
//                 ? Colors.yellow.withValues(alpha: 0.3)
//                 : AppColors.grey.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: isUnlocked
//                   ? Colors.yellow.withValues(alpha: 0.5)
//                   : AppColors.grey.withOpacity(0.15),
//               width: 2.0,
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.emoji_events,
//                   color: isUnlocked ? AppColors.primaryRed : AppColors.grey,
//                   size: 14.sp),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: Text(
//                   bottomTitle,
//                   style: TextStyle(
//                     color: isUnlocked
//                         ? AppColors.textSecondary
//                         : AppColors.grey,
//                     fontSize: 10.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//
//               /// 🔹 Show Play Button only if `showPlayButton == true`
//               if (showPlayButton)
//                 GestureDetector(
//                   onTap: isUnlocked ? onStart : null,
//                   child: Row(
//                     children: [
//                       Text(
//                         isUnlocked ? "Start" : "Locked",
//                         style: TextStyle(
//                           color: AppColors.primaryRed, // 🔴 Always red
//                           fontWeight: FontWeight.w700,
//                           fontSize: 12.sp,
//                         ),
//                       ),
//                       SizedBox(width: 6.w),
//                       CircleAvatar(
//                         radius: 10.r,
//                         backgroundColor: isUnlocked
//                             ? AppColors.primaryRed
//                             : AppColors.grey,
//                         child: Icon(Icons.play_arrow,
//                             color: Colors.white, size: 18.sp),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }
