// lib/controllers/notification_demo_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Demo controller to showcase all notification types
/// This shows static messages instead of actual notifications
class NotificationDemoController extends GetxController {

  // Helper method to show static notification message
  void _showDemoMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  // ============================================================================
  // SOLO MODE NOTIFICATION DEMOS
  // ============================================================================

  /// Demo: Solo evaluation completed successfully
  void demo_soloEvaluationCompleted() {
    _showDemoMessage(
      '📊 Solo Evaluation Complete',
      'Demo Player - Level 3 - Evaluation completed successfully!',
    );
  }

  /// Demo: Solo evaluation failed with retry
  void demo_soloEvaluationFailed() {
    _showDemoMessage(
      '⚠️ Solo Evaluation Failed',
      'Demo Player - 2 attempts remaining - Try again!',
    );
  }

  /// Demo: Solo overall completion
  void demo_soloOverallCompletion() {
    _showDemoMessage(
      '🎉 Solo Mode Complete',
      'Demo Player - Congratulations! You\'ve completed Solo Mode!',
    );
  }

  // ============================================================================
  // CHALLENGE MODE NOTIFICATION DEMOS
  // ============================================================================

  /// Demo: Challenge invitation received
  void demo_challengeInvitationReceived() {
    _showDemoMessage(
      '🎮 Challenge Invitation',
      'Challenge Host invited you to a challenge!',
    );
  }

  /// Demo: Challenge invitation accepted
  void demo_challengeInvitationAccepted() {
    _showDemoMessage(
      '✅ Invitation Accepted',
      'Demo Player accepted your challenge invitation!',
    );
  }

  /// Demo: Challenge started
  void demo_challengeStarted() {
    _showDemoMessage(
      '🚀 Challenge Started',
      'Challenge Host - The challenge has begun! Good luck!',
    );
  }

  /// Demo: Challenge player progress
  void demo_challengePlayerProgress() {
    _showDemoMessage(
      '📈 Player Progress',
      'Demo Player made progress in the challenge!',
    );
  }

  /// Demo: Challenge completed (winner)
  void demo_challengeCompletedWinner() {
    _showDemoMessage(
      '🏆 Challenge Complete - WINNER!',
      'Demo Player won the challenge! Congratulations!',
    );
  }

  /// Demo: Challenge completed (loser)
  void demo_challengeCompletedLoser() {
    _showDemoMessage(
      '🎯 Challenge Complete',
      'Demo Player - Better luck next time! Keep practicing!',
    );
  }

  // ============================================================================
  // CAMPAIGN MODE NOTIFICATION DEMOS
  // ============================================================================

  /// Demo: Campaign level unlocked
  void demo_campaignLevelUnlocked() {
    _showDemoMessage(
      '🔓 Level Unlocked!',
      'Demo Player - Level 2 is now available!',
    );
  }

  /// Demo: Campaign level reminder
  void demo_campaignLevelReminder() {
    _showDemoMessage(
      '⏰ Level Reminder',
      'Demo Player - Level 2 - 15 minutes remaining!',
    );
  }

  /// Demo: Campaign certification reminder
  void demo_campaignCertificationReminder() {
    _showDemoMessage(
      '📜 Certification Reminder',
      'Demo Player - 30 minutes until certification deadline!',
    );
  }

  /// Demo: Campaign certification complete
  void demo_campaignCertificationComplete() {
    _showDemoMessage(
      '🎓 Certification Complete!',
      'Demo Player - You\'ve earned your certification!',
    );
  }

  // ============================================================================
  // TEAM MODE NOTIFICATION DEMOS
  // ============================================================================

  /// Demo: Team invitation
  void demo_teamInvitation() {
    _showDemoMessage(
      '👥 Team Invitation',
      'Team Host invited you to join Team #123',
    );
  }

