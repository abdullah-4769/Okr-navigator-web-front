// lib/presentation/views/bonus_mode/badge_reward_screen.dart
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
import 'training_complete_screen.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class BadgeRewardScreen extends StatefulWidget {
  const BadgeRewardScreen({super.key});

  @override
  State<BadgeRewardScreen> createState() => _BadgeRewardScreenState();
}

class _BadgeRewardScreenState extends State<BadgeRewardScreen>
    with SingleTickerProviderStateMixin {
  final BonusModeController controller = Get.find();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
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
              subtitle: 'badge_reward_subtitle'.tr,
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
    return Obx(() => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Trophy icon with glow
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(_d(sw, 40)),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.amber.withOpacity(0.3), Colors.transparent],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events,
                size: sw >= 768 ? 120.0 : 140.sp,
                color: Colors.amber),
          ),
        ),

        SizedBox(height: _dh(sw, 40)),

        // Badge name banner
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: _d(sw, 32), vertical: _dh(sw, 16)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
              borderRadius: BorderRadius.circular(sw >= 768 ? 20 : 20.r),
              boxShadow: [BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 20, offset: const Offset(0, 8),
              )],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    controller.badgeName.value,
                    style: TextStyle(
                      fontSize: _fs(sw, 24, desktop: 22),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: _d(sw, 10)),
                Text(
                  'badge_earned'.tr,
                  style: TextStyle(
                    fontSize: _fs(sw, 24, desktop: 22),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: _dh(sw, 24)),

        // Score card
        Container(
          padding: EdgeInsets.all(_d(sw, 20)),
          decoration: BoxDecoration(
            color: sw >= 768
                ? Colors.grey.shade50
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 16.r),
            border: sw >= 768
                ? Border.all(color: Colors.amber.withOpacity(0.3))
                : null,
          ),
          child: Text(
            '${'score'.tr}: ${controller.evaluationScore.value}/100',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _fs(sw, 18, desktop: 18),
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),

        SizedBox(height: _dh(sw, 60)),

        // Continue button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
          child: CustomButton2(
            text: 'continue'.tr,
            onPressed: () async {
              print('📤 Submitting badge score...');
              await controller.submitBonusScore();
              print('✅ Badge score submitted');
              Get.to(() => const TrainingCompleteScreen());
            },
          ),
        ),
      ],
    ));
  }
}