import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class CampaignRoleSelectionScreen extends StatelessWidget {
  CampaignRoleSelectionScreen({super.key});

  final RoleSelectionController controller = Get.put(RoleSelectionController());

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 768;
    return isDesktop
        ? _buildDesktopLayout(context, sw)
        : _buildMobileLayout(context, sw);
  }

  // ── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, double sw) {
    final double sh = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(top: 0, bottom: AppDimensions.d10.h),
                  child: Column(
                    children: [
                      SizedBox(height: AppDimensions.d20.h),
                      CustomHeader(
                        title: trKey('Select Role'),
                        highlightedText: trKey('For Campaign'),
                        onBackTap: () => Get.offAllNamed(AppRoutes.pricingScreen),
                      ),
                      _buildIntroText(context, sw, isDesktop: false),
                      SizedBox(height: AppDimensions.d10.h),
                      _buildInstruction(context, sw, isDesktop: false),
                      SizedBox(height: AppDimensions.d14.h),
                      _buildRolesGrid(context, sw, isDesktop: false),
                      SizedBox(height: AppDimensions.d20.h),
                      _buildBottomActions(context, sw, isDesktop: false),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: sw * -0.07,
              top: sh * 0.50,
              child: const CustomHomeNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context, double sw) {
    final double sh = MediaQuery.of(context).size.height;
    final double containerWidth = sw > 1200 ? 860.0 : sw * 0.78;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // AppBar
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw,
              screenHeight: sh,
              title: trKey('Select Role'),
              subtitle: trKey('For Campaign'),
            ),
          ),

          // Main card
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildIntroText(context, sw, isDesktop: true),
                      const SizedBox(height: 16),
                      _buildInstruction(context, sw, isDesktop: true),
                      const SizedBox(height: 20),
                      _buildRolesGrid(context, sw, isDesktop: true),
                      const SizedBox(height: 28),
                      _buildBottomActions(context, sw, isDesktop: true),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Home NavBar
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: const Center(child: CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ── SHARED WIDGETS ─────────────────────────────────────────────────────────

  Widget _buildIntroText(BuildContext context, double sw,
      {required bool isDesktop}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : AppDimensions.d20.w),
      child: Column(
        children: [
          Text(
            trKey('welcome_navigator'),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 22 : 20.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isDesktop ? 10 : AppDimensions.d8.h),
          Text(
            trKey('company_crisis_description'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              height: 1.4,
              fontSize: isDesktop ? 14 : 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(BuildContext context, double sw,
      {required bool isDesktop}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : AppDimensions.d24.w),
      child: Text(
        trKey('choose_role_instruction'),
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: isDesktop ? 15 : 15.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRolesGrid(BuildContext context, double sw,
      {required bool isDesktop}) {
    // On desktop show as a horizontal wrap / row instead of grid
    if (isDesktop) {
      return Obx(() {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(controller.roles.length, (i) {
            return SizedBox(
              width: (sw > 1200 ? 860.0 : sw * 0.78) / 5 - 20,
              child: _DesktopRoleCard(
                index: i,
                role: controller.roles[i],
                controller: controller,
                selectedIndex: controller.selectedIndex.value,
              ),
            );
          }),
        );
      });
    }

    // Mobile grid
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.d16.w),
      child: LayoutBuilder(builder: (context, constraints) {
        int crossAxisCount = sw > 1200 ? 4 : sw > 800 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.roles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppDimensions.d10.w,
            mainAxisSpacing: AppDimensions.d10.h,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) => _MobileRoleCard(
            index: index,
            role: controller.roles[index],
            controller: controller,
          ),
        );
      }),
    );
  }

  Widget _buildBottomActions(BuildContext context, double sw,
      {required bool isDesktop}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : AppDimensions.d18.w),
      child: Column(
        children: [
          SizedBox(
            width: isDesktop ? 320 : double.infinity,
            child: CustomButton2(
              text: trKey('select_continue'),
              onPressed: controller.continueWithSelection,
            ),
          ),
          SizedBox(height: isDesktop ? 12 : AppDimensions.d12.h),
          Text(
            trKey('first_time_playing'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.black,
              fontSize: isDesktop ? 13 : 13.sp,
            ),
          ),
          SizedBox(height: isDesktop ? 8 : AppDimensions.d18.h),
        ],
      ),
    );
  }
}

// ── DESKTOP ROLE CARD ──────────────────────────────────────────────────────────
// Clean card with image on top, title + subtitle below, tap to select

