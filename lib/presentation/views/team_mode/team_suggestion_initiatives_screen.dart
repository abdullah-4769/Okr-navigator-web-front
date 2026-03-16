// lib/presentation/views/team_mode/team_suggestion_initiatives_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/journey_controller.dart';
import '../../../controllers/team_mode_controller/team_game_controller.dart';
import '../../../controllers/team_mode_controller/team_suggestion_initiative_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../core/app_theme.dart';
import '../../../generated/models/responses/key_results/key_results_response.dart' hide Text;
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_ai_strategy_container.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_industry_container.dart';
import '../../widgets/custom_initiative_input.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/responsive_arrow.dart';
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

class TeamSuggestionInitiativesScreen extends StatelessWidget {
  TeamSuggestionInitiativesScreen({
    super.key,
    required List selectedKeyResults,
  }) {
    final args = Get.arguments as Map<String, dynamic>?;
    final List<KeyResult> keyResults =
        (args?['selectedKeyResults'] as List<KeyResult>?) ?? [];
    Get.put(TeamSuggestionInitiativesController(keyResults: keyResults));
  }

  final JourneyController journeyController = Get.find<JourneyController>();
  TeamSuggestionInitiativesController get controller =>
      Get.find<TeamSuggestionInitiativesController>();

  String _safeTranslate(String? text, {String fallback = ''}) {
    if (text == null || text.isEmpty) return fallback;
    try {
      if (text.contains(' ')) return text;
      return text.tr;
    } catch (_) { return text; }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    // Defensive check
    if (controller.keyResults.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('error'.tr, 'key_results_missing'.tr);
        Get.offNamed(AppRoutes.teamKeyResultScreen);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final firstKR = controller.keyResults.first;
    final firstKRDescription =
    _safeTranslate(firstKR.description, fallback: 'detail_not_available'.tr);

    if (sw >= 768) {
      return _buildDesktopLayout(context, sw, sh, firstKRDescription);
    }
    return _buildMobileLayout(context, sw, sh, firstKRDescription);
  }

  // ── MOBILE — unchanged ─────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, double sw, double sh,
      String firstKRDescription) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: sh * 0.01),
                  child: _buildContent(context, sw, sh, firstKRDescription),
                ),
              ),
              Positioned(
                right: sw * -0.05,
                top: sh * 0.5,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, double sw, double sh,
      String firstKRDescription) {
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
              title: 'suggestion'.tr,
              subtitle: 'of_initiatives'.tr,
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
                  child: _buildContent(context, sw, sh, firstKRDescription),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.teamKeyResultScreen),
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
      String firstKRDescription) {
    return Column(
      children: [
        // Header — only in mobile (desktop uses DesktopAppBar)
        if (sw < 768)
          CustomHeader(
            title: 'suggestion'.tr,
            highlightedText: 'of_initiatives'.tr,
            showDashboardIcon: true,
            onBackTap: () => Get.toNamed(AppRoutes.teamKeyResultScreen),
          ),

        SizedBox(height: _dh(sw, 20)),

        // Timer
        Padding(
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
                        color: AppColors.grey),
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
        ),

        SizedBox(height: _dh(sw, 20)),

        // First KR description container
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 0 : sw * 0.06),
          child: CustomObjectiveContainer(
            title: '',
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(_d(sw, AppDimensions.d8)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6, offset: const Offset(0, 3),
                    )],
                  ),
                  child: Icon(Icons.rocket,
                      color: Colors.white,
                      size: sw >= 768 ? 20.0 : AppDimensions.d20.sp),
                ),
                SizedBox(width: _d(sw, AppDimensions.d10)),
                Expanded(
                  child: Text(
                    firstKRDescription,
                    style: appTheme.textTheme.bodySmall?.copyWith(
                      color: AppColors.black.withValues(alpha: 0.7),
                      fontSize: _fs(sw, 13, desktop: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: _dh(sw, 15)),
        const ResponsiveArrow(),
        SizedBox(height: _dh(sw, 20)),

        // Key Results list
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 0 : 16.w),
          child: Obx(() {
            if (controller.industries.isEmpty) return const SizedBox.shrink();
            return Column(
              children: controller.keyResults.map((kr) => Padding(
                padding: EdgeInsets.only(bottom: _dh(sw, 8)),
                child: CustomIndustryContainer(
                  showSelectionCircle: false,
                  title: '',
                  description: _safeTranslate(kr.description),
                  icon: Icons.key,
                  isSelected: false,
                  onTap: () {},
                  showTag1: true,
                  tag1Icon: Icons.trending_up,
                  tag1Text: 'goal'.tr,
                  showTag2: true,
                  tag2Icon: Icons.access_time,
                  tag2Text: 'timeframe'.tr,
                ),
              )).toList(),
            );
          }),
        ),

        SizedBox(height: _dh(sw, 20)),

        // Section title
        Center(
          child: Text(
            'select_key_results'.tr,
            style: appTheme.textTheme.headlineMedium?.copyWith(
              color: AppColors.primaryRed,
              fontSize: _fs(sw, 20, desktop: 20),
            ),
          ),
        ),
        SizedBox(height: _dh(sw, 6)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 0 : 8.w),
          child: Center(
            child: Text(
              'choose_3_outcomes'.tr,
              textAlign: TextAlign.center,
              style: appTheme.textTheme.titleSmall?.copyWith(
                color: AppColors.grey,
                fontSize: _fs(sw, 14, desktop: 14),
              ),
            ),
          ),
        ),

        SizedBox(height: _dh(sw, 12)),

        // Initiative inputs
        CustomInitiativeInput(
          numberText: 'first_initiative'.tr,
          titleController: controller.firstInitiativeTitle,
          descController: controller.firstInitiativeDesc,
        ),
        CustomInitiativeInput(
          numberText: 'second_initiative'.tr,
          titleController: controller.secondInitiativeTitle,
          descController: controller.secondInitiativeDesc,
        ),

        SizedBox(height: _dh(sw, 10)),
        const CustomAIStrategyContainer(),
        SizedBox(height: _dh(sw, 30)),

        // Journey Map
        Obx(() => CustomJourneyMap(
          progress: journeyController.progress.value,
          steps: journeyController.steps,
          completedSteps: journeyController.completedSteps,
          onToggle: journeyController.toggleJourneyDetails,
          showDetails: journeyController.showDetails.value,
        )),

        SizedBox(height: _dh(sw, 30)),

        // Submit button
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: sw >= 768 ? 40.0 : AppDimensions.d40.w),
          child: Obx(() => CustomButton2(
            text: controller.isSubmitting.value
                ? 'submitting'.tr
                : 'submit_analysis'.tr,
            onPressed: controller.isButtonEnabled
                ? () => controller.submitInitiatives()
                : null,
          )),
        ),

        SizedBox(height: _dh(sw, 30)),
      ],
    );
  }
}