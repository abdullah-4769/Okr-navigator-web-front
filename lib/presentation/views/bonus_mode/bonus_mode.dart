// lib/presentation/views/bonus_mode/daily_training_home_screen.dart
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
import 'case_presentation_screen.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class DailyTrainingHomeScreen extends StatefulWidget {
  const DailyTrainingHomeScreen({super.key});

  @override
  State<DailyTrainingHomeScreen> createState() => _DailyTrainingHomeScreenState();
}

class _DailyTrainingHomeScreenState extends State<DailyTrainingHomeScreen> {
  final BonusModeController controller = Get.put(BonusModeController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkPlayedToday();
      controller.getStreakInfo();
    });
  }

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
              title: 'daily_okr_training'.tr,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      _buildStreakCard(sw),
                      SizedBox(height: 32.h),
                      Expanded(child: _buildMainCard(sw)),
                    ],
                  ),
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
              title: 'daily_okr_training'.tr,
              subtitle: 'daily_training_subtitle'.tr,
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
                  child: Column(
                    children: [
                      _buildStreakCard(sw),
                      const SizedBox(height: 28),
                      _buildMainCard(sw),
                      const SizedBox(height: 8),
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

  // ── SHARED WIDGETS ─────────────────────────────────────────────────────────
  Widget _buildStreakCard(double sw) {
    return Obx(() => Container(
      padding: EdgeInsets.all(_d(sw, 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.2), Colors.deepOrange.withOpacity(0.15)],
        ),
        borderRadius: BorderRadius.circular(sw >= 768 ? 20 : 24.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department,
              color: Colors.deepOrange,
              size: sw >= 768 ? 40.0 : 48.sp),
          SizedBox(width: _d(sw, 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'current_streak'.tr,
                style: TextStyle(
                    fontSize: _fs(sw, 16, desktop: 15), color: Colors.black54),
              ),
              Text(
                '${controller.streakDays.value} ${'days'.tr}',
                style: TextStyle(
                    fontSize: _fs(sw, 32, desktop: 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildMainCard(double sw) {
    return Obx(() {
      if (controller.isLoading.value)      return _buildLoadingCard(sw);
      if (controller.hasPlayedToday.value) return _buildAlreadyPlayedCard(sw);
      return _buildChallengeCard(sw);
    });
  }

  Widget _buildLoadingCard(double sw) => Container(
    height: sw >= 768 ? 220 : null,
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [AppColors.primaryRed, AppColors.primaryRed.withOpacity(0.8)]),
      borderRadius: BorderRadius.circular(sw >= 768 ? 24 : 32.r),
    ),
    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
  );

  Widget _buildAlreadyPlayedCard(double sw) => Container(
    padding: EdgeInsets.all(_d(sw, 32)),
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [Colors.grey.shade600, Colors.grey.shade700]),
      borderRadius: BorderRadius.circular(sw >= 768 ? 24 : 32.r),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle,
            size: sw >= 768 ? 56.0 : 64.sp,
            color: Colors.white),
        SizedBox(height: _dh(sw, 24)),
        Text(
          'already_played_today'.tr,
          style: TextStyle(
              fontSize: _fs(sw, 24, desktop: 22),
              fontWeight: FontWeight.bold,
              color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _dh(sw, 16)),
        Text(
          'come_back_tomorrow'.tr,
          style: TextStyle(
              fontSize: _fs(sw, 16, desktop: 15), color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildChallengeCard(double sw) => Container(
    padding: EdgeInsets.all(_d(sw, 32)),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primaryRed, AppColors.primaryRed.withOpacity(0.8)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(sw >= 768 ? 24 : 32.r),
      boxShadow: [BoxShadow(
        color: AppColors.primaryRed.withOpacity(0.4),
        blurRadius: 24, offset: const Offset(0, 12),
      )],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(_d(sw, 20)),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(Icons.psychology,
              size: sw >= 768 ? 56.0 : 64.sp, color: Colors.white),
        ),
        SizedBox(height: _dh(sw, 24)),
        Text(
          'todays_challenge'.tr,
          style: TextStyle(
              fontSize: _fs(sw, 28, desktop: 24),
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        SizedBox(height: _dh(sw, 16)),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: _d(sw, 20), vertical: _dh(sw, 12)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(sw >= 768 ? 12 : 12.r),
          ),
          child: Text(
            'apply_okr_principles'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: _fs(sw, 18, desktop: 16),
                color: Colors.white,
                height: 1.4),
          ),
        ),
        SizedBox(height: _dh(sw, 40)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: CustomButton2(
            text: 'start_training'.tr,
            onPressed: () => Get.to(() => CasePresentationScreen()),
          ),
        ),
      ],
    ),
  );
}