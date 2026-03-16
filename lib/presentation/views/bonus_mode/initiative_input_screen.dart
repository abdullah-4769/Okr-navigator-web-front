// lib/presentation/views/bonus_mode/initiative_input_screen.dart
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
import 'evaluation_loading_screen.dart';
import 'persistent_timer_widget.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class InitiativeInputScreen extends StatefulWidget {
  final String objective;
  final String kr1;
  final String kr2;

  const InitiativeInputScreen({
    required this.objective,
    required this.kr1,
    required this.kr2,
    super.key,
  });

  @override
  State<InitiativeInputScreen> createState() => _InitiativeInputScreenState();
}

class _InitiativeInputScreenState extends State<InitiativeInputScreen> {
  final TextEditingController initiativeCtrl = TextEditingController();
  final BonusModeController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // ✅ DO NOT START A NEW TIMER — already running from CasePresentationScreen
    print('⏱️ InitiativeInputScreen - Timer already running: ${controller.getFormattedTime()}');
  }

  @override
  void dispose() {
    // ✅ DO NOT STOP THE TIMER — stopped after evaluation
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
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: CustomBackground(
          child: Column(
            children: [
              CustomHeader(
                title: 'step_3_initiative'.tr,
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
              subtitle: 'step_3_initiative'.tr,
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
        _buildInputField(sw, initiativeCtrl),
        SizedBox(height: _dh(sw, 50)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: CustomButton2(
            text: 'submit_for_ai_evaluation'.tr,
            onPressed: () {
              if (initiativeCtrl.text.isEmpty) {
                Get.snackbar('error'.tr, 'please_enter_initiative'.tr);
                return;
              }
              controller.setInitiative(initiativeCtrl.text);
              Get.to(() => EvaluationLoadingScreen(
                objective: widget.objective,
                kr1: widget.kr1,
                kr2: widget.kr2,
                initiative: initiativeCtrl.text,
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
          Icon(Icons.lightbulb,
              size: sw >= 768 ? 44.0 : 48.sp,
              color: AppColors.primaryRed),
          SizedBox(height: _dh(sw, 16)),
          Text(
            'propose_one_actionable_initiative'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 20, desktop: 18),
                color: Colors.black87,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _dh(sw, 8)),
          Text(
            'initiative_hint'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 14, desktop: 13), color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(double sw, TextEditingController ctrl) {
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
        maxLines: 6,
        style: TextStyle(
            color: Colors.black87,
            fontSize: _fs(sw, 16, desktop: 15),
            height: 1.5),
        decoration: InputDecoration(
          hintText: 'example_initiative'.tr,
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