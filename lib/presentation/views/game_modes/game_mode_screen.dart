import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/game_mode_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});

  bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux;

  bool get isWeb => kIsWeb;

  bool get isMobile =>
      !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);

  // ✅ Font size helpers
  double _getTitleFontSize(bool isDesktop, bool isTablet) {
    if (isDesktop || isWeb) return 42.0;
    return isTablet ? 36.sp : 30.sp;
  }

  double _getSubtitleFontSize(bool isDesktop, bool isTablet) {
    if (isDesktop || isWeb) return 18.0;
    return isTablet ? 16.sp : 14.sp;
  }

  @override
  Widget build(BuildContext context) {
    final GameModeController controller = Get.find();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetGameMode();
    });

    final size = MediaQuery.of(context).size;

    if (isMobile) {
      // ✅ Mobile
      return _buildMobileVersion(controller, size);
    } else {
      // ✅ Desktop / Web
      return _buildWebDesktopVersion(controller, size);
    }
  }

  // ---------------- MOBILE ----------------
  Widget _buildMobileVersion(GameModeController controller, Size size) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final cardHeight = orientation == Orientation.portrait
            ? size.height * 0.45
            : size.height * 0.65;

        return Scaffold(
          body: CustomBackground(
            child: SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity, // ✅ make background fill screen
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: AppDimensions.d20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppDimensions.d20.h),
                      /// Header
                      CustomHeader(
                        title: "select".tr,
                        highlightedText: "game_mode".tr,
                        onBackTap: () => Get.offAllNamed(AppRoutes.home),
                        showDashboardIcon: false,
                      ),

                      SizedBox(height: AppDimensions.d10.h),

                      /// Cards Carousel (Adaptive height)
                      SizedBox(
                        height: cardHeight,
                        width: size.width,
                        child: PageView.builder(
                          controller: controller.pageController,
                          onPageChanged: controller.onPageChanged,
                          itemCount: controller.gameModes.length,
                          itemBuilder: (context, index) => Obx(() {
                            final bool isSelected =
                                controller.selectedIndex.value == index;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(
                                horizontal: isSelected ? 8.w : 12.w,
                                vertical: isSelected ? 0.h : 30.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryRed
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    spreadRadius: 1.r,
                                    blurRadius: 6.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// Game Mode Icon
                                  controller.gameModes[index]['icon'] != null
                                      ? SvgPicture.asset(
                                    controller.gameModes[index]['icon']!,
                                    height: size.height * 0.20,
                                    placeholderBuilder: (context) =>
                                        Container(
                                          height: size.height * 0.20,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image,
                                            size: 50.r,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                  )
                                      : Container(
                                    height: size.height * 0.20,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50.r,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.d12.h),

                                  /// Game Mode Title
                                  Text(
                                    (controller.gameModes[index]['title'] ?? '')
                                        .toString()
                                        .tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                      fontSize: (size.width * 0.05).sp,
                                      color: isSelected
                                          ? AppColors.primaryRed
                                          : Colors.black54,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      decoration: isSelected
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),

                      SizedBox(height: AppDimensions.d20.h),

                      /// Navigation Arrows
                      Obx(
                            () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildArrowButton(
                              icon: Icons.arrow_back,
                              onTap: controller.previousCard,
                              isDisabled: controller.selectedIndex.value == 0,
                            ),
                            SizedBox(width: AppDimensions.d20.w),
                            _buildArrowButton(
                              icon: Icons.arrow_forward,
                              onTap: controller.nextCard,
                              isDisabled: controller.selectedIndex.value ==
                                  controller.gameModes.length - 1,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppDimensions.d30.h),

                      /// Continue Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.d32.w,
                        ),
                        child: CustomButton(
                          text: 'select_continue'.tr,
                          onPressed: controller.navigateToPricingScreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- WEB / DESKTOP ----------------
  Widget _buildWebDesktopVersion(GameModeController controller, Size size) {
    final isLargeScreen = size.width > 1024;
    final cardHeight = isLargeScreen ? size.height * 0.55 : size.height * 0.50;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/web_background.png'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.04),

                /// Title
                Text(
                  "select".tr,
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: _getTitleFontSize(isDesktop, false),
                    fontFamily: "GothamUltra",
                  ),
                ),

                /// Subtitle
                Text(
                  "game_mode".tr,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: _getSubtitleFontSize(isDesktop, false),
                    fontFamily: "GothamBold",
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                Expanded(
                  child: Row(
                    children: [
                      if (isDesktop)
                        _buildDesktopArrow(
                          icon: Icons.arrow_back,
                          onTap: controller.previousCard,
                          controller: controller,
                          isLeft: true,
                        ),

                      /// Cards
                      Expanded(
                        child: _buildDesktopCarousel(
                            controller, size, cardHeight),
                      ),

                      if (isDesktop)
                        _buildDesktopArrow(
                          icon: Icons.arrow_forward,
                          onTap: controller.nextCard,
                          controller: controller,
                          isLeft: false,
                        ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                /// Continue Button
                SizedBox(
                  width: size.width * 0.4,
                  height: 70.h,
                  child: CustomButton(
                    text: 'select_continue'.tr,
                    onPressed: controller.navigateToPricingScreen,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),

          if (isDesktop)
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
        ],
      ),
    );
  }

  // ---------------- CARDS ----------------
  Widget _buildDesktopCarousel(
      GameModeController controller, Size size, double cardHeight) {
    return SizedBox(
      height: cardHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          controller.gameModes.length,
              (index) => Obx(() {
            final bool isSelected =
                controller.selectedIndex.value == index;
            return GestureDetector(
              onTap: () {
                controller.selectedIndex.value = index;
                controller.pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: _buildDesktopGameModeCard(
                  controller, index, isSelected, size, cardHeight),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDesktopGameModeCard(GameModeController controller, int index,
      bool isSelected, Size size, double cardHeight) {
    final cardWidth = size.width * 0.22;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: cardWidth,
      height: isSelected ? cardHeight : cardHeight * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryRed : Colors.transparent,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isSelected ? 30 : 20),
            spreadRadius: isSelected ? 2 : 1,
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Icon
          controller.gameModes[index]['icon'] != null
              ? Image.asset(
            controller.gameModes[index]['icon']!,
            height: cardHeight * 0.4,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: cardHeight * 0.4,
              color: Colors.grey[200],
              child: Icon(
                Icons.image,
                size: cardHeight * 0.15,
                color: Colors.grey[400],
              ),
            ),
          )
              : Container(
            height: cardHeight * 0.4,
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              size: cardHeight * 0.15,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: cardHeight * 0.05),

          /// Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              (controller.gameModes[index]['title'] ?? '').toString().tr,
              style: TextStyle(
                fontSize: 20,
                color: isSelected ? AppColors.primaryRed : Colors.black54,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                decoration: isSelected
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ARROWS ----------------
  Widget _buildDesktopArrow({
    required IconData icon,
    required VoidCallback onTap,
    required GameModeController controller,
    required bool isLeft,
  }) {
    return Obx(() {
      final isDisabled = isLeft
          ? controller.selectedIndex.value == 0
          : controller.selectedIndex.value ==
          controller.gameModes.length - 1;

      return GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDisabled ? Colors.grey.shade300 : AppColors.primaryRed,
          ),
          child: Icon(
            icon,
            color: isDisabled ? Colors.grey : Colors.white,
            size: 28,
          ),
        ),
      );
    });
  }

  /// Mobile navigation arrows
  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDisabled,
  }) =>
      GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: EdgeInsets.all(AppDimensions.d12.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDisabled ? Colors.grey.shade300 : AppColors.primaryRed,
          ),
          child: Icon(
            icon,
            color: isDisabled ? Colors.grey : Colors.white,
            size: AppDimensions.d24.r,
          ),
        ),
      );
}
