import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/widgets/custom_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/journey_controller.dart';
import '../../../controllers/key_objective_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_industry_container.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import '../../widgets/common_image.dart';

class KeyObjectiveSelectedScreen extends StatelessWidget {
  KeyObjectiveSelectedScreen({super.key});

  final KeyObjectiveController controller = Get.put(KeyObjectiveController());
  final JourneyController journeyController = Get.find<JourneyController>();

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
        double containerWidth() => isMobile
            ? screenWidth * 0.9
            : isTablet
            ? screenWidth * 0.7
            : 600;

        if (isMobile) {
          return _buildMobileLayout(
              context, headerFont, bodyFont, buttonFont, isTablet, isDesktop);
        } else {
          return _buildDesktopWebLayout(context, headerFont, bodyFont, buttonFont,
              containerPadding(), containerWidth(), isTablet, isDesktop);
        }
      },
    );
  }

  /// ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(
      BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      bool isTablet,
      bool isDesktop,
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
                    padding: EdgeInsets.only(
                      bottom: _getResponsiveSpacing(screenHeight, 0.025),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),

                        /// Custom Header
                        CustomHeader(
                          title: _safeTranslate('choose'),
                          highlightedText: _safeTranslate('objective'),
                          onBackTap: () =>
                              Get.offAllNamed(AppRoutes.selectStrategy),
                          showDashboardIcon: true,
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        /// Selected Strategy Container
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: _getHorizontalPadding(screenWidth)),
                          child: CustomObjectiveContainer(
                            title: _safeTranslate('selected_strategy'),
                            subtitle: _safeTranslate('development_new_markets'),
                            description: _safeTranslate('objective_description'),
                            icon: Icons.emoji_objects,
                          ),
                        ),

                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),

                        /// Choose Your Objective Title
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: _getHorizontalPadding(screenWidth)),
                          child: Column(
                            children: [
                              Text(
                                _safeTranslate('choose_your_objective'),
                                style: TextStyle(
                                  fontSize: _getTitleFontSize(
                                      screenWidth, isTablet, isDesktop),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryRed,
                                  fontFamily: 'GothamBold',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                _safeTranslate('select_one_objective'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _getSubtitleFontSize(
                                      screenWidth, isTablet, isDesktop),
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Gotham',
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),

                        /// Objectives List
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: _getContentPadding(screenWidth, isTablet)),
                          child: Obx(() => _buildObjectivesList(controller, screenWidth, isTablet)),
                        ),

                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),

                        /// Journey Map
                        Obx(() => CustomJourneyMap(
                          progress: journeyController.progress.value,
                          steps: journeyController.steps,
                          completedSteps: journeyController.completedSteps,
                          onToggle: journeyController.toggleJourneyDetails,
                          showDetails: journeyController.showDetails.value,
                        )),

                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),

                        /// Complete Selection Button
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                              _getButtonPadding(screenWidth, isTablet, isDesktop)),
                          child: Obx(() => CustomButton2(
                            text: _safeTranslate('complete_selection'),
                            onPressed: controller.isButtonEnabled
                                ? () =>
                                Get.offAllNamed(AppRoutes.keyResultsScreen)
                                : null,
                          )),
                        ),

                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                      ],
                    ),
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
  Widget _buildDesktopWebLayout(
      BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      double padding,
      double containerWidth,
      bool isTablet,
      bool isDesktop,
      ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
              screenHeight: screenHeight, title: 'choose', subtitle: 'objective',
            ),
          ),


          /// Scrollable white container
          Center(
            child: Container(
              width: containerWidth,
              height: screenHeight ,
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
                  padding: EdgeInsets.only(
                      bottom: _getResponsiveSpacing(screenHeight, 0.025)),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.03),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: _getHorizontalPadding(screenWidth)),
                        child: CustomObjectiveContainer(
                          title: _safeTranslate('selected_strategy'),
                          subtitle: _safeTranslate('development_new_markets'),
                          description: _safeTranslate('objective_description'),
                          icon: Icons.emoji_objects,
                        ),
                      ),

                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: _getHorizontalPadding(screenWidth)),
                        child: Column(
                          children: [
                            Text(
                              _safeTranslate('choose_your_objective'),
                              style: TextStyle(
                                fontSize: _getTitleFontSize(
                                    screenWidth, isTablet, isDesktop),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryRed,
                                fontFamily: 'GothamBold',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              _safeTranslate('select_one_objective'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _getSubtitleFontSize(
                                    screenWidth, isTablet, isDesktop),
                                color: AppColors.textSecondary,
                                fontFamily: 'Gotham',
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: _getContentPadding(screenWidth, isTablet)),
                        child: Obx(() =>
                            _buildObjectivesList(controller, screenWidth, isTablet)),
                      ),

                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.0)),

                      Obx(() => CustomJourneyMap(
                        progress: journeyController.progress.value,
                        steps: journeyController.steps,
                        completedSteps: journeyController.completedSteps,
                        onToggle: journeyController.toggleJourneyDetails,
                        showDetails: journeyController.showDetails.value,
                      )),

                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: _getButtonPadding(screenWidth, isTablet, isDesktop)),
                        child: Obx(() => CustomButton2(
                          text: _safeTranslate('complete_selection'),
                          onPressed: controller.isButtonEnabled
                              ? () =>
                              Get.offAllNamed(AppRoutes.keyResultsScreen)
                              : null,
                        )),
                      ),

                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                    ],
                  ),
                ),
              ),
            ),
          ),



          /// Home Navbar
          Positioned(
            bottom: 20,
            left: 0,
            //right: 0,
            child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: '',),
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

  /// ----------------- Objectives -----------------
  Widget _buildObjectivesList(
      KeyObjectiveController controller, double screenWidth, bool isTablet) {
    if (isTablet && screenWidth > 800) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: AppDimensions.d16.w,
          mainAxisSpacing: AppDimensions.d16.h,
        ),
        itemCount: controller.objectives.length,
        itemBuilder: (context, index) => _buildObjectiveItem(controller, index),
      );
    }

    return Column(
      children: List.generate(
        controller.objectives.length,
            (index) => Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.d16.h),
          child: _buildObjectiveItem(controller, index),
        ),
      ),
    );
  }

  Widget _buildObjectiveItem(KeyObjectiveController controller, int index) {
    final obj = controller.objectives[index];
    final titleKey = obj['titleKey'] as String?;
    final descriptionKey = obj['descriptionKey'] as String?;

    return CustomIndustryContainer(
      title: _safeTranslate(titleKey, fallback: 'Unknown'),
      description: _safeTranslate(descriptionKey, fallback: 'No description available'),
      icon: obj['icon'] as IconData,
      isSelected: controller.isSelected(index),
      onTap: () {
        controller.selectObjective(index);
        if (controller.isSelected(index)) {
          journeyController.progress.value = 40;
          journeyController.completeStep(0);
        } else {
          journeyController.progress.value = 20;
          journeyController.completedSteps[0] = false;
        }
      },
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
