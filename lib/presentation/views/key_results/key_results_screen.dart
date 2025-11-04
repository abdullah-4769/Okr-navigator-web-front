import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/journey_controller.dart';
import '../../../controllers/key_results_controller.dart';
import '../../../controllers/okr_constellation_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_industry_container.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_selected_key_result_container.dart';
import '../../widgets/custom_okr_constellation.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import '../../widgets/website/desktop_appbar.dart';

class KeyResultsScreen extends StatelessWidget {
  KeyResultsScreen({super.key});

  final KeyResultsController keyResultsController = Get.put(
    KeyResultsController(),
  );
  final OKRConstellationController constellationController = Get.put(
    OKRConstellationController(),
  );
  final JourneyController journeyController = Get.find<JourneyController>();

  // Translation helper
  String _safeTranslate(String? key, {String fallback = ''}) {
    if (key == null) return fallback;
    try {
      return key.tr;
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      journeyController.completeStep(0);
      journeyController.setStep(1, true);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        bool isMobile = screenWidth < 768;
        bool isTablet = screenWidth >= 768 && screenWidth < 1024;
        bool isDesktop = screenWidth >= 1024;

        if (isMobile) {
          return _buildMobileLayout(context, isTablet, isDesktop);
        } else {
          return _buildDesktopWebLayout(context, isTablet, isDesktop);
        }
      },
    );
  }

  // ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(
      BuildContext context, bool isTablet, bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: _getResponsiveSpacing(screenHeight, 0.03),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),

                        /// Header
                        CustomHeader(
                          title: _safeTranslate('select'),
                          highlightedText: _safeTranslate('key_results'),
                          onBackTap: () =>
                              Get.offAllNamed(AppRoutes.keyObjectiveScreen),
                          showDashboardIcon: true,
                        ),

                        SizedBox(height: screenHeight * 0.015),

                        /// Objective
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getHorizontalPadding(screenWidth),
                          ),
                          child: CustomObjectiveContainer(
                            icon: Icons.rocket,
                            title: _safeTranslate('selected_objective'),
                            subtitle: _safeTranslate('launch_2_products'),
                            description:
                            _safeTranslate('objective_description'),
                          ),
                        ),

                        SizedBox(
                            height: _getResponsiveSpacing(screenHeight, 0.02)),

                        /// Selected Key Results
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getHorizontalPadding(screenWidth),
                          ),
                          child: const CustomSelectedKeyResultsContainer(),
                        ),

                        SizedBox(
                            height: _getResponsiveSpacing(screenHeight, 0.02)),

                        /// Title & Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getHorizontalPadding(screenWidth),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _safeTranslate('select_key_results'),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryRed,
                                  fontFamily: 'GothamExtraBold',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                _safeTranslate('choose_3_outcomes'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Gotham',
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height: _getResponsiveSpacing(screenHeight, 0.025)),

                        /// Key Results List
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                            _getContentPadding(screenWidth, isTablet),
                          ),
                          child: _buildKeyResultsList(screenWidth, isTablet),
                        ),

                        SizedBox(
                            height: _getResponsiveSpacing(screenHeight, 0.03)),

                        /// OKR Constellation
                        const CustomOKRConstellation(),

                        SizedBox(
                            height: _getResponsiveSpacing(screenHeight, 0.03)),

                        /// Journey Map
                        Obx(
                              () => CustomJourneyMap(
                            progress: journeyController.progress.value,
                            steps: journeyController.steps,
                            completedSteps:
                            journeyController.completedSteps,
                            onToggle:
                            journeyController.toggleJourneyDetails,
                            showDetails:
                            journeyController.showDetails.value,
                          ),
                        ),

                        SizedBox(
                            height: _getResponsiveSpacing(screenHeight, 0.03)),

                        /// Complete Selection Button
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getButtonPadding(
                                screenWidth, isTablet, isDesktop),
                          ),
                          child: Obx(
                                () => CustomButton2(
                              text: _safeTranslate('complete_selection'),
                              onPressed:
                              keyResultsController.selectedCount.value ==
                                  keyResultsController
                                      .requiredCount.value
                                  ? () {
                                journeyController.completeStep(2);
                                Get.offAllNamed(AppRoutes
                                    .suggestionInitiativeScreen);
                              }
                                  : null,
                            ),
                          ),
                        ),

                        SizedBox(
                            height: _getResponsiveSpacing(screenHeight, 0.025)),
                      ],
                    ),
                  ),
                ),
              ),

              /// Floating Nav
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
      BuildContext context, bool isTablet, bool isDesktop) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Appbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DesktopAppBar(
              title: _safeTranslate('select'),
              subtitle: _safeTranslate('key_results'),
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),

          /// Main Content
          Center(
            child: Container(
              width: isDesktop ? 600 : screenWidth * 0.7,
              margin: const EdgeInsets.only(top: 120, bottom: 40),
              padding: EdgeInsets.all(isDesktop ? 40 : 30),
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
                child: Column(
                  children: [
                    /// Objective
                    CustomObjectiveContainer(
                      icon: Icons.rocket,
                      title: _safeTranslate('selected_objective'),
                      subtitle: _safeTranslate('launch_2_products'),
                      description: _safeTranslate('objective_description'),
                    ),

                    SizedBox(
                        height: _getResponsiveSpacing(screenHeight, 0.02)),

                    /// Selected Key Results
                    const CustomSelectedKeyResultsContainer(),

                    SizedBox(
                        height: _getResponsiveSpacing(screenHeight, 0.02)),

                    /// Title & Subtitle
                    Column(
                      children: [
                        Text(
                          _safeTranslate('select_key_results'),
                          style: TextStyle(
                            fontSize: _getTitleFontSize(
                                screenWidth, isTablet, isDesktop),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                            fontFamily: 'GothamExtraBold',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          _safeTranslate('choose_3_outcomes'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _getSubtitleFontSize(
                                screenWidth, isTablet, isDesktop),
                            color: AppColors.textSecondary,
                            fontFamily: 'Gotham',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                        height: _getResponsiveSpacing(screenHeight, 0.025)),

                    /// Key Results List
                    _buildKeyResultsList(screenWidth, isTablet),

                    SizedBox(
                        height: _getResponsiveSpacing(screenHeight, 0.03)),

                    /// OKR Constellation
                    const CustomOKRConstellation(),

                    SizedBox(
                        height: _getResponsiveSpacing(screenHeight, 0.03)),

                    /// Journey Map
                    Obx(
                          () => CustomJourneyMap(
                        progress: journeyController.progress.value,
                        steps: journeyController.steps,
                        completedSteps: journeyController.completedSteps,
                        onToggle: journeyController.toggleJourneyDetails,
                        showDetails: journeyController.showDetails.value,
                      ),
                    ),

                    SizedBox(
                        height: _getResponsiveSpacing(screenHeight, 0.03)),

                    /// Complete Selection Button (✅ works now)
                    Obx(
                          () => CustomButton2(
                        text: _safeTranslate('complete_selection'),
                        onPressed: keyResultsController
                            .selectedCount.value ==
                            keyResultsController.requiredCount.value
                            ? () {
                          journeyController.completeStep(2);
                          Get.offAllNamed(
                              AppRoutes.suggestionInitiativeScreen);
                        }
                            : null,
                      ),
                    ),

                    SizedBox(
                        height: _getResponsiveSpacing(screenHeight, 0.025)),
                  ],
                ),
              ),
            ),
          ),

          /// Back Arrow
          Positioned(
            bottom: 20,
            left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(
                assetPath: 'assets/images/left.svg',
                semanticsLabel: '',
              ),
            ),
          ),

          /// NavBar
          Positioned(
            bottom: 20,
            left: 0,
            right: -20,
            child: const Center(child: CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ----------------- Helpers -----------------
  double _getResponsiveSpacing(double dim, double factor) => dim * factor;

  double _getHorizontalPadding(double w) {
    if (w > 1200) return w * 0.03;
    if (w > 900) return w * 0.02;
    if (w > 600) return w * 0.01;
    return w * 0.02;
  }

  double _getContentPadding(double w, bool isTablet) =>
      isTablet ? w * 0.06 : w * 0.04;

  double _getButtonPadding(double w, bool isTablet, bool isDesktop) {
    if (isDesktop) return w * 0.25;
    if (isTablet) return w * 0.15;
    return w * 0.1;
  }

  double _getTitleFontSize(
      double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return (screenWidth * 0.005).sp;
    if (isTablet) return (screenWidth * 0.004).sp;
    return (screenWidth * 0.045).sp;
  }

  double _getSubtitleFontSize(
      double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return (screenWidth * 0.0022).sp;
    if (isTablet) return (screenWidth * 0.0026).sp;
    return (screenWidth * 0.028).sp;
  }

  /// Build key results list
  Widget _buildKeyResultsList(double screenWidth, bool isTablet) {
    if (isTablet && screenWidth > 800) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: AppDimensions.d16.w,
          mainAxisSpacing: AppDimensions.d16.h,
        ),
        itemCount: keyResultsController.keyResults.length,
        itemBuilder: (context, index) => _buildKeyResultItem(index),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keyResultsController.keyResults.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: AppDimensions.d16.h),
        child: _buildKeyResultItem(index),
      ),
    );
  }

  /// Build single key result
  Widget _buildKeyResultItem(int index) {
    final item = keyResultsController.keyResults[index];
    final titleKey = item['titleKey'] as String?;
    final descriptionKey = item['descriptionKey'] as String?;
    final tag1Key = item['tag1Key'] as String?;
    final tag2Key = item['tag2Key'] as String?;

    return Obx(
          () => CustomIndustryContainer(
        title: _safeTranslate(titleKey, fallback: 'Unknown Title'),
        description:
        _safeTranslate(descriptionKey, fallback: 'No description'),
        icon: Icons.rocket,
        isSelected: keyResultsController.isSelected(index),
        onTap: () {
          keyResultsController.toggleSelection(index);
          final icon = item['icon'];
          if (keyResultsController.isSelected(index)) {
            constellationController.addIcon(icon);
          } else {
            constellationController.removeIcon(icon);
          }
        },
        showTag1: true,
        tag1Icon: Icons.trending_up,
        tag1Text: _safeTranslate(tag1Key, fallback: ''),
        showTag2: true,
        tag2Icon: Icons.access_time,
        tag2Text: _safeTranslate(tag2Key, fallback: ''),
      ),
    );
  }
}
