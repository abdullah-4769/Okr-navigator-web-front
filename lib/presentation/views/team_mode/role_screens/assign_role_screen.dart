// lib/presentation/views/team_mode/role_screens/assign_role_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/data/repositories/storage_repository.dart' show StorageRepository;
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:game_app/presentation/widgets/custom_button.dart';
import 'package:game_app/presentation/widgets/custom_circular_avatar.dart';
import 'package:game_app/presentation/widgets/custom_objective_container.dart';
import 'package:game_app/presentation/widgets/screens_unique_parts/custom_background.dart';
import 'package:game_app/presentation/widgets/screens_unique_parts/custom_header.dart';
import 'package:game_app/presentation/widgets/team_mode_widgets/custom_available_roles.dart';
import 'package:game_app/services/shared_preference.dart';
import 'package:get/get.dart';

import '../../../../controllers/team_mode_controller/create_team_controller.dart';
import '../../../../controllers/team_mode_controller/team_lobby_controller.dart';
import '../../../../controllers/team_mode_controller/assign_roles_controller.dart';
import '../../../../controllers/team_mode_controller/team_game_controller.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_dimensions.dart';
import '../../../widgets/Website/desktop_appbar.dart';
import '../../../widgets/custom_home_navbar.dart';
import '../../../widgets/custom_svg.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
 if (sw >= 1024) return desktop ?? tablet ?? mobile;
 if (sw >= 768)  return tablet  ?? mobile;
 return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class AssignRolesScreen extends StatelessWidget {
 const AssignRolesScreen({super.key});

 @override
 Widget build(BuildContext context) {
  final controller = Get.put(AssignRolesController());
  final sw = MediaQuery.of(context).size.width;
  final sh = MediaQuery.of(context).size.height;
  final StorageRepository storageRepo = Get.find<StorageRepository>();
  final String? currentUserId = storageRepo.getUser()?.id;
  final Map<String, dynamic> selectedIndustry = SharedPrefs.getSelectedIndustry() ?? {
   'titleKey': 'Technology',
   'title': 'Technology',
  };

  final TeamLobbyController lobbyController = Get.find<TeamLobbyController>();
  final CreateTeamController createController = Get.find<CreateTeamController>();
  final teamData = lobbyController.teamData.value;
  final avatarId = int.tryParse(teamData?.teamavatorid ?? '0') ?? 0;
  final avatarPath = createController.avatars.isNotEmpty
      ? createController.avatars[avatarId.clamp(0, createController.avatars.length - 1)]
      : 'assets/images/role_icon.png';

  if (sw >= 768) {
   return _buildDesktopLayout(
    context, controller, sw, sh, currentUserId, selectedIndustry, avatarPath,
   );
  }
  return _buildMobileLayout(
   context, controller, sw, sh, currentUserId, selectedIndustry, avatarPath,
  );
 }

 // ── MOBILE — original layout preserved ────────────────────────────────────
 Widget _buildMobileLayout(
     BuildContext context,
     AssignRolesController controller,
     double sw, double sh,
     String? currentUserId,
     Map<String, dynamic> selectedIndustry,
     String avatarPath,
     ) {
  final textTheme = Theme.of(context).textTheme;
  return Scaffold(
   body: CustomBackground(
    child: SafeArea(
     child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        SizedBox(height: sh * 0.015),
        CustomHeader(
         title: 'assign'.tr,
         highlightedText: 'roles'.tr,
         onBackTap: () => Navigator.pop(context),
        ),
        SizedBox(height: sh * 0.015),
        Padding(
         padding: EdgeInsets.symmetric(horizontal: AppDimensions.d16.w),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           _buildHeaderSection(context, textTheme, sw, sh, avatarPath),
           SizedBox(height: sh * 0.025),
           const CustomAvailableRoles(),
           SizedBox(height: sh * 0.03),
           _buildTeamMembersSection(
            context: context, controller: controller,
            textTheme: textTheme, sw: sw, sh: sh,
            currentUserId: currentUserId, selectedIndustry: selectedIndustry,
           ),
           SizedBox(height: sh * 0.03),
           CustomObjectiveContainer(
            icon: Icons.lightbulb,
            title: 'pro_tip'.tr,
            description: 'pro_tip_description'.tr,
           ),
           SizedBox(height: sh * 0.03),
           _buildActionButtons(
            controller: controller,
            currentUserId: currentUserId,
            selectedIndustry: selectedIndustry,
            sw: sw,
           ),
           SizedBox(height: sh * 0.08),
          ],
         ),
        ),
       ],
      ),
     ),
    ),
   ),
  );
 }

 // ── DESKTOP ────────────────────────────────────────────────────────────────
 Widget _buildDesktopLayout(
     BuildContext context,
     AssignRolesController controller,
     double sw, double sh,
     String? currentUserId,
     Map<String, dynamic> selectedIndustry,
     String avatarPath,
     ) {
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

     // AppBar
     Positioned(
      top: 0, left: 0, right: 0,
      child: DesktopAppBar(
       screenWidth: sw, screenHeight: sh,
       title: 'team_mode'.tr,
       subtitle: 'assign_roles'.tr,
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
           blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 8),
          ),
         ],
        ),
        child: SingleChildScrollView(
         physics: const BouncingScrollPhysics(),
         padding: const EdgeInsets.fromLTRB(48, 36, 48, 40),
         child: _buildDesktopBody(
          context, controller, sw, sh,
          currentUserId, selectedIndustry, avatarPath,
         ),
        ),
       ),
      ),
     ),

     // Back arrow
     Positioned(
      bottom: 20, left: 0,
      child: GestureDetector(
       onTap: () => Get.back(),
       child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: ''),
      ),
     ),

     // NavBar
     Positioned(
      bottom: 20, left: 0, right: -30,
      child: Center(child: const CustomHomeNavBar()),
     ),
    ],
   ),
  );
 }

 // ── DESKTOP BODY ───────────────────────────────────────────────────────────
 Widget _buildDesktopBody(
     BuildContext context,
     AssignRolesController controller,
     double sw, double sh,
     String? currentUserId,
     Map<String, dynamic> selectedIndustry,
     String avatarPath,
     ) {
  final textTheme = Theme.of(context).textTheme;

  return Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
    // Top row: avatar + timer left, available roles right
    Row(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
      // Left: avatar + timer + description
      Expanded(
       flex: 2,
       child: _buildHeaderSection(context, textTheme, sw, sh, avatarPath),
      ),
      const SizedBox(width: 32),
      // Right: available roles
      Expanded(
       flex: 3,
       child: const CustomAvailableRoles(),
      ),
     ],
    ),

    const SizedBox(height: 32),
    Divider(color: Colors.grey.shade200, thickness: 1),
    const SizedBox(height: 24),

    // Section label
    Text(
     'team_members'.tr,
     style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryRed,
     ),
    ),
    const SizedBox(height: 16),

    // Members list
    _buildTeamMembersSection(
     context: context, controller: controller,
     textTheme: textTheme, sw: sw, sh: sh,
     currentUserId: currentUserId, selectedIndustry: selectedIndustry,
    ),

    const SizedBox(height: 28),
    Divider(color: Colors.grey.shade200, thickness: 1),
    const SizedBox(height: 24),

    // Pro tip
    CustomObjectiveContainer(
     icon: Icons.lightbulb,
     title: 'pro_tip'.tr,
     description: 'pro_tip_description'.tr,
    ),

    const SizedBox(height: 28),

    // Action buttons
    _buildActionButtons(
     controller: controller,
     currentUserId: currentUserId,
     selectedIndustry: selectedIndustry,
     sw: sw,
    ),
   ],
  );
 }

 // ── Shared: header section ─────────────────────────────────────────────────
 Widget _buildHeaderSection(
     BuildContext context, TextTheme textTheme,
     double sw, double sh, String avatarPath,
     ) {
  return Center(
   child: Column(
    children: [
     CustomCircularAvatar(
      imagePath: avatarPath,
      innerColors: [
       Colors.yellow.shade100,
       Colors.orange.shade100,
       Colors.lightGreenAccent,
      ],
      borderGradient: [
       AppColors.primaryRed.withOpacity(0.9),
       AppColors.primaryRed.withOpacity(0.3),
      ],
      size: sw >= 768 ? 130 : 150,
     ),
     SizedBox(height: _dh(sw, 15)),
     CustomObjectiveContainer(
      title: '',
      child: Padding(
       padding: EdgeInsets.symmetric(
        horizontal: _d(sw, 16),
        vertical: _dh(sw, 8),
       ),
       child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         Text(
          'time_limit'.tr,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.grey),
         ),
         Obx(() {
          final timerController = Get.find<TeamGameTimerController>();
          final totalSeconds = timerController.remainingSeconds.value;
          final minutes = totalSeconds ~/ 60;
          final seconds = totalSeconds % 60;
          return Text(
           '$minutes:${seconds.toString().padLeft(2, '0')}',
           style: textTheme.titleLarge?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: _fs(sw, 18, desktop: 16),
           ),
          );
         }),
        ],
       ),
      ),
     ),
     SizedBox(height: _dh(sw, 15)),
     SizedBox(
      width: sw >= 768 ? double.infinity : sw * 0.8,
      child: Text(
       'assign_roles_description'.tr,
       textAlign: TextAlign.center,
       style: textTheme.bodyLarge?.copyWith(
        color: AppColors.black,
        fontWeight: FontWeight.w400,
        fontSize: _fs(sw, 16, desktop: 14),
       ),
      ),
     ),
    ],
   ),
  );
 }

 // ── Shared: team members section ───────────────────────────────────────────
 Widget _buildTeamMembersSection({
  required BuildContext context,
  required AssignRolesController controller,
  required TextTheme textTheme,
  required double sw, required double sh,
  required String? currentUserId,
  required Map<String, dynamic> selectedIndustry,
 }) {
  return Column(
   children: [
    if (sw < 768)
     Center(
      child: Text(
       'team_members'.tr,
       style: textTheme.headlineLarge?.copyWith(color: AppColors.primaryRed),
      ),
     ),
    if (sw < 768) SizedBox(height: sh * 0.015),
    Obx(() {
     if (controller.isLoading.value) return _buildLoadingState(sw);
     if (controller.errorMessage.value.isNotEmpty) return _buildErrorState(controller, sw);

     // Desktop: 2-column grid for member cards
     if (sw >= 1100) {
      final members = controller.members;
      final rows = <Widget>[];
      for (int i = 0; i < members.length; i += 2) {
       rows.add(
        Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          Expanded(
           child: _buildMemberCard(context, members[i].user?.name ?? 'Unknown', 'Level 5', members[i], controller, sw),
          ),
          const SizedBox(width: 16),
          if (i + 1 < members.length)
           Expanded(
            child: _buildMemberCard(context, members[i + 1].user?.name ?? 'Unknown', 'Level 5', members[i + 1], controller, sw),
           )
          else
           const Expanded(child: SizedBox()),
         ],
        ),
       );
       rows.add(const SizedBox(height: 16));
      }
      return Column(children: rows);
     }

     // Single column (mobile + tablet)
     return Column(
      children: controller.members.map((member) => Column(
       children: [
        _buildMemberCard(context, member.user?.name ?? 'Unknown', 'Level 5', member, controller, sw),
        SizedBox(height: _dh(sw, 15)),
       ],
      )).toList(),
     );
    }),
   ],
  );
 }

 Widget _buildLoadingState(double sw) {
  return Center(
   child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
     CircularProgressIndicator(color: AppColors.primaryRed),
     SizedBox(height: sw >= 768 ? 16 : 16.h),
     Text(
      'loading_team_members'.tr,
      style: TextStyle(
       color: AppColors.textSecondary,
       fontSize: sw >= 768 ? 15 : 16.sp,
      ),
     ),
    ],
   ),
  );
 }

 Widget _buildErrorState(AssignRolesController controller, double sw) {
  return Center(
   child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
     Icon(Icons.error_outline, color: AppColors.primaryRed, size: sw >= 768 ? 48 : 48.sp),
     SizedBox(height: sw >= 768 ? 16 : 16.h),
     Text(
      controller.errorMessage.value,
      style: TextStyle(color: AppColors.primaryRed, fontSize: sw >= 768 ? 15 : 16.sp),
      textAlign: TextAlign.center,
     ),
     SizedBox(height: sw >= 768 ? 16 : 16.h),
     SizedBox(
      width: sw >= 768 ? 200 : double.infinity,
      child: CustomButton(
       backgroundColor: AppColors.primaryRed,
       textColor: Colors.white,
       text: 'retry'.tr,
       onPressed: () => controller.fetchTeamMembers(),
      ),
     ),
    ],
   ),
  );
 }

 // ── Shared: action buttons ─────────────────────────────────────────────────
 Widget _buildActionButtons({
  required AssignRolesController controller,
  required String? currentUserId,
  required Map<String, dynamic> selectedIndustry,
  required double sw,
 }) {
  return sw >= 1100
      ? Obx(() {
   final isHost = controller.isCurrentUserHost;
   if (!isHost) {
    return Center(
     child: Text(
      'waiting_host_begin_mission'.tr,
      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      textAlign: TextAlign.center,
     ),
    );
   }
   return Row(
    children: [
     Expanded(
      child: CustomButton(
       text: 'begin_mission'.tr,
       onPressed: () => _navigateToStrategy(controller, currentUserId, selectedIndustry),
      ),
     ),
     const SizedBox(width: 16),
     Expanded(
      child: CustomButton(
       isLoading: controller.isAutoUpdatingRole.value,
       text: 'auto_assign_roles'.tr,
       onPressed: () => controller.setRoleForGame(),
       backgroundColor: AppColors.primaryBlue,
      ),
     ),
    ],
   );
  })
      : Column(
   children: [
    Obx(() {
     final isHost = controller.isCurrentUserHost;
     if (!isHost) {
      return Padding(
       padding: const EdgeInsets.all(18.0),
       child: Text(
        'waiting_host_begin_mission'.tr,
        style: TextStyle(
         color: AppColors.textSecondary,
         fontSize: sw >= 768 ? 14 : 14.sp,
        ),
        textAlign: TextAlign.center,
       ),
      );
     }
     return Center(
      child: Padding(
       padding: const EdgeInsets.all(18.0),
       child: CustomButton(
        text: 'begin_mission'.tr,
        onPressed: () => _navigateToStrategy(controller, currentUserId, selectedIndustry),
       ),
      ),
     );
    }),
    SizedBox(height: sw >= 768 ? 10 : 10.h),
    Obx(() {
     if (!controller.isCurrentUserHost) return const SizedBox.shrink();
     return Center(
      child: CustomButton(
       isLoading: controller.isAutoUpdatingRole.value,
       text: 'auto_assign_roles'.tr,
       onPressed: () => controller.setRoleForGame(),
       backgroundColor: AppColors.primaryBlue,
      ),
     );
    }),
   ],
  );
 }

 void _navigateToStrategy(
     AssignRolesController controller,
     String? currentUserId,
     Map<String, dynamic> selectedIndustry,
     ) {
  final currentUserMember = controller.members.firstWhereOrNull(
       (member) => member.userId == currentUserId,
  );
  final String currentRole = currentUserMember?.role ?? 'HOST';
  Get.toNamed(
   AppRoutes.teamStrategySelection,
   arguments: {
    'selectedRole': {'title': currentRole, 'titleKey': currentRole},
    'selectedIndustry': selectedIndustry,
   },
  );
 }

 String? _getValidRole(String? apiRole) {
  const validRoles = ['CEO', 'Strategist', 'HR Manager', 'Analyst', 'Team Lead', 'Manager'];
  if (apiRole == null) return null;
  return validRoles.contains(apiRole) ? apiRole : null;
 }

 // ── Shared: member card ────────────────────────────────────────────────────
 Widget _buildMemberCard(
     BuildContext context, String name, String level,
     dynamic member, AssignRolesController controller, double sw,
     ) {
  final textTheme = Theme.of(context).textTheme;
  final bool isHostMember = member.userId == controller.hostUserId.value;
  final bool isDisabled = isHostMember;
  final List<String> dropdownRoles = controller.getAvailableRoles(member.userId);
  final String? dropdownValue = _getValidRole(member.role);

  return Container(
   width: double.infinity,
   padding: EdgeInsets.all(_d(sw, 16)),
   decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(sw >= 768 ? 16 : AppDimensions.d16.r),
    border: Border.all(color: AppColors.grey.withOpacity(.3)),
    boxShadow: [
     BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: sw >= 768 ? 10 : 8,
      offset: const Offset(0, 2),
     ),
    ],
   ),
   child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     Row(
      children: [
       CustomCircularAvatar(
        imagePath: 'assets/images/role_icon.png',
        innerColors: [
         Colors.yellow.shade100,
         Colors.orange.shade100,
         Colors.lightGreenAccent,
        ],
        borderGradient: [
         AppColors.primaryRed.withOpacity(0.9),
         AppColors.primaryRed.withOpacity(0.3),
        ],
        size: 30,
       ),
       SizedBox(width: _d(sw, 12)),
       Expanded(
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          Text(
           name,
           style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            fontSize: _fs(sw, 14, desktop: 15),
           ),
           overflow: TextOverflow.ellipsis,
          ),
          Text(
           level,
           style: textTheme.titleMedium?.copyWith(
            color: AppColors.grey,
            fontSize: _fs(sw, 12, desktop: 13),
           ),
          ),
         ],
        ),
       ),
      ],
     ),
     SizedBox(height: _dh(sw, 14)),
     Text(
      'assign_role'.tr,
      style: textTheme.titleSmall?.copyWith(
       color: AppColors.black,
       fontWeight: FontWeight.w600,
       fontSize: _fs(sw, 12, desktop: 13),
      ),
     ),
     SizedBox(height: _dh(sw, 6)),
     Obx(() => DropdownButtonFormField<String>(
      value: dropdownRoles.contains(dropdownValue) ? dropdownValue : null,
      decoration: InputDecoration(
       hintText: isDisabled ? (member.role ?? 'HOST') : 'select_a_role'.tr,
       border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw >= 768 ? 12 : 12.r),
        borderSide: BorderSide(color: AppColors.softRed.withOpacity(0.5)),
       ),
       enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw >= 768 ? 12 : 12.r),
        borderSide: BorderSide(color: AppColors.softRed.withOpacity(0.5)),
       ),
       focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw >= 768 ? 12 : 12.r),
        borderSide: BorderSide(color: AppColors.primaryRed),
       ),
       filled: true,
       fillColor: isDisabled
           ? AppColors.grey.withOpacity(0.1)
           : AppColors.softRed.withOpacity(0.1),
       contentPadding: EdgeInsets.symmetric(
        horizontal: _d(sw, 12),
        vertical: _dh(sw, 10),
       ),
       suffixIcon: controller.isUpdatingRole.value
           ? Padding(
        padding: EdgeInsets.all(_d(sw, 8)),
        child: SizedBox(
         width: _d(sw, 16),
         height: _d(sw, 16),
         child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryRed),
        ),
       )
           : null,
      ),
      items: dropdownRoles.map((e) => DropdownMenuItem(
       value: e,
       child: Text(
        e.tr,
        style: textTheme.titleSmall?.copyWith(
         color: AppColors.black,
         fontSize: _fs(sw, 13, desktop: 14),
        ),
       ),
      )).toList(),
      onChanged: isDisabled ? null : (val) {
       if (val != null && member.userId != null) {
        controller.assignRole(member.userId!, val);
       }
      },
     )),
     if (isDisabled)
      Padding(
       padding: EdgeInsets.only(top: _dh(sw, 8)),
       child: Text(
        'host_cannot_assign_self'.tr,
        style: textTheme.bodySmall?.copyWith(
         color: AppColors.primaryRed,
         fontSize: _fs(sw, 11, desktop: 12),
        ),
       ),
      ),
    ],
   ),
  );
 }
}