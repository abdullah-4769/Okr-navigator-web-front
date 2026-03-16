// lib/presentation/views/team_mode/role_screens/team_strategy_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/core/app_theme.dart';
import 'package:get/get.dart';

import '../../../controllers/journey_controller.dart';
import '../../../controllers/team_mode_controller/team_game_controller.dart';
import '../../../controllers/team_mode_controller/team_strategy_selection_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_cards_pagebuilder.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_svg.dart';
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

class TeamStrategySelectionScreen extends StatelessWidget {
  TeamStrategySelectionScreen({super.key});

  final TeamStrategySelectionController teamController =
  Get.put(TeamStrategySelectionController());
  final JourneyController journeyController = Get.find<JourneyController>();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    if (sw >= 768) return _buildDesktopLayout(context, sw, sh);
    return _buildMobileLayout(context, sw, sh);
  }

  // ── MOBILE — unchanged ─────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, double sw, double sh) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.d2.h),
                    child: Column(
                      children: [
                        SizedBox(height: sh * 0.02),
                        CustomHeader(
                          title: 'select'.tr,
                          highlightedText: 'strategy'.tr,
                          subtitle: '',
                          onBackTap: () => Get.offAllNamed(AppRoutes.teamLobby),
                        ),
                        SizedBox(height: sh * 0.01),
                        _buildTimerCard(context, sw),
                        SizedBox(height: sh * 0.015),
                        _buildBodyContent(context, sw, sh),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: sw * -0.07,
                top: sh * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, double sw, double sh) {
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
              title: 'select'.tr,
              subtitle: 'strategy'.tr,
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
                  child: Column(
                    children: [
                      _buildTimerCard(context, sw),
                      SizedBox(height: _dh(sw, 20)),
                      _buildBodyContent(context, sw, sh),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.offAllNamed(AppRoutes.teamLobby),
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

  // ── TIMER CARD ─────────────────────────────────────────────────────────────
  Widget _buildTimerCard(BuildContext context, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 0 : sw * 0.06),
      child: CustomObjectiveContainer(
        title: '',
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _d(sw, AppDimensions.d16),
            vertical: _dh(sw, AppDimensions.d8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'time_limit'.tr,
                style: appTheme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                ),
              ),
              Obx(() {
                final timerController = Get.find<TeamGameTimerController>();
                final totalSeconds = timerController.remainingSeconds.value;
                final minutes = totalSeconds ~/ 60;
                final seconds = totalSeconds % 60;
                return Text(
                  '$minutes:${seconds.toString().padLeft(2, '0')}',
                  style: appTheme.textTheme.titleLarge?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: _fs(sw, 20, desktop: 22),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── SHARED BODY ────────────────────────────────────────────────────────────
  Widget _buildBodyContent(BuildContext context, double sw, double sh) {
    return Column(
      children: [
        // Welcome texts
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 0 : sw * 0.041),
          child: Column(
            children: [
              Text(
                'welcome_team'.tr,
                style: appTheme.textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryRed,
                  fontFamily: 'Gotham-Bold',
                  fontSize: _fs(sw, 22, desktop: 24),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _dh(sw, 10)),
              Text(
                'draw_team_strategy_subtitle'.tr,
                style: appTheme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.black,
                  fontFamily: 'Gotham-Bold',
                  fontSize: _fs(sw, 16, desktop: 16),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: _dh(sw, 25)),

        // Cards
        CustomCardPagerBuilder(controller: teamController),

        SizedBox(height: _dh(sw, 25)),

        // Journey Map
        Obx(() => CustomJourneyMap(
          progress: journeyController.progress.value,
          steps: journeyController.steps,
          completedSteps: journeyController.completedSteps,
          onToggle: journeyController.toggleJourneyDetails,
          showDetails: journeyController.showDetails.value,
        )),

        SizedBox(height: _dh(sw, 25)),

        // Begin Mission Button
        Obx(() => Padding(
          padding: EdgeInsets.symmetric(
              horizontal: sw >= 768 ? 40.0 : sw * 0.12),
          child: CustomButton2(
            text: 'begin_mission'.tr,
            onPressed: teamController.isCardRevealed.value
                ? () => teamController.beginMission()
                : null,
          ),
        )),

        SizedBox(height: _dh(sw, 16)),
      ],
    );
  }
}