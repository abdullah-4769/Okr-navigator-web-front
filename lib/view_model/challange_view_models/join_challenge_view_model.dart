// import 'package:get/get.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:game_app/generated/models/requests/challange_mode/join_challange_request.dart';
import 'package:get/get.dart';
import '../../data/repositories/storage_repository.dart';
import '../../presentation/challenge_view/challenge_details_screen.dart';
import '../../repository/challange_repositories/join_challange_repository.dart';

class JoinChallengeViewModel extends GetxController {
  final TextEditingController inviteCodeController = TextEditingController();
  final StorageRepository _storageRepo = Get.find<StorageRepository>();
  final JoinChallengeRepository _repository = JoinChallengeRepository();

  var isJoining = false.obs;
  var joinStatus = ''.obs;
  var inviteCode = ''.obs;

  void clearStatus() {
    joinStatus.value = '';
  }

  bool isValidInviteCode(String code) {
    return code.length == 6 && RegExp(r'^[A-Z0-9]{6}$').hasMatch(code.toUpperCase());
  }

  /// Join a challenge using invite code
  Future<void> joinChallengeWithCode(String inviteCode, String userId) async {
    if (!isValidInviteCode(inviteCode)) {
      Get.snackbar(
        'Invalid Code',
        'Please enter a valid 6-character invite code',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isJoining.value = true;
      joinStatus.value = 'Joining challenge...';

      final upperCode = inviteCode.toUpperCase();

      print('\n🎯 ========== JOINING CHALLENGE ==========');
      print('📋 Code: $upperCode');
      print('👤 User ID: $userId');

      // Call repository to join
      final result = await _repository.joinChallenge(upperCode, userId as JoinChallengeRequest);

      final challengeId = result['challengeId'];

      print('✅ Join successful!');
      print('   Challenge ID: $challengeId');
      print('   User ID: $userId');
      print('=========================================\n');

      joinStatus.value = 'Successfully joined!';

      // Show success message
      Get.snackbar(
        'Success! 🎉',
        'You joined the challenge!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      // Navigate to challenge details
      await Future.delayed(Duration(milliseconds: 800));
      Get.to(() => ChallengeDetailsScreen());

    } catch (e) {
      print('❌ ERROR: $e');

      joinStatus.value = 'Error: ${e.toString()}';

      Get.snackbar(
        'Failed to Join',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isJoining.value = false;
    }
  }

  @override
  void onClose() {
    inviteCodeController.dispose();
    super.onClose();
  }
}
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:game_app/data/response/api_response.dart';
// import '../../generated/models/requests/challange_mode/join_challange_request.dart';
// import '../../repository/challange_repositories/join_challange_repository.dart';
//
// class JoinChallengeViewModel extends GetxController {
//   final JoinChallengeRepository _repository = JoinChallengeRepository();
//
//   final Rx<ApiResponse> _joinChallengeResponse = ApiResponse.notStarted().obs;
//   ApiResponse get joinChallengeResponse => _joinChallengeResponse.value;
//
//   final isJoining = false.obs;
//
//   Future<void> joinChallenge(String code) async {
//     print('JoinChallengeViewModel: joinChallenge called with code: $code');
//     try {
//       isJoining.value = true;
//       _joinChallengeResponse.value = ApiResponse.loading();
//       print('JoinChallengeViewModel: Set isJoining to true, response to loading');
//
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString('userId');
//       print('JoinChallengeViewModel: Retrieved userId: $userId');
//
//       if (userId == null) {
//         print('JoinChallengeViewModel: Error - User ID not found in SharedPreferences');
//         _joinChallengeResponse.value = ApiResponse.error("User ID not found");
//         return;
//       }
//
//       final request = JoinChallengeRequest(userId: userId);
//       print('JoinChallengeViewModel: Sending join request with code: $code, userId: $userId');
//
//       final response = await _repository.joinChallenge(code, request);
//       print('JoinChallengeViewModel: Received response: $response');
//
//       _joinChallengeResponse.value = ApiResponse.completed(response);
//       print('JoinChallengeViewModel: Set response to completed');
//       // ✅ Save joined challenge ID for later use
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         // Assuming response is a Map (based on your API response)
//         final challengeId = response['id']?.toString();
//         if (challengeId != null) {
//           await prefs.setString('joinChallengeId', challengeId);
//           print('✅ Saved joinChallengeId: $challengeId');
//         } else {
//           print('⚠️ No challenge ID found in join challenge response');
//         }
//       } catch (e) {
//         print('⚠️ Error saving joinChallengeId to SharedPreferences: $e');
//       }
//
//     } catch (error) {
//       print('JoinChallengeViewModel: Error occurred: $error');
//       _joinChallengeResponse.value = ApiResponse.error(error.toString());
//     } finally {
//       isJoining.value = false;
//       print('JoinChallengeViewModel: Set isJoining to false');
//     }
//
//   }
// }