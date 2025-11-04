import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/core/app_dimensions.dart';
import 'package:game_app/presentation/widgets/custom_svg.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: AppConstants.splashDuration));
    if (!mounted) return;


    await Get.offAllNamed(AppRoutes.language);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final bool isMobile = screenWidth < 768;
        final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
        final bool isDesktop = screenWidth >= 1024;

        // ✅ Helpers for logo size based on platform
        double okrLogoHeight() =>
            isMobile ? 60.h : isTablet ? screenHeight * 0.20 : screenHeight * 0.25;
        double okrLogoWidth() =>
            isMobile ? 70.w : isTablet ? screenWidth * 0.2 : screenWidth * 0.1;

        double bottomLogoSize() =>
            isMobile ? 15.w : isTablet ? screenWidth * 0.05: screenWidth * 0.06;

        return Scaffold(
          body: Stack(
            children: [
              /// ✅ Background
              Positioned.fill(
                child: isMobile
                    ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.backgroundTop,
                        AppColors.backgroundBottom
                      ],
                    ),
                  ),
                )
                    : Opacity(
                  opacity: 0.15,
                  child: Image.asset(
                    'assets/images/web_background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// ✅ Center OKR Logo
              Center(
                child: CustomSvg(
                  semanticsLabel: 'OKR Logo',
                  assetPath: 'assets/images/okrnev.svg',
                  height: okrLogoHeight(),
                  width: okrLogoWidth(),
                ),
              ),

              /// ✅ Bottom Company Logo
              Positioned(
                bottom: AppDimensions.d28.h,
                left: 0,
                right: 0,
                child: Center(
                  child: CustomSvg(
                    semanticsLabel: 'Company Logo',
                    assetPath: 'assets/images/logo.svg',
                    height: bottomLogoSize(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
}
