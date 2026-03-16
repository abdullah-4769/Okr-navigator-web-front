import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../presentation/routes/app_routes.dart';
import '../../services/shared_preference.dart';

class PricingController extends GetxController {
  final RxInt currentPageIndex = 0.obs;

  // ✅ Own the mode locally — never depend on GameModeController which gets
  //    deleted by Get.offAllNamed before this controller even inits
  final RxString selectedMode = 'solo'.obs;

  final List<Map<String, dynamic>> pricingPlans = [
    {
      'title': 'navigator',
      'price': 'Free',
      'features': [
        {'text': 'solo_mode_level_1', 'included': true},
        {'text': 'ai_feedback_per_day', 'included': true},
        {'text': 'certified_challenge_per_day', 'included': true},
        {'text': 'limited_badges', 'included': true},
      ],
      'level': 'level_1_access',
      'users': 'single_user',
      'highlighted': false,
    },
    {
      'title': 'navigator_plus',
      'price': '3.99€/month',
      'features': [
        {'text': 'full_solo_mode', 'included': true},
        {'text': 'weekly_missions', 'included': true},
        {'text': 'ai_tips_debrief', 'included': true},
        {'text': 'xp_tracking', 'included': true},
        {'text': 'community_leaderboard', 'included': true},
        {'text': 'bonus_mode', 'included': true},
      ],
      'level': 'level_2_access',
      'users': 'single_user',
      'highlighted': true,
    },
    {
      'title': 'master_navigation',
      'price': '9.99€/month',
      'features': [
        {'text': 'all_navigator_plus_features', 'included': true},
        {'text': 'official_certificate', 'included': true},
        {'text': 'performance_reports', 'included': true},
        {'text': 'monthly_live_coaching', 'included': true},
        {'text': 'exclusive_badge_sets', 'included': true},
      ],
      'level': 'level_3_access',
      'users': 'multiple_users',
      'highlighted': false,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _readModeFromArguments();
  }

  void _readModeFromArguments() {
    final args = Get.arguments as Map<String, dynamic>?;

    // Priority 1: navigation args (most reliable)
    if (args != null && args['selectedMode'] != null) {
      final mode = args['selectedMode'] as String;
      selectedMode.value = mode;
      SharedPrefs.saveGameMode(mode);
      debugPrint('✅ PricingController - mode from args: $mode');
      return;
    }

    // Priority 2: SharedPrefs sync getter
    final savedMode = SharedPrefs.getGameMode();
    if (savedMode != null && savedMode.isNotEmpty) {
      selectedMode.value = savedMode;
      debugPrint('✅ PricingController - mode from SharedPrefs: $savedMode');
      return;
    }

    // Final fallback
    selectedMode.value = 'solo';
    SharedPrefs.saveGameMode('solo');
    debugPrint('⚠️ PricingController - defaulting to solo');
  }

  void onPageChanged(int index) => currentPageIndex.value = index;

  void nextCard(PageController pageController) {
    if (currentPageIndex.value < pricingPlans.length - 1) {
      currentPageIndex.value++;
      pageController.animateToPage(
        currentPageIndex.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousCard(PageController pageController) {
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
      pageController.animateToPage(
        currentPageIndex.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void handleContinue() {
    // ✅ Read from our own local RxString — never from GameModeController
    final mode = selectedMode.value;
    SharedPrefs.saveGameMode(mode);
    debugPrint('🎮 handleContinue — mode: $mode');

    switch (mode) {
      case 'team':
        Get.delete<PricingController>();
        Get.toNamed(
          AppRoutes.splashScreenTeam,
          arguments: {'selectedMode': mode}, // ✅ always pass mode in args
        );
        break;

      case 'campaign':
        Get.delete<PricingController>();
        // ✅ Pass mode explicitly in arguments — do NOT rely on SharedPrefs
        //    being readable after Get.offAllNamed clears the controller graph
        Get.toNamed(
          AppRoutes.campaignRoleSelectionScreen,
          arguments: {'selectedMode': mode},
        );
        break;

      default:
        selectPlan(currentPageIndex.value, mode);
        break;
    }
  }

  void selectPlan(int index, [String? mode]) {
    final m = mode ?? selectedMode.value;
    Get.delete<PricingController>();
    Get.toNamed(
      AppRoutes.roleSelection,
      arguments: {'selectedMode': m}, // ✅ pass mode here too
    );
  }
}


// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import '../presentation/routes/app_routes.dart';
// import 'game_mode_controller.dart';
// import '../../services/shared_preference.dart';
//
// class PricingController extends GetxController {
//   final RxInt currentPageIndex = 0.obs;
//   final GameModeController gameModeController = Get.find<GameModeController>();
//
//   final List<Map<String, dynamic>> pricingPlans = [
//     {
//       'title': 'navigator',
//       'price': 'Free'.tr,
//       'features': [
//         {'text': 'solo_mode_level_1', 'included': true},
//         {'text': 'ai_feedback_per_day', 'included': true},
//         {'text': 'certified_challenge_per_day', 'included': true},
//         {'text': 'limited_badges', 'included': true},
//       ],
//       'level': 'level_1_access',
//       'users': 'single_user',
//       'highlighted': false,
//     },
//     {
//       'title': 'navigator_plus',
//       'price': '3.99€/month',
//       'features': [
//         {'text': 'full_solo_mode', 'included': true},
//         {'text': 'weekly_missions', 'included': true},
//         {'text': 'ai_tips_debrief', 'included': true},
//         {'text': 'xp_tracking', 'included': true},
//         {'text': 'community_leaderboard', 'included': true},
//         {'text': 'bonus_mode', 'included': true},
//       ],
//       'level': 'level_2_access',
//       'users': 'single_user',
//       'highlighted': true,
//     },
//     {
//       'title': 'master_navigation',
//       'price': '9.99€/month',
//       'features': [
//         {'text': 'all_navigator_plus_features', 'included': true},
//         {'text': 'official_certificate', 'included': true},
//         {'text': 'performance_reports', 'included': true},
//         {'text': 'monthly_live_coaching', 'included': true},
//         {'text': 'exclusive_badge_sets', 'included': true},
//       ],
//       'level': 'level_3_access',
//       'users': 'multiple_users',
//       'highlighted': false,
//     },
//   ];
//
//   @override
//   void onInit() {
//     super.onInit();
//     _readModeFromArguments(); // READ ARGS FIRST
//   }
//
//   void _readModeFromArguments() {
//     // 1. Try to get from navigation arguments (most reliable)
//     final args = Get.arguments as Map<String, dynamic>?;
//     if (args != null && args['selectedMode'] != null) {
//       final mode = args['selectedMode'] as String;
//       gameModeController.selectedMode.value = mode;
//       SharedPrefs.saveGameMode(mode);
//       print('✅ PricingController - mode from args: $mode');
//       return;
//     }
//
//     // 2. Fallback to SharedPrefs
//     final savedMode = SharedPrefs.getGameMode();
//     if (savedMode != null && savedMode.isNotEmpty) {
//       gameModeController.selectedMode.value = savedMode;
//       print('✅ PricingController - mode from SharedPrefs: $savedMode');
//       return;
//     }
//
//     // 3. Final fallback
//     gameModeController.selectedMode.value = 'solo';
//     SharedPrefs.saveGameMode('solo');
//     print('⚠️ PricingController - defaulting to solo');
//   }
//
//   void onPageChanged(int index) {
//     currentPageIndex.value = index;
//   }
//
//   void nextCard(PageController pageController) {
//     if (currentPageIndex.value < pricingPlans.length - 1) {
//       currentPageIndex.value++;
//       pageController.animateToPage(
//         currentPageIndex.value,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   void previousCard(PageController pageController) {
//     if (currentPageIndex.value > 0) {
//       currentPageIndex.value--;
//       pageController.animateToPage(
//         currentPageIndex.value,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   void handleContinue() {
//     final mode = gameModeController.selectedMode.value;
//     SharedPrefs.saveGameMode(mode);
//
//     if (mode == 'team') {
//       Get.toNamed(AppRoutes.splashScreenTeam);
//       Get.delete<PricingController>();
//     } else if (mode == 'campaign') {
//       Get.toNamed(AppRoutes.campaignRoleSelectionScreen);
//       Get.delete<PricingController>();
//     } else {
//       selectPlan(currentPageIndex.value);
//     }
//   }
//
//   void selectPlan(int index) {
//     Get.toNamed(AppRoutes.roleSelection);
//     Get.delete<PricingController>();
//   }
// }