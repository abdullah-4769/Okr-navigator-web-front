// lib/presentation/views/team_mode/team_lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:get/get.dart';

import '../../../controllers/team_mode_controller/create_team_controller.dart';
import '../../../controllers/team_mode_controller/team_lobby_controller.dart';
import '../../../core/app_colors.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../utils/snackbar_helper.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_circular_avatar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/global_widgets/custom_progress_path.dart';
import '../../widgets/scoreboard_widgets/custom_rank_container.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class TeamLobbyScreen extends StatelessWidget {
  const TeamLobbyScreen({super.key});

  Widget _buildInviteSlot(double sw) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: sw >= 768 ? 16 : 16.w,
      vertical: sw >= 768 ? 10 : 10.h,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(sw >= 768 ? 48 : 48.r),
      border: Border.all(color: AppColors.primaryRed, width: 1),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.person,
            size: sw >= 768 ? 24 : 24.sp, color: AppColors.primaryRed),
        SizedBox(width: sw >= 768 ? 12 : 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'waiting_for_player'.tr,
              style: TextStyle(
                fontSize: sw >= 768 ? 14 : 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'invite_someone_to_join'.tr,
              style: TextStyle(
                fontSize: sw >= 768 ? 12 : 12.sp,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeamLobbyController());
    final createController = Get.find<CreateTeamController>();
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    if (sw >= 768) return _buildDesktopLayout(context, controller, createController, sw, sh);
    return _buildMobileLayout(context, controller, createController, sw, sh);
  }

  // ── MOBILE — original layout preserved ────────────────────────────────────
  Widget _buildMobileLayout(
      BuildContext context,
      TeamLobbyController controller,
      CreateTeamController createController,
      double sw,
      double sh,
      ) {
    const String BASE_INVITE_URL = "okrnav://join?code=";

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Obx(() {
            final teamData = controller.teamData.value;
            final currentUserId = Get.find<StorageRepository>().getUser()?.id;
            final isHost = teamData?.members?.any(
                  (m) => m.role == 'HOST' && m.user?.id == currentUserId,
            ) ??
                false;
            final membersCount = controller.players.length;
            final teamToken = teamData?.token ?? 'N/A'.tr;
            final avatarId = int.tryParse(teamData?.teamavatorid ?? '0') ?? 0;
            final avatarPath = createController.avatars.isNotEmpty
                ? createController.avatars[avatarId.clamp(0, createController.avatars.length - 1)]
                : 'assets/images/role_icon.png';

            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryRed),
                    SizedBox(height: 16.h),
                    Text('loading_team_details'.tr,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp)),
                  ],
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.primaryRed, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(controller.errorMessage.value,
                        style: TextStyle(color: AppColors.primaryRed, fontSize: 16.sp),
                        textAlign: TextAlign.center),
                    SizedBox(height: 16.h),
                    CustomButton(
                      backgroundColor: AppColors.primaryRed,
                      textColor: Colors.white,
                      text: 'retry'.tr,
                      onPressed: () => controller.fetchTeamDetails(),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: sh * 0.015),
                        CustomHeader(
                          title: teamData?.title ?? 'Team'.tr,
                          highlightedText: 'lobby'.tr,
                          showDashboardIcon: true,
                          onBackTap: () => Get.back(),
                        ),
                        SizedBox(height: sh * 0.01),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CustomCircularAvatar(
                              imagePath: avatarPath,
                              size: 150,
                              innerColors: const [Colors.yellow, Colors.orange, Colors.red],
                              borderGradient: [
                                AppColors.primaryRed.withOpacity(0.9),
                                AppColors.primaryRed.withOpacity(0.3),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: sh * 0.015),
                        _buildTeamCodeBadge(sw, teamToken),
                        SizedBox(height: sh * 0.015),
                        Text('waiting_for_others_to_join'.tr,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
                        SizedBox(height: sh * 0.02),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                          child: _buildMembersProgress(sw, membersCount),
                        ),
                        SizedBox(height: sh * 0.02),
                        Text('start_game_minimum_players'.tr,
                            style: TextStyle(
                                color: AppColors.primaryRed,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: sh * 0.02),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                          child: _buildPlayersList(controller, currentUserId, membersCount, sw),
                        ),
                        SizedBox(height: sh * 0.03),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
                          child: _buildActionButtons(
                              context, controller, isHost, membersCount, sw, BASE_INVITE_URL),
                        ),
                        SizedBox(height: sh * 0.04),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── DESKTOP — matches KeyResultsInputScreen web layout pattern ─────────────
  Widget _buildDesktopLayout(
      BuildContext context,
      TeamLobbyController controller,
      CreateTeamController createController,
      double sw,
      double sh,
      ) {
    const String BASE_INVITE_URL = "okrnav://join?code=";
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
              subtitle: 'lobby'.tr,
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
                child: Obx(() {
                  final teamData = controller.teamData.value;
                  final currentUserId = Get.find<StorageRepository>().getUser()?.id;
                  final isHost = teamData?.members?.any(
                        (m) => m.role == 'HOST' && m.user?.id == currentUserId,
                  ) ??
                      false;
                  final membersCount = controller.players.length;
                  final teamToken = teamData?.token ?? 'N/A'.tr;
                  final avatarId = int.tryParse(teamData?.teamavatorid ?? '0') ?? 0;
                  final avatarPath = createController.avatars.isNotEmpty
                      ? createController.avatars[avatarId.clamp(0, createController.avatars.length - 1)]
                      : 'assets/images/role_icon.png';

                  if (controller.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryRed),
                            const SizedBox(height: 16),
                            Text('loading_team_details'.tr,
                                style: const TextStyle(color: Colors.black54, fontSize: 15)),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, color: AppColors.primaryRed, size: 48),
                            const SizedBox(height: 16),
                            Text(controller.errorMessage.value,
                                style: TextStyle(color: AppColors.primaryRed, fontSize: 15),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 200,
                              child: CustomButton(
                                backgroundColor: AppColors.primaryRed,
                                textColor: Colors.white,
                                text: 'retry'.tr,
                                onPressed: () => controller.fetchTeamDetails(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(48, 36, 48, 40),
                    child: _buildDesktopBody(
                      context, controller, currentUserId, isHost,
                      membersCount, teamToken, avatarPath, sw, BASE_INVITE_URL,
                      teamData?.title,
                    ),
                  );
                }),
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
  Widget _buildDesktopBody(
      BuildContext context,
      TeamLobbyController controller,
      String? currentUserId,
      bool isHost,
      int membersCount,
      String teamToken,
      String avatarPath,
      double sw,
      String BASE_INVITE_URL,
      String? teamTitle,
      ) {
    return Column(
      children: [
        // Top row: avatar left, team info right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CustomCircularAvatar(
              imagePath: avatarPath,
              size: 120,
              innerColors: const [Colors.yellow, Colors.orange, Colors.red],
              borderGradient: [
                AppColors.primaryRed.withOpacity(0.9),
                AppColors.primaryRed.withOpacity(0.3),
              ],
            ),
            const SizedBox(width: 28),

            // Team name + code + waiting text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    teamTitle ?? 'Team'.tr,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'lobby'.tr,
                    style: const TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  const SizedBox(height: 16),
                  _buildTeamCodeBadge(sw, teamToken),
                  const SizedBox(height: 12),
                  Text(
                    'waiting_for_others_to_join'.tr,
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 24),

        // Members progress
        _buildMembersProgress(sw, membersCount),

        const SizedBox(height: 8),
        Text(
          'start_game_minimum_players'.tr,
          style: TextStyle(
            color: AppColors.primaryRed,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 20),

        // Players list
        _buildPlayersList(controller, currentUserId, membersCount, sw),

        const SizedBox(height: 32),
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 28),

        // Action buttons — 2 column on wide desktop
        sw > 1100
            ? Row(
          children: [
            Expanded(
              child: _buildBeginMissionButton(controller, isHost, membersCount),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInviteAndEditButtons(
                  context, controller, isHost, sw, BASE_INVITE_URL),
            ),
          ],
        )
            : _buildActionButtons(
            context, controller, isHost, membersCount, sw, BASE_INVITE_URL),
      ],
    );
  }

  // ── Shared: team code badge ────────────────────────────────────────────────
  Widget _buildTeamCodeBadge(double sw, String teamToken) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw >= 768 ? 16 : 16.w,
        vertical: sw >= 768 ? 10 : 10.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.softRed.withValues(alpha: 0.5),
        border: Border.all(color: AppColors.primaryRed, width: 0.5),
        borderRadius: BorderRadius.circular(sw >= 768 ? 30 : 30.r),
      ),
      child: Row(
        mainAxisSize: sw >= 768 ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Text(
            'team_code_label'.tr,
            style: TextStyle(
              fontSize: sw >= 768 ? 14 : 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: sw >= 768 ? 8 : 8.w),
          Flexible(
            child: Text(
              teamToken,
              style: TextStyle(
                fontSize: sw >= 768 ? 16 : 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: sw >= 768 ? 8 : 8.w),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: teamToken));
              SnackbarHelper.info('Team code copied!');
            },
            child: CircleAvatar(
              radius: sw >= 768 ? 16 : 16.r,
              backgroundColor: AppColors.primaryRed,
              child: Icon(Icons.copy,
                  size: sw >= 768 ? 18 : 18.sp, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared: members progress ───────────────────────────────────────────────
  Widget _buildMembersProgress(double sw, int membersCount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, color: AppColors.primaryRed),
            SizedBox(width: sw >= 768 ? 6 : 6.w),
            Text(
              'members_joined_label'.trParams({'count': membersCount.toString()}),
              style: TextStyle(
                color: AppColors.primaryRed,
                fontSize: sw >= 768 ? 16 : 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: sw >= 768 ? 10 : 10.h),
        CustomProgressPath(
          stepLabels: const ["1", "2", "3", "4", "5"],
          currentStep: (membersCount > 0 ? membersCount - 1 : 0).clamp(0, 4),
          showCircles: false,
        ),
      ],
    );
  }

  // ── Shared: players list ───────────────────────────────────────────────────
  Widget _buildPlayersList(
      TeamLobbyController controller,
      String? currentUserId,
      int membersCount,
      double sw,
      ) {
    return Column(
      children: [
        ...controller.memberScores.asMap().entries.map((entry) {
          final index = entry.key;
          final memberData = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: sw >= 768 ? 10 : 0),
            child: CustomRankContainer(
              rank: index + 1,
              name: memberData['name'] ?? 'unknown_user'.tr,
              level: memberData['level'] ?? 1,
              points: memberData['points'] ?? 0,
              score: memberData['score'] ?? 0,
              isHighlighted: memberData['userId'] == currentUserId,
            ),
          );
        }).toList(),
        if (membersCount < 5) _buildInviteSlot(sw),
      ],
    );
  }

  // ── Shared: begin mission button ───────────────────────────────────────────
  Widget _buildBeginMissionButton(
      TeamLobbyController controller,
      bool isHost,
      int membersCount,
      ) {
    return Column(
      children: [
        CustomButton2(
          backgroundColor: (isHost && membersCount >= 2)
              ? AppColors.primaryBlue
              : AppColors.textSecondary.withOpacity(0.3),
          textColor: Colors.white,
          text: 'begin_mission'.tr,
          onPressed: (isHost && membersCount >= 2) ? controller.beginMission : null,
        ),
        if (!isHost)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'host_only_begin_mission'.tr,
              style: const TextStyle(color: Colors.black45, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  // ── Shared: invite + edit buttons ─────────────────────────────────────────
  Widget _buildInviteAndEditButtons(
      BuildContext context,
      TeamLobbyController controller,
      bool isHost,
      double sw,
      String BASE_INVITE_URL,
      ) {
    return Column(
      children: [
        if (isHost)
          Obx(() => CustomButton(
            backgroundColor: AppColors.primaryRed,
            textColor: Colors.white,
            text: controller.isInvitingMember.value ? 'inviting'.tr : 'invite_members'.tr,
            isLoading: controller.isInvitingMember.value,
            onPressed: () {
              controller.inviteMembers().then((token) {
                if (token != null) {
                  final shareableLink = BASE_INVITE_URL + token;
                  Get.defaultDialog(
                    title: 'shareable_team_link_title'.tr,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'shareable_team_link_body'.tr,
                          style: TextStyle(
                            fontSize: sw >= 768 ? 15 : 16.sp,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: sw >= 768 ? 15 : 15.h),
                        Container(
                          padding: EdgeInsets.all(sw >= 768 ? 12 : 12.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(sw >= 768 ? 8 : 8.r),
                            border: Border.all(color: AppColors.primaryBlue, width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  shareableLink,
                                  style: TextStyle(
                                    fontSize: sw >= 768 ? 14 : 14.sp,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              SizedBox(width: sw >= 768 ? 8 : 8.w),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: shareableLink));
                                  SnackbarHelper.success('team_code_copied_clipboard'.tr);
                                  Get.back();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(sw >= 768 ? 8 : 8.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(sw >= 768 ? 6 : 6.r),
                                  ),
                                  child: Icon(Icons.copy,
                                      size: sw >= 768 ? 16 : 16.sp, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: sw >= 768 ? 15 : 15.h),
                        CustomButton(
                          text: 'done'.tr,
                          onPressed: () => Get.back(),
                          backgroundColor: AppColors.primaryRed,
                        ),
                      ],
                    ),
                    textConfirm: null,
                    onConfirm: null,
                    confirmTextColor: Colors.white,
                  );
                }
              });
            },
          )),
        SizedBox(height: sw >= 768 ? 10 : 10.h),
        CustomButton(
          backgroundColor: AppColors.primaryBlue,
          textColor: Colors.white,
          text: "Edit Team Info".tr,
          onPressed: () => Get.toNamed(
            AppRoutes.createTeam,
            arguments: {'isEditing': true},
          ),
        ),
      ],
    );
  }

  // ── Mobile: all action buttons together ───────────────────────────────────
  Widget _buildActionButtons(
      BuildContext context,
      TeamLobbyController controller,
      bool isHost,
      int membersCount,
      double sw,
      String BASE_INVITE_URL,
      ) {
    return Column(
      children: [
        _buildBeginMissionButton(controller, isHost, membersCount),
        SizedBox(height: sw >= 768 ? 10 : 10.h),
        _buildInviteAndEditButtons(context, controller, isHost, sw, BASE_INVITE_URL),
      ],
    );
  }
}