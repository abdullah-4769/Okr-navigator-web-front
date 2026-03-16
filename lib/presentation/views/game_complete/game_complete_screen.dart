import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../controllers/journey_controller.dart';
import '../../../core/responsive_helper.dart'; // ✅ new import
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/game_complete_widgets/achievement_summary.dart';
import '../../widgets/game_complete_widgets/custom_score_card.dart';
import '../../widgets/game_complete_widgets/performance_breakdown.dart';
import '../../widgets/game_complete_widgets/rewards_unlocked.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';


class GameCompleteScreen extends StatelessWidget {
  GameCompleteScreen({super.key});

  final JourneyController journeyController = Get.find<JourneyController>();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        final helper =
        ResponsiveHelper(constraints.maxWidth, constraints.maxHeight);

        if (helper.isMobile) {
          return _buildMobileLayout(context, helper);
        } else {
          return _buildDesktopWebLayout(context, helper);
        }
      },
    );

  /// ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(BuildContext context, ResponsiveHelper helper) {
    final width = helper.screenWidth;
    final height = helper.screenHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBackground(
        child: OrientationBuilder(
          builder: (context, orientation) => Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: helper.responsiveSpacing(0.015)),
                  child: Column(
                    children: [
                      CustomHeader(
                        title: 'game'.tr,
                        highlightedText: 'complete'.tr,
                        subtitle: '',
                        onBackTap: () => Get.back(),
                      ),
                      SizedBox(height: helper.responsiveSpacing(0.0025)),

                      CustomScoreCard(
                        score: 78,
                        title: "strategic_architect".tr,
                        description: "strategic_architect_desc".tr,
                      ),

                      SizedBox(height: helper.responsiveSpacing(0.025)),

                      PerformanceBreakdown(
                        points: 9,
                        totalPoints: 10,
                        items: [
                          BreakdownItem("strategy_selection".tr, "2/2", true),
                          BreakdownItem("objective_alignment".tr, "2/2", true),
                          BreakdownItem("key_results_quality".tr, "1/2", false),
                          BreakdownItem("initiative_relevance".tr, "2/2", true),
                          BreakdownItem("challenge_adaptation".tr, "2/2", true),
                        ],
                      ),
                      SizedBox(height: helper.responsiveSpacing(0.025)),

                      RewardsUnlocked(
                        badgeImage: "assets/images/badge.png",
                        badgeName: "Strategic Thinker",
                        titleImage: "assets/images/game.png",
                        titleName: "Master Adapter",
                        trophyImage: "assets/images/trophy.png",
                        trophyName: "Silver",
                      ),

                      SizedBox(height: helper.responsiveSpacing(0.025)),

                      Obx(() => CustomJourneyMap(
                        progress: journeyController.progress.value,
                        steps: journeyController.steps,
                        completedSteps: journeyController.completedSteps,
                        onToggle: journeyController.toggleJourneyDetails,
                        showDetails: journeyController.showDetails.value,
                      )),

                      SizedBox(height: helper.responsiveSpacing(0.025)),

                      AchievementSummary(
                        achievements: [
                          "completed_strategic_cycle".tr,
                          "adapted_market_challenge".tr,
                          "demonstrated_thinking_excellence".tr,
                          "earned_strategic_architect".tr,
                        ],
                      ),

                      SizedBox(height: helper.responsiveSpacing(0.04)),

                      CustomButton(
                        text: "play_again".tr,
                        icon: Icons.play_arrow,
                        onPressed: () {},
                      ),
                      SizedBox(height: 12.h),
                      CustomButton(
                        text: "view_badges".tr,
                        icon: Icons.badge_outlined,
                        onPressed: () {
                          Get.offAllNamed(AppRoutes.personalAchievementScreen);
                        },
                      ),
                      SizedBox(height: 12.h),
                      CustomButton(
                        text: "share_score".tr,
                        icon: Icons.score,
                        onPressed: () {},
                      ),

                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.strategyJourneyScreen);
                        },
                        child: Text(
                          "view_your_journey".tr,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                            fontSize: AppDimensions.d14.sp,
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: width * -0.07,
                top: height * 0.5,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ----------------- Desktop/Web Layout -----------------
  Widget _buildDesktopWebLayout(BuildContext context, ResponsiveHelper helper) {
    final height = helper.screenHeight;
    final width = helper.screenWidth;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DesktopAppBar(screenWidth: width, screenHeight: height, title: 'game', subtitle: 'complete',),
          ),
          Center(
            child: Container(
              width: helper.containerWidth(),
              height: height,
              margin: const EdgeInsets.only(top: 120),
              padding: EdgeInsets.all(helper.containerPadding()),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: helper.responsiveSpacing(0.015)),
                child: Column(
                  children: [
                    CustomScoreCard(
                      score: 78,
                      title: "strategic_architect".tr,
                      description: "strategic_architect_desc".tr,
                    ),
                    SizedBox(height: helper.responsiveSpacing(0.025)),

                    PerformanceBreakdown(
                      points: 9,
                      totalPoints: 10,
                      items: [
                        BreakdownItem("strategy_selection".tr, "2/2", true),
                        BreakdownItem("objective_alignment".tr, "2/2", true),
                        BreakdownItem("key_results_quality".tr, "1/2", false),
                        BreakdownItem("initiative_relevance".tr, "2/2", true),
                        BreakdownItem("challenge_adaptation".tr, "2/2", true),
                      ],
                    ),
                    SizedBox(height: helper.responsiveSpacing(0.025)),

                    RewardsUnlocked(
                      badgeImage: "assets/images/badge.png",
                      badgeName: "Strategic Thinker",
                      titleImage: "assets/images/game.png",
                      titleName: "Master Adapter",
                      trophyImage: "assets/images/trophy.png",
                      trophyName: "Silver",
                    ),
                    SizedBox(height: helper.responsiveSpacing(0.025)),

                    Obx(() => CustomJourneyMap(
                      progress: journeyController.progress.value,
                      steps: journeyController.steps,
                      completedSteps: journeyController.completedSteps,
                      onToggle: journeyController.toggleJourneyDetails,
                      showDetails: journeyController.showDetails.value,
                    )),
                    SizedBox(height: helper.responsiveSpacing(0.025)),

                    AchievementSummary(
                      achievements: [
                        "completed_strategic_cycle".tr,
                        "adapted_market_challenge".tr,
                        "demonstrated_thinking_excellence".tr,
                        "earned_strategic_architect".tr,
                      ],
                    ),

                    SizedBox(height: helper.responsiveSpacing(0.04)),

                    CustomButton(
                      text: "play_again".tr,
                      icon: Icons.play_arrow,
                      onPressed: () {},
                    ),
                    SizedBox(height: 12.h),
                    CustomButton(
                      text: "view_badges".tr,
                      icon: Icons.badge_outlined,
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.personalAchievementScreen);
                      },
                    ),
                    SizedBox(height: 12.h),
                    CustomButton(
                      text: "share_score".tr,
                      icon: Icons.score,
                      onPressed: () {},
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.strategyJourneyScreen);
                      },
                      child: Text(
                        "view_your_journey".tr,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                          fontSize: AppDimensions.d14.sp,
                          color: AppColors.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ----------------- Responsive Helpers -----------------
  double _getResponsiveSpacing(double dimension, double factor) => dimension * factor;

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1200) return screenWidth * 0.08;
    if (screenWidth > 900) return screenWidth * 0.06;
    if (screenWidth > 600) return screenWidth * 0.05;
    return screenWidth * 0.04;
  }

  double _getContentPadding(double screenWidth, bool isTablet) {
    if (isTablet) return screenWidth * 0.07;
    return screenWidth * 0.03;
  }



  double _getTitleFontSize(double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return (screenWidth * 0.005).sp;
    if (isTablet) return (screenWidth * 0.004).sp;
    return (screenWidth * 0.045).sp;
  }

  double _getSubtitleFontSize(double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return (screenWidth * 0.0022).sp;
    if (isTablet) return (screenWidth * 0.0026).sp;
    return (screenWidth * 0.028).sp;
  }


  double _getButtonPadding(double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return screenWidth * 0.025;
    if (isTablet) return screenWidth * 0.015;
    return screenWidth * 0.1;
  }
}