  /// Demo: Team auto-joined
  void demo_teamAutoJoined() {
    _showDemoMessage(
      '🤝 Auto-Joined Team',
      'You\'ve been automatically added to Team #123 by Team Host',
    );
  }

  /// Demo: Team member joined
  void demo_teamMemberJoined() {
    _showDemoMessage(
      '➕ Member Joined',
      'New Player joined Team #123',
    );
  }

  /// Demo: Team member left
  void demo_teamMemberLeft() {
    _showDemoMessage(
      '➖ Member Left',
      'Leaving Player left Team #123',
    );
  }

  /// Demo: Team roster updated
  void demo_teamRosterUpdated() {
    _showDemoMessage(
      '📋 Roster Updated',
      'Team #123 roster has been updated',
    );
  }

  /// Demo: Team role assigned
  void demo_teamRoleAssigned() {
    _showDemoMessage(
      '🎭 Role Assigned',
      'Demo Player - You are now the Strategic Architect',
    );
  }

  /// Demo: Team game started
  void demo_teamGameStarted() {
    _showDemoMessage(
      '🎲 Team Game Started',
      'Team #123 - The game has begun! Good luck team!',
    );
  }

  /// Demo: Team player progress
  void demo_teamPlayerProgress() {
    _showDemoMessage(
      '📊 Team Progress',
      'Demo Player made progress in Team #123',
    );
  }

  /// Demo: Team time reminder
  void demo_teamTimeReminder() {
    _showDemoMessage(
      '⏱️ Time Reminder',
      'Team #123 - 10 minutes remaining in the game!',
    );
  }

  /// Demo: Team score updated
  void demo_teamScoreUpdated() {
    _showDemoMessage(
      '⭐ Score Update',
      'Demo Player scored points for Team #123',
    );
  }

  /// Demo: Team game complete (winner)
  void demo_teamGameCompleteWinner() {
    _showDemoMessage(
      '🏆 TEAM VICTORY!',
      'Team #123 - Congratulations! Your team won!',
    );
  }

  /// Demo: Team game complete (loser)
  void demo_teamGameCompleteLoser() {
    _showDemoMessage(
      '🎮 Game Complete',
      'Team #123 - Great effort! Try again next time!',
    );
  }

  // ============================================================================
  // BATCH DEMO METHODS
  // ============================================================================

  /// Demo all solo mode notifications
  void demo_allSoloNotifications() {
    demo_soloEvaluationCompleted();
    Future.delayed(const Duration(seconds: 2), () {
      demo_soloEvaluationFailed();
    });
    Future.delayed(const Duration(seconds: 4), () {
      demo_soloOverallCompletion();
    });
  }

  /// Demo all challenge mode notifications
  void demo_allChallengeNotifications() {
    demo_challengeInvitationReceived();
    Future.delayed(const Duration(seconds: 2), () {
      demo_challengeInvitationAccepted();
    });
    Future.delayed(const Duration(seconds: 4), () {
      demo_challengeStarted();
    });
    Future.delayed(const Duration(seconds: 6), () {
      demo_challengePlayerProgress();
    });
    Future.delayed(const Duration(seconds: 8), () {
      demo_challengeCompletedWinner();
    });
  }

  /// Demo all campaign mode notifications
  void demo_allCampaignNotifications() {
    demo_campaignLevelUnlocked();
    Future.delayed(const Duration(seconds: 2), () {
      demo_campaignLevelReminder();
    });
    Future.delayed(const Duration(seconds: 4), () {
      demo_campaignCertificationReminder();
    });
    Future.delayed(const Duration(seconds: 6), () {
      demo_campaignCertificationComplete();
    });
  }

