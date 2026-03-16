// lib/presentation/views/team_mode/team_strategy_journey_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/team_mode_controller/team_strategy_journey_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/game_complete_widgets/achievement_summary.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import '../../widgets/strategic_icons_show.dart';
import '../screens_after_complete_game/section_card.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class TeamStrategyJourneyScreen extends StatelessWidget {
  const TeamStrategyJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TeamStrategyJourneyController.getOrPut();
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    if (sw >= 768) return _buildDesktopLayout(context, sw, sh, controller);
    return _buildMobileLayout(context, sw, sh, controller);
  }

  // ── MOBILE — unchanged ─────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, double sw, double sh,
      TeamStrategyJourneyController controller) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: sh * 0.014),
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
      TeamStrategyJourneyController controller) {
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
              title: 'strategic'.tr,
              subtitle: 'journey'.tr,
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
      TeamStrategyJourneyController controller) {
    return Column(
      children: [
        if (sw < 768) ...[
          CustomHeader(
            title: 'strategic'.tr,
            highlightedText: 'journey'.tr,
            subtitle: '',
            onBackTap: () => Get.back(),
          ),
          SizedBox(height: sh * 0.02),
        ] else
          SizedBox(height: _dh(sw, 8)),

        // Strategic icon cluster
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: StrategicIconsShow(),
        ),

        SizedBox(height: _dh(sw, 20)),

        // Key Strengths
        Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 16)),
          child: SectionCard(
            icon: Icons.thumb_up,
            borderColor: AppColors.primaryRed,
            title: 'key_strengths',
            items: controller.strengths.toList(),
          ),
        )),

        SizedBox(height: _dh(sw, 12)),

        // Growth Opportunities
        Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 16)),
          child: SectionCard(
            icon: Icons.trending_up,
            borderColor: const Color(0xFFF0B400),
            title: 'growth_opportunities',
            items: controller.growthOpportunities.toList(),
          ),
        )),

        SizedBox(height: _dh(sw, 12)),

        // Achievement Summary
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 12)),
          child: AchievementSummary(
            achievements: controller.achievements.toList(),
          ),
        ),

        SizedBox(height: _dh(sw, 32)),

        // Action Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : AppDimensions.d24.w),
          child: Column(
            children: [
              CustomButton(
                text: 'play_again'.tr,
                onPressed: () => controller.resetJourney(),
              ),
              SizedBox(height: _dh(sw, 12)),
              CustomButton(
                text: 'go_to_dashboard'.tr,
                onPressed: () => Get.offNamed(AppRoutes.teamDashboard),
                backgroundColor: AppColors.primaryBlue,
              ),
              SizedBox(height: _dh(sw, 12)),
              CustomButton(
                text: 'bonus_case_study_mode'.tr,
                onPressed: () {},
              ),
            ],
          ),
        ),

        SizedBox(height: _dh(sw, 40)),
      ],
    );
  }
}