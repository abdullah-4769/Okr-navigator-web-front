import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/journey_controller.dart';
import '../../../controllers/strategy_selection_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../services/shared_preference.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_cards_pagebuilder.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_journey_map.dart';
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

class StrategySelectionScreen extends StatelessWidget {
  StrategySelectionScreen({super.key});

  // ✅ Use find — these are registered by the binding before navigation
  final JourneyController         journeyController = Get.find<JourneyController>();
  final StrategySelectionController controller       = Get.find<StrategySelectionController>();

  @override
  Widget build(BuildContext context) {
    // Reset to back card after frame (same as original)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetToBackCard();
    });

    final args             = Get.arguments as Map<String, dynamic>?;
    final selectedRole     = args?['selectedRole']     as Map<String, dynamic>?;
    final selectedIndustry = args?['selectedIndustry'] as Map<String, dynamic>?;

    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    if (sw >= 768) return _buildDesktopLayout(context, sw, sh, selectedRole, selectedIndustry);
    return _buildMobileLayout(context, sw, sh, selectedRole, selectedIndustry);
  }

  // ==========================================================================
  // MOBILE LAYOUT — unchanged from original
  // ==========================================================================
  Widget _buildMobileLayout(
      BuildContext context,
      double sw,
      double sh,
      Map<String, dynamic>? selectedRole,
      Map<String, dynamic>? selectedIndustry,
      ) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.d20.h),
                    child: _buildContent(
                      context, sw, sh, selectedRole, selectedIndustry,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: sw * -0.07,
                top:   sh * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT — matches established web pattern exactly
  // ==========================================================================
  Widget _buildDesktopLayout(
      BuildContext context,
      double sw,
      double sh,
      Map<String, dynamic>? selectedRole,
      Map<String, dynamic>? selectedIndustry,
      ) {
    final double containerWidth = sw > 1200 ? 720.0 : sw * 0.72;

    return Scaffold(
      body: Stack(
        children: [
          // Background image 10% opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // DesktopAppBar pinned at top
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth:  sw,
              screenHeight: sh,
              title:    'strategy'.tr,
              subtitle: 'selection'.tr,
            ),
          ),

          // White centered card
          Positioned(
            top: 110, left: 0, right: 0, bottom: 80,
            child: Center(
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(36),
                  child: _buildContent(
                    context, sw, sh, selectedRole, selectedIndustry,
                  ),
                ),
              ),
            ),
          ),

          // Back SVG bottom-left
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () {
                final gameMode = SharedPrefs.getGameMode();
                if (gameMode == 'campaign') {
                  Get.offAllNamed(AppRoutes.missionScreen);
                } else {
                  Get.offAllNamed(AppRoutes.chooseIndustry);
                }
              },
              child: CustomSvg(
                assetPath:      'assets/images/left.svg',
                semanticsLabel: '',
              ),
            ),
          ),

          // Bottom nav bar
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SHARED CONTENT — same for mobile and desktop
  // ==========================================================================
  Widget _buildContent(
      BuildContext context,
      double sw,
      double sh,
      Map<String, dynamic>? selectedRole,
      Map<String, dynamic>? selectedIndustry,
      ) {
    return Column(
      children: [
        SizedBox(height: sw >= 768 ? 20.0 : sh * 0.03),
        //
        // // Header
        // CustomHeader(
        //   title:           'strategy'.tr,
        //   highlightedText: 'selection'.tr,
        //   onBackTap: () {
        //     final gameMode = SharedPrefs.getGameMode();
        //     if (gameMode == 'campaign') {
        //       Get.offAllNamed(AppRoutes.missionScreen);
        //     } else {
        //       Get.offAllNamed(AppRoutes.chooseIndustry);
        //     }
        //   },
        // ),

        SizedBox(height: sw >= 768 ? 16.0 : sh * 0.01),

        // Draw strategy text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, sw * 0.06)),
          child: Column(
            children: [
              Text(
                'draw_strategy'.tr,
                style: TextStyle(
                  fontFamily: 'GothamBold',
                  fontSize:   _fs(sw, sw * 0.055, desktop: 22),
                  color:      AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sw >= 768 ? 10.0 : sh * 0.01),
              Text(
                'draw_strategy_subtitle'.tr,
                style: TextStyle(
                  fontSize:   _fs(sw, sw * 0.037, desktop: 14),
                  color:      AppColors.textSecondary,
                  fontFamily: 'Gotham',
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: sw >= 768 ? 24.0 : sh * 0.03),

        // Card pager — key widget unchanged
        CustomCardPagerBuilder(controller: controller),

        SizedBox(height: sw >= 768 ? 24.0 : sh * 0.03),

        // Begin Mission button
        Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, sw * 0.12)),
          child: CustomButton2(
            text:      'begin_mission'.tr,
            onPressed: controller.canBeginMission
                ? () {
              journeyController.completeStep(0);
              controller.beginMission(selectedRole, selectedIndustry);
            }
                : null,
          ),
        )),

        SizedBox(height: sw >= 768 ? 24.0 : sh * 0.03),

        // Journey map
        Obx(() => CustomJourneyMap(
          progress:       journeyController.progress.value,
          steps:          journeyController.steps,
          completedSteps: journeyController.completedSteps,
          onToggle:       journeyController.toggleJourneyDetails,
          showDetails:    journeyController.showDetails.value,
        )),

        SizedBox(height: sw >= 768 ? 24.0 : sh * 0.03),
      ],
    );
  }
}