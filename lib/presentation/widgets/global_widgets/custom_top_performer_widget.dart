import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/widgets_controllers/top_performer_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';

class CustomTopPerformerWidget extends StatelessWidget {
  CustomTopPerformerWidget({super.key});

  final TopPerformerController controller = Get.put(TopPerformerController());

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final size = media.size;
    final isPortrait = size.height > size.width;

    // Determine device type for responsive design
    bool isMobile = screenWidth < 768;
    bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    bool isDesktop = screenWidth >= 1024;

    // Responsive dimensions based on screen size
    double getResponsiveDimension(double mobile, double tablet, double desktop) {
      if (isMobile) return mobile;
      if (isTablet) return tablet;
      return desktop;
    }

    // Overall padding responsive
    double overallPadding = getResponsiveDimension(12.0, 16.0, 20.0);
    double verticalSpacing = getResponsiveDimension(16.0, 20.0, 24.0);

    // Tab container responsive
    double tabContainerPadding = getResponsiveDimension(4.0, 6.0, 8.0);
    double tabBorderRadius = getResponsiveDimension(12.0, 16.0, 18.0);
    double tabButtonHorizontalPadding = getResponsiveDimension(12.0, 15.0, 18.0);
    double tabButtonVerticalPadding = getResponsiveDimension(8.0, 10.0, 12.0);
    double tabButtonBorderRadius = getResponsiveDimension(8.0, 12.0, 14.0);
    double tabFontSize = getResponsiveDimension(12.0, 14.0, 16.0);

    // Podium responsive
    double podiumMaxWidth = isDesktop ? 900.0 : double.infinity;
    double blockWidthAdjustment = getResponsiveDimension(12.0, 16.0, 20.0);
    double podiumHeightMultiplier1st = getResponsiveDimension(
        isPortrait ? 0.22 : 0.28, // Mobile
        0.24, // Tablet
        0.26  // Desktop
    );
    double podiumHeightMultiplier2nd = getResponsiveDimension(
        isPortrait ? 0.16 : 0.21, // Mobile
        0.18, // Tablet
        0.20  // Desktop
    );
    double podiumHeightMultiplier3rd = getResponsiveDimension(
        isPortrait ? 0.14 : 0.18, // Mobile
        0.16, // Tablet
        0.18  // Desktop
    );
    double podiumBlockBorderRadius = getResponsiveDimension(8.0, 12.0, 16.0);
    double podiumShadowBlur = getResponsiveDimension(6.0, 8.0, 12.0);
    double podiumShadowOffsetY = getResponsiveDimension(3.0, 4.0, 5.0);

    // Avatar and rank responsive
    double avatarPadding = getResponsiveDimension(4.0, 6.0, 8.0);
    double avatarSize = getResponsiveDimension(40.0, 55.0, 65.0);
    double avatarBorderWidth = getResponsiveDimension(1.5, 2.0, 2.5);
    double rankBadgePadding = getResponsiveDimension(3.0, 4.0, 5.0);
    double rankFontSize = getResponsiveDimension(10.0, 12.0, 14.0);
    double avatarToPodiumSpacing = getResponsiveDimension(6.0, 8.0, 10.0);

    // Podium content responsive
    double scoreFontSize = getResponsiveDimension(14.0, 18.0, 22.0);
    double nameFontSize = getResponsiveDimension(12.0, 14.0, 16.0);
    double contentVerticalSpacing = getResponsiveDimension(4.0, 6.0, 8.0);
    double podiumBlockWidth = getResponsiveDimension(80.0, 100.0, 120.0); // Fallback for block width

