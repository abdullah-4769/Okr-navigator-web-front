// lib/presentation/views/bonus_mode/case_presentation_screen.dart
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
import 'objective_input_screen.dart';
import 'persistent_timer_widget.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class CasePresentationScreen extends StatefulWidget {
  final Map? selectedIndustry;

  const CasePresentationScreen({super.key, this.selectedIndustry});

  @override
  State<CasePresentationScreen> createState() => _CasePresentationScreenState();
}

class _CasePresentationScreenState extends State<CasePresentationScreen> {
  final BonusModeController controller = Get.find();
  bool isLoadingScenario = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScenarioAndStartTimer();
    });
  }

  Future<void> _loadScenarioAndStartTimer() async {
    try {
      setState(() => isLoadingScenario = true);
      final industryName = widget.selectedIndustry?['titleKey'] ?? 'Banking';
      const role = 'CEO';
      print('🔄 Generating scenario...');
      print('   Industry: $industryName');
      print('   Role: $role');
      await controller.generateScenario(role, industryName);
      print('✅ Scenario loaded:');
      print('   Title: ${controller.scenarioTitle.value}');
      print('   Description: ${controller.scenarioDescription.value}');
      setState(() => isLoadingScenario = false);
      controller.startCountdownTimer();
      print('⏱️ Timer started in CasePresentationScreen');
    } catch (e) {
      print('❌ Error loading scenario: $e');
      setState(() => isLoadingScenario = false);
    }
  }

  @override
  void dispose() {
    // ✅ DO NOT STOP TIMER — persists across screens
    super.dispose();
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
              title: 'todays_case'.tr,
              onBackTap: () {
                controller.stopCountdownTimer();
                Get.back();
              },
            ),
            _buildTimerBar(sw),
            Expanded(
              child: SafeArea(
                top: false,
                child: isLoadingScenario
                    ? Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
                    : SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: _buildBody(sw, sh),
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
              subtitle: 'todays_case'.tr,
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
                child: Column(
                  children: [
                    // Timer pinned at top of card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(36, 24, 36, 0),
                      child: _buildTimerBar(sw),
                    ),
                    Expanded(
                      child: isLoadingScenario
                          ? Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
                          : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(36, 16, 36, 36),
                        child: _buildBody(sw, sh),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () {
                controller.stopCountdownTimer();
                Get.back();
              },
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

  // ── SHARED: timer bar ──────────────────────────────────────────────────────
  Widget _buildTimerBar(double sw) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(
          horizontal: _d(sw, 24), vertical: _dh(sw, 12)),
      decoration: BoxDecoration(
        color: controller.isTimeWarning()
            ? Colors.red.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: sw >= 768 ? BorderRadius.circular(12) : null,
        border: sw >= 768 && controller.isTimeWarning()
            ? Border.all(color: Colors.red.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: controller.isTimeWarning() ? Colors.red : Colors.green,
            size: sw >= 500 ? 16.0 : 18.sp,
          ),
          SizedBox(width: _d(sw, 12)),
          Text(
            controller.getFormattedTime(),
            style: TextStyle(
              fontSize: _fs(sw, 16, desktop: 18),
              fontWeight: FontWeight.bold,
              color: controller.isTimeWarning() ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    ));
  }

  // ── SHARED BODY ────────────────────────────────────────────────────────────
  Widget _buildBody(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: _dh(sw, 30)),
        _buildInfoCard(sw,
          'industry'.tr,
          controller.scenarioTitle.value.isEmpty
              ? 'banking'.tr
              : controller.scenarioTitle.value,
          Icons.business,
        ),
        SizedBox(height: _dh(sw, 16)),
        _buildInfoCard(sw, 'vision'.tr, 'leading_digital_bank'.tr, Icons.visibility),
        SizedBox(height: _dh(sw, 16)),
        _buildInfoCard(sw, 'strategy'.tr, 'strategy_description'.tr, Icons.lightbulb_outline),
        SizedBox(height: _dh(sw, 32)),
        _buildProblemsSection(sw),
        SizedBox(height: _dh(sw, 50)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: CustomButton2(
            text: 'define_objective'.tr,
            onPressed: () => Get.to(() => ObjectiveInputScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(double sw, String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(_d(sw, 20)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(sw >= 768 ? 1.0 : 0.9),
        borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 20.r),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12, offset: const Offset(0, 4),
        )],
        border: sw >= 768
            ? Border.all(color: Colors.grey.shade200)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(_d(sw, 12)),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(sw >= 768 ? 12 : 12.r),
            ),
            child: Icon(icon,
                color: AppColors.primaryRed,
                size: sw >= 768 ? 26.0 : 28.sp),
          ),
          SizedBox(width: _d(sw, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: _fs(sw, 14, desktop: 13),
                      color: Colors.black54,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: _dh(sw, 6)),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: _fs(sw, 16, desktop: 15),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemsSection(double sw) {
    return Container(
      padding: EdgeInsets.all(_d(sw, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primaryRed.withOpacity(0.1),
          AppColors.primaryRed.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 20.r),
        border: Border.all(
            color: AppColors.primaryRed.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.primaryRed,
                  size: sw >= 768 ? 26.0 : 28.sp),
              SizedBox(width: _d(sw, 12)),
              Text(
                'problems_faced'.tr,
                style: TextStyle(
                    fontSize: _fs(sw, 18, desktop: 17),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed),
              ),
            ],
          ),
          SizedBox(height: _dh(sw, 16)),
          ...['digital_outages'.tr, 'high_operational_costs'.tr, 'slow_staff_adoption'.tr]
              .map((p) => Padding(
            padding: EdgeInsets.symmetric(vertical: _dh(sw, 8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: _dh(sw, 6)),
                  width: _d(sw, 8),
                  height: _d(sw, 8),
                  decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle),
                ),
                SizedBox(width: _d(sw, 12)),
                Expanded(
                  child: Text(
                    p,
                    style: TextStyle(
                        fontSize: _fs(sw, 15, desktop: 14),
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