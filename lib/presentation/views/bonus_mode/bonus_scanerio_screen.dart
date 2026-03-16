// lib/presentation/views/bonus_mode/bonus_scenario_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../view_model/bonus_controller/bonus_controller.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class BonusScenarioLoadingScreen extends StatelessWidget {
  final controller = Get.find<BonusModeController>();

  BonusScenarioLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    if (sw >= 768) return _buildDesktopLayout(sw, sh);
    return _buildMobileLayout(sw, sh);
  }

  // ── MOBILE ─────────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(double sw, double sh) {
    return Scaffold(
      body: CustomBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryRed, strokeWidth: 6),
                    SizedBox(height: 30.h),
                    Text(
                      'ai_creating_scenario'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'based_on_role_industry'.tr,
                      style: TextStyle(fontSize: 16.sp, color: Colors.white70),
                    ),
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
              title: 'bonus_mode'.tr,
              subtitle: 'generating_scenario'.tr,
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
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryRed, strokeWidth: 6),
                      SizedBox(height: _dh(sw, 30)),
                      Text(
                        'ai_creating_scenario'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: _fs(sw, 20, desktop: 22), fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: _dh(sw, 16)),
                      Text(
                        'based_on_role_industry'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: _fs(sw, 16, desktop: 16), color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
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
}