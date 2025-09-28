import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/contextual_challange_controller.dart';
import '../../../controllers/journey_controller.dart';
import '../../../controllers/key_objective_controller.dart';
import '../../../controllers/key_results_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_adjustment_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_market_distribution_card.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class ContextualChallengeScreen extends StatelessWidget {
  ContextualChallengeScreen({super.key});

  final controller = Get.put(ContextualChallengeController());
  final journeyController = Get.find<JourneyController>();

  // Get.lazyPut
  //
  // (
  //
  // () => KeyObjectiveController());
  // Get.lazyPut(() => KeyResultsController());

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


  // ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      bool isTablet,
      bool isDesktop,) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBackground(
        child: OrientationBuilder(
          builder: (context, orientation) =>
              Stack(
                children: [

                  /// Scrollable Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: screenHeight * 0.001),
                      child: Column(
                        children: [

                          /// Header
                          CustomHeader(
                            title: 'contextual'.tr,
                            highlightedText: 'challenge'.tr,
                            subtitle: ''.tr,
                            onBackTap: () =>
                                Get.toNamed(AppRoutes.aiAnalysisShowScreen),
                          ),

                          SizedBox(height: screenHeight * 0.025),

                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'adapt_strategy_to_challenge'.tr,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                    color: AppColors.black,
                                    height: 1.2,
                                    fontWeight: FontWeight.w400
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),

                          /// Challenge Alert
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05),
                            child: CustomObjectiveContainer(

                              title: 'challenge_alert'.tr,
                              subtitle: '',
                              description: 'adaptation_required'.tr,
                              titleColor: AppColors.primaryRed,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.025),

                          /// Market Disruption
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05),
                            child: CustomMarketDisruptionCard(
                              icon: Icons.warning_amber_rounded,
                              title: "market_disruption_challenge".tr,
                              description: "competitor_launched_product".tr,
                              warningText: "revenue_drop_warning".tr,
                              warningIcon: Icons.trending_down,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.001),

                          /// Adapt Section
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    'adapt_you'.tr,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                      color: AppColors.primaryRed,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 6.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w),
                                    child: Text(
                                      'readjust_strategy'.tr,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        color: AppColors.black,
                                        height: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.001),

                          /// Current Strategy & Related Containers
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05),
                            child: Column(
                              children: [

                                /// 🔹 Current Strategy
                                CustomAdjustmentContainer(
                                  icon: Icons.track_changes,
                                  iconColor: AppColors.primaryRed,
                                  title: "current_strategy".tr,
                                  description: "development_new_markets".tr,
                                ),

                                SizedBox(height: 4.h),

                                /// 🔹 Objective
                                CustomAdjustmentContainer(
                                  icon: Icons.flag,
                                  iconColor: AppColors.primaryRed,
                                  title: "objective".tr,
                                  description: "expand_emerging_markets".tr,
                                  actionText: "modify".tr,
                                  actionColor: AppColors.primaryBlue,
                                  onActionTap: () {
                                    // TODO: open objective editing dialog
                                  },
                                ),

                                SizedBox(height: 4.h),

                                /// 🔹 Key Results
                                CustomAdjustmentContainer(
                                  icon: Icons.flag,
                                  iconColor: AppColors.primaryGreen,
                                  title: "key_results".tr,
                                  actionText: "adjust".tr,
                                  actionColor: AppColors.primaryBlue,
                                  onActionTap: () {},
                                  children: [
                                    _buildResultItem(
                                      context,
                                      "achieve_revenue_new_products".tr,
                                      highlight: true,
                                    ),
                                    _buildResultItem(
                                      context,
                                      "launch_new_geographic_markets".tr,
                                    ),
                                    _buildResultItem(
                                      context,
                                      "achieve_market_share_target".tr,
                                    ),
                                  ],
                                ),

                                /// 🔹 Initiatives
                                CustomAdjustmentContainer(
                                  icon: Icons.rocket_launch,
                                  iconColor: AppColors.primaryRed,
                                  title: "initiatives".tr,
                                  actionText: "revise".tr,
                                  actionColor: AppColors.primaryBlue,
                                  onActionTap: () {},
                                  children: [
                                    _buildInitiativeItem(
                                      context,
                                      1,
                                      "first_initiative".tr,
                                      "premium_product_program".tr,
                                    ),
                                    _buildInitiativeItem(
                                      context,
                                      2,
                                      "second_initiative".tr,
                                      "strategic_market_entry".tr,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.003),

                          /// Propose Adjustment Button
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.05.w,
                                horizontal: screenHeight * 0.05.h,
                              ),
                              child: CustomButton(
                                text: 'propose_adjustment'.tr,
                                onPressed: () {
                                  Get.toNamed(AppRoutes.contextualCAdjustment);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Home Navbar
                  Positioned(
                    right: screenWidth * -0.07,
                    top: screenHeight * 0.5,
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
              screenHeight: screenHeight, title: 'contextual'.tr, subtitle:'challenge',
            ),
          ),


          /// Scrollable white container
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: screenHeight * 0.001),
            child: Column(
              children: [


                SizedBox(height: screenHeight * 0.025),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'adapt_strategy_to_challenge'.tr,
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                          color: AppColors.black,
                          height: 1.2,
                          fontWeight: FontWeight.w400
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                /// Challenge Alert
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: CustomObjectiveContainer(

                    title: 'challenge_alert'.tr,
                    subtitle: '',
                    description: 'adaptation_required'.tr,
                    titleColor: AppColors.primaryRed,
                  ),
                ),

                SizedBox(height: screenHeight * 0.025),

                /// Market Disruption
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: CustomMarketDisruptionCard(
                    icon: Icons.warning_amber_rounded,
                    title: "market_disruption_challenge".tr,
                    description: "competitor_launched_product".tr,
                    warningText: "revenue_drop_warning".tr,
                    warningIcon: Icons.trending_down,
                  ),
                ),

                SizedBox(height: screenHeight * 0.001),

                /// Adapt Section
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'adapt_you'.tr,
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            color: AppColors.primaryRed,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(
                            'readjust_strategy'.tr,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color: AppColors.black,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.001),

                /// Current Strategy & Related Containers
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [

                      /// 🔹 Current Strategy
                      CustomAdjustmentContainer(
                        icon: Icons.track_changes,
                        iconColor: AppColors.primaryRed,
                        title: "current_strategy".tr,
                        description: "development_new_markets".tr,
                      ),

                      SizedBox(height: 4.h),

                      /// 🔹 Objective
                      CustomAdjustmentContainer(
                        icon: Icons.flag,
                        iconColor: AppColors.primaryRed,
                        title: "objective".tr,
                        description: "expand_emerging_markets".tr,
                        actionText: "modify".tr,
                        actionColor: AppColors.primaryBlue,
                        onActionTap: () {
                          // TODO: open objective editing dialog
                        },
                      ),

                      SizedBox(height: 4.h),

                      /// 🔹 Key Results
                      CustomAdjustmentContainer(
                        icon: Icons.flag,
                        iconColor: AppColors.primaryGreen,
                        title: "key_results".tr,
                        actionText: "adjust".tr,
                        actionColor: AppColors.primaryBlue,
                        onActionTap: () {},
                        children: [
                          _buildResultItem(
                            context,
                            "achieve_revenue_new_products".tr,
                            highlight: true,
                          ),
                          _buildResultItem(
                            context,
                            "launch_new_geographic_markets".tr,
                          ),
                          _buildResultItem(
                            context,
                            "achieve_market_share_target".tr,
                          ),
                        ],
                      ),

                      /// 🔹 Initiatives
                      CustomAdjustmentContainer(
                        icon: Icons.rocket_launch,
                        iconColor: AppColors.primaryRed,
                        title: "initiatives".tr,
                        actionText: "revise".tr,
                        actionColor: AppColors.primaryBlue,
                        onActionTap: () {},
                        children: [
                          _buildInitiativeItem(
                            context,
                            1,
                            "first_initiative".tr,
                            "premium_product_program".tr,
                          ),
                          _buildInitiativeItem(
                            context,
                            2,
                            "second_initiative".tr,
                            "strategic_market_entry".tr,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.003),

                /// Propose Adjustment Button
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.05.w,
                      horizontal: screenHeight * 0.05.h,
                    ),
                    child: CustomButton(
                      text: 'propose_adjustment'.tr,
                      onPressed: () {
                        Get.toNamed(AppRoutes.contextualCAdjustment);
                      },
                    ),
                  ),
                ),
              ],
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


  /// 🔹 Key Result Item
  Widget _buildResultItem(BuildContext context, String text,
      {bool highlight = false}) =>
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: highlight ? AppColors.primaryRed : AppColors.grey
                .withOpacity(0.5),
            width: highlight ? 1.5 : 1,
          ),
          color: Colors.white,
        ),
        child: Text(
          text,
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: highlight ? AppColors.primaryRed : AppColors.textSecondary,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      );

  /// 🔹 Initiative Item
  Widget _buildInitiativeItem(BuildContext context, int number, String title,
      String subtitle) =>
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey.withOpacity(0.4)),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Number Circle
            Container(
              width: 28.w,
              height: 28.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed,
              ),
              child: Text(
                "$number",
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            /// Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );


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
