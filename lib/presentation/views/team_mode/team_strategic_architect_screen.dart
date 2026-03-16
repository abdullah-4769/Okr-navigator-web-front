// lib/presentation/views/team_mode/team_strategic_architect_screen2.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/team_mode_controller/team_strategic_architect_controller.dart';
import '../../../core/app_colors.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/game_complete_widgets/achievement_summary.dart';
import '../../widgets/game_complete_widgets/custom_score_card.dart';
import '../../widgets/game_complete_widgets/performance_breakdown.dart';
import '../../widgets/game_complete_widgets/rewards_unlocked.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class TeamStrategicArchitectScreen2 extends StatelessWidget {
  const TeamStrategicArchitectScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeamStrategicArchitectController>();
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    if (sw >= 768) return _buildDesktopLayout(context, sw, sh, controller);
    return _buildMobileLayout(context, sw, sh, controller);
  }

  // ── MOBILE — unchanged ─────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, double sw, double sh,
      TeamStrategicArchitectController controller) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: sh * 0.015),
                child: _buildContent(context, sw, sh, controller),
              ),
            ),
            Positioned(
              right: sw * -0.07,
              top: sh * 0.5,
              child: const CustomHomeNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, double sw, double sh,
      TeamStrategicArchitectController controller) {
    final double containerWidth = sw > 1200 ? 720.0 : sw * 0.72;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/web_background.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw, screenHeight: sh,
              title: 'game'.tr,
              subtitle: 'complete'.tr,
            ),
          ),
          Positioned(
            top: 110, left: 0, right: 0, bottom: 80,
            child: Center(
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 8),
                  )],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(36),
                  child: _buildContent(context, sw, sh, controller),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: ''),
            ),
          ),
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ── SHARED CONTENT ─────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, double sw, double sh,
      TeamStrategicArchitectController controller) {
    return Column(
      children: [
        if (sw < 768) ...[
          CustomHeader(
            title: 'game'.tr,
            highlightedText: 'complete'.tr,
            subtitle: '',
            onBackTap: () => Get.back(),
          ),
          SizedBox(height: sh * 0.025),
        ] else
          SizedBox(height: _dh(sw, 8)),

        // Score Card
        Obx(() => CustomScoreCard(
          score: controller.score.value,
          title: 'strategic_architect'.tr,
          description: 'strategic_architect_desc'.tr,
        )),

        SizedBox(height: _dh(sw, 28)),

        // Performance Breakdown
        Obx(() => PerformanceBreakdown(
          points: controller.points.value,
          totalPoints: controller.totalPoints.value,
          items: controller.breakdownItems
              .map((item) => BreakdownItem(item['title'], item['score'], item['success']))
              .toList(),
        )),

        SizedBox(height: _dh(sw, 28)),

        // Rewards Unlocked
        Obx(() => RewardsUnlocked(
          badgeImage: 'assets/images/badge.png',
          badgeName: controller.badges.isNotEmpty ? controller.badges[0] : 'strategic_thinker'.tr,
          titleImage: 'assets/images/game.png',
          titleName: controller.titles.isNotEmpty ? controller.titles[0] : 'master_adapter'.tr,
          trophyImage: 'assets/images/trophy.png',
          trophyName: controller.trophy.value,
        )),

        SizedBox(height: _dh(sw, 28)),

        // Journey Map
        Obx(() => CustomJourneyMap(
          progress: 100.0,
          steps: [
            'strategy_selection'.tr,
            'objective_selection'.tr,
            'key_result_selection'.tr,
            'initiatives_suggestion'.tr,
            'result_performance'.tr,
          ],
          completedSteps: const [true, true, true, true, true],
          onToggle: controller.toggleJourneyDetails,
          showDetails: controller.showJourneyDetails.value,
        )),

        SizedBox(height: _dh(sw, 28)),

        // Achievement Summary
        Obx(() => AchievementSummary(
          achievements: controller.achievements.toList(),
        )),

        SizedBox(height: _dh(sw, 40)),

        // Action Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: Column(
            children: [
              CustomButton(
                text: 'play_again'.tr,
                icon: Icons.play_arrow,
                onPressed: controller.playAgain,
              ),
              SizedBox(height: _dh(sw, 12)),
              CustomButton(
                text: 'view_badges'.tr,
                icon: Icons.badge_outlined,
                onPressed: controller.viewBadges,
              ),
              SizedBox(height: _dh(sw, 12)),
              CustomButton(
                text: 'share_score'.tr,
                icon: Icons.share,
                onPressed: controller.shareScore,
              ),
            ],
          ),
        ),

        SizedBox(height: _dh(sw, 16)),

        GestureDetector(
          onTap: controller.viewJourney,
          child: Text(
            'view_your_journey'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        SizedBox(height: _dh(sw, 16)),
      ],
    );
  }
}