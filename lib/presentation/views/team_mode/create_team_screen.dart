// lib/presentation/views/team_mode/create_team_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/app_colors.dart';
import '../../../controllers/team_mode_controller/create_team_controller.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  late CreateTeamController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CreateTeamController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.preloadAllAvatarImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final args = Get.arguments as Map<String, dynamic>?;
    final bool isEditing = args?['isEditing'] ?? false;

    if (sw >= 768) return _buildDesktopLayout(sw, sh, isEditing);
    return _buildMobileLayout(sw, sh, isEditing);
  }

  // ── MOBILE — original layout preserved ────────────────────────────────────
  Widget _buildMobileLayout(double sw, double sh, bool isEditing) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) => Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: sh * 0.014),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: sh * 0.01),
                      CustomHeader(
                        title: isEditing ? 'Edit'.tr : 'create'.tr,
                        highlightedText: isEditing ? 'Team'.tr : 'new_team'.tr,
                        showDashboardIcon: false,
                        onBackTap: () => Get.back(),
                      ),
                      SizedBox(height: sh * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _roundedField(
                              controller: controller.teamNameController,
                              hint: "enter_team_name".tr,
                              maxLines: 1,
                              sw: sw,
                            ),
                            SizedBox(height: sh * 0.02),
                            _roundedField(
                              controller: controller.teamMissionController,
                              hint: "describe_your_team_mission".tr,
                              maxLines: 4,
                              sw: sw,
                            ),
                            SizedBox(height: sh * 0.035),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "choose_team_avatar".tr,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: sh * 0.015),
                            _buildAvatarGrid(sw),
                            SizedBox(height: sh * 0.035),
                            if (!isEditing) _buildJoinTeamSection(context, sw, sh),
                            SizedBox(height: sh * 0.035),
                            Obx(() => CustomButton(
                              backgroundColor: AppColors.primaryRed,
                              textColor: Colors.white,
                              text: isEditing
                                  ? (controller.isCreatingTeam.value ? "saving".tr : "save_changes".tr)
                                  : (controller.isCreatingTeam.value ? "creating".tr : "continue".tr),
                              onPressed: controller.isCreatingTeam.value
                                  ? () {}
                                  : () => controller.continueCreateTeam(isEditing: isEditing),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -sw * 0.05,
                  top: sh * 0.45,
                  child: const CustomHomeNavBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── DESKTOP — matches KeyResultsInputScreen web layout pattern ─────────────
  Widget _buildDesktopLayout(double sw, double sh, bool isEditing) {
    final double containerWidth = sw > 1200 ? 760.0 : sw * 0.72;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/web_background.png', fit: BoxFit.cover),
            ),
          ),

          // Desktop AppBar
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw,
              screenHeight: sh,
              title: 'team_mode'.tr,
              subtitle: isEditing ? 'edit_team'.tr : 'create_new_team'.tr,
            ),
          ),

          // Main scrollable card
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
                  padding: const EdgeInsets.fromLTRB(48, 36, 48, 40),
                  child: _buildDesktopBody(sw, sh, isEditing),
                ),
              ),
            ),
          ),

          // Left back arrow
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: ''),
            ),
          ),

          // Bottom NavBar
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ── DESKTOP BODY ───────────────────────────────────────────────────────────
  Widget _buildDesktopBody(double sw, double sh, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Team Info
        _desktopSectionLabel(context, 'team_info_label'.tr),
        const SizedBox(height: 16),

        // Two-column row: Team Name + Team Mission side by side on wide screens
        sw > 1100
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _desktopField(
              controller: controller.teamNameController,
              hint: "enter_team_name".tr,
              label: "team_name_label".tr,
              maxLines: 1,
              sw: sw,
            )),
            const SizedBox(width: 24),
            Expanded(child: _desktopField(
              controller: controller.teamMissionController,
              hint: "describe_your_team_mission".tr,
              label: "team_mission_label".tr,
              maxLines: 4,
              sw: sw,
            )),
          ],
        )
            : Column(
          children: [
            _desktopField(
              controller: controller.teamNameController,
              hint: "enter_team_name".tr,
              label: "team_name_label".tr,
              maxLines: 1,
              sw: sw,
            ),
            const SizedBox(height: 20),
            _desktopField(
              controller: controller.teamMissionController,
              hint: "describe_your_team_mission".tr,
              label: "team_mission_label".tr,
              maxLines: 4,
              sw: sw,
            ),
          ],
        ),

        const SizedBox(height: 36),
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 28),

        // Section: Avatar
        _desktopSectionLabel(context, 'choose_team_avatar'.tr),
        const SizedBox(height: 20),
        _buildDesktopAvatarGrid(sw),

        const SizedBox(height: 36),
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 28),

        // Section: Join existing team (only when not editing)
        if (!isEditing) ...[
          _buildDesktopJoinTeamSection(sw),
          const SizedBox(height: 36),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 28),
        ],

        // Continue / Save button
        Center(
          child: SizedBox(
            width: sw > 1100 ? 320.0 : double.infinity,
            child: Obx(() => CustomButton(
              backgroundColor: AppColors.primaryRed,
              textColor: Colors.white,
              text: isEditing
                  ? (controller.isCreatingTeam.value ? "saving".tr : "save_changes".tr)
                  : (controller.isCreatingTeam.value ? "creating".tr : "continue".tr),
              onPressed: controller.isCreatingTeam.value
                  ? () {}
                  : () => controller.continueCreateTeam(isEditing: isEditing),
            )),
          ),
        ),
      ],
    );
  }

  // ── Desktop section label ──────────────────────────────────────────────────
  Widget _desktopSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlue,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Desktop labeled field ──────────────────────────────────────────────────
  Widget _desktopField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required double sw,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.softRed.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.softRed, width: 1.2),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ── Desktop avatar grid (horizontal scroll, larger avatars) ───────────────
  Widget _buildDesktopAvatarGrid(double sw) {
    final double avatarSize = sw > 1100 ? 80.0 : 70.0;
    return SizedBox(
      height: avatarSize + 20,
      child: Obx(() {
        final selectedIndex = controller.selectedAvatarIndex.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.avatars.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => controller.selectAvatarInstantly(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                  border: isSelected
                      ? Border.all(color: AppColors.primaryRed, width: 3.5)
                      : Border.all(color: Colors.transparent, width: 3.5),
                  boxShadow: isSelected
                      ? [BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )]
                      : [],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      controller.avatars[index],
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ── Desktop join team section ──────────────────────────────────────────────
  Widget _buildDesktopJoinTeamSection(double sw) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: sw > 1100
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: icon + description
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryRed,
                      child: Icon(Icons.groups, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "join_existing_team".tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "team_code".tr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right: input + button
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: controller.teamCodeController,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: "enter_team_code".tr,
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() => CustomButton(
                  backgroundColor: AppColors.primaryBlue,
                  textColor: Colors.white,
                  text: controller.isJoiningTeam.value ? 'loading'.tr : "join_team".tr,
                  onPressed: controller.isJoiningTeam.value ? () {} : controller.joinTeam,
                )),
              ],
            ),
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryRed,
                child: Icon(Icons.groups, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "join_existing_team".tr,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "team_code".tr,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: controller.teamCodeController,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "enter_team_code".tr,
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() => CustomButton(
            backgroundColor: AppColors.primaryBlue,
            textColor: Colors.white,
            text: controller.isJoiningTeam.value ? 'loading'.tr : "join_team".tr,
            onPressed: controller.isJoiningTeam.value ? () {} : controller.joinTeam,
          )),
        ],
      ),
    );
  }

  // ── Mobile avatar grid (original) ─────────────────────────────────────────
  Widget _buildAvatarGrid(double sw) {
    return SizedBox(
      height: sw * 0.25,
      child: Obx(() {
        final selectedIndex = controller.selectedAvatarIndex.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.avatars.length,
          separatorBuilder: (_, __) => SizedBox(width: sw * 0.04),
          itemBuilder: (context, index) {
            return _UltraFastAvatar(
              key: ValueKey('avatar_$index'),
              imagePath: controller.avatars[index],
              isSelected: selectedIndex == index,
              onTap: () => controller.selectAvatarInstantly(index),
              size: 70,
            );
          },
        );
      }),
    );
  }

  Widget _buildJoinTeamSection(BuildContext context, double sw, double sh) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryRed,
                child: Icon(Icons.groups, color: AppColors.white),
              ),
              SizedBox(width: 8.w),
              Text(
                "join_existing_team".tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.black),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "team_code".tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.black),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.teamCodeController,
            decoration: InputDecoration(
              hintText: "enter_team_code".tr,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.textSecondary),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(() => CustomButton(
            backgroundColor: AppColors.primaryBlue,
            textColor: Colors.white,
            text: controller.isJoiningTeam.value ? 'loading'.tr : "join_team".tr,
            onPressed: controller.isJoiningTeam.value ? () {} : controller.joinTeam,
          )),
        ],
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    required double sw,
    int maxLines = 1,
  }) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.softRed.withOpacity(0.7),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(color: AppColors.softRed, width: 1.2),
          ),
        ),
      );
}

// ── Avatar widget (mobile) ─────────────────────────────────────────────────
class _UltraFastAvatar extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  const _UltraFastAvatar({
    required Key key,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.primaryRed, width: 3)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: (size - 4).w,
              height: (size - 4).w,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
            ),
            Image.asset(
              imagePath,
              width: (size * 0.5).w,
              height: (size * 0.5).w,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.low,
              isAntiAlias: false,
            ),
          ],
        ),
      ),
    );
  }
}