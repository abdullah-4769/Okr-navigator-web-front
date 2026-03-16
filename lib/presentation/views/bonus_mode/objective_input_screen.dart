// lib/presentation/views/bonus_mode/objective_input_screen.dart
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
import 'key_result_input_screen.dart';
import 'persistent_timer_widget.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class ObjectiveInputScreen extends StatelessWidget {
  final TextEditingController objectiveCtrl = TextEditingController();
  final BonusModeController controller = Get.find();

  ObjectiveInputScreen({super.key});

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
                title: 'step_1_objective'.tr,
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
              subtitle: 'step_1_objective'.tr,
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
        SizedBox(height: _dh(sw, 40)),
        _buildInstructionCard(sw),
        SizedBox(height: _dh(sw, 32)),
        _buildInputField(sw, objectiveCtrl, 'example_objective'.tr, 5),
        SizedBox(height: _dh(sw, 50)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: CustomButton2(
            text: 'next_key_results'.tr,
            onPressed: () {
              if (objectiveCtrl.text.isEmpty) {
                Get.snackbar('error'.tr, 'please_enter_objective'.tr);
                return;
              }
              controller.setObjective(objectiveCtrl.text);
              Get.to(() => KeyResultsInputScreen(objective: objectiveCtrl.text));
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
          Icon(Icons.flag,
              size: sw >= 768 ? 44.0 : 48.sp,
              color: AppColors.primaryRed),
          SizedBox(height: _dh(sw, 16)),
          Text(
            'write_one_ambitious_objective'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 20, desktop: 18),
                color: Colors.black87,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _dh(sw, 8)),
          Text(
            'objective_hint'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 14, desktop: 13), color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(double sw, TextEditingController ctrl,
      String hint, int maxLines) {
    return Container(
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
        maxLines: maxLines,
        style: TextStyle(
            color: Colors.black87,
            fontSize: _fs(sw, 16, desktop: 15),
            height: 1.5),
        decoration: InputDecoration(
          hintText: hint,
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
    );
  }
}