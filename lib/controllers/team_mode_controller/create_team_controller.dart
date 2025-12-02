
import 'package:flutter/material.dart';
import 'package:game_app/data/repositories/team_repo.dart';
import 'package:game_app/generated/models/requests/team_mode/join_team.dart';
import 'package:game_app/generated/models/requests/team_mode/edit_team_request.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:dio/dio.dart';

import '../../presentation/routes/app_routes.dart';
import '../../generated/network.dart';
import '../../generated/models/requests/team_mode/create_team_request.dart';
import '../../generated/models/responses/team_mode/create_team_response.dart';
import '../../data/repositories/storage_repository.dart';
import '../../utils/snackbar_helper.dart';
import 'team_lobby_controller.dart';

class CreateTeamController extends GetxController {
  final teamNameController = TextEditingController();
  final teamMissionController = TextEditingController();
  final teamCodeController = TextEditingController();

  var selectedAvatarIndex = (-1).obs;
  var isCreatingTeam = false.obs;
  var isJoiningTeam = false.obs;
  var createdTeamId = Rxn<int>();

  final TeamRepository _teamRepository = Get.find<TeamRepository>();
  final StorageRepository _storageRepository = Get.find<StorageRepository>();

  final List<String> avatars = [
    'assets/images/role_icon.png',
    'assets/images/role_icon2.png',
    'assets/images/role_icon.png',
    'assets/images/role_icon2.png',
  ];

  static const int maxTeamSize = 5;

  @override
  void onInit() {
    super.onInit();
    selectedAvatarIndex.value = -1;
  }

  void preloadAllAvatarImages() {
    for (final avatar in avatars) {
      try {
        precacheImage(AssetImage(avatar), Get.context!);
        log('Pre-loaded avatar: $avatar');
      } catch (e) {
        log('Failed to pre-load avatar: $avatar - $e');
      }
    }
  }

  void selectAvatarInstantly(int index) {
    selectedAvatarIndex.value = index;
  }

  // JOIN TEAM — NO NOTIFICATIONS
  Future<void> joinTeam() async {
    final token = teamCodeController.text.trim();
    final user = _storageRepository.getUser();
    final userId = user?.id;

    if (token.isEmpty) {
      SnackbarHelper.warning("Please enter a team code.");
      return;
    }
    if (userId == null) {
      SnackbarHelper.error("User not logged in.");
      return;
    }

    try {
      isJoiningTeam.value = true;
      final request = JoinTeamRequest(token: token, userId: userId);
      final response = await _teamRepository.joinTeam(request);

      if (response.id != null) {
        final joinedTeamId = response.id!;  // بس یہی کافی ہے
        createdTeamId.value = joinedTeamId;

        SnackbarHelper.success("Successfully joined the team!");

        // WebSocket join
        try {
          await _teamRepository.joinWsTeam(token, userId);
          log('Joined WebSocket room');
        } catch (e) {
          log('WebSocket join failed: $e');
        }

        // Update lobby if already open
        if (Get.isRegistered<TeamLobbyController>()) {
          final lobby = Get.find<TeamLobbyController>();
          lobby.teamData.value = response;
          lobby.players.assignAll(
            response.members?.map((m) => m.user?.name ?? 'Player').toList() ?? [],
          );
        }

        // Navigate to Assign Roles
        Get.toNamed(
          AppRoutes.assignRoleScreen,
          arguments: {'teamId': joinedTeamId},
        );
      }    } on DioException catch (e) {
      _handleJoinError(e);
    } catch (e) {
      SnackbarHelper.error("Unexpected error.");
      log(e.toString());
    } finally {
      isJoiningTeam.value = false;
    }
  }

  void _handleJoinError(DioException e) {
    final errorData = e.response?.data;
    final message = errorData is Map ? errorData['message']?.toString() : errorData?.toString();

    if (e.response?.statusCode == 400 && message?.toLowerCase().contains('already a member') == true) {
      SnackbarHelper.info("You are already part of this team.");
      int? teamId;
      if (errorData is Map) {
        teamId ??= int.tryParse(errorData['teamId']?.toString() ?? '');
        teamId ??= int.tryParse(errorData['id']?.toString() ?? '');
        if (errorData['team'] is Map) {
          teamId ??= int.tryParse(errorData['team']['id']?.toString() ?? '');
        }
      }
      if (teamId != null) {
        Get.toNamed(AppRoutes.teamLobby, arguments: {'teamId': teamId});
      }
    } else if (e.response?.statusCode == 400 && message?.toLowerCase().contains('full') == true) {
      SnackbarHelper.error("Team is full (Max $maxTeamSize players).");
    } else {
      SnackbarHelper.error(message ?? "Failed to join team.");
    }
  }