class _DesktopRoleCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> role;
  final RoleSelectionController controller;
  final int selectedIndex;

  const _DesktopRoleCard({
    required this.index,
    required this.role,
    required this.controller,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = selectedIndex == index;
    final bool isPng = (role['asset'] as String).endsWith('.png');

    return GestureDetector(
      onTap: () => controller.selectRole(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryRed.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryRed
                : Colors.grey.withOpacity(0.2),
            width: selected ? 2.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primaryRed.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: selected ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Role image — PNG via Image.asset, SVG via CustomSvg
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.primaryRed.withOpacity(0.08)
                    : Colors.grey.shade50,
              ),
              child: Center(
                child: isPng
                    ? Image.asset(role['asset'], width: 40, height: 40)
                    : CustomSvg(
                  assetPath: role['asset'],
                  semanticsLabel: trKey(role['title']),
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              trKey(role['title']),
              style: const TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              trKey(role['subtitle']),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (role['extra'] != null &&
                role['extra'].toString().isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                trKey(role['extra']),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 10),

            // Selected indicator chip
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✓ Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── MOBILE ROLE CARD ────────────────────────────────────────────────────────────

class _MobileRoleCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> role;
  final RoleSelectionController controller;

  const _MobileRoleCard({
    required this.index,
    required this.role,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isPng = (role['asset'] as String).endsWith('.png');

    return Obx(() {
      final bool selected = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () => controller.selectRole(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          padding: EdgeInsets.all(AppDimensions.d12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.d16.r),
            border: Border.all(
              color: selected
                  ? AppColors.primaryRed
                  : AppColors.grey.withOpacity(0.2),
              width: selected ? 2.2 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Avatar — fix PNG-loaded-as-SVG crash
                  Container(
                    padding: EdgeInsets.all(AppDimensions.d8.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primaryRed.withOpacity(0.06)
                          : Colors.grey.shade50,
                    ),
                    child: Center(
                      child: isPng
                          ? Image.asset(
                        role['asset'],
                        width: sw * 0.12,
                        height: sw * 0.12,
                        fit: BoxFit.contain,
                      )
                          : CustomSvg(
                        assetPath: role['asset'],
                        semanticsLabel: trKey(role['title']),
                        width: sw * 0.12,
                        height: sw * 0.12,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.d8.h),

                  Text(
                    trKey(role['title']),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimensions.d4.h),

                  Text(
                    trKey(role['subtitle']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      fontSize: 10.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (role['extra'] != null &&
                      role['extra'].toString().isNotEmpty)
                    Text(
                      trKey(role['extra']),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 9.sp,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

              // Top-right icon badge
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.d4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: role['iconBg'],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    role['icon'],
                    color: Colors.white,
                    size: sw * 0.035,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:game_app/presentation/widgets/screens_unique_parts/custom_background.dart';
// import 'package:get/get.dart';
//
// import '../../../controllers/role_selection_controller.dart';
// import '../../../core/app_colors.dart';
// import '../../../core/app_dimensions.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/custom_button2.dart';
// import '../../widgets/custom_home_navbar.dart';
// import '../../widgets/custom_svg.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
//
// // ✅ Global trKey
// String trKey(Object? key) => key != null ? key.toString().tr : '';
//
// class CampaignRoleSelectionScreen extends StatelessWidget {
//   CampaignRoleSelectionScreen({super.key});
//
//   final RoleSelectionController controller = Get.put(RoleSelectionController());
//
//   @override
//   Widget build(BuildContext context) => OrientationBuilder(
//     builder: (context, orientation) {
//       final screenWidth = MediaQuery.of(context).size.width;
//       final screenHeight = MediaQuery.of(context).size.height;
//
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: CustomBackground(
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 0, bottom: AppDimensions.d10.h),
//                     child: Column(
//                       children: [
//                         SizedBox(height: AppDimensions.d20.h),
//                         // ✅ Reusable Header
//                         CustomHeader(
//                           title: trKey('Select Role'),
//                           highlightedText: trKey('For Campaign'),
//                           onBackTap: () => Get.offAllNamed(AppRoutes.pricingScreen),
//                         ),
//
//                         // ✅ Welcome Section
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: AppDimensions.d20.w),
//                           child: Column(
//                             children: [
//                               Text(
//                                 trKey('welcome_navigator'),
//                                 style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                                   color: AppColors.primaryRed,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: orientation == Orientation.portrait ? 20.sp : 16.sp,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                               SizedBox(height: AppDimensions.d8.h),
//                               Text(
//                                 trKey('company_crisis_description'),
//                                 style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                                   height: 1.4,
//                                   fontSize: orientation == Orientation.portrait ? 14.sp : 12.sp,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: AppDimensions.d10.h),
//
//                         // ✅ Instruction
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: AppDimensions.d24.w),
//                           child: Align(
//                             child: Text(
//                               trKey('choose_role_instruction'),
//                               style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: orientation == Orientation.portrait ? 15.sp : 13.sp,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: AppDimensions.d14.h),
//
//                         // ✅ Roles Grid
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: AppDimensions.d16.w),
//                           child: LayoutBuilder(
//                             builder: (context, constraints) {
//                               final screenWidth = MediaQuery.of(context).size.width;
//                               final screenHeight = MediaQuery.of(context).size.height;
//
//                               int crossAxisCount = 2;
//                               if (screenWidth > 1200) {
//                                 crossAxisCount = 4;
//                               } else if (screenWidth > 800) {
//                                 crossAxisCount = 3;
//                               }
//
//                               double childAspectRatio = (screenWidth / crossAxisCount) / (screenHeight * (orientation == Orientation.portrait ? 0.38 : 0.55));
//
//                               return GridView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: controller.roles.length,
//                                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: crossAxisCount,
//                                   crossAxisSpacing: AppDimensions.d10.w,
//                                   mainAxisSpacing: AppDimensions.d10.h,
//                                   childAspectRatio: childAspectRatio.clamp(0.72, 0.95),
//                                 ),
//                                 itemBuilder: (context, index) {
//                                   final role = controller.roles[index];
//                                   return _RoleCard(
//                                     index: index,
//                                     role: role,
//                                     controller: controller,
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//
//                         SizedBox(height: AppDimensions.d20.h),
//
//                         // ✅ Continue Button & Tutorial
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: AppDimensions.d18.w),
//                           child: Column(
//                             children: [
//                               CustomButton2(
//                                 text: trKey('select_continue'),
//                                 onPressed: controller.continueWithSelection,
//                               ),
//                               SizedBox(height: AppDimensions.d12.h),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     trKey('first_time_playing'),
//                                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                       color: Colors.black,
//                                       fontSize: orientation == Orientation.portrait ? 13.sp : 11.sp,
//                                     ),
//                                   ),
//                                   // Padding(
//                                   //   padding: EdgeInsets.symmetric(horizontal: 8.w),
//                                   //   child: GestureDetector(
//                                   //     onTap: controller.openTutorial,
//                                   //     child: Text(
//                                   //       trKey('watch_tutorial'),
//                                   //       style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                                   //         color: AppColors.primaryRed,
//                                   //         fontWeight: FontWeight.bold,
//                                   //         decoration: TextDecoration.underline,
//                                   //         fontSize: orientation == Orientation.portrait ? 13.sp : 11.sp,
//                                   //       ),
//                                   //     ),
//                                   //   ),
//                                   // ),
//                                 ],
//                               ),
//                               SizedBox(height: AppDimensions.d18.h),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               // ✅ Floating NavBar
//               Positioned(
//                 right: screenWidth * -0.07,
//                 top: screenHeight * 0.50,
//                 child: const CustomHomeNavBar(),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
//
// // ✅ Role Card (unchanged)
// class _RoleCard extends StatelessWidget {
//   final int index;
//   final Map<String, dynamic> role;
//   final RoleSelectionController controller;
//
//   const _RoleCard({
//     required this.index,
//     required this.role,
//     required this.controller,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Obx(() {
//       final selected = controller.selectedIndex.value == index;
//       return GestureDetector(
//         onTap: () => controller.selectRole(index),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 260),
//           padding: EdgeInsets.all(AppDimensions.d12.w),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(AppDimensions.d16.r),
//             border: Border.all(
//               color: selected ? AppColors.primaryRed : AppColors.grey.withOpacity(0.2),
//               width: selected ? 2.2 : 1,
//             ),
//             boxShadow: selected
//                 ? [
//               BoxShadow(
//                 color: AppColors.primaryRed.withOpacity(0.12),
//                 blurRadius: 12,
//                 offset: const Offset(0, 6),
//               ),
//             ]
//                 : [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.03),
//                 blurRadius: 6,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Avatar Icon
//                   Container(
//                     padding: EdgeInsets.all(AppDimensions.d8.w),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: selected ? AppColors.primaryRed.withOpacity(0.06) : Colors.grey.shade50,
//                     ),
//                     child: Center(
//                       child: CustomSvg(
//                         assetPath: role['asset'],
//                         semanticsLabel: trKey(role['title']),
//                         width: screenWidth * 0.18,
//                         height: screenWidth * 0.16,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: AppDimensions.d12.h),
//
//                   // Role Title
//                   Text(
//                     trKey(role['title']),
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       color: AppColors.primaryRed,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: AppDimensions.d4.h),
//
//                   // Role Subtitle
//                   Text(
//                     trKey(role['subtitle']),
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       height: 1.2,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//
//                   // Extra Info
//                   if (role['extra'] != null && role['extra'].toString().isNotEmpty)
//                     Text(
//                       trKey(role['extra']),
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: AppColors.grey,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                 ],
//               ),
//
//               // Top-Right Icon
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: Container(
//                   padding: EdgeInsets.all(AppDimensions.d6.w),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: role['iconBg'],
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 4,
//                         offset: const Offset(1, 2),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     role['icon'],
//                     color: Colors.white,
//                     size: (screenWidth * 0.04).sp,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }