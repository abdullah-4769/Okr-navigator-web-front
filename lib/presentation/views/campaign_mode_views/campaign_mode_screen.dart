import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/game_mode_controller.dart';
import '../../../controllers/key_results_controller.dart';
import '../../../controllers/role_selection_controller.dart';
import '../../../core/app_colors.dart';
import '../../../generated/models/responses/key_results/key_results_response.dart'
    hide Text;
import '../../../services/shared_preference.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/campaign_mode_widgets/custom_industry_card.dart';
import '../../widgets/campaign_mode_widgets/custom_progress_bar.dart';
import '../../widgets/campaign_progress_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_circular_avatar.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import 'navigator_certification_screen_start.dart';

class CampaignModeScreen extends StatefulWidget {
  const CampaignModeScreen({super.key});

  @override
  State<CampaignModeScreen> createState() => _CampaignModeScreenState();
}

class _CampaignModeScreenState extends State<CampaignModeScreen>
    with WidgetsBindingObserver {
  final RoleSelectionController controller = Get.put(RoleSelectionController());

  Map<String, dynamic> _campaignStatus = {
    'currentLevel': 1,
    'level1Unlocked': true,
    'level1Completed': false,
    'level2Unlocked': false,
    'level2Completed': false,
    'level3Unlocked': false,
    'level3Completed': false,
  };
  bool _isLoading = true;
  bool _isStartingLevel = false;
  int? _currentStartingLevel;

  // ── Adaptive font helper ───────────────────────────────────────────────────
  static double _fs(double sw, double mobile,
      {double? tablet, double? desktop}) {
    if (sw >= 1024) return desktop ?? tablet ?? mobile - 2;
    if (sw >= 768) return tablet ?? mobile - 1;
    return mobile.sp;
  }

  // ── LIFECYCLE ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _readModeFromArguments();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mode = await SharedPrefs.getGameMode();
      debugPrint('🔍 CampaignModeScreen - Verified saved mode: $mode');
      if (mode != 'campaign') {
        debugPrint('⚠️ Fixing mode to campaign');
        await SharedPrefs.saveGameMode('campaign');
      }
      _loadCampaignStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 Screen resumed - reloading campaign status');
      _loadCampaignStatus();
    }
  }

  @override
  void didPopNext() {
    debugPrint('🔄 Screen focused - reloading campaign status');
    _loadCampaignStatus();
  }

  // ── MODE READING (same as mobile) ─────────────────────────────────────────

  void _readModeFromArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['selectedMode'] != null) {
      final mode = args['selectedMode'] as String;
      debugPrint('📥 CampaignModeScreen - mode from args: $mode');
      SharedPrefs.saveGameMode(mode);
      final gameModeController = Get.put(GameModeController());
      gameModeController.selectedMode.value = mode;
    } else {
      final savedMode = SharedPrefs.getGameMode();
      debugPrint('📥 CampaignModeScreen - mode from SharedPrefs: $savedMode');
      if (savedMode == null) {
        SharedPrefs.saveGameMode('campaign');
        debugPrint('⚠️ Setting default campaign mode');
      }
    }
  }

  // ── CAMPAIGN STATUS ────────────────────────────────────────────────────────

  Future<void> _loadCampaignStatus() async {
    setState(() => _isLoading = true);
    try {
      await CampaignProgressService.initializeCampaign();
      final status = await CampaignProgressService.getCampaignStatus();

      setState(() {
        _campaignStatus = status;
        _isLoading = false;
      });

      final savedMode = await SharedPrefs.getGameMode();
      debugPrint('🎮 Campaign Mode: $savedMode');
      debugPrint('📊 Campaign Status: $status');

      _showUnlockMessages(status);
    } catch (e) {
      debugPrint('❌ Error loading campaign status: $e');
      setState(() => _isLoading = false);
    }
  }

  // ✅ Mirrors mobile — snackbars intentionally commented out
  void _showUnlockMessages(Map<String, dynamic> status) {
    if (status['level2Unlocked'] as bool && !(status['level2Completed'] as bool)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // Get.snackbar("🎉 Level 2 Unlocked!".tr, "You can now start Organization B".tr, ...);
      });
    }
    if (status['level3Unlocked'] as bool && !(status['level3Completed'] as bool)) {
      Future.delayed(const Duration(milliseconds: 800), () {
        // Get.snackbar("🎉 Level 3 Unlocked!".tr, "You can now start Organization C".tr, ...);
      });
    }
  }

  Future<void> _onRefresh() async => _loadCampaignStatus();

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    return sw < 768
        ? _buildMobileLayout(context, sw)
        : _buildDesktopLayout(context, sw);
  }

  // ── MOBILE LAYOUT ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, double sw) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      CustomHeader(
                        title: 'camp'.tr,
                        highlightedText: 'mode'.tr,
                        onBackTap: () => Get.back(),
                        showDashboardIcon: false,
                      ),
                      SizedBox(height: 12.h),
                      _buildAvatar(sw),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _buildMissionCard(),
                      ),
                      _buildSectionTitle(context, 'campaign_progress'.tr, sw),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _isLoading
                            ? _buildProgressBarLoader(sw)
                            : CustomProgressBar(
                          totalSteps: 3,
                          currentStep: _campaignStatus['currentLevel'] as int,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildSectionTitle(context, 'organizations'.tr, sw),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'organizations_desc'.tr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.black,
                            fontSize: _fs(sw, 13),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildOrganizationCards(sw),
                      SizedBox(height: 20.h),
                      _buildActionButtons(sw),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: sw * -0.07,
              top: MediaQuery.of(context).size.height * 0.4,
              child: const CustomHomeNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  // ── DESKTOP LAYOUT ─────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context, double sw) {
    final double sh = MediaQuery.of(context).size.height;
    final double containerWidth = sw > 1200 ? 780.0 : sw * 0.75;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
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
              screenWidth: sw,
              screenHeight: sh,
              title: 'camp'.tr,
              subtitle: 'mode'.tr,
            ),
          ),

          // Centered card
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
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildAvatar(sw),
                            const SizedBox(width: 24),
                            Expanded(child: _buildMissionCard()),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _buildSectionTitle(context, 'campaign_progress'.tr, sw),
                        const SizedBox(height: 16),
                        _isLoading
                            ? _buildProgressBarLoader(sw)
                            : CustomProgressBar(
                          totalSteps: 3,
                          currentStep: _campaignStatus['currentLevel'] as int,
                        ),
                        const SizedBox(height: 28),
                        _buildSectionTitle(context, 'organizations'.tr, sw),
                        const SizedBox(height: 8),
                        Text(
                          'organizations_desc'.tr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.black,
                            fontSize: _fs(sw, 13, tablet: 13, desktop: 13),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildOrganizationCards(sw),
                        const SizedBox(height: 28),
                        _buildActionButtons(sw),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: ''),
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

  Widget _buildAvatar(double sw) {
    final bool isDesktop = sw >= 1024;
    return CustomCircularAvatar(
      imagePath: 'assets/images/solo2.png',
      size: isDesktop ? 50 : 60,
      innerColors: const [AppColors.softRed, AppColors.softRed, AppColors.softRed],
      borderGradient: [AppColors.primaryRed, AppColors.primaryRed.withOpacity(0.3)],
      borderWidth: 2,
      innermostFactor: 0.8,
      imageScale: isDesktop ? 40 : 50,
      imageOffset: const Offset(0, 9),
    );
  }

  Widget _buildMissionCard() {
    return CustomObjectiveContainer(
      title: 'navigator_mission'.tr,
      description: 'navigator_mission_desc'.tr,
      titleColor: AppColors.black,
      icon: Icons.explore,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text, double sw) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: _fs(sw, 18, tablet: 17, desktop: 16),
          ),
        ),
      ),
    );
  }

  // ── ORGANIZATION CARDS ─────────────────────────────────────────────────────

  Widget _buildOrganizationCards(double sw) {
    if (_isLoading) return _buildOrganizationCardsLoader(sw);

    final bool isDesktop = sw >= 1024;

    final cards = [
      _buildOrganizationCard(
        sw: sw,
        level: 1,
        orgTitle: 'organization_a'.tr,
        subTitle: 'startup_phase_level1'.tr,
        strategyText: 'strategy_cards'.tr,
        challengeText: 'Object_Results'.tr,
        bottomTitle: 'growth_scale_obj'.tr,
        isUnlocked: _campaignStatus['level1Unlocked'] as bool,
        isCompleted: _campaignStatus['level1Completed'] as bool,
        isLoading: _isStartingLevel && _currentStartingLevel == 1,
      ),
      _buildOrganizationCard(
        sw: sw,
        level: 2,
        orgTitle: 'organization_b'.tr,
        subTitle: 'startup_phase_level2'.tr,
        strategyText: 'initiatives'.tr,
        challengeText: 'contextual_chal'.tr,
        bottomTitle: (_campaignStatus['level2Unlocked'] as bool)
            ? 'ready_to_start'.tr
            : 'locked'.tr,
        isUnlocked: _campaignStatus['level2Unlocked'] as bool,
        isCompleted: _campaignStatus['level2Completed'] as bool,
        isLoading: _isStartingLevel && _currentStartingLevel == 2,
      ),
      _buildOrganizationCard(
        sw: sw,
        level: 3,
        orgTitle: 'organization_c'.tr,
        subTitle: 'description3'.tr,
        strategyText: 'redthread'.tr,
        challengeText: '',
        bottomTitle: (_campaignStatus['level3Unlocked'] as bool)
            ? 'final_challenge'.tr
            : 'locked'.tr,
        isUnlocked: _campaignStatus['level3Unlocked'] as bool,
        isCompleted: _campaignStatus['level3Completed'] as bool,
        isLoading: _isStartingLevel && _currentStartingLevel == 3,
      ),
    ];

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
          const SizedBox(width: 12),
          Expanded(child: cards[2]),
        ],
      );
    }

    return Column(children: cards);
  }

  Widget _buildOrganizationCard({
    required double sw,
    required int level,
    required String orgTitle,
    required String subTitle,
    required String strategyText,
    required String challengeText,
    required String bottomTitle,
    required bool isUnlocked,
    required bool isCompleted,
    required bool isLoading,
  }) {
    final bool isDesktop = sw >= 1024;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : 12.w,
        vertical: isDesktop ? 4 : 8.h,
      ),
      child: Stack(
        children: [
          CustomIndustryCard(
            orgTitle: orgTitle,
            subTitle: subTitle,
            strategyText: strategyText,
            challengeText: challengeText,
            bottomTitle: isCompleted
                ? '✅ ${'completed'.tr}'
                : isLoading
                ? '⏳ ${'loading'.tr}'
                : bottomTitle,
            onStart: (isUnlocked && !isLoading)
                ? () => _startOrganization(level)
                : () {
              if (!isUnlocked && !isLoading) {
                Get.snackbar(
                  'Locked'.tr,
                  'Complete previous organization first'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            imagePath: 'assets/images/role_icon.png',
            isUnlocked: isUnlocked,
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 12.r),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(isDesktop ? 14 : 16.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: isDesktop ? 20 : 20.w,
                      height: isDesktop ? 20 : 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── ACTION BUTTONS ─────────────────────────────────────────────────────────

  Widget _buildActionButtons(double sw) {
    final bool isDesktop = sw >= 1024;
    final double hPad = isDesktop ? 0 : 16.w;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: CustomButton(
            text: 'Start Certification'.tr,
            backgroundColor: AppColors.primaryBlue,
            icon: Icons.school,
            onPressed: () => Get.to(NavigatorCertificationStartScreen()),
          ),
        ),
        SizedBox(height: isDesktop ? 12 : 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: CustomButton(
            text: 'campaign_guide'.tr,
            backgroundColor: AppColors.primaryBlue,
            icon: Icons.info,
            onPressed: () => debugPrint('📚 Campaign guide pressed'),
          ),
        ),
        SizedBox(height: isDesktop ? 12 : 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: CustomButton(
            text: 'refresh_status'.tr,
            backgroundColor: AppColors.primaryGreen,
            icon: Icons.refresh,
            onPressed: _isLoading ? () {} : _loadCampaignStatus,
          ),
        ),
      ],
    );
  }

  // ── LOADERS ────────────────────────────────────────────────────────────────

  Widget _buildProgressBarLoader(double sw) {
    final bool isDesktop = sw >= 1024;
    return Container(
      height: isDesktop ? 50 : 60.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 30.r),
      ),
      child: Center(
        child: SizedBox(
          width: isDesktop ? 20 : 20.w,
          height: isDesktop ? 20 : 20.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryRed,
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationCardsLoader(double sw) {
    final bool isDesktop = sw >= 1024;
    final loaders = [1, 2, 3].map((_) => _buildOrganizationCardLoader(sw)).toList();

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: loaders[0])),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: loaders[1])),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: loaders[2])),
        ],
      );
    }
    return Column(children: loaders);
  }

  Widget _buildOrganizationCardLoader(double sw) {
    final bool isDesktop = sw >= 1024;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : 12.w,
        vertical: isDesktop ? 4 : 8.h,
      ),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 14 : 16.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(isDesktop ? 10 : 12.r),
        ),
        child: Row(
          children: [
            Container(
              width: isDesktop ? 36 : 40.w,
              height: isDesktop ? 36 : 40.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(isDesktop ? 7 : 8.r),
              ),
              child: Center(
                child: SizedBox(
                  width: isDesktop ? 14 : 16.w,
                  height: isDesktop ? 14 : 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 10 : 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: isDesktop ? 110 : 120.w, height: isDesktop ? 14 : 16.h, color: Colors.grey[300]),
                  SizedBox(height: isDesktop ? 7 : 8.h),
                  Container(width: isDesktop ? 72 : 80.w, height: isDesktop ? 10 : 12.h, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── NAVIGATION LOGIC (matches mobile exactly) ──────────────────────────────

  void _startOrganization(int level) async {
    if (_isStartingLevel) return; // prevent double-tap

    setState(() {
      _isStartingLevel = true;
      _currentStartingLevel = level;
    });

    debugPrint('🎯 Starting Organization Level $level');

    try {
      // ✅ Ensure campaign mode is set (web-side fix, mirrors mobile intent)
      final savedMode = await SharedPrefs.getGameMode();
      debugPrint('🎮 _startOrganization - Current saved mode: $savedMode');
      if (savedMode != 'campaign') {
        debugPrint('⚠️ Fixing game mode to campaign');
        await SharedPrefs.saveGameMode('campaign');
        final gameModeController = Get.put(GameModeController());
        gameModeController.selectedMode.value = 'campaign';
      }

      // ✅ Verify level is unlocked
      final status = await CampaignProgressService.getCampaignStatus();
      final isLevelUnlocked = status['level${level}Unlocked'] as bool;
      if (!isLevelUnlocked) {
        Get.snackbar(
          'Locked'.tr,
          'Complete Level ${level - 1} first to unlock Level $level'.tr,
        );
        return;
      }

      // ✅ Verify role selection
      final selectedRoleIndex = SharedPrefs.getSelectedRoleIndex();
      if (selectedRoleIndex == -1) {
        Get.snackbar('Error'.tr, 'No role selected'.tr);
        return;
      }

      final roleData = controller.roles[selectedRoleIndex];
      final language = Get.locale?.languageCode ?? 'en';

      debugPrint('🚀 Starting Level $level with role: ${roleData['role']}');

      // ✅ Save current level before navigating
      await SharedPrefs.saveString('current_campaign_level', level.toString());
      debugPrint('💾 Saved current campaign level: $level');

      // ✅ Navigate — identical logic to mobile
      switch (level) {
        case 1:
          final response = await controller.postRoleAndLanguage(
            roleData['role'].toString(),
            language,
          );
          if (response != null) {
            final description =
                response['description'] ?? response['name'] ?? 'No description available';
            await SharedPrefs.saveMissionDescription(description);
            Get.toNamed(AppRoutes.missionScreen);
          }
          break;

        case 2:
          final savedKeyResults = await _getKeyResultsFromSharedPreferences();
          if (savedKeyResults.isNotEmpty) {
            debugPrint(
                '🎯 Navigating to SuggestionInitiativesScreen with ${savedKeyResults.length} saved key results');
            Get.toNamed(
              AppRoutes.suggestionInitiativeScreen,
              arguments: {
                'selectedKeyResults': savedKeyResults, // List<KeyResult>
                'isCampaignMode': true,
              },
            );
          } else {
            // ✅ Mirrors mobile fallback — navigate without key results
            debugPrint('⚠️ No saved key results found, navigating without key results');
            Get.toNamed(
              AppRoutes.suggestionInitiativeScreen,
              arguments: {'isCampaignMode': true},
            );
          }
          break;

        case 3:
          Get.to(NavigatorCertificationStartScreen());
          break;

        default:
          Get.snackbar('Error'.tr, 'Invalid level: $level'.tr);
          break;
      }
    } catch (e) {
      debugPrint('❌ Error starting level $level: $e');
      Get.snackbar('Error'.tr, 'Failed to start level: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isStartingLevel = false;
          _currentStartingLevel = null;
        });
      }
    }
  }

  // ✅ Mirrors mobile — called after completing a level from within the flow
  Future<void> _navigateCampaignMode(String source) async {
    debugPrint('🏆 Campaign Mode Navigation - Source: $source');

    if (source == 'contextual_challenge' || source == 'challenge_adjustment') {
      debugPrint('➡️ Campaign Mode: Completing current level and navigating...');
      final currentLevel = await _getCurrentCampaignLevel();
      debugPrint('🎯 Current campaign level: $currentLevel');

      if (currentLevel > 0 && currentLevel <= 3) {
        await CampaignProgressService.completeLevel(currentLevel);
        debugPrint('✅ Level $currentLevel marked as completed');
      }

      debugPrint('➡️ Returning to Campaign Mode Screen');
      Get.offAllNamed(AppRoutes.campaignModeScreen);
    } else {
      debugPrint('➡️ Campaign Mode: Default navigation to Campaign Mode Screen');
      Get.offAllNamed(AppRoutes.campaignModeScreen);
    }
  }

  // ✅ Mirrors mobile
  void _markLevelComplete() async {
    try {
      final savedMode = await SharedPrefs.getGameMode();
      if (savedMode == 'campaign') {
        final currentLevelStr =
            await SharedPrefs.getString('current_campaign_level') ?? '1';
        final currentLevel = int.tryParse(currentLevelStr) ?? 1;
        await CampaignProgressService.completeLevel(currentLevel);
        debugPrint('✅ Campaign Level $currentLevel marked as completed!');
        Get.snackbar(
          'Level Completed!'.tr,
          'Organization ${currentLevel == 1 ? 'A' : currentLevel == 2 ? 'B' : 'C'} completed!'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error marking level complete: $e');
    }
  }

  Future<int> _getCurrentCampaignLevel() async {
    try {
      final levelStr = await SharedPrefs.getString('current_campaign_level');
      return int.tryParse(levelStr ?? '1') ?? 1;
    } catch (e) {
      debugPrint('❌ Error getting current campaign level: $e');
      return 1;
    }
  }

  Future<List<KeyResult>> _getKeyResultsFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keyResultsJson = prefs.getString('selected_key_results');
      if (keyResultsJson != null) {
        final List<dynamic> jsonList = json.decode(keyResultsJson);
        debugPrint('📦 Retrieved ${jsonList.length} key results from SharedPreferences');
        return jsonList
            .map((item) => KeyResult(
          id: item['id'] ?? 0,
          title: item['title']?.toString(),
          description: item['description']?.toString(),
        ))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ Error reading key results from SharedPreferences: $e');
    }
    return [];
  }
}






// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../controllers/game_mode_controller.dart';
// import '../../../controllers/key_results_controller.dart';
// import '../../../controllers/role_selection_controller.dart';
// import '../../../core/app_colors.dart';
// import '../../../generated/models/responses/key_results/key_results_response.dart'
//     hide Text;
// import '../../../services/shared_preference.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/Website/desktop_appbar.dart';
// import '../../widgets/campaign_mode_widgets/custom_industry_card.dart';
// import '../../widgets/campaign_mode_widgets/custom_progress_bar.dart';
// import '../../widgets/campaign_progress_service.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_circular_avatar.dart';
// import '../../widgets/custom_home_navbar.dart';
// import '../../widgets/custom_objective_container.dart';
// import '../../widgets/custom_svg.dart';
// import '../../widgets/screens_unique_parts/custom_background.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
// import 'navigator_certification_screen_start.dart';
//
// class CampaignModeScreen extends StatefulWidget {
//   const CampaignModeScreen({super.key});
//
//   @override
//   State<CampaignModeScreen> createState() => _CampaignModeScreenState();
// }
//
// class _CampaignModeScreenState extends State<CampaignModeScreen>
//     with WidgetsBindingObserver {
//   final RoleSelectionController controller = Get.put(RoleSelectionController());
//
//   Map<String, dynamic> _campaignStatus = {
//     'currentLevel': 1,
//     'level1Unlocked': true,
//     'level1Completed': false,
//     'level2Unlocked': false,
//     'level2Completed': false,
//     'level3Unlocked': false,
//     'level3Completed': false,
//   };
//   bool _isLoading = true;
//   bool _isStartingLevel = false;
//   int? _currentStartingLevel;
//
//   // ── Adaptive font helper ───────────────────────────────────────────────────
//   static double _fs(double sw, double mobile,
//       {double? tablet, double? desktop}) {
//     if (sw >= 1024) return desktop ?? tablet ?? mobile - 2;
//     if (sw >= 768) return tablet ?? mobile - 1;
//     return mobile.sp;
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     // Read mode from arguments first
//     _readModeFromArguments();
//
//     // Verify mode is saved before loading status
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final mode = await SharedPrefs.getGameMode();
//       print('🔍 CampaignModeScreen - Verified saved mode: $mode');
//       if (mode != 'campaign') {
//         print('⚠️ Fixing mode to campaign');
//         await SharedPrefs.saveGameMode('campaign');
//       }
//       _loadCampaignStatus();
//     });
//   }
//   void _readModeFromArguments() {
//     final args = Get.arguments as Map<String, dynamic>?;
//     if (args != null && args['selectedMode'] != null) {
//       final mode = args['selectedMode'] as String;
//       print('📥 CampaignModeScreen - mode from args: $mode');
//
//       // IMPORTANT: Save to SharedPrefs immediately!
//       SharedPrefs.saveGameMode(mode);
//
//       // Also update the GameModeController if needed
//       final gameModeController = Get.put(GameModeController());
//       gameModeController.selectedMode.value = mode;
//     } else {
//       // Fallback to SharedPrefs
//       final savedMode = SharedPrefs.getGameMode();
//       print('📥 CampaignModeScreen - mode from SharedPrefs: $savedMode');
//
//       // If still null, set a default
//       if (savedMode == null) {
//         SharedPrefs.saveGameMode('campaign');
//         print('⚠️ Setting default campaign mode');
//       }
//     }
//   }
//
//
//   // void _readModeFromArguments() {
//   //   final args = Get.arguments as Map<String, dynamic>?;
//   //   if (args != null && args['selectedMode'] != null) {
//   //     final mode = args['selectedMode'] as String;
//   //     print('📥 CampaignModeScreen - mode from args: $mode');
//   //
//   //     // Save to SharedPrefs to ensure it's set
//   //     SharedPrefs.saveGameMode(mode);
//   //   } else {
//   //     // Fallback to SharedPrefs
//   //     final savedMode = SharedPrefs.getGameMode();
//   //     print('📥 CampaignModeScreen - mode from SharedPrefs: $savedMode');
//   //   }
//   // }
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   WidgetsBinding.instance.addObserver(this);
//   //   _loadCampaignStatus();
//   // }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) _loadCampaignStatus();
//   }
//
//   @override
//   void didPopNext() => _loadCampaignStatus();
//
//   Future<void> _loadCampaignStatus() async {
//     setState(() => _isLoading = true);
//     try {
//       await CampaignProgressService.initializeCampaign();
//       final status = await CampaignProgressService.getCampaignStatus();
//       setState(() {
//         _campaignStatus = status;
//         _isLoading = false;
//       });
//       _showUnlockMessages(status);
//     } catch (e) {
//       debugPrint('❌ Error loading campaign status: $e');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _showUnlockMessages(Map<String, dynamic> status) {
//     // snackbars intentionally commented out — preserved from original
//   }
//
//   Future<void> _onRefresh() async => _loadCampaignStatus();
//
//   // ── BUILD ──────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final bool isMobile = screenWidth < 768;
//
//     return isMobile
//         ? _buildMobileLayout(context, screenWidth)
//         : _buildDesktopLayout(context, screenWidth);
//   }
//
//   // ── MOBILE ─────────────────────────────────────────────────────────────────
//   Widget _buildMobileLayout(BuildContext context, double screenWidth) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: CustomBackground(
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: RefreshIndicator(
//                 onRefresh: _onRefresh,
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: EdgeInsets.only(bottom: 15.h),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(height: 10.h),
//                       CustomHeader(
//                         title: 'camp'.tr,
//                         highlightedText: 'mode'.tr,
//                         onBackTap: () => Get.back(),
//                         showDashboardIcon: false,
//                       ),
//                       SizedBox(height: 12.h),
//                       _buildAvatar(screenWidth),
//                       SizedBox(height: 8.h),
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: _buildMissionCard(),
//                       ),
//                       _buildSectionTitle(
//                           context, 'campaign_progress'.tr, screenWidth),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: _isLoading
//                             ? _buildProgressBarLoader(screenWidth)
//                             : CustomProgressBar(
//                           totalSteps: 3,
//                           currentStep: _campaignStatus['currentLevel']
//                           as int,
//                         ),
//                       ),
//                       SizedBox(height: 2.h),
//                       _buildSectionTitle(
//                           context, 'organizations'.tr, screenWidth),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'organizations_desc'.tr,
//                           textAlign: TextAlign.center,
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: AppColors.black,
//                             fontSize: _fs(screenWidth, 13),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 8.h),
//                       _buildOrganizationCards(screenWidth),
//                       SizedBox(height: 20.h),
//                       _buildActionButtons(screenWidth),
//                       SizedBox(height: 20.h),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               right: screenWidth * -0.07,
//               top: MediaQuery.of(context).size.height * 0.4,
//               child: const CustomHomeNavBar(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── DESKTOP ────────────────────────────────────────────────────────────────
//   Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double containerWidth =
//     screenWidth > 1200 ? 780.0 : screenWidth * 0.75;
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Stack(
//         children: [
//           // Background image
//           Positioned.fill(
//             child: Opacity(
//               opacity: 0.1,
//               child: Image.asset(
//                 'assets/images/web_background.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//
//           // Desktop AppBar
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: DesktopAppBar(
//               screenWidth: screenWidth,
//               screenHeight: screenHeight,
//               title: 'camp'.tr,
//               subtitle: 'mode'.tr,
//             ),
//           ),
//
//           // Centered white scrollable card
//           Positioned(
//             top: 110,
//             left: 0,
//             right: 0,
//             bottom: 80,
//             child: Center(
//               child: Container(
//                 width: containerWidth,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 20,
//                       spreadRadius: 4,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: RefreshIndicator(
//                   onRefresh: _onRefresh,
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.all(36),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Avatar + mission card side by side on desktop
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             _buildAvatar(screenWidth),
//                             const SizedBox(width: 24),
//                             Expanded(child: _buildMissionCard()),
//                           ],
//                         ),
//
//                         const SizedBox(height: 28),
//
//                         // Progress
//                         _buildSectionTitle(
//                             context, 'campaign_progress'.tr, screenWidth),
//                         const SizedBox(height: 16),
//                         _isLoading
//                             ? _buildProgressBarLoader(screenWidth)
//                             : CustomProgressBar(
//                           totalSteps: 3,
//                           currentStep:
//                           _campaignStatus['currentLevel'] as int,
//                         ),
//
//                         const SizedBox(height: 28),
//
//                         // Organizations
//                         _buildSectionTitle(
//                             context, 'organizations'.tr, screenWidth),
//                         const SizedBox(height: 8),
//                         Text(
//                           'organizations_desc'.tr,
//                           textAlign: TextAlign.center,
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: AppColors.black,
//                             fontSize: _fs(screenWidth, 13,
//                                 tablet: 13, desktop: 13),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildOrganizationCards(screenWidth),
//
//                         const SizedBox(height: 28),
//                         _buildActionButtons(screenWidth),
//                         const SizedBox(height: 16),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // Back SVG
//           Positioned(
//             bottom: 20,
//             left: 0,
//             child: GestureDetector(
//               onTap: () => Get.back(),
//               child: CustomSvg(
//                 assetPath: 'assets/images/left.svg',
//                 semanticsLabel: '',
//               ),
//             ),
//           ),
//
//           // Home NavBar
//           Positioned(
//             bottom: 20,
//             left: 0,
//             right: -30,
//             child: Center(child: const CustomHomeNavBar()),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── SHARED WIDGETS ─────────────────────────────────────────────────────────
//
//   Widget _buildAvatar(double screenWidth) {
//     final bool isDesktop = screenWidth >= 1024;
//     return CustomCircularAvatar(
//       imagePath: 'assets/images/solo2.png',
//       size: isDesktop ? 50 : 60,
//       innerColors: const [
//         AppColors.softRed,
//         AppColors.softRed,
//         AppColors.softRed,
//       ],
//       borderGradient: [
//         AppColors.primaryRed,
//         AppColors.primaryRed.withOpacity(0.3),
//       ],
//       borderWidth: 2,
//       innermostFactor: 0.8,
//       imageScale: isDesktop ? 40 : 50,
//       imageOffset: const Offset(0, 9),
//     );
//   }
//
//   Widget _buildMissionCard() {
//     return CustomObjectiveContainer(
//       title: 'navigator_mission'.tr,
//       description: 'navigator_mission_desc'.tr,
//       titleColor: AppColors.black,
//       icon: Icons.explore,
//     );
//   }
//
//   Widget _buildSectionTitle(
//       BuildContext context, String text, double screenWidth) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: Center(
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//             color: AppColors.primaryRed,
//             fontWeight: FontWeight.bold,
//             // ✅ adaptive — no .sp on desktop
//             fontSize: _fs(screenWidth, 18, tablet: 17, desktop: 16),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrganizationCards(double screenWidth) {
//     if (_isLoading) return _buildOrganizationCardsLoader(screenWidth);
//
//     final bool isDesktop = screenWidth >= 1024;
//
//     // On desktop show all 3 cards side-by-side
//     if (isDesktop) {
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: _buildOrganizationCard(
//               screenWidth: screenWidth,
//               level: 1,
//               orgTitle: 'organization_a'.tr,
//               subTitle: 'startup_phase_level1'.tr,
//               strategyText: 'strategy_cards'.tr,
//               challengeText: 'Object_Results'.tr,
//               bottomTitle: 'growth_scale_obj'.tr,
//               isUnlocked: _campaignStatus['level1Unlocked'] as bool,
//               isCompleted: _campaignStatus['level1Completed'] as bool,
//               isLoading: _isStartingLevel && _currentStartingLevel == 1,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildOrganizationCard(
//               screenWidth: screenWidth,
//               level: 2,
//               orgTitle: 'organization_b'.tr,
//               subTitle: 'startup_phase_level2'.tr,
//               strategyText: 'initiatives'.tr,
//               challengeText: 'contextual_chal'.tr,
//               bottomTitle: (_campaignStatus['level2Unlocked'] as bool)
//                   ? 'ready_to_start'.tr
//                   : 'locked'.tr,
//               isUnlocked: _campaignStatus['level2Unlocked'] as bool,
//               isCompleted: _campaignStatus['level2Completed'] as bool,
//               isLoading: _isStartingLevel && _currentStartingLevel == 2,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildOrganizationCard(
//               screenWidth: screenWidth,
//               level: 3,
//               orgTitle: 'organization_c'.tr,
//               subTitle: 'description3'.tr,
//               strategyText: 'redthread'.tr,
//               challengeText: '',
//               bottomTitle: (_campaignStatus['level3Unlocked'] as bool)
//                   ? 'final_challenge'.tr
//                   : 'locked'.tr,
//               isUnlocked: _campaignStatus['level3Unlocked'] as bool,
//               isCompleted: _campaignStatus['level3Completed'] as bool,
//               isLoading: _isStartingLevel && _currentStartingLevel == 3,
//             ),
//           ),
//         ],
//       );
//     }
//
//     // Mobile/tablet — stacked
//     return Column(
//       children: [
//         _buildOrganizationCard(
//           screenWidth: screenWidth,
//           level: 1,
//           orgTitle: 'organization_a'.tr,
//           subTitle: 'startup_phase_level1'.tr,
//           strategyText: 'strategy_cards'.tr,
//           challengeText: 'Object_Results'.tr,
//           bottomTitle: 'growth_scale_obj'.tr,
//           isUnlocked: _campaignStatus['level1Unlocked'] as bool,
//           isCompleted: _campaignStatus['level1Completed'] as bool,
//           isLoading: _isStartingLevel && _currentStartingLevel == 1,
//         ),
//         _buildOrganizationCard(
//           screenWidth: screenWidth,
//           level: 2,
//           orgTitle: 'organization_b'.tr,
//           subTitle: 'startup_phase_level2'.tr,
//           strategyText: 'initiatives'.tr,
//           challengeText: 'contextual_chal'.tr,
//           bottomTitle: (_campaignStatus['level2Unlocked'] as bool)
//               ? 'ready_to_start'.tr
//               : 'locked'.tr,
//           isUnlocked: _campaignStatus['level2Unlocked'] as bool,
//           isCompleted: _campaignStatus['level2Completed'] as bool,
//           isLoading: _isStartingLevel && _currentStartingLevel == 2,
//         ),
//         _buildOrganizationCard(
//           screenWidth: screenWidth,
//           level: 3,
//           orgTitle: 'organization_c'.tr,
//           subTitle: 'description3'.tr,
//           strategyText: 'redthread'.tr,
//           challengeText: '',
//           bottomTitle: (_campaignStatus['level3Unlocked'] as bool)
//               ? 'final_challenge'.tr
//               : 'locked'.tr,
//           isUnlocked: _campaignStatus['level3Unlocked'] as bool,
//           isCompleted: _campaignStatus['level3Completed'] as bool,
//           isLoading: _isStartingLevel && _currentStartingLevel == 3,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOrganizationCard({
//     required double screenWidth,
//     required int level,
//     required String orgTitle,
//     required String subTitle,
//     required String strategyText,
//     required String challengeText,
//     required String bottomTitle,
//     required bool isUnlocked,
//     required bool isCompleted,
//     required bool isLoading,
//   }) {
//     final bool isDesktop = screenWidth >= 1024;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: isDesktop ? 0 : 12.w,
//         vertical: isDesktop ? 4 : 8.h,
//       ),
//       child: Stack(
//         children: [
//           CustomIndustryCard(
//             orgTitle: orgTitle,
//             subTitle: subTitle,
//             strategyText: strategyText,
//             challengeText: challengeText,
//             bottomTitle: isCompleted
//                 ? '✅ ${'completed'.tr}'
//                 : isLoading
//                 ? '⏳ ${'loading'.tr}'
//                 : bottomTitle,
//             onStart: (isUnlocked && !isLoading)
//                 ? () => _startOrganization(level)
//                 : () {
//               if (!isUnlocked && !isLoading) {
//                 Get.snackbar(
//                   'Locked'.tr,
//                   'Complete previous organization first'.tr,
//                   snackPosition: SnackPosition.BOTTOM,
//                 );
//               }
//             },
//             imagePath: 'assets/images/role_icon.png',
//             isUnlocked: isUnlocked,
//           ),
//
//           // Loading overlay
//           if (isLoading)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(
//                       isDesktop ? 12 : 12.r),
//                 ),
//                 child: Center(
//                   child: Container(
//                     padding: EdgeInsets.all(isDesktop ? 14 : 16.w),
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: SizedBox(
//                       width: isDesktop ? 20 : 20.w,
//                       height: isDesktop ? 20 : 20.w,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppColors.primaryRed,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons(double screenWidth) {
//     final bool isDesktop = screenWidth >= 1024;
//     final double hPad = isDesktop ? 0 : 16.w;
//
//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: hPad),
//           child: CustomButton(
//             text: 'Start Certification'.tr,
//             backgroundColor: AppColors.primaryBlue,
//             icon: Icons.school,
//             onPressed: () => Get.to(NavigatorCertificationStartScreen()),
//           ),
//         ),
//         SizedBox(height: isDesktop ? 12 : 20.h),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: hPad),
//           child: CustomButton(
//             text: 'campaign_guide'.tr,
//             backgroundColor: AppColors.primaryBlue,
//             icon: Icons.info,
//             onPressed: () => debugPrint('📚 Campaign guide pressed'),
//           ),
//         ),
//         SizedBox(height: isDesktop ? 12 : 20.h),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: hPad),
//           child: CustomButton(
//             text: 'refresh_status'.tr,
//             backgroundColor: AppColors.primaryGreen,
//             icon: Icons.refresh,
//             onPressed: _isLoading ? () {} : _loadCampaignStatus,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── LOADERS ────────────────────────────────────────────────────────────────
//   Widget _buildProgressBarLoader(double screenWidth) {
//     final bool isDesktop = screenWidth >= 1024;
//     return Container(
//       height: isDesktop ? 50 : 60.h,
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(isDesktop ? 8 : 30.r),
//       ),
//       child: Center(
//         child: SizedBox(
//           width: isDesktop ? 20 : 20.w,
//           height: isDesktop ? 20 : 20.w,
//           child: const CircularProgressIndicator(
//             strokeWidth: 2,
//             color: AppColors.primaryRed,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrganizationCardsLoader(double screenWidth) {
//     final bool isDesktop = screenWidth >= 1024;
//     if (isDesktop) {
//       return Row(
//         children: [1, 2, 3]
//             .map((l) => Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 6),
//             child: _buildOrganizationCardLoader(screenWidth),
//           ),
//         ))
//             .toList(),
//       );
//     }
//     return Column(
//       children: [1, 2, 3]
//           .map((_) => _buildOrganizationCardLoader(screenWidth))
//           .toList(),
//     );
//   }
//
//   Widget _buildOrganizationCardLoader(double screenWidth) {
//     final bool isDesktop = screenWidth >= 1024;
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: isDesktop ? 0 : 12.w,
//         vertical: isDesktop ? 4 : 8.h,
//       ),
//       child: Container(
//         padding: EdgeInsets.all(isDesktop ? 14 : 16.w),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius:
//           BorderRadius.circular(isDesktop ? 10 : 12.r),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: isDesktop ? 36 : 40.w,
//               height: isDesktop ? 36 : 40.w,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius:
//                 BorderRadius.circular(isDesktop ? 7 : 8.r),
//               ),
//               child: Center(
//                 child: SizedBox(
//                   width: isDesktop ? 14 : 16.w,
//                   height: isDesktop ? 14 : 16.w,
//                   child: const CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: AppColors.primaryRed,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: isDesktop ? 10 : 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: isDesktop ? 110 : 120.w,
//                     height: isDesktop ? 14 : 16.h,
//                     color: Colors.grey[300],
//                   ),
//                   SizedBox(height: isDesktop ? 7 : 8.h),
//                   Container(
//                     width: isDesktop ? 72 : 80.w,
//                     height: isDesktop ? 10 : 12.h,
//                     color: Colors.grey[300],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _startOrganization(int level) async {
//     if (_isStartingLevel) return;
//
//     setState(() {
//       _isStartingLevel = true;
//       _currentStartingLevel = level;
//     });
//
//     try {
//       // First, ensure mode is set to campaign
//       final savedMode = await SharedPrefs.getGameMode();
//       print('🎮 _startOrganization - Current saved mode: $savedMode');
//
//       // If mode is null or not campaign, fix it
//       if (savedMode != 'campaign') {
//         print('⚠️ Fixing game mode to campaign');
//         await SharedPrefs.saveGameMode('campaign');
//
//         // Also update controller
//         final gameModeController = Get.put(GameModeController());
//         gameModeController.selectedMode.value = 'campaign';
//       }
//
//       // Now proceed with campaign logic
//       final status = await CampaignProgressService.getCampaignStatus();
//       final isLevelUnlocked = status['level${level}Unlocked'] as bool;
//
//       if (!isLevelUnlocked) {
//         Get.snackbar(
//           'Locked'.tr,
//           'Complete Level ${level - 1} first to unlock Level $level'.tr,
//         );
//         return;
//       }
//
//       final selectedRoleIndex = SharedPrefs.getSelectedRoleIndex();
//       if (selectedRoleIndex == -1) {
//         Get.snackbar('Error'.tr, 'No role selected'.tr);
//         return;
//       }
//
//       final roleData = controller.roles[selectedRoleIndex];
//       final language = Get.locale?.languageCode ?? 'en';
//       await SharedPrefs.saveString('current_campaign_level', level.toString());
//
//       switch (level) {
//         case 1:
//           final response = await controller.postRoleAndLanguage(
//               roleData['role'].toString(), language);
//           if (response != null) {
//             final description = response['description'] ?? response['name'] ?? '';
//             await SharedPrefs.saveMissionDescription(description);
//             Get.toNamed(AppRoutes.missionScreen);
//           }
//           break;
//         case 2:
//           final savedKeyResults = await _getKeyResultsFromSharedPreferences();
//           Get.toNamed(
//             AppRoutes.suggestionInitiativeScreen,
//             arguments: {
//               'selectedKeyResults': savedKeyResults,
//               'isCampaignMode': true,
//             },
//           );
//           break;
//         case 3:
//           Get.to(NavigatorCertificationStartScreen());
//           break;
//         default:
//           Get.snackbar('Error'.tr, 'Invalid level: $level'.tr);
//       }
//     } catch (e) {
//       debugPrint('❌ Error starting level $level: $e');
//       Get.snackbar('Error'.tr, 'Failed to start level: ${e.toString()}');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isStartingLevel = false;
//           _currentStartingLevel = null;
//         });
//       }
//     }
//   }
//
//   void _markLevelComplete() async {
//     try {
//       final savedMode = await SharedPrefs.getGameMode();
//       if (savedMode == 'campaign') {
//         final currentLevelStr =
//             await SharedPrefs.getString('current_campaign_level') ?? '1';
//         final currentLevel = int.tryParse(currentLevelStr) ?? 1;
//         await CampaignProgressService.completeLevel(currentLevel);
//         Get.snackbar(
//           'Level Completed!'.tr,
//           'Organization ${currentLevel == 1 ? 'A' : currentLevel == 2 ? 'B' : 'C'} completed!'
//               .tr,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Error marking level complete: $e');
//     }
//   }
//
//   Future<int> _getCurrentCampaignLevel() async {
//     try {
//       final levelStr =
//       await SharedPrefs.getString('current_campaign_level');
//       return int.tryParse(levelStr ?? '1') ?? 1;
//     } catch (e) {
//       return 1;
//     }
//   }
//
//   Future<List<KeyResult>> _getKeyResultsFromSharedPreferences() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final keyResultsJson = prefs.getString('selected_key_results');
//       if (keyResultsJson != null) {
//         final List<dynamic> jsonList = json.decode(keyResultsJson);
//         return jsonList
//             .map((item) => KeyResult(
//           id: item['id'] ?? 0,
//           title: item['title']?.toString(),
//           description: item['description']?.toString(),
//         ))
//             .toList();
//       }
//     } catch (e) {
//       debugPrint('❌ Error reading key results: $e');
//     }
//     return [];
//   }
// }
//
//