  // EDIT TEAM
  void loadTeamDetailsForEdit(int teamId) async {
    try {
      final response = await _teamRepository.getTeamDetails(teamId);
      teamNameController.text = response.title ?? '';
      teamMissionController.text = response.mission ?? '';
      selectedAvatarIndex.value = int.tryParse(response.teamavatorid ?? '-1') ?? -1;
    } catch (e) {
      SnackbarHelper.error('Failed to load team details.');
    }
  }

  Future<void> _performEdit(int teamId) async {
    try {
      isCreatingTeam.value = true;
      final request = EditTeamRequest(
        title: teamNameController.text.trim(),
        mission: teamMissionController.text.trim(),
        teamavatorid: selectedAvatarIndex.value >= 0 ? selectedAvatarIndex.value.toString() : "0",
      );

      final updatedTeam = await _teamRepository.editTeam(teamId, request);
      SnackbarHelper.success("Team updated successfully!");

      if (Get.isRegistered<TeamLobbyController>()) {
        Get.find<TeamLobbyController>().fetchTeamDetails();
      }

      Get.offNamed(AppRoutes.teamLobby);
    } catch (e) {
      SnackbarHelper.error("Failed to update team.");
    } finally {
      isCreatingTeam.value = false;
    }
  }

  // CREATE TEAM — NO NOTIFICATIONS
  Future<void> createTeam() async {
    try {
      isCreatingTeam.value = true;
      final user = _storageRepository.getUser();
      final hostId = user?.id;

      if (hostId == null) {
        SnackbarHelper.error("User not found. Please login again.");
        return;
      }

      final request = CreateTeamRequest(
        title: teamNameController.text.trim(),
        mission: teamMissionController.text.trim(),
        hostId: hostId,
        teamavatorid: selectedAvatarIndex.value >= 0 ? selectedAvatarIndex.value.toString() : "0",
      );

      final response = await dio.post('/team/create', data: request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final teamId = CreateTeamResponse.fromJson(response.data).team?.id;
        createdTeamId.value = teamId;
        SnackbarHelper.success("Team created successfully!");
        Get.offNamed(AppRoutes.teamLobby);
      } else {
        SnackbarHelper.error(response.data['message'] ?? "Failed to create team.");
      }
    } catch (e) {
      SnackbarHelper.error("Network error.");
      log('Create team error: $e');
    } finally {
      isCreatingTeam.value = false;
    }
  }

  void continueCreateTeam({required bool isEditing}) {
    if (teamNameController.text.trim().isEmpty) {
      SnackbarHelper.warning("Please enter a team name");
      return;
    }
    if (selectedAvatarIndex.value == -1) {
      SnackbarHelper.warning("Please choose a team avatar");
      return;
    }

    if (isEditing) {
      final teamId = createdTeamId.value;
      if (teamId != null) _performEdit(teamId);
      else SnackbarHelper.error("Team ID missing.");
    } else {
      createTeam();
    }
  }

  @override
  void onClose() {
    teamNameController.dispose();
    teamMissionController.dispose();
    teamCodeController.dispose();
    super.onClose();
  }
}
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../presentation/routes/app_routes.dart';
//
// class CreateTeamController extends GetxController {
//   final teamNameController = TextEditingController();
//   final teamMissionController = TextEditingController();
//   final teamCodeController = TextEditingController();
//
//
// // For now static local images (replace with your assets)
//   final avatars = <String>[
//     'assets/images/role_icon.png',
//     'assets/images/role_icon2.png',
//     'assets/images/role_icon.png',
//     'assets/images/role_icon2.png',
//   ].obs;
//
//   var selectedAvatarIndex = (-1).obs;
//
//   void selectAvatar(int index) {
//     selectedAvatarIndex.value = index;
//   }
//
//
//   void joinTeam() {
//     if (teamCodeController.text.trim().isEmpty) return;
//     // TODO: handle join team logic
//     Get.snackbar("Success".tr, "Joined existing team!".tr);
//   }
//
//   void continueCreateTeam() {
//     if (teamNameController.text.trim().isEmpty) {
//       Get.snackbar("Error".tr, "Please enter a team name".tr);
//       return;
//     }
//
//
//     Get.toNamed(AppRoutes.teamLobby);
//   }
//
//   @override
//   void onClose() {
//     teamNameController.dispose();
//     teamMissionController.dispose();
//     teamCodeController.dispose();
//     super.onClose();
//   }
// }
