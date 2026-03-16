import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:game_app/core/app_colors.dart';
import 'package:game_app/core/app_dimensions.dart';
import 'package:game_app/services/shared_preference.dart';
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:game_app/controllers/choose_industry_controller.dart';
import 'package:game_app/presentation/widgets/custom_button2.dart';
import 'package:game_app/presentation/widgets/custom_industry_container.dart';
import 'package:game_app/presentation/widgets/screens_unique_parts/custom_background.dart';
import 'package:game_app/presentation/widgets/screens_unique_parts/custom_header.dart';

import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../bonus_mode/case_presentation_screen.dart';
import '../roles/role_selection_screen.dart';
import '../roles/tutorial_screen.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class ChooseIndustryScreen extends StatefulWidget {
  final Map? selectedRole;

  const ChooseIndustryScreen({super.key, this.selectedRole});

  @override
  State<ChooseIndustryScreen> createState() => _ChooseIndustryScreenState();
}

class _ChooseIndustryScreenState extends State<ChooseIndustryScreen> {
  // ✅ Safe: put only if not already registered
  late final ChooseIndustryController controller;
  late final bool fromBonus;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ChooseIndustryController>()
        ? Get.find<ChooseIndustryController>()
        : Get.put(ChooseIndustryController());

    final args = Get.arguments;
    fromBonus = args != null && args['fromBonus'] == true;
  }

  // ── Continue handler (exact from mobile) ───────────────────────────────────
  Future<void> _handleContinue() async {
    if (controller.selectedIndex.value == -1) {
      Get.snackbar(
        'Error'.tr,
        'Please select an industry'.tr,
        backgroundColor: AppColors.primaryRed,
        colorText: Colors.white,
      );
      return;
    }

    final selectedIndustry =
    controller.filteredIndustries[controller.selectedIndex.value];
    await SharedPrefs.saveSelectedIndustry(selectedIndustry);

    if (fromBonus) {
      Get.to(() => CasePresentationScreen(selectedIndustry: selectedIndustry));
    } else {
      Get.toNamed(AppRoutes.selectStrategy, arguments: {
        'selectedRole': widget.selectedRole ?? Get.arguments?['selectedRole'],
        'selectedIndustry': selectedIndustry,
      });
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    if (sw >= 768) return _buildDesktopLayout(sw, sh);
    return _buildMobileLayout(sw, sh);
  }

  // ==========================================================================
  // MOBILE LAYOUT — unchanged from original
  // ==========================================================================
  Widget _buildMobileLayout(double sw, double sh) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomBackground(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppDimensions.d20.h),
                    child: _buildContent(sw, sh),
                  ),
                ),
              ),
              Positioned(
                right: sw * -0.07,
                top:   sh * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT — matches established web pattern exactly
  // ==========================================================================
  Widget _buildDesktopLayout(double sw, double sh) {
    final double containerWidth = sw > 1200 ? 720.0 : sw * 0.72;

    return Scaffold(
      body: Stack(
        children: [
          // Background image 10% opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // DesktopAppBar pinned at top
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth:  sw,
              screenHeight: sh,
              title:    'choose'.tr,
              subtitle: 'your_industry'.tr,
            ),
          ),

          // White centered card
          Positioned(
            top: 110, left: 0, right: 0, bottom: 80,
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
                  padding: const EdgeInsets.all(36),
                  child: _buildContent(sw, sh),
                ),
              ),
            ),
          ),

          // Back SVG bottom-left
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(
                assetPath:      'assets/images/left.svg',
                semanticsLabel: '',
              ),
            ),
          ),

          // Bottom nav bar
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SHARED CONTENT — same for mobile and desktop
  // ==========================================================================
  Widget _buildContent(double sw, double sh) {
    // Industry list height: fixed on desktop (no outer scroll conflict),
    // proportional on mobile
    final double listHeight = sw >= 768 ? 340.0 : sh * 0.45;

    return Column(
      children: [
        SizedBox(height: sw >= 768 ? 20.0 : sh * 0.03),



        SizedBox(height: sw >= 768 ? 20.0 : sh * 0.02),

        // Search field
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 24)),
          child: TextField(
            onChanged: controller.filterIndustries,
            style: TextStyle(fontSize: _fs(sw, 14, desktop: 14)),
            decoration: InputDecoration(
              hintText: 'search_industry'.tr,
              hintStyle: TextStyle(fontSize: _fs(sw, 14, desktop: 14)),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_d(sw, 12)),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical:   _dh(sw, 12),
                horizontal: _d(sw, 10),
              ),
            ),
          ),
        ),

        SizedBox(height: sw >= 768 ? 16.0 : sh * 0.02),

        // Industries list
        Padding(
          padding: EdgeInsets.symmetric(
            vertical:   sw >= 768 ? 0 : sh * 0.01,
            horizontal: _d(sw, 16),
          ),
          child: Container(
            height: listHeight,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.accentRed, width: 2),
              borderRadius: BorderRadius.circular(_d(sw, 16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Obx(() {
              final list = controller.filteredIndustries;
              return Scrollbar(
                radius: const Radius.circular(8),
                child: ListView.builder(
                  padding: EdgeInsets.all(_d(sw, 12)),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final industry   = list[index];
                    final title       = (industry['titleKey']?.toString() ?? '').tr;
                    final description = (industry['descriptionKey']?.toString() ?? '').tr;

                    return Padding(
                      padding: EdgeInsets.only(bottom: _dh(sw, 8)),
                      child: Obx(() => CustomIndustryContainer(
                        title:       title,
                        description: description,
                        icon: industry['icon'] as IconData? ?? Icons.business,
                        isSelected:  controller.selectedIndex.value == index,
                        onTap:       () => controller.selectIndustry(index),
                      )),
                    );
                  },
                ),
              );
            }),
          ),
        ),

        SizedBox(height: sw >= 768 ? 24.0 : sh * 0.03),

        // Continue button + tutorial
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 24)),
          child: Column(
            children: [
              CustomButton2(
                text:      'select_continue'.tr,
                onPressed: _handleContinue,
              ),
              SizedBox(height: sw >= 768 ? 14.0 : sh * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'first_time_playing'.tr,
                    style: TextStyle(
                      color:    Colors.black,
                      fontSize: _fs(sw, 12, desktop: 13),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(width: _d(sw, 6)),
                  GestureDetector(
                    onTap: () => Get.to(() => const TutorialVideoScreen()),
                    child: Text(
                      trKey('watch_tutorial'),
                      style: TextStyle(
                        color:      AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize:   _fs(sw, 12, desktop: 13),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: _dh(sw, 18)),
            ],
          ),
        ),
      ],
    );
  }
}