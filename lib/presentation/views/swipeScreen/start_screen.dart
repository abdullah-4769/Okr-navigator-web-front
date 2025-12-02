import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_image.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/swipe_to_start.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1024;
  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // ✅ Responsive font size helper
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
        // ---------------- Background ----------------
        if (_isDesktop(context) || _isTablet(context))
        // Web / Desktop → Background image with opacity
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
        // Mobile → Gradient background
          Container(
            decoration:  BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
              ),
            ),
          ),

        // ---------------- Content ----------------
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (_isDesktop(context) || _isTablet(context)) {
                // ---------------- Web / Desktop / Tablet Layout ----------------
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
                          // ---------- Left Section (Text + Logo) ----------
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo
                                CustomSvg(
                                  assetPath: AppAssets.okrLogo,
                                  width: AppDimensions.d100.w,
                                  height: AppDimensions.d90.h,
                                  semanticsLabel: '',
                                ),
                                SizedBox(height: AppDimensions.d32.h),

                                // Title
                                Text(
                                  'welcome_to_okr_navigator'.tr,
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

                                // Description
                                Text(
                                  'start_screen_description'.tr,
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

                                // Swipe Button (aligned left in web/tablet)
                                SwipeToStart(
                                  onSwipeComplete: () {
                                    Get.offAllNamed(AppRoutes.splash1);
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: AppDimensions.d40.w),

                          // ---------- Right Section (Image) ----------
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
                // ---------------- Mobile Layout (Unchanged) ----------------
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
                            // Logo
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

                            // MaskGroup Image
                            CommonImage(
                              assetPath: 'assets/images/start_screen_img.png',
                              width: AppDimensions.d180.w,
                              height: AppDimensions.d200.h,
                              semanticsLabel: '',
                            ),

                            SizedBox(height: AppDimensions.d40.h),

                            // Title
                            Text(
                              'welcome_to_okr_navigator'.tr,
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

                            // Description
                            Text(
                              'start_screen_description'.tr,
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
                              onSwipeComplete: () {
                                Get.offAllNamed(AppRoutes.splash1);
                              },
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
