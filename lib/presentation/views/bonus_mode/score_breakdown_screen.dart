// lib/presentation/views/bonus_mode/score_breakdown_screen.dart
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
import 'feed_back_bonus.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class ScoringBreakdownScreen extends StatelessWidget {
  final BonusModeController controller = Get.find();

  ScoringBreakdownScreen({super.key});

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
              title: 'evaluation_results'.tr,
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
              subtitle: 'evaluation_results'.tr,
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
        _buildOverallScoreCard(sw),
        SizedBox(height: _dh(sw, 32)),
        _buildDetailedScoresCard(sw),
        SizedBox(height: _dh(sw, 50)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: CustomButton2(
            text: 'see_feedback'.tr,
            onPressed: () => Get.to(() => FeedbackBonusScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallScoreCard(double sw) {
    final score = controller.evaluationScore.value;
    final Color scoreColor =
    score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red);

    return Container(
      padding: EdgeInsets.all(_d(sw, 32)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          scoreColor.withOpacity(0.7),
          scoreColor.withOpacity(0.5),
        ]),
        borderRadius: BorderRadius.circular(sw >= 768 ? 24 : 30.r),
        boxShadow: [BoxShadow(
          color: scoreColor.withOpacity(0.4),
          blurRadius: 20, offset: const Offset(0, 10),
        )],
      ),
      child: Column(
        children: [
          Icon(Icons.stars,
              color: Colors.white, size: sw >= 768 ? 44.0 : 48.sp),
          SizedBox(height: _dh(sw, 12)),
          Text(
            'overall_score'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 20, desktop: 18),
                color: Colors.white70,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(height: _dh(sw, 8)),
          Text(
            '$score',
            style: TextStyle(
                fontSize: sw >= 768 ? 72.0 : 80.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          Text(
            score >= 80 ? 'excellent_performance'.tr : 'good_performance'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 18, desktop: 17), color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedScoresCard(double sw) {
    return Container(
      padding: EdgeInsets.all(_d(sw, 24)),
      decoration: BoxDecoration(
        color: sw >= 768 ? Colors.grey.shade50 : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(sw >= 768 ? 20 : 24.r),
        border: sw >= 768 ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'detailed_breakdown'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 20, desktop: 18),
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          SizedBox(height: _dh(sw, 20)),
          _buildScoreBar(sw, 'objective_quality'.tr, controller.objectiveScore.value),
          _buildScoreBar(sw, 'key_results_quality'.tr, controller.krScore.value),
          _buildScoreBar(sw, 'initiative_impact'.tr, controller.initiativeScore.value),
          _buildScoreBar(sw, 'global_alignment'.tr, controller.alignmentScore.value),
          _buildScoreBar(sw, 'contextual_relevance'.tr, controller.relevanceScore.value),
        ],
      ),
    );
  }

  Widget _buildScoreBar(double sw, String label, int value) {
    final Color color =
    value >= 80 ? Colors.green : (value >= 60 ? Colors.orange : Colors.red);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: _dh(sw, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: _fs(sw, 16, desktop: 15),
                      color: Colors.black87,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$value%',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: _fs(sw, 16, desktop: 15)),
              ),
            ],
          ),
          SizedBox(height: _dh(sw, 8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(sw >= 768 ? 8 : 8.r),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: sw >= 768 ? 10 : 10.h,
            ),
          ),
        ],
      ),
    );
  }
}