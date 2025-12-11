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

class StrategySelectionScreen extends StatelessWidget {
  StrategySelectionScreen({super.key});

  final journeyController = Get.find<JourneyController>();
  final controller = Get.find<StrategySelectionController>();

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetToBackCard();
    });

    // ✅ Get arguments from GetX
    final args = Get.arguments as Map<String, dynamic>?;
    final selectedRole = args?['selectedRole'] as Map<String, dynamic>?;
    final selectedIndustry = args?['selectedIndustry'] as Map<String, dynamic>?;

    return LayoutBuilder(builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;
      double screenHeight = constraints.maxHeight;

      // Device detection
      bool isMobile = screenWidth < 768;
      bool isTablet = screenWidth >= 768 && screenWidth < 1024;
      bool isDesktop = screenWidth >= 1024;

      // Responsive font helpers
      double headerFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;
      double bodyFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;
      double buttonFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;

      double containerPadding() => isMobile ? 20 : isTablet ? 30 : 40;
      double containerWidth() =>
          isMobile
              ? screenWidth * 0.9
              : isTablet
              ? screenWidth * 0.7
              : 600;

      if (isMobile) {
        return _buildMobileLayout(
            context,
            headerFont,
            bodyFont,
            buttonFont,
            selectedRole,
            selectedIndustry
        );
      } else {
        return _buildDesktopWebLayout(
          context,
          headerFont,
          bodyFont,
          buttonFont,
          containerPadding(),
          containerWidth(),
          selectedRole,
          selectedIndustry,
        );
      }
    });
  }

  // ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(
      BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      Map<String, dynamic>? selectedRole,
      Map<String, dynamic>? selectedIndustry,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              /// Scrollable Content
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.d20.h),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),

                        // 🔹 Custom Header
                        CustomHeader(
                          title: 'select'.tr,
                          highlightedText: 'strategy'.tr,
                          onBackTap: () {
                            // ✅ Navigate back based on game mode
                            final gameMode = SharedPrefs.getGameMode();
                            if (gameMode == 'campaign') {
                              Get.offAllNamed(AppRoutes.missionScreen);
                            } else {
                              Get.offAllNamed(AppRoutes.chooseIndustry);
                            }
                          },
                          showDashboardIcon: true,
                        ),

                        SizedBox(height: screenHeight * 0.01),

                        // Welcome Text
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'draw_strategy'.tr,
                                style: TextStyle(
                                  fontFamily: 'GothamBold',
                                  fontSize: (screenWidth * 0.055).sp,
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'draw_strategy_subtitle'.tr,
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.037).sp,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Gotham',
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Cards Section
                        CustomCardPagerBuilder(controller: controller),

                        SizedBox(height: screenHeight * 0.03),

                        // Journey Map
                        Obx(
                              () => CustomJourneyMap(
                            progress: journeyController.progress.value,
                            steps: journeyController.steps,
                            completedSteps: journeyController.completedSteps,
                            onToggle: journeyController.toggleJourneyDetails,
                            showDetails: journeyController.showDetails.value,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Begin Mission Button
                        Obx(
                              () => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.012,
                            ),
                            child: CustomButton2(
                              text: 'begin_mission'.tr,
                              onPressed: controller.canBeginMission
                                  ? () {
                                journeyController.completeStep(0); // Mark strategy step as complete
                                controller.beginMission(selectedRole, selectedIndustry);
                              }
                                  : null,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔹 Floating Navbar
              Positioned(
                right: screenWidth * -0.07,
                top: screenHeight * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- Desktop/Web Layout -----------------
  Widget _buildDesktopWebLayout(
      BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      double padding,
      double containerWidth,
      Map<String, dynamic>? selectedRole,
      Map<String, dynamic>? selectedIndustry,
      ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with opacity
          Positioned.fill(
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/images/web_background.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DesktopAppBar(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              title: 'select'.tr,
              subtitle: 'strategy'.tr,
            ),
          ),

          // Scrollable white container
          Center(
            child: Container(
              width: containerWidth,
              height: screenHeight * 0.75,
              margin: const EdgeInsets.only(top: 120),
              padding: EdgeInsets.all(padding),
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
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppDimensions.d20.h),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.03),

                      // Welcome Text
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'draw_strategy'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: bodyFont(14, 16, 18),
                                color: AppColors.primaryRed,
                                fontFamily: "GothamUltra",
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'draw_strategy_subtitle'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: bodyFont(12, 14, 16),
                                color: AppColors.black,
                                fontFamily: "Gotham",
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Cards Section
                      CustomCardPagerBuilder(controller: controller),

                      SizedBox(height: screenHeight * 0.03),

                      // Journey Map
                      Obx(
                            () => CustomJourneyMap(
                          progress: journeyController.progress.value,
                          steps: journeyController.steps,
                          completedSteps: journeyController.completedSteps,
                          onToggle: journeyController.toggleJourneyDetails,
                          showDetails: journeyController.showDetails.value,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Begin Mission Button - UPDATED with API integration
                      Obx(
                            () => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.003,
                          ),
                          child: CustomButton2(
                            text: 'begin_mission'.tr,
                            onPressed: controller.canBeginMission
                                ? () {
                              journeyController.completeStep(0); // Mark strategy step as complete
                              controller.beginMission(selectedRole, selectedIndustry);
                            }
                                : null,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Back Button
          Positioned(
            bottom: 20,
            left: 0,
            child: GestureDetector(
              onTap: () {
                // ✅ Navigate back based on game mode
                final gameMode = SharedPrefs.getGameMode();
                if (gameMode == 'campaign') {
                  Get.offAllNamed(AppRoutes.missionScreen);
                } else {
                  Get.offAllNamed(AppRoutes.chooseIndustry);
                }
              },
              child: CustomSvg(
                assetPath: 'assets/images/left.svg',
                semanticsLabel: '',
              ),
            ),
          ),

          // Home Navbar at bottom middle
          Positioned(
            bottom: 20,
            left: 0,
            right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }
}
