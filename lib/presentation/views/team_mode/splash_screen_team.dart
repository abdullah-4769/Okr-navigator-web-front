import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_curved_arrow.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768) return tablet ?? mobile;
  return mobile.sp;
}

double _d(double sw, double v) => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class SplashScreenTeam extends StatelessWidget {
  const SplashScreenTeam({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    if (sw >= 768) return _buildDesktopLayout(sw, sh);
    return _buildMobileLayout(sw, sh);
  }

  // ── MOBILE — original layout preserved ────────────────────────────────────
  Widget _buildMobileLayout(double sw, double sh) {
    final isPortrait = sh > sw;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: sh * 0.06),

                    /// Top Logo
                    CustomSvg(
                      semanticsLabel: 'okr_logo'.tr,
                      assetPath: 'assets/images/okrnev.svg',
                      height: sh * 0.08,
                      width: sw * 0.25,
                    ),

                    SizedBox(height: sh * 0.003),

                    /// Team Image
                    CustomSvg(
                      semanticsLabel: 'mask_group'.tr,
                      assetPath: 'assets/images/teamteam.png',
                      height: isPortrait ? sh * 0.26 : sh * 0.6,
                      width: isPortrait ? sw * 0.59 : sw * 0.39,
                    ),

                    SizedBox(height: sh * 0.0002),

                    /// Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.008),
                      child: Text(
                        'welcome_team'.tr,
                        style: Theme.of(Get.context!).textTheme.displayLarge?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w900,
                          fontSize: isPortrait ? sw * 0.07 : sw * 0.05,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: sh * 0.02),

                    /// Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
                      child: Text(
                        'splash_team_subtitle'.tr,
                        style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                          color: AppColors.black,
                          height: 1.5,
                          fontSize: isPortrait ? sw * 0.04 : sw * 0.03,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: sh * 0.22),

                    /// Bottom Logo
                    CustomSvg(
                      assetPath: 'assets/images/logo.svg',
                      width: sw * 0.1,
                      height: sw * 0.1,
                      semanticsLabel: '',
                    ),
                    SizedBox(height: sh * 0.03),
                  ],
                ),
              ),

              /// Left Arrow
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: sw * 0.0,
                    bottom: sh * 0.15,
                  ),
                  child: CustomCurvedArrow(
                    isLeft: true,
                    onTap: () => Get.back(),
                    width: sw * 0.15,
                    height: sh * 0.2,
                  ),
                ),
              ),

              /// Right Arrow
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: sw * 0.0,
                    bottom: sh * 0.15,
                  ),
                  child: CustomCurvedArrow(
                    isLeft: false,
                    onTap: () => Get.toNamed(AppRoutes.createTeam),
                    width: sw * 0.15,
                    height: sh * 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESKTOP — matches KeyResultsInputScreen web layout pattern ─────────────
  Widget _buildDesktopLayout(double sw, double sh) {
    final double containerWidth = sw > 1200 ? 720.0 : sw * 0.72;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background image (same as KeyResultsInputScreen) ──
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ── Desktop AppBar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DesktopAppBar(
              screenWidth: sw,
              screenHeight: sh,
              title: 'team_setup'.tr,
              subtitle: 'welcome_team'.tr,
            ),
          ),

          // ── Centered white card ──
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            bottom: 80,
            child: Center(
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(36, 36, 36, 36),
                  child: _buildDesktopBody(sw, sh),
                ),
              ),
            ),
          ),

          // ── Left back arrow (same position as KeyResultsInputScreen) ──
          Positioned(
            bottom: 20,
            left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(
                assetPath: 'assets/images/left.svg',
                semanticsLabel: '',
              ),
            ),
          ),

          // ── Right next arrow ──
          Positioned(
            bottom: 20,
            right: 0,
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.createTeam),
              child: CustomSvg(
                assetPath: 'assets/images/right.svg',
                semanticsLabel: '',
              ),
            ),
          ),

          // ── Bottom NavBar ──
          Positioned(
            bottom: 20,
            left: 0,
            right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ── DESKTOP BODY ───────────────────────────────────────────────────────────
  Widget _buildDesktopBody(double sw, double sh) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // OKR Logo
        CustomSvg(
          semanticsLabel: 'okr_logo'.tr,
          assetPath: 'assets/images/okrnev.svg',
          height: 60,
          width: 160,
        ),

        const SizedBox(height: 32),

        // Team illustration
        CustomSvg(
          semanticsLabel: 'mask_group'.tr,
          assetPath: 'assets/images/teamteam.png',
          height: sh * 0.28,
          width: sw * 0.28,
        ),

        const SizedBox(height: 28),

        // Welcome title
        Text(
          'welcome_team'.tr,
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w900,
            fontSize: _fs(sw, 28, desktop: 32),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'splash_team_subtitle'.tr,
            style: TextStyle(
              color: Colors.black54,
              height: 1.6,
              fontSize: _fs(sw, 14, desktop: 15),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        // Divider
        Divider(color: Colors.grey.shade200, thickness: 1),

        const SizedBox(height: 28),

        // Bottom logo
        CustomSvg(
          assetPath: 'assets/images/logo.svg',
          width: 48,
          height: 48,
          semanticsLabel: '',
        ),
      ],
    );
  }
}