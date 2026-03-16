import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/views/roles/tutorial_screen.dart';
import 'package:game_app/presentation/widgets/screens_unique_parts/custom_background.dart';
import 'package:get/get.dart';

import '../../../controllers/role_selection_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

String trKey(Object? key) => key != null ? key.toString().tr : '';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // ✅ Safe: put only if not already registered
  late final RoleSelectionController controller;
  final RxBool isDropdownOpen = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<RoleSelectionController>()
        ? Get.find<RoleSelectionController>()
        : Get.put(RoleSelectionController());
  }

  // ── Continue handler (exact from mobile) ───────────────────────────────────
  void _handleContinue() {
    if (controller.selectedIndex.value == -1) {
      Get.snackbar(
        'Error'.tr,
        'Please select a role'.tr,
        backgroundColor: AppColors.primaryRed,
        colorText: Colors.white,
      );
      return;
    }
    final selectedRole = controller.roles[controller.selectedIndex.value];
    final args      = Get.arguments ?? {};
    final fromBonus = args['fromBonus'] as bool? ?? false;

    Get.toNamed(AppRoutes.chooseIndustry, arguments: {
      'selectedRole': selectedRole,
      'fromBonus':    fromBonus,
    });
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
      body: CustomBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppDimensions.d10.h),
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
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT — matches the established web pattern exactly
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
              title:     'select'.tr,
              subtitle:  'role'.tr,
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
                assetPath: 'assets/images/left.svg',
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
    return Column(
      children: [
        SizedBox(height: _dh(sw, 20)),



        SizedBox(height: _dh(sw, 12)),

        // Welcome section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 20)),
          child: Column(
            children: [
              Text(
                trKey('welcome_navigator'),
                style: TextStyle(
                  fontFamily: 'GothamBold',
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: _fs(sw, 20, desktop: 22),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _dh(sw, 8)),
              Text(
                trKey('company_crisis_description'),
                style: TextStyle(
                  height: 1.4,
                  fontSize: _fs(sw, 14, desktop: 14),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: _dh(sw, 10)),

        // Instruction
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 24)),
          child: Text(
            trKey('choose_role_instruction'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: _fs(sw, 15, desktop: 15),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: _dh(sw, 14)),

        // Dropdown trigger
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 16)),
          child: Obx(() => GestureDetector(
            onTap: () => isDropdownOpen.toggle(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: _d(sw, 16),
                vertical:   _dh(sw, 14),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_d(sw, 12)),
                border: Border.all(
                  color: isDropdownOpen.value
                      ? AppColors.primaryRed
                      : AppColors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.selectedIndex.value >= 0
                        ? trKey(controller.roles[controller.selectedIndex.value]['title'])
                        : 'select_your_role'.tr,
                    style: TextStyle(
                      fontSize: _fs(sw, 16, desktop: 15),
                      fontWeight: FontWeight.w600,
                      color: controller.selectedIndex.value >= 0
                          ? AppColors.primaryRed
                          : Colors.black87,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isDropdownOpen.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryRed,
                      size: _fs(sw, 28, desktop: 24),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),

        SizedBox(height: _dh(sw, 12)),

        // Dropdown content — roles list
        Obx(() => AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: isDropdownOpen.value
              ? Padding(
            padding: EdgeInsets.symmetric(horizontal: _d(sw, 16)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_d(sw, 12)),
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.roles.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.grey.withOpacity(0.15),
                ),
                itemBuilder: (context, index) {
                  final role = controller.roles[index];
                  return _RoleListTile(
                    index:      index,
                    role:       role,
                    controller: controller,
                    sw:         sw,
                    onTap: () {
                      controller.selectRole(index);
                      isDropdownOpen.value = false;
                    },
                  );
                },
              ),
            ),
          )
              : const SizedBox.shrink(),
        )),

        SizedBox(height: _dh(sw, 20)),

        // Continue button + tutorial
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _d(sw, 18)),
          child: Column(
            children: [
              CustomButton2(
                text:      trKey('select_continue'),
                onPressed: _handleContinue,
              ),
              SizedBox(height: _dh(sw, 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    trKey('first_time_playing'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: _fs(sw, 12, desktop: 13),
                    ),
                  ),
                  SizedBox(width: _d(sw, 8)),
                  GestureDetector(
                    onTap: () => Get.to(() => const TutorialVideoScreen()),
                    child: Text(
                      trKey('watch_tutorial'),
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: _fs(sw, 12, desktop: 13),
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

// ─────────────────────────────────────────────────────────────────────────────
// Role list tile — adaptive sizing
// ─────────────────────────────────────────────────────────────────────────────
class _RoleListTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> role;
  final RoleSelectionController controller;
  final VoidCallback onTap;
  final double sw;

  const _RoleListTile({
    required this.index,
    required this.role,
    required this.controller,
    required this.onTap,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) => Obx(() {
    final selected = controller.selectedIndex.value == index;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: _d(sw, 14),
          vertical:   _dh(sw, 12),
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryRed.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(_d(sw, 8)),
        ),
        child: Row(
          children: [
            // Avatar icon
            Container(
              width:   sw >= 768 ? 48.0 : 56.sp,
              height:  sw >= 768 ? 48.0 : 56.sp,
              padding: EdgeInsets.all(_d(sw, 10)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.primaryRed.withOpacity(0.1)
                    : Colors.grey.shade100,
                border: Border.all(
                  color: selected
                      ? AppColors.primaryRed.withOpacity(0.3)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: CustomSvg(
                assetPath:      role['asset'],
                semanticsLabel: trKey(role['title']),
              ),
            ),

            SizedBox(width: _d(sw, 12)),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trKey(role['title']),
                    style: TextStyle(
                      color:      selected ? AppColors.primaryRed : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize:   _fs(sw, 16, desktop: 15),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: _dh(sw, 2)),
                  Text(
                    trKey(role['subtitle']),
                    style: TextStyle(
                      color:      Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize:   _fs(sw, 13, desktop: 13),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (role['extra'] != null &&
                      role['extra'].toString().isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: _dh(sw, 2)),
                      child: Text(
                        trKey(role['extra']),
                        style: TextStyle(
                          color:      AppColors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize:   _fs(sw, 11, desktop: 11),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(width: _d(sw, 8)),

            // Trailing icon
            Container(
              padding: EdgeInsets.all(_d(sw, 8)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: role['iconBg'],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                role['icon'],
                color: Colors.white,
                size: sw >= 768 ? 20.0 : 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  });
}