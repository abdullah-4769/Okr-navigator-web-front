import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/widgets/screens_unique_parts/custom_background.dart';
import 'package:get/get.dart';

import '../../../controllers/journey_controller.dart';
import '../../../controllers/suggestion_initiatives_ontroller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';

import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_ai_strategy_container.dart';

import '../../widgets/custom_button2.dart';

import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_initiative_input.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class SuggestionInitiativesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedKeyResults;

  SuggestionInitiativesScreen({super.key, required this.selectedKeyResults});


  final JourneyController journeyController = Get.find<JourneyController>();

  /// Safe translate helper
  String _safeTranslate(String? key, {String fallback = ''}) {
    if (key == null) return fallback;
    try {
      return key.tr;
    } catch (e) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {


    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        final bool isMobile = screenWidth < 768;
        final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
        final bool isDesktop = screenWidth >= 1024;

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
              context, headerFont, bodyFont, buttonFont, isTablet, isDesktop);
        } else {
          return _buildDesktopWebLayout(
              context,
              headerFont,
              bodyFont,
              buttonFont,
              containerPadding(),
              containerWidth(),
              isTablet,
              isDesktop);
        }
      },
    );
  }


  /// ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      bool isTablet,
      bool isDesktop,) {
    final controller = Get.put(
      SuggestionInitiativesController(keyResults: selectedKeyResults),
    );
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(

      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // 🔹 Main Content
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: AppDimensions.d18.h),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.03),

                      /// 🔹 Header
                      CustomHeader(
                        title: 'suggestion'.tr,
                        highlightedText: 'of_initiatives'.tr,
                        subtitle: 'add_initiatives_subtitle'.tr,
                        onBackTap: () =>
                            Get.offAllNamed(AppRoutes.keyResultsScreen),
                        showDashboardIcon: true,
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      /// 🔹 Initiative Inputs
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

                      SizedBox(height: AppDimensions.d12.h),

                      /// 🔹 AI Strategy Suggestion
                      const CustomAIStrategyContainer(),

                      SizedBox(height: AppDimensions.d28.h),

                      /// 🔹 Journey Map
                      Obx(
                            () =>
                            CustomJourneyMap(
                              progress: journeyController.progress.value,
                              steps: journeyController.steps,
                              completedSteps: journeyController.completedSteps,
                              onToggle: journeyController.toggleJourneyDetails,
                              showDetails: journeyController.showDetails.value,
                            ),
                      ),

                      SizedBox(height: AppDimensions.d28.h),

                      /// 🔹 Complete Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.d40.w,
                        ),
                        child: Obx(
                              () =>
                              CustomButton2(
                                text: controller.isSubmitting.value
                                    ? 'submitting'.tr
                                    : 'submit_analysis'.tr,
                                onPressed: controller.isSubmitting.value
                                    ? null
                                    : () => controller.submitInitiatives(),
                              ),
                        ),
                      ),

                      SizedBox(height: AppDimensions.d28.h),
                    ],
                  ),
                ),
              ),

              /// Floating Navigation Bar
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


  /// ----------------- Desktop/Web Layout -----------------
  Widget _buildDesktopWebLayout(BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      double padding,
      double containerWidth,
      bool isTablet,
      bool isDesktop,) {
    final controller = Get.put(
      SuggestionInitiativesController(keyResults: selectedKeyResults),
    );
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      body: Stack(
        children: [

          /// Background Image
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
            child: DesktopAppBar(
              screenWidth: screenWidth,
              screenHeight: screenHeight, title: 'suggestion'.tr, subtitle: 'of_initiatives'.tr,
    ),
          ),


          /// Scrollable white container
          Center(
            child: Container(
              width: containerWidth,
              height: screenHeight,
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
                padding: EdgeInsets.only(bottom: AppDimensions.d18.h),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    //
                    // /// 🔹 Header
                    // CustomHeader(
                    //   title: 'suggestion'.tr,
                    //   highlightedText: 'of_initiatives'.tr,
                    //   subtitle: 'add_initiatives_subtitle'.tr,
                    //   onBackTap: () =>
                    //       Get.offAllNamed(AppRoutes.keyResultsScreen),
                    //   showDashboardIcon: true,
                    // ),

                    SizedBox(height: screenHeight * 0.01),

                    /// 🔹 Initiative Inputs
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

                    SizedBox(height: AppDimensions.d12.h),

                    /// 🔹 AI Strategy Suggestion
                    const CustomAIStrategyContainer(),

                    SizedBox(height: AppDimensions.d28.h),

                    /// 🔹 Journey Map
                    Obx(
                          () =>
                          CustomJourneyMap(
                            progress: journeyController.progress.value,
                            steps: journeyController.steps,
                            completedSteps: journeyController.completedSteps,
                            onToggle: journeyController.toggleJourneyDetails,
                            showDetails: journeyController.showDetails.value,
                          ),
                    ),

                    SizedBox(height: AppDimensions.d28.h),

                    /// 🔹 Complete Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.d40.w,
                      ),
                      child: Obx(
                            () =>
                            CustomButton2(
                              text: controller.isSubmitting.value
                                  ? 'submitting'.tr
                                  : 'submit_analysis'.tr,
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : () => controller.submitInitiatives(),
                            ),
                      ),
                    ),

                    SizedBox(height: AppDimensions.d28.h),
                  ],
                ),
              ),
            ),
          ),


          /// Home Navbar
          Positioned(
            bottom: 20,
            left: 0,
            //right: 0,
            child: CustomSvg(
              assetPath: 'assets/images/left.svg', semanticsLabel: '',),
          ),


          /// Home Navbar
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


  /// ----------------- Responsive Helpers -----------------
  double _getResponsiveSpacing(double dimension, double factor) =>
      dimension * factor;

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

  double _getSubtitleFontSize(double screenWidth, bool isTablet,
      bool isDesktop) {
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