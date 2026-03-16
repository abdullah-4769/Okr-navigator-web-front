// lib/presentation/views/bonus_mode/evaluation_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../view_model/bonus_controller/bonus_controller.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import 'score_breakdown_screen.dart';
import 'training_complete_screen.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class EvaluationLoadingScreen extends StatefulWidget {
  final String objective;
  final String kr1;
  final String kr2;
  final String initiative;

  const EvaluationLoadingScreen({
    required this.objective,
    required this.kr1,
    required this.kr2,
    required this.initiative,
    super.key,
  });

  @override
  State<EvaluationLoadingScreen> createState() => _EvaluationLoadingScreenState();
}

class _EvaluationLoadingScreenState extends State<EvaluationLoadingScreen>
    with SingleTickerProviderStateMixin {
  final BonusModeController controller = Get.find();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startEvaluation());
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startEvaluation() async {
    try {
      print('🔍 Starting evaluation...');
      await controller.evaluateUserResponse(
        objective: widget.objective,
        keyResults: '${widget.kr1}, ${widget.kr2}',
        initiative: widget.initiative,
      );
      print('✅ Evaluation done');
      print('   Score: ${controller.evaluationScore.value}');
      print('   Badge: ${controller.badgeName.value}');
      controller.stopCountdownTimer();
      print('⏱️ Timer stopped after evaluation');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _routeBasedOnBadge();
    } catch (e) {
      print('❌ Evaluation failed: $e');
      controller.stopCountdownTimer();
      if (mounted) {
        Get.snackbar('Error', 'Evaluation failed: $e',
            backgroundColor: Colors.red);
        Get.back();
      }
    }
  }

  void _routeBasedOnBadge() {
    final badge = controller.badgeName.value.toLowerCase().trim();
    final score = controller.evaluationScore.value;
    print('🎯 Badge-based routing:');
    print('   Badge: $badge');
    print('   Score: $score');
    if (badge == 'none' || badge.isEmpty || score < 60) {
      print('❌ No badge earned (score < 60) - Going to TrainingCompleteScreen');
      Get.off(() => const TrainingCompleteScreen());
    } else {
      print('🏅 Badge earned: $badge - Going to ScoringBreakdownScreen');
      Get.off(() => ScoringBreakdownScreen());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: _buildContent(sw, sh),
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
              subtitle: 'evaluating_subtitle'.tr,
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
                  child: _buildContent(sw, sh),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(_d(sw, 40)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(sw >= 768 ? 1 : 0.9),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.3),
                blurRadius: 20, spreadRadius: 5,
              )],
              border: sw >= 768
                  ? Border.all(color: AppColors.primaryRed.withOpacity(0.2), width: 2)
                  : null,
            ),
            child: CircularProgressIndicator(
                color: AppColors.primaryRed, strokeWidth: 6),
          ),
        ),
        SizedBox(height: _dh(sw, 50)),
        Text(
          'ai_evaluating_okr'.tr,
          style: TextStyle(
            fontSize: _fs(sw, 26, desktop: 24),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _dh(sw, 20)),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: _d(sw, 20), vertical: _dh(sw, 12)),
          decoration: BoxDecoration(
            color: sw >= 768
                ? Colors.grey.shade50
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(sw >= 768 ? 12 : 12.r),
            border: sw >= 768
                ? Border.all(color: Colors.grey.shade200)
                : null,
          ),
          child: Text(
            'checking_quality_alignment_relevance'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: _fs(sw, 16, desktop: 15),
                color: Colors.black87,
                height: 1.4),
          ),
        ),
      ],
    );
  }
}