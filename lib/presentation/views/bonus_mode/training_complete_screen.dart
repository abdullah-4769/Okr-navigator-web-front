// lib/presentation/views/bonus_mode/training_complete_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../view_model/bonus_controller/bonus_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class TrainingCompleteScreen extends StatefulWidget {
  const TrainingCompleteScreen({super.key});

  @override
  State<TrainingCompleteScreen> createState() => _TrainingCompleteScreenState();
}

class _TrainingCompleteScreenState extends State<TrainingCompleteScreen>
    with SingleTickerProviderStateMixin {
  final BonusModeController controller = Get.find();
  late AnimationController _animationController;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStreakAndShowSnackbar();
    });
  }

  Future<void> _loadStreakAndShowSnackbar() async {
    try {
      print('📥 Loading streak data...');
      print('💾 Submitting score to backend...');
      await controller.submitBonusScore();
      print('✅ Score submitted');
      await controller.getStreakInfo();
      print('✅ Streak loaded: ${controller.streakDays.value} days');
      _showScoreSnackbar();
    } catch (e) {
      print('❌ Error: $e');
      _showScoreSnackbar();
    }
  }

  void _showScoreSnackbar() {
    final score = controller.evaluationScore.value;
    final badge = controller.badgeName.value;
    final streak = controller.streakDays.value;
    print('🎯 Showing snackbar: Score=$score, Badge=$badge, Streak=$streak');
    final String streakMessage = score < 60
        ? '${'streak'.tr}: $streak ${'days'.tr} (current)'
        : '${'streak'.tr}: $streak ${'days'.tr}';
    Get.snackbar(
      'today_score'.tr,
      '${'score'.tr}: $score/100\n${'obtained_score'.tr}: $badge\n$streakMessage',
      backgroundColor: _getScoreColor(score),
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
      padding: EdgeInsets.all(16.w),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.grey;
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
      body: SingleChildScrollView(
        child: CustomBackground(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Obx(() => _buildContent(sw, sh)),
            ),
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
              subtitle: 'training_completed'.tr,
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
        // Checkmark animation
        ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.elasticOut),
          ),
          child: Container(
            padding: EdgeInsets.all(_d(sw, 32)),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle,
                size: sw >= 768 ? 100.0 : 120.sp,
                color: Colors.green),
          ),
        ),

        SizedBox(height: _dh(sw, 40)),

        Text(
          'training_completed'.tr,
          style: TextStyle(
              fontSize: _fs(sw, 32, desktop: 28),
              fontWeight: FontWeight.bold,
              color: Colors.black87),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: _dh(sw, 24)),

        // Score card
        Container(
          padding: EdgeInsets.all(_d(sw, 20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              _getScoreColor(controller.evaluationScore.value).withOpacity(0.15),
              _getScoreColor(controller.evaluationScore.value).withOpacity(0.08),
            ]),
            borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 16.r),
            border: Border.all(
              color: _getScoreColor(controller.evaluationScore.value).withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'today_score'.tr,
                    style: TextStyle(
                        fontSize: _fs(sw, 18, desktop: 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  Text(
                    '${controller.evaluationScore.value}/100',
                    style: TextStyle(
                        fontSize: _fs(sw, 24, desktop: 22),
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(controller.evaluationScore.value)),
                  ),
                ],
              ),
              SizedBox(height: _dh(sw, 12)),
              const Divider(color: Colors.black12),
              SizedBox(height: _dh(sw, 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'obtained_score'.tr,
                    style: TextStyle(
                        fontSize: _fs(sw, 16, desktop: 14),
                        color: Colors.black54),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: _d(sw, 16), vertical: _dh(sw, 8)),
                    decoration: BoxDecoration(
                      color: _getScoreColor(controller.evaluationScore.value),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.badgeName.value,
                      style: TextStyle(
                          fontSize: _fs(sw, 14, desktop: 13),
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: _dh(sw, 24)),

        // Streak card
        Container(
          padding: EdgeInsets.all(_d(sw, 20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.orange.withOpacity(0.15),
              Colors.deepOrange.withOpacity(0.08),
            ]),
            borderRadius: BorderRadius.circular(sw >= 768 ? 16 : 16.r),
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department,
                      color: Colors.deepOrange,
                      size: sw >= 768 ? 30.0 : 32.sp),
                  SizedBox(width: _d(sw, 12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('streak'.tr,
                          style: TextStyle(
                              fontSize: _fs(sw, 14, desktop: 13),
                              color: Colors.black54)),
                      Row(
                        children: [
                          Text(
                            '${controller.streakDays.value}',
                            style: TextStyle(
                                fontSize: _fs(sw, 20, desktop: 18),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          SizedBox(width: _d(sw, 8)),
                          Text(
                            'days'.tr,
                            style: TextStyle(
                                fontSize: _fs(sw, 20, desktop: 18),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: _dh(sw, 16)),
              // Conditional streak message
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _d(sw, 16), vertical: _dh(sw, 8)),
                decoration: BoxDecoration(
                  color: controller.evaluationScore.value < 60
                      ? Colors.orange.withOpacity(0.15)
                      : Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.evaluationScore.value < 60
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.green.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  controller.evaluationScore.value < 60
                      ? 'low_score_streak_not_increment'.tr
                      : 'great_job_streak_increment'.tr,
                  style: TextStyle(
                    fontSize: _fs(sw, 12, desktop: 12),
                    color: controller.evaluationScore.value < 60
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: _dh(sw, 20)),

        Text('see_you_tomorrow'.tr,
            style: TextStyle(
                fontSize: _fs(sw, 16, desktop: 15), color: Colors.black54)),

        SizedBox(height: _dh(sw, 48)),

        Obx(() {
          if (isLoading.value) {
            return CircularProgressIndicator(color: AppColors.primaryRed);
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sw >= 768 ? 40.0 : 0),
            child: CustomButton2(
              text: 'back_to_home'.tr,
              onPressed: () async {
                isLoading.value = true;
                await Future.delayed(const Duration(seconds: 1));
                isLoading.value = false;
                Get.offAllNamed(AppRoutes.home);
              },
            ),
          );
        }),
      ],
    );
  }
}