  /// Demo all team mode notifications
  void demo_allTeamNotifications() {
    demo_teamInvitation();
    Future.delayed(const Duration(seconds: 2), () {
      demo_teamMemberJoined();
    });
    Future.delayed(const Duration(seconds: 4), () {
      demo_teamRoleAssigned();
    });
    Future.delayed(const Duration(seconds: 6), () {
      demo_teamGameStarted();
    });
    Future.delayed(const Duration(seconds: 8), () {
      demo_teamPlayerProgress();
    });
    Future.delayed(const Duration(seconds: 10), () {
      demo_teamScoreUpdated();
    });
    Future.delayed(const Duration(seconds: 12), () {
      demo_teamGameCompleteWinner();
    });
  }

  /// Demo all notification types
  void demo_allNotifications() {
    demo_allSoloNotifications();
    Future.delayed(const Duration(seconds: 15), () {
      demo_allChallengeNotifications();
    });
    Future.delayed(const Duration(seconds: 30), () {
      demo_allCampaignNotifications();
    });
    Future.delayed(const Duration(seconds: 45), () {
      demo_allTeamNotifications();
    });
  }
}



// // lib/controllers/notification_demo_controller.dart
// import 'package:get/get.dart';
// import '../services/notification_service.dart';
// import '../data/repositories/storage_repository.dart';
//
// /// Demo controller to showcase all notification types
// /// This can be used for testing the notification system
// class NotificationDemoController extends GetxController {
//   final FirebaseNotificationService _notificationService = Get.find<FirebaseNotificationService>();
//   final StorageRepository _storageRepository = Get.find<StorageRepository>();
//
//   // ============================================================================
//   // SOLO MODE NOTIFICATION DEMOS
//   // ============================================================================
//
//   /// Demo: Solo evaluation completed successfully
//   void demo_soloEvaluationCompleted() {
//     _notificationService.sendSoloEvaluationCompleted(
//       playerName: 'Demo Player',
//       level: 3,
//     );
//   }
//
//   /// Demo: Solo evaluation failed with retry
//   void demo_soloEvaluationFailed() {
//     _notificationService.sendSoloEvaluationFailed(
//       playerName: 'Demo Player',
//       remainingAttempts: 2,
//     );
//   }
//
//   /// Demo: Solo overall completion
//   void demo_soloOverallCompletion() {
//     _notificationService.sendSoloOverallCompletion(
//       playerName: 'Demo Player',
//     );
//   }
//
//   // ============================================================================
//   // CHALLENGE MODE NOTIFICATION DEMOS
//   // ============================================================================
//
//   /// Demo: Challenge invitation received
//   void demo_challengeInvitationReceived() {
//     _notificationService.sendChallengeInvitation(
//       hostName: 'Challenge Host',
//       recipientName: 'Demo Player',
//       recipientUserId: 'demo_user_id',
//       isReceived: true,
//     );
//   }
//
//   /// Demo: Challenge invitation accepted
//   void demo_challengeInvitationAccepted() {
//     _notificationService.sendChallengeInvitationResponse(
//       playerName: 'Demo Player',
//       hostUserId: 'host_user_id',
//       isAccepted: true,
//     );
//   }
//
//   /// Demo: Challenge started
//   void demo_challengeStarted() {
//     _notificationService.sendChallengeStarted(
//       hostName: 'Challenge Host',
//       participantUserIds: ['player1', 'player2', 'player3'],
//     );
//   }
//
//   /// Demo: Challenge player progress
//   void demo_challengePlayerProgress() {
//     _notificationService.sendChallengePlayerProgress(
//       playerName: 'Demo Player',
//       otherParticipantUserIds: ['player1', 'player2'],
//     );
//   }
//
//   /// Demo: Challenge completed (winner)
//   void demo_challengeCompletedWinner() {
//     _notificationService.sendChallengeCompleted(
//       playerName: 'Demo Player',
//       recipientUserId: 'demo_user_id',
//       isWinner: true,
//     );
//   }
//
//   /// Demo: Challenge completed (loser)
//   void demo_challengeCompletedLoser() {
//     _notificationService.sendChallengeCompleted(
//       playerName: 'Demo Player',
//       recipientUserId: 'demo_user_id',
//       isWinner: false,
//     );
//   }
//
//   // ============================================================================
//   // CAMPAIGN MODE NOTIFICATION DEMOS
//   // ============================================================================
//
//   /// Demo: Campaign level unlocked
//   void demo_campaignLevelUnlocked() {
//     _notificationService.sendCampaignLevelUnlocked(
//       playerName: 'Demo Player',
//       level: 2,
//       playerUserId: 'demo_user_id',
//     );
//   }
//
//   /// Demo: Campaign level reminder
//   void demo_campaignLevelReminder() {
//     _notificationService.sendCampaignLevelReminder(
//       playerName: 'Demo Player',
//       level: 2,
//       remainingMinutes: 15,
//       playerUserId: 'demo_user_id',
//     );
//   }
//
//   /// Demo: Campaign certification reminder
//   void demo_campaignCertificationReminder() {
//     _notificationService.sendCampaignCertificationReminder(
//       playerName: 'Demo Player',
//       remainingMinutes: 30,
//       playerUserId: 'demo_user_id',
//     );
//   }
//
//   /// Demo: Campaign certification complete
//   void demo_campaignCertificationComplete() {
//     _notificationService.sendCampaignCertificationComplete(
//       playerName: 'Demo Player',
//       playerUserId: 'demo_user_id',
//     );
//   }
//
//   // ============================================================================
//   // TEAM MODE NOTIFICATION DEMOS
//   // ============================================================================
//
//   /// Demo: Team invitation
//   void demo_teamInvitation() {
//     _notificationService.sendTeamInvitation(
//       hostName: 'Team Host',
//       recipientUserId: 'demo_user_id',
//       teamId: 123,
//       autoJoin: false,
//     );
//   }
//
//   /// Demo: Team auto-joined
//   void demo_teamAutoJoined() {
//     _notificationService.sendTeamInvitation(
//       hostName: 'Team Host',
//       recipientUserId: 'demo_user_id',
//       teamId: 123,
//       autoJoin: true,
//     );
//   }
//
//   /// Demo: Team member joined
//   void demo_teamMemberJoined() {
//     _notificationService.sendTeamMemberUpdate(
//       playerName: 'New Player',
//       hasJoined: true,
//       teamId: 123,
//       teamMemberUserIds: ['player1', 'player2', 'player3'],
//     );
//   }
//
//   /// Demo: Team member left
//   void demo_teamMemberLeft() {
//     _notificationService.sendTeamMemberUpdate(
//       playerName: 'Leaving Player',
//       hasJoined: false,
//       teamId: 123,
//       teamMemberUserIds: ['player1', 'player2'],
//     );
//   }
//
//   /// Demo: Team roster updated
//   void demo_teamRosterUpdated() {
//     _notificationService.sendTeamRosterUpdated(
//       teamId: 123,
//       teamMemberUserIds: ['player1', 'player2', 'player3'],
//     );
//   }
//
//   /// Demo: Team role assigned
//   void demo_teamRoleAssigned() {
//     _notificationService.sendTeamRoleAssigned(
//       playerName: 'Demo Player',
//       roleName: 'Strategic Architect',
//       playerUserId: 'demo_user_id',
//       teamId: 123,
//     );
//   }
//
//   /// Demo: Team game started
//   void demo_teamGameStarted() {
//     _notificationService.sendTeamGameStarted(
//       teamId: 123,
//       teamMemberUserIds: ['player1', 'player2', 'player3'],
//     );
//   }
//
//   /// Demo: Team player progress
//   void demo_teamPlayerProgress() {
//     _notificationService.sendTeamPlayerProgress(
//       playerName: 'Demo Player',
//       teamId: 123,
//       otherTeamMemberUserIds: ['player1', 'player2'],
//     );
//   }
//
//   /// Demo: Team time reminder
//   void demo_teamTimeReminder() {
//     _notificationService.sendTeamTimeReminder(
//       remainingMinutes: 10,
//       teamId: 123,
//       teamMemberUserIds: ['player1', 'player2', 'player3'],
//     );
//   }
//
//   /// Demo: Team score updated
//   void demo_teamScoreUpdated() {
//     _notificationService.sendTeamScoreUpdated(
//       playerName: 'Demo Player',
//       teamId: 123,
//       otherTeamMemberUserIds: ['player1', 'player2'],
//     );
//   }
//
//   /// Demo: Team game complete (winner)
//   void demo_teamGameCompleteWinner() {
//     _notificationService.sendTeamGameComplete(
//       playerName: 'Demo Player',
//       recipientUserId: 'demo_user_id',
//       teamId: 123,
//       isWinner: true,
//     );
//   }
//
//   /// Demo: Team game complete (loser)
//   void demo_teamGameCompleteLoser() {
//     _notificationService.sendTeamGameComplete(
//       playerName: 'Demo Player',
//       recipientUserId: 'demo_user_id',
//       teamId: 123,
//       isWinner: false,
//     );
//   }
//
//   // ============================================================================
//   // BATCH DEMO METHODS
//   // ============================================================================
//
//   /// Demo all solo mode notifications
//   void demo_allSoloNotifications() {
//     demo_soloEvaluationCompleted();
//     Future.delayed(const Duration(seconds: 2), () {
//       demo_soloEvaluationFailed();
//     });
//     Future.delayed(const Duration(seconds: 4), () {
//       demo_soloOverallCompletion();
//     });
//   }
//
//   /// Demo all challenge mode notifications
//   void demo_allChallengeNotifications() {
//     demo_challengeInvitationReceived();
//     Future.delayed(const Duration(seconds: 2), () {
//       demo_challengeInvitationAccepted();
//     });
//     Future.delayed(const Duration(seconds: 4), () {
//       demo_challengeStarted();
//     });
//     Future.delayed(const Duration(seconds: 6), () {
//       demo_challengePlayerProgress();
//     });
//     Future.delayed(const Duration(seconds: 8), () {
//       demo_challengeCompletedWinner();
//     });
//   }
//
//   /// Demo all campaign mode notifications
//   void demo_allCampaignNotifications() {
//     demo_campaignLevelUnlocked();
//     Future.delayed(const Duration(seconds: 2), () {
//       demo_campaignLevelReminder();
//     });
//     Future.delayed(const Duration(seconds: 4), () {
//       demo_campaignCertificationReminder();
//     });
//     Future.delayed(const Duration(seconds: 6), () {
//       demo_campaignCertificationComplete();
//     });
//   }
//
//   /// Demo all team mode notifications
//   void demo_allTeamNotifications() {
//     demo_teamInvitation();
//     Future.delayed(const Duration(seconds: 2), () {
//       demo_teamMemberJoined();
//     });
//     Future.delayed(const Duration(seconds: 4), () {
//       demo_teamRoleAssigned();
//     });
//     Future.delayed(const Duration(seconds: 6), () {
//       demo_teamGameStarted();
//     });
//     Future.delayed(const Duration(seconds: 8), () {
//       demo_teamPlayerProgress();
//     });
//     Future.delayed(const Duration(seconds: 10), () {
//       demo_teamScoreUpdated();
//     });
//     Future.delayed(const Duration(seconds: 12), () {
//       demo_teamGameCompleteWinner();
//     });
//   }
//
//   /// Demo all notification types
//   void demo_allNotifications() {
//     demo_allSoloNotifications();
//     Future.delayed(const Duration(seconds: 15), () {
//       demo_allChallengeNotifications();
//     });
//     Future.delayed(const Duration(seconds: 30), () {
//       demo_allCampaignNotifications();
//     });
//     Future.delayed(const Duration(seconds: 45), () {
//       demo_allTeamNotifications();
//     });
//   }
// }
