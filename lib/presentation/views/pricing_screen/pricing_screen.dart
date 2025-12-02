import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/game_mode_controller.dart';
import '../../../controllers/pricing_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive_helper.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_curved_arrow.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';

class PricingScreen extends StatelessWidget {
  PricingScreen({super.key});

  final PricingController controller = Get.put(PricingController());
  final PageController pageController = PageController(viewportFraction: 0.85);
  final GameModeController gameModeController = Get.find();

  String trKey(Object? key) => key != null ? key.toString().tr : '';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return _ResponsivePricingScreen(
              controller: controller,
              pageController: pageController,
              gameModeController: gameModeController,
              trKey: trKey,
              constraints: constraints,
              orientation: orientation,
            );
          },
        );
      },
    );
  }
}

class _ResponsivePricingScreen extends StatelessWidget {
  final PricingController controller;
  final PageController pageController;
  final GameModeController gameModeController;
  final String Function(Object?) trKey;
  final BoxConstraints constraints;
  final Orientation orientation;

  const _ResponsivePricingScreen({
    required this.controller,
    required this.pageController,
    required this.gameModeController,
    required this.trKey,
    required this.constraints,
    required this.orientation,
  });

  double get screenWidth => constraints.maxWidth;
  double get screenHeight => constraints.maxHeight;

  DeviceType get deviceType {
    if (screenWidth < 600) return DeviceType.mobile;
    if (screenWidth >= 600 && screenWidth < 900) return DeviceType.tablet;
    if (screenWidth >= 900 && screenWidth < 1200) return DeviceType.desktop;
    if (screenWidth >= 1200 && screenWidth < 1920) return DeviceType.largeDesktop;
    return DeviceType.ultraWide;
  }

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop ||
      deviceType == DeviceType.largeDesktop ||
      deviceType == DeviceType.ultraWide;
  bool get isWeb => screenWidth >= 1200;

