import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/personal_dashboard_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/common_image.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_circular_avatar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class PersonalDashboardScreen extends StatelessWidget {
  PersonalDashboardScreen({super.key});

  final PersonalDashboardController controller = Get.put(PersonalDashboardController());

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final double width = constraints.maxWidth;
      final double height = constraints.maxHeight;

      final bool isMobile = width < 768;
      final bool isTablet = width >= 768 && width < 1024;
      final bool isDesktop = width >= 1024;

      // Responsive font helpers
      double headerFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;
      double bodyFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;
      double buttonFont(double mobile, double tablet, double desktop) =>
          isMobile ? mobile : isTablet ? tablet : desktop;

      double containerPadding() => isMobile ? 20 : isTablet ? 30 : 40;
      double containerWidth() => isMobile
          ? width * 0.9
          : isTablet
          ? width * 0.7
          : 600;

      if (isMobile) {
        return _buildMobileLayout(
          context,
          headerFont,
          bodyFont,
          buttonFont,
          isTablet,
          isDesktop,
        );
      } else {
        return _buildDesktopWebLayout(
          context,
          headerFont,
          bodyFont,
          buttonFont,
          containerPadding(),
          containerWidth(),
          isTablet,
          isDesktop,
        );
      }
    },
  );

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
      backgroundColor: Colors.white,
      body: CustomBackground(
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              final bool isPortrait = orientation == Orientation.portrait;
              final double width = MediaQuery.of(context).size.width;
              final double height = MediaQuery.of(context).size.height;

              final double sidePadding = _getHorizontalPadding(width);
              final double avatarSize = isPortrait ? width * 0.35 : width * 0.25;
              final double smallCardHeight = isPortrait ? height * 0.14 : height * 0.18;

              return Stack(
                children: [
                  /// Scroll everything including header
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: _getResponsiveSpacing(height, 0.019),
                        top: 12.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Header
                          CustomHeader(
                            title: 'Your',
                            highlightedText: 'ScoreBoard',
                            subtitle: '',
                            onBackTap: () => Get.back(),
                          ),

                          SizedBox(height: _getResponsiveSpacing(height, 0.002)),

                          /// Content with side padding
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: sidePadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                /// Avatar + Level Badge
                                Center(
                                  child: CustomCircularAvatar(
                                    imagePath: 'assets/images/solo_image.png',
                                    innerColors: [
                                      AppColors.softRed.withValues(alpha: 0.5),
                                      AppColors.softRed.withValues(alpha: 0.5),
                                      AppColors.softRed.withValues(alpha: 0.5)
                                    ],
                                    borderGradient: [
                                      AppColors.primaryRed,
                                      AppColors.primaryRed.withOpacity(0.5)
                                    ],
                                    size: 120,
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                /// Title & Success rate
                                Text(
                                  'strategic_architect'.tr,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                    fontSize: _getTitleFontSize(screenWidth, isTablet, isDesktop),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),

                                Obx(() {
                                  return Column(
                                    children: [
                                      Text(
                                        '${controller.successRate.value}% ${'success_rate'.tr}',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: AppColors.primaryRed,
                                          fontWeight: FontWeight.bold,
                                          fontSize: _getSubtitleFontSize(screenWidth, isTablet, isDesktop),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8.h),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.r),
                                        child: LinearProgressIndicator(
                                          value: controller.progressValue(),
                                          minHeight: 8.h,
                                          color: AppColors.primaryRed,
                                          backgroundColor: AppColors.textSecondary.withOpacity(0.12),
                                        ),
                                      ),
                                    ],
                                  );
                                }),

                                SizedBox(height: 20.h),

                                /// Stats Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _smallStatCard(
                                        context,
                                        label: 'badges'.tr,
                                        count: controller.badgesCount.value,
                                        height: smallCardHeight,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _smallStatCard(
                                        context,
                                        label: 'trophies'.tr,
                                        count: controller.trophiesCount.value,
                                        height: smallCardHeight,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _smallStatCard(
                                        context,
                                        label: 'cards'.tr,
                                        count: controller.cardsCount.value,
                                        height: smallCardHeight,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 22.h),

                                /// Achievements
                                _sectionCard(
                                  context,
                                  titleKey: 'recent_achievements',
                                  icon: Icons.thumb_up,
                                  borderColor: AppColors.primaryRed,
                                  items: controller.achievements,
                                  showCheck: true,
                                ),

                                SizedBox(height: 18.h),

                                /// Recent Games
                                _gamesCard(context, controller.recentGames.toList()),

                                SizedBox(height: 24.h),

                                /// Bottom buttons
                                CustomButton(
                                  text: 'schedule_async_game'.tr,
                                  onPressed: controller.scheduleAsyncGame,
                                  ),
                                SizedBox(height: 12.h),
                                CustomButton(
                                  text: 'invite_a_player'.tr,
                                  onPressed: controller.invitePlayer,
                                  backgroundColor: AppColors.primaryBlue,
                                 ),
                                SizedBox(height: 12.h),
                                CustomButton(
                                  text: 'launch_challenge'.tr,
                                  onPressed: controller.launchChallenge,
                                  backgroundColor: AppColors.primaryRed,
                                   ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Floating Home Nav
                  Positioned(
                    right: -width * 0.05,
                    top: height * 0.45,
                    child: CustomHomeNavBar(), // Removed const to fix constructor error
                  ),
                ],
              );
            },
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
    final double height = screenHeight; // Define height for desktop
    final double sidePadding = _getHorizontalPadding(screenWidth);
    final double smallCardHeight = height * 0.14; // Define smallCardHeight

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
              screenHeight: screenHeight, title: 'Your', subtitle: 'ScoreBoard',
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
                padding: EdgeInsets.only(
                  bottom: _getResponsiveSpacing(height, 0.019),
                  top: 12.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // /// Header
                    // CustomHeader(
                    //   title: 'Your',
                    //   highlightedText: 'ScoreBoard',
                    //   subtitle: '',
                    //   onBackTap: () => Get.back(),
                    // ),

                    SizedBox(height: _getResponsiveSpacing(height, 0.002)),

                    /// Content with side padding
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Avatar + Level Badge
                          Center(
                            child: CustomCircularAvatar(
                              imagePath: 'assets/images/solo_image.png',
                              innerColors: [
                                AppColors.softRed.withValues(alpha: 0.5),
                                AppColors.softRed.withValues(alpha: 0.5),
                                AppColors.softRed.withValues(alpha: 0.5)
                              ],
                              borderGradient: [
                                AppColors.primaryRed,
                                AppColors.primaryRed.withOpacity(0.5)
                              ],
                              size: 120,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          /// Title & Success rate
                          Text(
                            'strategic_architect'.tr,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: _getTitleFontSize(screenWidth, isTablet, isDesktop),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),

                          Obx(() {
                            return Column(
                              children: [
                                Text(
                                  '${controller.successRate.value}% ${'success_rate'.tr}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _getSubtitleFontSize(screenWidth, isTablet, isDesktop),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: LinearProgressIndicator(
                                    value: controller.progressValue(),
                                    minHeight: 8.h,
                                    color: AppColors.primaryRed,
                                    backgroundColor: AppColors.textSecondary.withOpacity(0.12),
                                  ),
                                ),
                              ],
                            );
                          }),

                          SizedBox(height: 20.h),

                          /// Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: _smallStatCard(
                                  context,
                                  label: 'badges'.tr,
                                  count: controller.badgesCount.value,
                                  height: smallCardHeight,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _smallStatCard(
                                  context,
                                  label: 'trophies'.tr,
                                  count: controller.trophiesCount.value,
                                  height: smallCardHeight,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _smallStatCard(
                                  context,
                                  label: 'cards'.tr,
                                  count: controller.cardsCount.value,
                                  height: smallCardHeight,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 22.h),

                          /// Achievements
                          _sectionCard(
                            context,
                            titleKey: 'recent_achievements',
                            icon: Icons.thumb_up,
                            borderColor: AppColors.primaryRed,
                            items: controller.achievements,
                            showCheck: true,
                          ),

                          SizedBox(height: 18.h),

                          /// Recent Games
                          _gamesCard(context, controller.recentGames.toList()),

                          SizedBox(height: 24.h),

                          /// Bottom buttons
                          CustomButton(
                            text: 'schedule_async_game'.tr,
                            onPressed: controller.scheduleAsyncGame,

                          ),
                          SizedBox(height: 12.h),
                          CustomButton(
                            text: 'invite_a_player'.tr,
                            onPressed: controller.invitePlayer,
                            backgroundColor: AppColors.primaryBlue,

                          ),
                          SizedBox(height: 12.h),
                          CustomButton(
                            text: 'launch_challenge'.tr,
                            onPressed: controller.launchChallenge,
                            backgroundColor: AppColors.primaryRed,

                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Home Navbar (Fixed duplicate and incorrect positioning)
          Positioned(
            bottom: 20,
            right: 20,
            child: CustomHomeNavBar(), // Removed const to fix constructor error
          ),
        ],
      ),
    );
  }

  /// Small stat card
  Widget _smallStatCard(
      BuildContext context, {
        required String label,
        required int count,
        required double height,
      }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey.withOpacity(0.28)),
      ),
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, color: AppColors.primaryBlue, size: 26.sp),
          SizedBox(height: 6.h),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Section card
  Widget _sectionCard(
      BuildContext context, {
        required String titleKey,
        required IconData icon,
        required Color borderColor,
        required List<Map<String, dynamic>> items,
        bool showCheck = false,
      }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(AppDimensions.d12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.d18.r),
        border: Border.all(color: borderColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.d18.r,
                backgroundColor: borderColor,
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: AppDimensions.d12.w),
              Expanded(
                child: Text(
                  titleKey.tr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
          SizedBox(height: AppDimensions.d12.h),

          ...items.map((m) {
            final titleKey = m['key'] as String? ?? '';
            final done = m['done'] as bool? ?? false;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titleKey.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showCheck)
                      Icon(
                        Icons.check_circle,
                        color: done ? Colors.green : Colors.grey,
                        size: 20.sp,
                      ),
                  ],
                ),
                Divider(
                  color: AppColors.grey.withOpacity(0.2),
                  height: 14.h,
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Recent games card
  Widget _gamesCard(BuildContext context, List<Map<String, String>> games) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(AppDimensions.d12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.d18.r),
        border: Border.all(color: AppColors.grey.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.d18.r,
                backgroundColor: AppColors.primaryBlue,
                child: const Icon(Icons.history, color: Colors.white),
              ),
              SizedBox(width: AppDimensions.d12.w),
              Expanded(
                child: Text(
                  'recent_games'.tr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
          SizedBox(height: AppDimensions.d12.h),

          ...games.map((g) {
            return Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.softRed,
                      child: Icon(Icons.person, color: AppColors.primaryRed),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g['titleKey']!.tr,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            g['date'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${g['score']} ${'score'.tr}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Divider(
                  color: AppColors.grey.withOpacity(0.2),
                  height: 14.h,
                ),
              ],
            );
          }).toList(),
        ],
      ),
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
    return screenWidth * 0.01;
  }
}