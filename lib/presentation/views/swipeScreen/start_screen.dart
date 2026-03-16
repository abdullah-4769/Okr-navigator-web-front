import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../services/shared_preference.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_image.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/swipe_to_start.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool fromGameMode = false;
  String? selectedMode;

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1024;
  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  void initState() {
    super.initState();
    _checkNavigationSource();
  }

  void _checkNavigationSource() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      fromGameMode = args['fromGameMode'] ?? false;
      selectedMode = args['selectedMode'];
      print('🎮 StartScreen - From GameMode: $fromGameMode');
      print('🎮 StartScreen - Selected Mode: $selectedMode');
    }
  }

  String _getWelcomeTitle() {
    if (!fromGameMode || selectedMode == null) {
      return 'welcome_to_okr_navigator'.tr;
    }
    switch (selectedMode) {
      case 'solo':
        return 'ready_for_solo_mode'.tr;
      case 'team':
        return 'ready_for_team_mode'.tr;
      case 'campaign':
        return 'ready_for_campaign_mode'.tr;
      default:
        return 'welcome_to_okr_navigator'.tr;
    }
  }

  String _getModeDescription() {
    if (!fromGameMode || selectedMode == null) {
      return 'start_screen_description'.tr;
    }
    switch (selectedMode) {
      case 'solo':
        return 'solo_mode_description'.tr;
      case 'team':
        return 'team_mode_description'.tr;
      case 'campaign':
        return 'campaign_mode_description'.tr;
      default:
        return 'start_screen_description'.tr;
    }
  }

  void _handleSwipeComplete() async {
    if (fromGameMode && selectedMode != null) {
      // Coming from game mode selection - proceed to pricing screen WITH MODE ARGUMENT
      print('🎮 Proceeding to PricingScreen with mode: $selectedMode');

      // Save the mode
      await SharedPrefs.saveGameMode(selectedMode!);

      // Navigate to pricing screen WITH the mode as argument
      Get.offAllNamed(
        AppRoutes.pricingScreen,
        arguments: {'selectedMode': selectedMode}, // THIS IS THE KEY FIX
      );
    } else {
      // Normal flow - go to splash1
      Get.offAllNamed(AppRoutes.splash1);
    }
  }

  double _fontSize(BuildContext context, double mobile, double tablet, double desktop) {
    if (_isMobile(context)) return mobile.sp;
    if (_isTablet(context)) return tablet;
    return desktop;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    body: Stack(
      children: [
        // Background (keep your existing UI)
        if (_isDesktop(context) || _isTablet(context))
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
              ),
            ),
          ),

        // Content
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (_isDesktop(context) || _isTablet(context)) {
                // Web/Desktop Layout
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.d32.w,
                        vertical: AppDimensions.d24.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomSvg(
                                  assetPath: AppAssets.okrLogo,
                                  width: AppDimensions.d100.w,
                                  height: AppDimensions.d90.h,
                                  semanticsLabel: '',
                                ),
                                SizedBox(height: AppDimensions.d32.h),

                                Text(
                                  _getWelcomeTitle(), // Dynamic title
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontSize: _fontSize(context, 22, 28, 34),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: AppDimensions.d16.h),

                                Text(
                                  _getModeDescription(), // Dynamic description
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                    color: AppColors.black,
                                    height: 1.6,
                                    fontSize: _fontSize(context, 14, 16, 18),
                                  ),
                                ),

                                SizedBox(height: AppDimensions.d40.h),

                                SwipeToStart(
                                  onSwipeComplete: _handleSwipeComplete,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: AppDimensions.d40.w),

                          Expanded(
                            flex: 3,
                            child: Center(
                              child: CommonImage(
                                assetPath: 'assets/images/start_screen_img.png',
                                width: _isTablet(context)
                                    ? AppDimensions.d200.w
                                    : AppDimensions.d300.w,
                                height: _isTablet(context)
                                    ? AppDimensions.d240.h
                                    : 350.h,
                                semanticsLabel: '',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // Mobile Layout (keep your existing mobile UI)
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.d24.w),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                CustomSvg(
                                  assetPath: AppAssets.okrLogo,
                                  width: AppDimensions.d90.w,
                                  height: AppDimensions.d80.h,
                                  semanticsLabel: '',
                                ),
                                SizedBox(height: AppDimensions.d16.h),
                              ],
                            ),
                            SizedBox(height: AppDimensions.d20.h),

                            CommonImage(
                              assetPath: 'assets/images/start_screen_img.png',
                              width: AppDimensions.d180.w,
                              height: AppDimensions.d200.h,
                              semanticsLabel: '',
                            ),

                            SizedBox(height: AppDimensions.d40.h),

                            Text(
                              _getWelcomeTitle(),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                color: AppColors.primaryBlue,
                                fontSize: _fontSize(context, 22, 28, 34),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: AppDimensions.d16.h),

                            Text(
                              _getModeDescription(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: AppColors.black,
                                height: 1.5,
                                fontSize: _fontSize(context, 14, 16, 18),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: AppDimensions.d40.h),

                            SwipeToStart(
                              onSwipeComplete: _handleSwipeComplete,
                            ),

                            SizedBox(height: AppDimensions.d40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}