  ResponsiveHelper get responsiveHelper => ResponsiveHelper(screenWidth, screenHeight);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileLayout(context);
    } else {
      return _buildDesktopWebLayout(context);
    }
  }

  /// Mobile Layout (Keep as original)
  Widget _buildMobileLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                /// Top Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.offAllNamed('/splash0'),
                        child: CustomCurvedArrow(
                          isLeft: true,
                          width: 60.w,
                          height: 150.h,
                          onTap: () => Get.offAllNamed(AppRoutes.gameMode),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 130.h,
                        width: 150.w,
                        child: CustomSvg(
                          assetPath: 'assets/images/okrnev.svg',
                          semanticsLabel: trKey('okr_logo'),
                          height: 90.h,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: 60.w),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),

                /// PageView for Pricing Cards
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: controller.pricingPlans.length,
                    onPageChanged: controller.onPageChanged,
                    itemBuilder: (context, index) {
                      final plan = controller.pricingPlans[index];
                      return Obx(() {
                        bool isSelected = controller.currentPageIndex.value == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(
                            horizontal: isSelected ? 20.w : 24.w,
                            vertical: isSelected ? 90.h : 90.h,
                          ),
                          width: screenWidth * 0.80,
                          child: _buildMobilePricingCard(plan, isSelected),
                        );
                      });
                    },
                  ),
                ),
                SizedBox(height: 20.h),

                /// Navigation Controls
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        return _buildMobileArrowButton(
                          icon: Icons.arrow_back,
                          isDisabled: controller.currentPageIndex.value == 0,
                          onTap: () => controller.previousCard(pageController),
                        );
                      }),
                      SizedBox(
                        width: constraints.maxWidth * 0.45,

                        child: CustomButton2(
                          text: trKey('select_continue'),
                          onPressed: () {
                            controller.selectPlan(controller.currentPageIndex.value);
                          },
                        ),
                      ),
                      Obx(() {
                        return _buildMobileArrowButton(
                          icon: Icons.arrow_forward,
                          isDisabled: controller.currentPageIndex.value ==
                              controller.pricingPlans.length - 1,
                          onTap: () => controller.nextCard(pageController),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobilePricingCard(Map<String, dynamic> plan, bool isSelected) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: isSelected ? 10 : 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: isSelected ? AppColors.primaryRed : AppColors.primaryRed,
              width: 1,
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.softRed.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan['price'],
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                SizedBox(height: 12.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plan['features'].length,
                  separatorBuilder: (_, __) => Divider(
                    height: 12.h,
                    color: AppColors.grey.withOpacity(0.3),
                    thickness: 1,
                  ),
                  itemBuilder: (_, index) {
                    final feature = plan['features'][index];
                    return Row(
                      children: [
                        Icon(
                          feature['included'] ? Icons.check_circle : Icons.cancel,
                          color: feature['included']
                              ? AppColors.sucessColor
                              : AppColors.grey,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            trKey(feature['text']),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -105.h,
          right: 150.w,
          child: Obx(() {
            final String imagePath = gameModeController.modeSvg;
            return CustomSvg(
              assetPath: imagePath,
              semanticsLabel: trKey(imagePath.split('/').last.split('.').first),
              height: 120.h,
              width: 95.w,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMobileArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDisabled,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled
              ? AppColors.grey.withOpacity(0.3)
              : AppColors.primaryRed,
        ),
        child: Icon(icon, color: Colors.white, size: 24.r),
      ),
    );
  }

  /// Fixed Desktop/Web Layout
  Widget _buildDesktopWebLayout(BuildContext context) {
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

          /// Desktop App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DesktopAppBar(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              title: '',
              subtitle: '',
            ),
          ),

          /// Main Content
          Positioned(
            top: screenHeight * 0.15, // Clear space for AppBar
            left: 0,
            right: 0,
            bottom: screenHeight * 0.12, // Space for bottom nav
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 1920 ? 1400 : screenWidth * 0.9,
                ),
                child: Column(
                  children: [
                    /// Main Pricing Card Display
                    Expanded(
                      flex: 5,
                      child: _buildDesktopPricingCards(context),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    /// Bottom Controls
                    _buildDesktopBottomControls(),
                  ],
                ),
              ),
            ),
          ),

          /// Bottom Navigation
          Positioned(
            bottom: 20,
            left: 0,
            right: -25,
            child: const Center(child: CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopPricingCards(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.pricingPlans.length,
              (index) {
            final plan = controller.pricingPlans[index];
            final bool isSelected = controller.currentPageIndex.value == index;

            return GestureDetector(
              onTap: () => controller.onPageChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: _getCardWidth(isSelected),
                height: _getCardHeight(),
                child: _buildDesktopPricingCard(context, plan, isSelected),
              ),
            );
          },
        ),
      );
    });
  }

  double _getCardWidth(bool isSelected) {
    double baseWidth;
    if (screenWidth >= 1920) {
      baseWidth = 350;
    } else if (screenWidth >= 1400) {
      baseWidth = 300;
    } else if (screenWidth >= 1200) {
      baseWidth = 280;
    } else {
      baseWidth = screenWidth * 0.25;
    }
    return isSelected ? baseWidth * 1.1 : baseWidth;
  }

  double _getCardHeight() {
    if (screenHeight >= 1080) return 450;
    if (screenHeight >= 900) return 400;
    if (screenHeight >= 768) return 350;
    return screenHeight * 0.55;
  }

  Widget _buildDesktopBottomControls() {
    return Container(
      width: screenWidth * 0.5,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.4,
            height: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CustomButton2(
              text: trKey('select_continue'),
              onPressed: controller.handleContinue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDisabled,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled
              ? AppColors.grey.withOpacity(0.3)
              : AppColors.primaryRed,
          boxShadow: !isDisabled ? [
            BoxShadow(
              color: AppColors.primaryRed.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopPricingCard(
      BuildContext context,
      Map<String, dynamic> plan,
      bool isSelected,
      ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Main Card
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: AppColors.softRed.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryRed,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primaryRed.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 8),
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top spacing for character image
                SizedBox(height: 60),

                /// Price
                Text(
                  plan['price'].toString(),
                  style: TextStyle(
                    fontSize: _getPriceFontSize(),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 24),

                /// Features List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        (plan['features'] as List).length,
                            (index) {
                          final feature = (plan['features'] as List)[index] as Map<String, dynamic>;
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  feature['included']
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: feature['included']
                                      ? AppColors.sucessColor
                                      : AppColors.grey,
                                  size: _getIconSize(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    trKey(feature['text']),
                                    style: TextStyle(
                                      fontSize: _getFeatureFontSize(),
                                      color: AppColors.textBlack,
                                      height: 1.3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Character Image - Positioned at top center
        Positioned(
          top: -50,
          left: 0,
          right: 0,
          child: Center(
            child: Obx(() {
              final String imagePath = gameModeController.modeSvg;
              return Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return CustomSvg(
                        assetPath: gameModeController.modeSvg,
                        semanticsLabel: trKey(
                          imagePath.split('/').last.split('.').first,
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  double _getPriceFontSize() {
    if (screenWidth >= 1920) return 32;
    if (screenWidth >= 1400) return 28;
    if (screenWidth >= 1200) return 24;
    return 22;
  }

  double _getFeatureFontSize() {
    if (screenWidth >= 1920) return 14;
    if (screenWidth >= 1400) return 13;
    if (screenWidth >= 1200) return 12;
    return 11;
  }

  double _getIconSize() {
    if (screenWidth >= 1920) return 18;
    if (screenWidth >= 1400) return 16;
    if (screenWidth >= 1200) return 15;
    return 14;
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
  ultraWide,
}