import 'package:flutter/material.dart';
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:get/get.dart';

class GameModeController extends GetxController {
  final PageController pageController = PageController(viewportFraction: 0.8);
  final RxInt selectedIndex = 0.obs;

  /// Selected mode for PricingScreen ('solo', 'team', 'campaign')
  final RxString selectedMode = 'solo'.obs;

  /// Reactive PNG & SVG paths for PricingScreen
  RxString modePng = 'assets/images/solo11.png'.obs;
  RxString modeSvg = 'assets/images/solo.svg'.obs;

  /// Game modes list
  final List<Map<String, dynamic>> gameModes = [
    {
      'title': 'Solo'.tr,
      'subtitle': 'Play alone at your own pace'.tr,
      'icon': 'assets/images/solo11.png',
      'color': const Color(0xFF4ECDC4),
      'description': 'Challenge yourself and improve your skills individually'.tr,
      'mode': 'solo',
      'svg': 'assets/images/solo.svg',
    },
    {
      'title': 'Team'.tr,
      'subtitle': 'Collaborate with others'.tr,
      'icon': 'assets/images/team11.png',
      'color': const Color(0xFFFF6B6B),
      'description': 'Work together with your team to achieve common goals'.tr,
      'mode': 'team',
      'svg': 'assets/images/team.svg',
    },
    {
      'title': 'Campaign'.tr,
      'subtitle': 'Complete missions and progress'.tr,
      'icon': 'assets/images/campaign11.png',
      'color': const Color(0xFF45B7D1),
      'description': 'Engage in structured missions with progressive difficulty'.tr,
      'mode': 'campaign',
      'svg': 'assets/images/campaign.svg',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) pageController.jumpToPage(0);
    });
    pageController.addListener(_handlePageChange);
  }

  @override
  void onClose() {
    pageController.removeListener(_handlePageChange);
    pageController.dispose();
    super.onClose();
  }

  void resetGameMode() {
    selectedIndex.value = 0;
    selectedMode.value = 'solo';
    modePng.value = 'assets/images/solo11.png';
    modeSvg.value = 'assets/images/solo.svg';
    if (pageController.hasClients) pageController.jumpToPage(0);
  }

  void _handlePageChange() {
    if (pageController.page != null) {
      final newIndex = pageController.page!.round();
      if (newIndex != selectedIndex.value) {
        selectedIndex.value = newIndex;
      }
    }
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  void nextCard() {
    if (selectedIndex.value < gameModes.length - 1) {
      selectedIndex.value++;
      pageController.animateToPage(
        selectedIndex.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousCard() {
    if (selectedIndex.value > 0) {
      selectedIndex.value--;
      pageController.animateToPage(
        selectedIndex.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to Pricing screen and update selected mode
  void navigateToPricingScreen() {
    final selectedGameMode = gameModes[selectedIndex.value]['mode'] as String;
    selectedMode.value = selectedGameMode;

    // Update reactive PNG & SVG
    modePng.value = gameModes[selectedIndex.value]['icon'] as String;
    modeSvg.value = gameModes[selectedIndex.value]['svg'] as String;

    Get.toNamed(AppRoutes.pricingScreen);
  }

  /// Getters for current PNG & SVG (reactive)
  String get currentModePng => modePng.value;
  String get currentModeSvg => modeSvg.value;
}
