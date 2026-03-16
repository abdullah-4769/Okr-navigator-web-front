// lib/presentation/views/bonus_mode/key_result_input_screen.dart
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
import 'initiative_input_screen.dart';
import 'persistent_timer_widget.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class KeyResultsInputScreen extends StatelessWidget {
  final String objective;
  final TextEditingController kr1Ctrl = TextEditingController();
  final TextEditingController kr2Ctrl = TextEditingController();
  final BonusModeController controller = Get.find();

  KeyResultsInputScreen({required this.objective, super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    if (sw >= 768) return _buildDesktopLayout(sw, sh);
    return _buildMobileLayout(sw, sh);
  }

  // ── MOBILE — unchanged from original ──────────────────────────────────────
  Widget _buildMobileLayout(double sw, double sh) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: CustomBackground(
          child: Column(
            children: [
              CustomHeader(
                title: 'step_2_key_results'.tr,
                onBackTap: () => Get.back(),
              ),
              PersistentTimerWidget(showTimeUpAlert: true),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: _buildBody(sw, sh),
                  ),
                ),
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
              title: 'bonus_mode'.tr,
              subtitle: 'step_2_key_results'.tr,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(36, 20, 36, 0),
                      child: PersistentTimerWidget(showTimeUpAlert: true),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
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

  // ── SHARED BODY ────────────────────────────────────────────────────────────
  Widget _buildBody(double sw, double sh) {
    return Column(
      children: [
        SizedBox(height: _dh(sw, 32)),
        _buildInstructionCard(sw),
        SizedBox(height: _dh(sw, 32)),
        _buildKRField(sw, kr1Ctrl, 1),
        SizedBox(height: _dh(sw, 24)),
        _buildKRField(sw, kr2Ctrl, 2),
        SizedBox(height: _dh(sw, 50)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: CustomButton2(
            text: 'next_initiative'.tr,
            onPressed: () {
              if (kr1Ctrl.text.isEmpty || kr2Ctrl.text.isEmpty) {
                Get.snackbar('error'.tr, 'please_fill_key_results'.tr);
                return;
              }
              controller.setKeyResults(kr1Ctrl.text, kr2Ctrl.text);
              Get.to(() => InitiativeInputScreen(
                objective: objective,
                kr1: kr1Ctrl.text,
                kr2: kr2Ctrl.text,
              ));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard(double sw) {
    return Container(
      padding: EdgeInsets.all(_d(sw, 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primaryRed.withOpacity(0.1),
          AppColors.primaryRed.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 20.r),
      ),
      child: Column(
        children: [
          Icon(Icons.track_changes,
              size: sw >= 768 ? 44.0 : 48.sp,
              color: AppColors.primaryRed),
          SizedBox(height: _dh(sw, 16)),
          Text(
            'define_two_measurable_krs'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 20, desktop: 18),
                color: Colors.black87,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _dh(sw, 8)),
          Text(
            'kr_hint'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 14, desktop: 13), color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKRField(double sw, TextEditingController ctrl, int number) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: sw >= 768 ? 30.0 : 32.w,
              height: sw >= 768 ? 30.0 : 32.w,
              decoration: const BoxDecoration(
                  color: AppColors.primaryRed, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: _fs(sw, 16, desktop: 14)),
                ),
              ),
            ),
            SizedBox(width: _d(sw, 12)),
            Text(
              'key_result_$number'.tr,
              style: TextStyle(
                  fontSize: _fs(sw, 18, desktop: 16),
                  color: Colors.black87,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: _dh(sw, 12)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 20.r),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12, offset: const Offset(0, 4),
            )],
            border: sw >= 768
                ? Border.all(color: Colors.grey.shade200)
                : null,
          ),
          child: TextField(
            controller: ctrl,
            maxLines: 3,
            style: TextStyle(
                color: Colors.black87,
                fontSize: _fs(sw, 16, desktop: 15),
                height: 1.5),
            decoration: InputDecoration(
              hintText: 'example_kr_$number'.tr,
              hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: _fs(sw, 15, desktop: 14)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 20.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(_d(sw, 20)),
            ),
          ),
        ),
      ],
    );
  }
}