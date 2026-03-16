// lib/presentation/views/bonus_mode/feed_back_bonus.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../view_model/bonus_controller/bonus_controller.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import 'badge_reward_screen.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class FeedbackBonusScreen extends StatelessWidget {
  final BonusModeController controller = Get.find();

  FeedbackBonusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    if (sw >= 768) return _buildDesktopLayout(sw, sh);
    return _buildMobileLayout(sw, sh);
  }

  // ── MOBILE — unchanged from original ──────────────────────────────────────
  Widget _buildMobileLayout(double sw, double sh) {
    return Scaffold(
      body: CustomBackground(
        child: Column(
          children: [
            CustomHeader(
              title: 'ai_feedback'.tr,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Obx(() => _buildContent(sw, sh)),
                ),
              ),
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
              subtitle: 'ai_feedback'.tr,
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
                  child: Obx(() => _buildContent(sw, sh)),
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

  // ── SHARED CONTENT ─────────────────────────────────────────────────────────
  Widget _buildContent(double sw, double sh) {
    return Column(
      children: [
        SizedBox(height: _dh(sw, 32)),
        _buildFeedbackCard(sw),
        SizedBox(height: _dh(sw, 28)),
        _buildSection(sw, 'strengths'.tr, controller.strengths, Colors.green, Icons.check_circle),
        SizedBox(height: _dh(sw, 24)),
        _buildSection(sw, 'improvements'.tr, controller.improvements, Colors.orange, Icons.lightbulb_outline),
        SizedBox(height: _dh(sw, 50)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: CustomButton2(
            text: 'view_badge_reward'.tr,
            onPressed: () => Get.to(() => const BadgeRewardScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(double sw) {
    return Container(
      padding: EdgeInsets.all(_d(sw, 28)),
      decoration: BoxDecoration(
        color: sw >= 768 ? Colors.grey.shade50 : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(sw >= 768 ? 20 : 24.r),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16, offset: const Offset(0, 4),
        )],
        border: sw >= 768
            ? Border.all(color: Colors.grey.shade200)
            : null,
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome,
              size: sw >= 768 ? 38.0 : 40.sp,
              color: AppColors.primaryRed),
          SizedBox(height: _dh(sw, 16)),
          Text(
            controller.feedbackText.value,
            style: TextStyle(
                fontSize: _fs(sw, 18, desktop: 16),
                color: Colors.black87,
                height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(double sw, String title, RxList<String> items,
      Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(_d(sw, 24)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 20.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: sw >= 768 ? 26.0 : 28.sp),
              SizedBox(width: _d(sw, 12)),
              Text(
                title,
                style: TextStyle(
                    fontSize: _fs(sw, 20, desktop: 18),
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
          SizedBox(height: _dh(sw, 16)),
          ...items.map((item) => Padding(
            padding: EdgeInsets.symmetric(vertical: _dh(sw, 8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: _dh(sw, 6)),
                  width: _d(sw, 8),
                  height: _d(sw, 8),
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                SizedBox(width: _d(sw, 12)),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                        fontSize: _fs(sw, 16, desktop: 15),
                        color: Colors.black87,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}