// lib/presentation/views/custom_ai_analysis_screen2.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_info_container.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class CustomAIAnalysisScreen2 extends StatelessWidget {
  const CustomAIAnalysisScreen2({super.key});

  String _safeTranslate(String? key, {String fallback = ''}) {
    if (key == null) return fallback;
    try { return key.tr; } catch (_) { return fallback; }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    if (sw >= 768) return _buildDesktopLayout(sw, sh);
    return _buildMobileLayout(sw, sh);
  }

  // ── MOBILE — unchanged ─────────────────────────────────────────────────────
  Widget _buildMobileLayout(double sw, double sh) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: AppDimensions.d18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomHeader(
                        title: _safeTranslate('custom'),
                        highlightedText: _safeTranslate('analysis'),
                        subtitle: '',
                        onBackTap: () => Get.offAllNamed(AppRoutes.teamKeyResultScreen),
                      ),
                      SizedBox(height: AppDimensions.d20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: CustomInfoContainer(
                          percentage: 80,
                          robotAsset: 'assets/images/robort.png',
                          title: _safeTranslate('ai_insights_title'),
                          description: _safeTranslate('ai_insights_description'),
                          percentageBarColor: AppColors.primaryRed,
                        ),
                      ),
                      SizedBox(height: AppDimensions.d25.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: CustomButton(
                          text: _safeTranslate('proceed'),
                          onPressed: () => Get.toNamed(AppRoutes.teamGameCompleteScreen),
                          icon: Icons.play_arrow,
                        ),
                      ),
                      SizedBox(height: AppDimensions.d30.h),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: sw * -0.07,
                top: sh * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(double sw, double sh) {
    final double containerWidth = sw > 1200 ? 720.0 : sw * 0.72;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/web_background.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw, screenHeight: sh,
              title: 'custom'.tr,
              subtitle: 'analysis'.tr,
            ),
          ),
          Positioned(
            top: 110, left: 0, right: 0, bottom: 80,
            child: Center(
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 8),
                  )],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(36),
                  child: _buildContent(sw, sh),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.offAllNamed(AppRoutes.teamKeyResultScreen),
              child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: ''),
            ),
          ),
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomInfoContainer(
          percentage: 80,
          robotAsset: 'assets/images/robort.png',
          title: _safeTranslate('ai_insights_title'),
          description: _safeTranslate('ai_insights_description'),
          percentageBarColor: AppColors.primaryRed,
        ),
        SizedBox(height: _dh(sw, 32)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 20.w),
          child: CustomButton(
            text: _safeTranslate('proceed'),
            onPressed: () => Get.toNamed(AppRoutes.teamGameCompleteScreen),
            icon: Icons.play_arrow,
          ),
        ),
      ],
    );
  }
}