    return Padding(
      padding: EdgeInsets.all(overallPadding),
      child: Column(
        children: [
          /// 🔥 Timeframe Tabs
          Obx(
                () => Container(
              padding: EdgeInsets.all(tabContainerPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(tabBorderRadius),
                border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                boxShadow: isDesktop ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ] : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  {"key": "today", "label": "today".tr},
                  {"key": "this_week", "label": "this_week".tr},
                  {"key": "this_month", "label": "this_month".tr},
                ].map((tab) {
                  final isSelected = controller.selectedTimeframe.value == tab["key"];
                  return GestureDetector(
                    onTap: () => controller.changeTimeframe(tab["key"]!),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: tabButtonHorizontalPadding,
                        vertical: tabButtonVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryRed : Colors.white,
                        borderRadius: BorderRadius.circular(tabButtonBorderRadius),
                        border: isSelected ? null : Border.all(color: AppColors.primaryRed, width: 1.0),
                      ),
                      child: Text(
                        tab["label"]!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                          fontSize: tabFontSize,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: verticalSpacing),

          /// 🔥 Podium Section
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: podiumMaxWidth),
            child: Obx(() {
              if (controller.performers.isEmpty) {
                return Center(
                  child: Text(
                    "No data".tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: getResponsiveDimension(14.0, 16.0, 18.0),
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              final performers = controller.performers;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final blockWidth = ((maxWidth - (blockWidthAdjustment * 2)) / 3).clamp(podiumBlockWidth * 0.8, podiumBlockWidth);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      /// 🥈 2nd
                      Flexible(
                        child: _buildPodiumTile(
                          name: performers[1]["name"],
                          score: performers[1]["score"],
                          level: performers[1]["level"],
                          rank: 2,
                          height: screenHeight * podiumHeightMultiplier2nd,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: blockWidth,
                          avatarSize: avatarSize,
                          scoreFontSize: scoreFontSize,
                          nameFontSize: nameFontSize,
                          contentSpacing: contentVerticalSpacing,
                          borderRadius: podiumBlockBorderRadius,
                          shadowBlur: podiumShadowBlur,
                          shadowOffsetY: podiumShadowOffsetY,
                          avatarPadding: avatarPadding,
                          avatarBorderWidth: avatarBorderWidth,
                          rankPadding: rankBadgePadding,
                          rankFontSize: rankFontSize,
                          avatarToPodiumSpacing: avatarToPodiumSpacing,
                        ),
                      ),

                      /// 🥇 1st
                      Flexible(
                        child: _buildPodiumTile(
                          name: performers[0]["name"],
                          score: performers[0]["score"],
                          level: performers[0]["level"],
                          rank: 1,
                          height: screenHeight * podiumHeightMultiplier1st,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF176), Color(0xFFFBC02D)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: blockWidth,
                          avatarSize: avatarSize,
                          scoreFontSize: scoreFontSize,
                          nameFontSize: nameFontSize,
                          contentSpacing: contentVerticalSpacing,
                          borderRadius: podiumBlockBorderRadius,
                          shadowBlur: podiumShadowBlur,
                          shadowOffsetY: podiumShadowOffsetY,
                          avatarPadding: avatarPadding,
                          avatarBorderWidth: avatarBorderWidth,
                          rankPadding: rankBadgePadding,
                          rankFontSize: rankFontSize,
                          avatarToPodiumSpacing: avatarToPodiumSpacing,
                        ),
                      ),

                      /// 🥉 3rd
                      Flexible(
                        child: _buildPodiumTile(
                          name: performers[2]["name"],
                          score: performers[2]["score"],
                          level: performers[2]["level"],
                          rank: 3,
                          height: screenHeight * podiumHeightMultiplier3rd,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: blockWidth,
                          avatarSize: avatarSize,
                          scoreFontSize: scoreFontSize,
                          nameFontSize: nameFontSize,
                          contentSpacing: contentVerticalSpacing,
                          borderRadius: podiumBlockBorderRadius,
                          shadowBlur: podiumShadowBlur,
                          shadowOffsetY: podiumShadowOffsetY,
                          avatarPadding: avatarPadding,
                          avatarBorderWidth: avatarBorderWidth,
                          rankPadding: rankBadgePadding,
                          rankFontSize: rankFontSize,
                          avatarToPodiumSpacing: avatarToPodiumSpacing,
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 🔥 Podium Tile Builder
  Widget _buildPodiumTile({
    required String name,
    required int score,
    required int level,
    required int rank,
    required double height,
    required Gradient gradient,
    required double width,
    required double avatarSize,
    required double scoreFontSize,
    required double nameFontSize,
    required double contentSpacing,
    required double borderRadius,
    required double shadowBlur,
    required double shadowOffsetY,
    required double avatarPadding,
    required double avatarBorderWidth,
    required double rankPadding,
    required double rankFontSize,
    required double avatarToPodiumSpacing,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        /// Avatar + Rank
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(avatarPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryRed, width: avatarBorderWidth),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: shadowBlur * 0.8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                "assets/images/solo.svg",
                height: avatarSize,
                width: avatarSize,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(rankPadding),
                decoration: BoxDecoration(
                  color: rank == 1 ? AppColors.primaryRed : Colors.black87,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4.0,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: Text(
                  "$rank",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: rankFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: avatarToPodiumSpacing),

        /// Podium Block
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: Offset(2, shadowOffsetY),
                blurRadius: shadowBlur,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "⭐\n$score",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: scoreFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(height: contentSpacing),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(height: contentSpacing * 0.5),
            ],
          ),
        ),
      ],
    );
  }
}