import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/game_mode_controller.dart';
import '../../../controllers/pricing_controller.dart';
import '../../../core/app_colors.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_curved_arrow.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button2.dart';

class PricingScreen extends StatelessWidget {
  PricingScreen({super.key});

  final PricingController controller = Get.put(PricingController());
  final PageController pageController = PageController(viewportFraction: 0.85);
  final GameModeController gameModeController = Get.find();

  String trKey(Object? key) => key != null ? key.toString().tr : '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 900;

    return isWeb
        ? _buildWebLayout(context)
        : _buildMobileLayout(context);
  }

  // ─── MOBILE (unchanged) ───────────────────────────────────────────────────
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.offAllNamed(AppRoutes.gameMode),
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

                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: controller.pricingPlans.length,
                    onPageChanged: controller.onPageChanged,
                    itemBuilder: (context, index) {
                      final plan = controller.pricingPlans[index];
                      return Obx(() {
                        final bool isSelected =
                            controller.currentPageIndex.value == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(
                            horizontal: isSelected ? 20.w : 24.w,
                            vertical: 90.h,
                          ),
                          child: _buildMobileCard(plan, isSelected, context),
                        );
                      });
                    },
                  ),
                ),

                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => _buildMobileArrowButton(
                        icon: Icons.arrow_back,
                        isDisabled: controller.currentPageIndex.value == 0,
                        onTap: () => controller.previousCard(pageController),
                      )),
                      SizedBox(
                        width: screenWidth * 0.45,
                        child: CustomButton2(
                          text: trKey('select_continue'),
                          onPressed: controller.handleContinue,
                        ),
                      ),
                      Obx(() => _buildMobileArrowButton(
                        icon: Icons.arrow_forward,
                        isDisabled: controller.currentPageIndex.value ==
                            controller.pricingPlans.length - 1,
                        onTap: () => controller.nextCard(pageController),
                      )),
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

  // ─── ORIGINAL WEB LAYOUT (RESTORED) ────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Desktop App Bar
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

          // Main Content
          Positioned(
            top: screenHeight * 0.15,
            left: 0,
            right: 0,
            bottom: screenHeight * 0.12,
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 1920 ? 1400 : screenWidth * 0.9,
                ),
                child: Column(
                  children: [
                    // Pricing Cards
                    Expanded(
                      flex: 5,
                      child: _buildWebPricingCards(),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Continue Button
                    _buildWebBottomControls(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation
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

  Widget _buildWebPricingCards() {
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
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: _getCardWidth(isSelected),
                height: _getCardHeight(),
                child: _buildWebPricingCard(plan, isSelected),
              ),
            );
          },
        ),
      );
    });
  }

  double _getCardWidth(bool isSelected) {
    final screenWidth = Get.width;
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
    final screenHeight = Get.height;
    if (screenHeight >= 1080) return 450;
    if (screenHeight >= 900) return 400;
    if (screenHeight >= 768) return 350;
    return screenHeight * 0.55;
  }

  Widget _buildWebBottomControls() {
    final screenWidth = Get.width;

    return Container(
      width: screenWidth * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.4,
            height: 70,
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

  Widget _buildWebPricingCard(
      Map<String, dynamic> plan,
      bool isSelected,
      ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card
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
                // Space for character image
                const SizedBox(height: 60),

                // Price
                Text(
                  plan['price'].toString(),
                  style: TextStyle(
                    fontSize: _getPriceFontSize(),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 24),

                // Features List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        (plan['features'] as List).length,
                            (index) {
                          final feature = (plan['features'] as List)[index] as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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

        // Character Image at top center
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

        // Mode name badge (optional - add if you want)
        if (isSelected)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                gameModeController.selectedMode.value.capitalizeFirst ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Mobile Card (separate from web)
  Widget _buildMobileCard(
      Map<String, dynamic> plan,
      bool isSelected,
      BuildContext context
      ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: isSelected ? 10 : 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: AppColors.primaryRed),
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
                  plan['price'].toString(),
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
                  itemCount: (plan['features'] as List).length,
                  separatorBuilder: (_, __) => Divider(
                    height: 12.h,
                    color: AppColors.grey.withOpacity(0.3),
                  ),
                  itemBuilder: (_, index) {
                    final feature = (plan['features'] as List)[index] as Map<String, dynamic>;
                    return Row(
                      children: [
                        Icon(
                          feature['included']
                              ? Icons.check_circle
                              : Icons.cancel,
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

  // Mobile Arrow Button
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

  // Web font size helpers
  double _getPriceFontSize() {
    final screenWidth = Get.width;
    if (screenWidth >= 1920) return 32;
    if (screenWidth >= 1400) return 28;
    if (screenWidth >= 1200) return 24;
    return 22;
  }

  double _getFeatureFontSize() {
    final screenWidth = Get.width;
    if (screenWidth >= 1920) return 14;
    if (screenWidth >= 1400) return 13;
    if (screenWidth >= 1200) return 12;
    return 11;
  }

  double _getIconSize() {
    final screenWidth = Get.width;
    if (screenWidth >= 1920) return 18;
    if (screenWidth >= 1400) return 16;
    if (screenWidth >= 1200) return 15;
    return 14;
  }
}