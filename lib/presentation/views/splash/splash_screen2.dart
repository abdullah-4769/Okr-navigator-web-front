import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_image.dart';
import '../../widgets/custom_curved_arrow.dart';
import '../../widgets/custom_svg.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isMobile
            ? BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundTop,
              AppColors.backgroundBottom,
            ],
          ),
        )
            : BoxDecoration(
          image: DecorationImage(
            image:
            const AssetImage('assets/images/web_background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;

              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: screenHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: AppDimensions.d50.h),

                          // Top Logo
                          CustomSvg(
                            semanticsLabel: 'okr_logo'.tr,
                            assetPath: 'assets/images/okrnev.svg',
                            height: (isDesktop ? 80 : 70).h,
                            width: (isDesktop ? 120 : 90).w,
                          ),

                          SizedBox(height: AppDimensions.d24.h),

                          // Mask Image
                          CommonImage(
                            semanticsLabel: 'mask_group'.tr,
                            assetPath: 'assets/images/start_screen_img.png',
                            height: (isDesktop ? 240 : 190).h,
                            width: (isDesktop ? 260 : 200).w,
                          ),

                          SizedBox(height: AppDimensions.d20.h),

                          // Title
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.d16.w,
                            ),
                            child: Center(
                              child: Text(
                                'splash2_title'.tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w900,
                                  fontSize: isDesktop ? 36 : 28.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          SizedBox(height: AppDimensions.d16.h),

                          // Subtitle
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.d12.w,
                            ),
                            child: Center(
                              child: Text(
                                'splash2_subtitle'.tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                  color: AppColors.black,
                                  height: 1.5,
                                  fontSize: isDesktop ? 20 : 16.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.20),

                          // Bottom Logo
                          Center(
                            child: CustomSvg(
                              assetPath: 'assets/images/logo.svg',
                              width: AppDimensions.d30.w,
                              height: AppDimensions.d30.h,
                              semanticsLabel: '',
                            ),
                          ),
                          SizedBox(height: AppDimensions.d20.h),
                        ],
                      ),
                    ),
                  ),

                  // Left Arrow
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: screenHeight * 0.12,
                      ),
                      child: CustomCurvedArrow(
                        isLeft: true,
                        onTap: () => Get.offAllNamed(AppRoutes.splash1),
                        width: screenWidth.clamp(40.0, 70.0),
                        height: screenHeight.clamp(100.0, 160.0),
                      ),
                    ),
                  ),

                  // Right Arrow
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: screenHeight * 0.12,
                      ),
                      child: CustomCurvedArrow(
                        isLeft: false,
                        onTap: () => Get.toNamed(AppRoutes.home),
                        width: screenWidth.clamp(40.0, 70.0),
                        height: screenHeight.clamp(100.0, 160.0),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
