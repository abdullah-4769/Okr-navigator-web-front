// lib/presentation/views/team_mode/team_lobby_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:get/get.dart';

import '../../../controllers/team_mode_controller/create_team_controller.dart';
import '../../../controllers/team_mode_controller/team_lobby_controller.dart';
import '../../../core/app_colors.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../../utils/snackbar_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_circular_avatar.dart';
import '../../widgets/global_widgets/custom_progress_path.dart';
import '../../widgets/scoreboard_widgets/custom_rank_container.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class TeamLobbyScreen extends StatelessWidget {
  const TeamLobbyScreen({super.key});

  // Reusable Invite Slot (Waiting for player...)
  Widget _buildInviteSlot(double width) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48.r),
        border: Border.all(color: AppColors.primaryRed, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryRed, width: 1.5),
            ),
            child: Icon(Icons.add, size: 16.sp, color: AppColors.primaryRed),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Waiting for player...",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                "Invite someone to join",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeamLobbyController());
    final createController = Get.find<CreateTeamController>();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    const String baseInviteUrl = "okrnav://join?code=";

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Obx(() {
            final teamData = controller.teamData.value;
            final currentUserId = Get.find<StorageRepository>().getUser()?.id;
            final isHost = teamData?.members?.any((m) => m.role == 'HOST' && m.user?.id == currentUserId) ?? false;
            final membersCount = controller.players.length;
            final teamToken = teamData?.token ?? "N/A";

            // Dynamic avatar from selected index
            final avatarId = int.tryParse(teamData?.teamavatorid ?? '0') ?? 0;
            final avatarPath = createController.avatars.isNotEmpty
                ? createController.avatars[avatarId.clamp(0, createController.avatars.length - 1)]
                : 'assets/images/role_icon.png';

            // Loading State
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              );
            }

            // Error State
            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.primaryRed, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(controller.errorMessage.value, style: TextStyle(color: AppColors.primaryRed, fontSize: 16.sp)),
                    SizedBox(height: 16.h),
                    CustomButton(
                      backgroundColor: AppColors.primaryRed,
                      textColor: Colors.white,
                      text: 'Retry',
                      onPressed: controller.fetchTeamDetails,
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
                        SizedBox(height: height * 0.015),

                        // Header - Dynamic Team Name
                        CustomHeader(
                          title: teamData?.title ?? 'Team'.tr,
                          highlightedText: "Lobby".tr,
                          showDashboardIcon: true,
                          onBackTap: () => Get.back(),
                        ),

                        SizedBox(height: height * 0.01),

                        // Team Avatar
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

                        SizedBox(height: height * 0.015),

                        // Team Code Box
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: AppColors.softRed.withValues(alpha: 0.5),
                            border: Border.all(color: AppColors.primaryRed, width: 0.5),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Team Code: ",
                                style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  teamToken,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryRed,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: teamToken));
                                  SnackbarHelper.info('Team code copied!');
                                },
                                child: CircleAvatar(
                                  radius: 16.r,
                                  backgroundColor: AppColors.primaryRed,
                                  child: Icon(Icons.copy, size: 18.sp, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.015),
                        Text("Waiting for others to join...", style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
                        SizedBox(height: height * 0.02),

                        // Members Progress
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.groups, color: AppColors.primaryRed),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "$membersCount Members Joined",
                                    style: TextStyle(color: AppColors.primaryRed, fontSize: 16.sp, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              CustomProgressPath(
                                stepLabels: const ["1", "2", "3", "4", "5"],
                                currentStep: (membersCount > 0 ? membersCount - 1 : 0).clamp(0, 4),
                                showCircles: false,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.02),
                        Text(
                          "Start Game (Minimum 2 players required)",
                          style: TextStyle(color: AppColors.primaryRed, fontSize: 13.sp, fontWeight: FontWeight.w500),
                        ),

                        SizedBox(height: height * 0.02),

                        // Players List (Dynamic)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                          child: Column(
                            children: [
                              ...controller.memberScores.asMap().entries.map((entry) {
                                final index = entry.key;
                                final member = entry.value;
                                return CustomRankContainer(
                                  rank: index + 1,
                                  name: member['name'] ?? "Unknown",
                                  level: member['level'] ?? 1,
                                  points: member['points'] ?? 0,
                                  score: member['score'] ?? 0,
                                  isHighlighted: member['userId'] == currentUserId,
                                );
                              }).toList(),

                              if (membersCount < 5) _buildInviteSlot(width),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.03),

                        // Action Buttons
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                          child: Column(
                            children: [
                              // Begin Mission
                              CustomButton2(
                                backgroundColor: (isHost && membersCount >= 2)
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary.withOpacity(0.3),
                                textColor: Colors.white,
                                text: "Begin Mission".tr,
                                onPressed: (isHost && membersCount >= 2) ? controller.beginMission : null,
                              ),

                              if (!isHost)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Text(
                                    "Only the host can begin the mission.",
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              SizedBox(height: 10.h),

                              // Invite Members (Only Host)
                              if (isHost)
                                Obx(() => CustomButton(
                                  backgroundColor: AppColors.primaryRed,
                                  textColor: Colors.white,
                                  text: controller.isInvitingMember.value ? "Inviting..." : "Invite Members".tr,
                                  isLoading: controller.isInvitingMember.value,
                                  onPressed: () async {
                                    final token = await controller.inviteMembers();
                                    if (token != null) {
                                      final shareLink = baseInviteUrl + token;

                                      // 100% safe way to show dialog
                                      Future.delayed(Duration.zero, () {
                                        Get.defaultDialog(
                                          barrierDismissible: true,
                                          title: "Shareable Team Link".tr,
                                          titleStyle: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                                          content: Padding(
                                            padding: EdgeInsets.all(16.w),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Share this link with your team members:",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                                                ),
                                                SizedBox(height: 16.h),
                                                Container(
                                                  padding: EdgeInsets.all(12.w),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryBlue.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12.r),
                                                    border: Border.all(color: AppColors.primaryBlue),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: SelectableText(
                                                          shareLink,
                                                          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Clipboard.setData(ClipboardData(text: shareLink));
                                                          SnackbarHelper.success("Link copied!");
                                                          Get.back();
                                                        },
                                                        child: Icon(Icons.copy, color: AppColors.primaryBlue),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            CustomButton(
                                              text: "Done",
                                              onPressed: () => Get.back(),
                                              backgroundColor: AppColors.primaryRed,
                                            ),
                                          ],
                                        );
                                      });
                                    }
                                  },                                )),

                              SizedBox(height: 10.h),

                              // Edit Team Info
                              CustomButton(
                                backgroundColor: AppColors.primaryBlue,
                                textColor: Colors.white,
                                text: "Edit Team Info".tr,
                                onPressed: () {
                                  Get.toNamed(AppRoutes.createTeam, arguments: {'isEditing': true});
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.04),
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
}