import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:game_app/view_model/key_result_latest_view_model.dart';
import '../../../controllers/journey_controller.dart';
import '../../../controllers/key_objective_controller.dart';
import '../../../controllers/okr_constellation_controller.dart';
import '../../../controllers/strategy_selection_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../generated/models/requests/key_results_latest_model.dart';
import '../../../generated/models/responses/key_results/key_results_response.dart' hide Text;
import '../../../services/shared_preference.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_industry_container.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_okr_constellation.dart';
import '../../widgets/custom_selected_key_result_container.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import '../../widgets/website/desktop_appbar.dart';
import '../feedback_screen.dart';
import '../suggestion_Initiatives/suggestion_initiatives_creen.dart';

class KeyResultsScreen extends StatefulWidget {
  const KeyResultsScreen({super.key});

  @override
  State<KeyResultsScreen> createState() => _KeyResultsScreenState();
}

class _KeyResultsScreenState extends State<KeyResultsScreen> {
  late final KeyResultsLatestViewModel keyResultsViewModel;
  late final OKRConstellationController constellationController;
  late final JourneyController journeyController;
  late final KeyObjectiveController objectiveController;
  late final StrategySelectionController strategyController;
  late final LanguageController languageController;
  final ScrollController _keyResultsScrollController = ScrollController();

  // Track source and initialization
  bool _isInitialized = false;
  bool _hasShownMessage = false;

  // Different sources with different behaviors
  final bool _isRetryFromAnalysis = Get.parameters['isRetry'] == 'true';
  final bool _isModifyFromContextual = Get.parameters['source'] == 'contextual_challenge';
  final bool _isNormalFlow = !Get.parameters.containsKey('isRetry') && !Get.parameters.containsKey('source');

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    try {
      keyResultsViewModel = Get.find<KeyResultsLatestViewModel>();
      constellationController = Get.find<OKRConstellationController>();
      journeyController = Get.find<JourneyController>();
      objectiveController = Get.find<KeyObjectiveController>();
      strategyController = Get.find<StrategySelectionController>();
      languageController = Get.find<LanguageController>();
    } catch (e) {
      print('❌ Error finding controllers: $e');
      // Handle missing controllers gracefully
    }

    print('🎯 Key Results Screen Source:');
    print('   - Retry from Analysis: $_isRetryFromAnalysis');
    print('   - Modify from Contextual: $_isModifyFromContextual');
    print('   - Normal Flow: $_isNormalFlow');

    // Use delayed initialization to avoid build phase conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
      journeyController.completeStep(0);
      journeyController.setStep(1, true);
    });
  }

  void _initializeScreen() {
    if (_isInitialized) return;

    _isInitialized = true;

    // Handle different scenarios with appropriate messages
    if (!_hasShownMessage) {
      _hasShownMessage = true;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isRetryFromAnalysis) {
          Get.snackbar(
            'Try Again',
            'Please select different key results to improve your initiatives',
            backgroundColor: AppColors.primaryRed,
            colorText: Colors.white,
          );
        } else if (_isModifyFromContextual) {
          Get.snackbar(
            'Modify Key Results',
            'Select new key results to adapt to the market challenge',
            backgroundColor: AppColors.primaryBlue,
            colorText: Colors.white,
          );
        }
      });
    }

    // Clear previous selection for retry/modify scenarios
    if (_isRetryFromAnalysis || _isModifyFromContextual) {
      keyResultsViewModel.clearSelection();
    }

    // For normal flow, ALWAYS initialize key results
    if (_isNormalFlow) {
      print('🚀 Normal Flow - Generating new key results...');
      _initializeKeyResults();
    } else {
      // For modify/retry flows, use existing key results without re-fetching
      print('🔄 Using existing ${keyResultsViewModel.allKeyResults.length} key results');
    }
  }

  // Proper initialization for key results generation
  void _initializeKeyResults() async {
    print('🚀 Initializing Key Results for Normal Flow...');

    try {
      // Get all required data dynamically
      final selectedRole = await _getSelectedRole();
      final selectedStrategy = await _getSelectedStrategy();
      final selectedObjectives = await _getSelectedObjectives();
      final selectedLanguage = await _getSelectedLanguage();

      print('📋 Data Summary for API:');
      print('   - Strategy: $selectedStrategy');
      print('   - Objectives: $selectedObjectives');
      print('   - Role: $selectedRole');
      print('   - Language: $selectedLanguage');

      if (selectedObjectives.isEmpty || selectedStrategy == null || selectedRole == null) {
        print('❌ Missing required data for API call');
        Get.snackbar(
          'Error',
          'Missing required data. Please go back and try again.',
          backgroundColor: AppColors.primaryRed,
          colorText: Colors.white,
        );
        return;
      }

      // Generate key results using the new viewmodel
      await keyResultsViewModel.generateKeyResults(
        strategy: selectedStrategy,
        objectives: selectedObjectives,
        role: selectedRole,
        language: selectedLanguage,
      );

      print('✅ Key results generation completed');
      print('📊 Total key results generated: ${keyResultsViewModel.allKeyResults.length}');

    } catch (e) {
      print('❌ Error generating key results: $e');
      Get.snackbar(
        'Error',
        'Failed to generate key results. Please try again.',
        backgroundColor: AppColors.primaryRed,
        colorText: Colors.white,
      );
    }
  }

  // Get dynamic objectives from the previous screen
  Future<List<String>> _getSelectedObjectives() async {
    try {
      final List<String> objectives = [];

      // 1. Get the main selected objective from controller
      final selectedObjective = objectiveController.selectedObjective.value;
      if (selectedObjective?.title != null && selectedObjective!.title!.isNotEmpty) {
        print('🎯 Main Selected Objective: ${selectedObjective.title}');
        objectives.add(selectedObjective.title!);
      }

      // 2. Get AI-generated objectives from various sources
      final aiObjectives = await _getAIGeneratedObjectives();

      // 3. Add AI objectives to the list
      for (final objective in aiObjectives) {
        if (objectives.length < 8 && !objectives.contains(objective)) {
          objectives.add(objective);
        }
        if (objectives.length >= 8) break;
      }

      // 4. If we still don't have enough objectives, use fallback
      if (objectives.length < 8) {
        final additionalObjectives = await _getFallbackObjectives();
        for (final objective in additionalObjectives) {
          if (objectives.length < 8 && !objectives.contains(objective)) {
            objectives.add(objective);
          }
          if (objectives.length >= 8) break;
        }
      }

      print('🎯 Final Objectives for API (${objectives.length}): $objectives');
      return objectives;

    } catch (e) {
      print('❌ Error getting objectives: $e');
      return await _getFallbackObjectives();
    }
  }

  // Get AI-generated objectives from various sources
  Future<List<String>> _getAIGeneratedObjectives() async {
    try {
      final List<String> objectives = [];

      final savedStrategy = await SharedPrefs.getSelectedStrategy();
      if (savedStrategy != null && savedStrategy['title'] != null) {
        final strategyTitle = savedStrategy['title'].toString();
        objectives.add('Implement $strategyTitle Strategy');
      }

      if (objectiveController.selectedObjective.value?.title != null) {
        final mainObjective = objectiveController.selectedObjective.value!.title!;
        objectives.addAll([
          'Optimize $mainObjective Implementation',
          'Enhance $mainObjective Efficiency',
          'Scale $mainObjective Across Organization',
        ]);
      }

      final industryData = await SharedPrefs.getSelectedIndustry();
      if (industryData != null && industryData['titleKey'] != null) {
        final industry = industryData['titleKey'].toString();
        objectives.add('Align $industry Best Practices');
      }

      print('📚 AI Objectives from available data: $objectives');
      return objectives;

    } catch (e) {
      print('❌ Error getting AI objectives: $e');
      return [];
    }
  }

  Future<List<String>> _getFallbackObjectives() async {
    final mainObjective = objectiveController.selectedObjective.value?.title ?? 'HR Technology';

    final List<String> diverseHRObjectives = [
      'Improve Employee Retention in $mainObjective',
      'Enhance Training and Development Programs for $mainObjective',
      'Boost Employee Morale and Engagement through $mainObjective',
      'Develop Leadership Pipeline for $mainObjective',
      'Improve Work-Life Balance Initiatives with $mainObjective',
      'Enhance Diversity and Inclusion in $mainObjective',
      'Strengthen Employer Brand through $mainObjective',
      'Optimize Performance Management System with $mainObjective',
      'Increase Employee Productivity using $mainObjective',
      'Reduce Recruitment Costs with $mainObjective',
      'Improve Onboarding Process through $mainObjective',
      'Enhance Employee Benefits Package with $mainObjective',
    ];

    final shuffledObjectives = List<String>.from(diverseHRObjectives)..shuffle();
    return shuffledObjectives.take(8).toList();
  }

  Future<String?> _getSelectedRole() async {
    try {
      final roleData = await SharedPrefs.getSelectedRole();
      if (roleData != null && roleData['titleKey'] != null) {
        final role = roleData['titleKey'].toString();
        print('👤 Role from SharedPrefs: $role');
        return role;
      }

      final args = Get.arguments as Map<String, dynamic>?;
      final roleFromArgs = args?['selectedRole'] as Map<String, dynamic>?;
      if (roleFromArgs != null && roleFromArgs['titleKey'] != null) {
        final role = roleFromArgs['titleKey'].toString();
        print('👤 Role from arguments: $role');
        return role;
      }

      final userRole = SharedPrefs.getUserRole();
      if (userRole != null) {
        print('👤 Role from userRole: $userRole');
        return userRole;
      }

      print('⚠️ No role found, using default');
      return 'Manager';
    } catch (e) {
      print('❌ Error getting role: $e');
      return 'Manager';
    }
  }

  Future<String?> _getSelectedStrategy() async {
    try {
      final strategy = strategyController.selectedStrategy.value;
      if (strategy?.title != null && strategy!.title!.isNotEmpty) {
        print('🎯 Strategy from controller: ${strategy.title}');
        return strategy.title!;
      }

      final strategyData = await SharedPrefs.getSelectedStrategy();
      if (strategyData != null && strategyData['title'] != null) {
        final strategyTitle = strategyData['title'].toString();
        print('🎯 Strategy from SharedPrefs: $strategyTitle');
        return strategyTitle;
      }

      final certificateStrategy = SharedPrefs.getCertificateSelectedAIStrategy();
      if (certificateStrategy.isNotEmpty && certificateStrategy['title'] != null) {
        final strategyTitle = certificateStrategy['title'].toString();
        print('🎯 Strategy from certificate: $strategyTitle');
        return strategyTitle;
      }

      print('⚠️ No strategy found, using default');
      return 'Default Strategy';
    } catch (e) {
      print('❌ Error getting strategy: $e');
      return 'Default Strategy';
    }
  }

  Future<String> _getSelectedLanguage() async {
    try {
      final language = languageController.selectedLanguage.value;
      // Check if language is a String or an object with a name property
      if (language is String) {
        print('🌐 Language from controller: $language');
        return language;
      } else if (language != null) {
        // Try to get the name property dynamically
        final languageName = (language as dynamic).name?.toString() ?? 'English';
        print('🌐 Language from controller: $languageName');
        return languageName;
      }
      print('🌐 Using default language: English');
      return 'English';
    } catch (e) {
      print('❌ Error getting language: $e');
      return 'English';
    }
  }

  String _getHeaderTitle() {
    if (_isRetryFromAnalysis) return 'try_again_with'.tr;
    if (_isModifyFromContextual) return 'modify'.tr;
    return 'select'.tr;
  }

  String _getHeaderHighlight() => 'key_results'.tr;

  String _getSubtitleText() {
    if (_isRetryFromAnalysis) return 'choose_3_outcomes_retry'.tr;
    if (_isModifyFromContextual) return 'choose_3_outcomes_modify'.tr;
    return 'choose_3_outcomes'.tr;
  }

  String _getButtonText() {
    if (_isModifyFromContextual) return 'save_changes'.tr;
    return 'complete_selection'.tr;
  }

  void _navigateToNextScreen() {
    if (_isModifyFromContextual) {
      Get.back();
      Get.snackbar(
        'Success',
        'Key results updated successfully',
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
      );
    } else {
      final selectedKeyResults = keyResultsViewModel.getSelectedKeyResultsAsKeyResult();

      // Option 1: Using named route with arguments
      Get.toNamed(
        AppRoutes.suggestionInitiativeScreen,
        arguments: {
          'selectedKeyResults': selectedKeyResults,
        },
      );

      // Option 2: If you have FeedbackScreen imported and want to use constructor
      // Get.to(() => FeedbackScreen(
      //   selectedKeyResults: selectedKeyResults,
      // ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isMobile = screenWidth < 768;

        if (isMobile) {
          return _buildMobileLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: _getResponsiveSpacing(screenHeight, 0.03)),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        CustomHeader(
                          title: _getHeaderTitle(),
                          highlightedText: _getHeaderHighlight(),
                          onBackTap: () {
                            if (_isModifyFromContextual) {
                              Get.back();
                            } else {
                              Get.toNamed(AppRoutes.keyObjectiveScreen);
                            }
                          },
                          showDashboardIcon: true,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(screenWidth)),
                          child: Obx(() {
                            final selectedObjective = objectiveController.selectedObjective.value;
                            return CustomObjectiveContainer(
                              icon: Icons.flag,
                              title: _safeTranslate('selected_objective'),
                              subtitle: selectedObjective?.title?.tr ?? 'No objective selected',
                              description: selectedObjective?.description?.tr ?? '',
                            );
                          }),
                        ),
                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
                        _buildTitleSection(screenWidth, screenHeight, isTablet, isDesktop),
                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                        _buildKeyResultsSection(screenWidth, isTablet),
                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
                        const CustomOKRConstellation(),
                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
                        if (!_isModifyFromContextual) ...[
                          Obx(() => CustomJourneyMap(
                            progress: journeyController.progress.value,
                            steps: journeyController.steps,
                            completedSteps: journeyController.completedSteps,
                            onToggle: journeyController.toggleJourneyDetails,
                            showDetails: journeyController.showDetails.value,
                          )),
                          SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
                        ],
                        _buildCompleteButton(screenWidth, isTablet, isDesktop), // sticky button
                        SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: screenWidth * -0.07,
                top: screenHeight * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/web_background.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DesktopAppBar(
              title: _getHeaderTitle(),
              subtitle: _getHeaderHighlight(),
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),
          Center(
            child: Container(
              width: isDesktop ? 600 : screenWidth * 0.7,
              margin: const EdgeInsets.only(top: 120, bottom: 40),
              padding: EdgeInsets.all(isDesktop ? 40 : 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Obx(() {
                      final selectedObjective = objectiveController.selectedObjective.value;
                      return CustomObjectiveContainer(
                        icon: Icons.flag,
                        title: _safeTranslate('selected_objective'),
                        subtitle: selectedObjective?.title?.tr ?? 'No objective selected',
                        description: selectedObjective?.description?.tr ?? '',
                      );
                    }),
                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
                    // const CustomSelectedKeyResultsContainer(),
                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
                    _buildTitleSection(screenWidth, screenHeight, isTablet, isDesktop),
                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                    _buildKeyResultsSection(screenWidth, isTablet),
                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
                    // const CustomOKRConstellation(),
                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
                    if (!_isModifyFromContextual) ...[
                      Obx(() => CustomJourneyMap(
                        progress: journeyController.progress.value,
                        steps: journeyController.steps,
                        completedSteps: journeyController.completedSteps,
                        onToggle: journeyController.toggleJourneyDetails,
                        showDetails: journeyController.showDetails.value,
                      )),
                      SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
                    ],
                    _buildCompleteButton(screenWidth, isTablet, isDesktop),
                    SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: ''),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: -20,
            child: const Center(child: CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ==================== SHARED WIDGETS ====================
  Widget _buildTitleSection(double screenWidth, double screenHeight, bool isTablet, bool isDesktop) => Padding(
      padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(screenWidth)),
      child: Column(
        children: [
          Text(
            _safeTranslate('select_key_results'),
            style: TextStyle(
              fontSize: _getTitleFontSize(screenWidth, isTablet, isDesktop),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
              fontFamily: 'GothamExtraBold',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          Obx(() {
            final isLoading = keyResultsViewModel.loading.value && _isNormalFlow;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: isLoading
                  ? Column(
                children: [
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'please_wait'.tr,
                        style: TextStyle(
                          fontSize: _getSubtitleFontSize(screenWidth, isTablet, isDesktop),
                          color: AppColors.primaryRed,
                          fontFamily: 'Gotham',
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  : Text(
                '${_getSubtitleText()} (${keyResultsViewModel.selectedCount}/${keyResultsViewModel.requiredCount})',
                key: ValueKey<int>(keyResultsViewModel.selectedCount),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _getSubtitleFontSize(screenWidth, isTablet, isDesktop),
                  color: keyResultsViewModel.selectedCount >= keyResultsViewModel.requiredCount
                      ? AppColors.primaryRed
                      : _getSubtitleColor(),
                  fontFamily: 'Gotham',
                  height: 1.4,
                  fontWeight: _getSubtitleFontWeight(),
                ),
              ),
            );
          }),
          if (_isRetryFromAnalysis) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
              ),
              child: Text('retry_attempt'.tr, style: TextStyle(fontSize: 12.sp, color: AppColors.primaryRed, fontWeight: FontWeight.w600)),
            ),
          ] else if (_isModifyFromContextual) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
              ),
              child: Text('adapting_to_challenge'.tr, style: TextStyle(fontSize: 12.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );

  Widget _buildKeyResultsSection(double screenWidth, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getContentPadding(screenWidth, isTablet)),
      child: Obx(() {
        final isLoading = keyResultsViewModel.loading.value && _isNormalFlow;

        if (isLoading) {
          return Container(
            height: 200.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed)),
                  SizedBox(height: 16.h),
                  Text('generating_key_results'.tr, style: TextStyle(fontSize: 6.sp, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }

        if (keyResultsViewModel.allKeyResults.isEmpty) {
          return Column(
            children: [
              SizedBox(height: 50),
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text('No Key Results Available', style: TextStyle(fontSize: 18.sp, color: Colors.grey[600], fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text('Please check your configuration', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
              if (_isNormalFlow) ...[
                SizedBox(height: 16.h),
                ElevatedButton(onPressed: _initializeKeyResults, child: Text('Retry Generation')),
              ],
            ],
          );
        }
        return _buildKeyResultsList(screenWidth, isTablet);
      }),
    );
  }

  Widget _buildKeyResultsList(double screenWidth, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.accentRed.withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8.r, offset: Offset(0, 2.h))],
      ),
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'available_key_results'.tr,
                  style: TextStyle(
                    fontSize: 4.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                    fontFamily: 'GothamBold',
                  ),
                ),
                Obx(() => Text(
                  '${keyResultsViewModel.allKeyResults.length} available'.tr,
                  style: TextStyle(
                    fontSize: 6.sp,
                    color: AppColors.textSecondary,
                  ),
                )
                ),
              ],
            ),
          ),
          _buildKeyResultsGrid(screenWidth, isTablet),
        ],
      ),
    );
  }

  Widget _buildKeyResultsGrid(double screenWidth, bool isTablet) {
    final shuffledKeyResults = List.from(keyResultsViewModel.allKeyResults)..shuffle();
    final visibleHeight = 320.h;

    return SizedBox(
      height: visibleHeight,
      child: Scrollbar(
        controller: _keyResultsScrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _keyResultsScrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: shuffledKeyResults.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.d16.h),
            child: _buildKeyResultItem(shuffledKeyResults[index], index,index),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyResultItem(KeyResultLatest item, int displayIndex,index) {
    final originalIndex = keyResultsViewModel.allKeyResults.indexOf(item);
    final icons = [Icons.star, Icons.rocket, Icons.lightbulb, Icons.flag, Icons.trending_up, Icons.bar_chart, Icons.thumb_up, Icons.work, Icons.public, Icons.check_circle];
    final tagIcons = [Icons.trending_up, Icons.access_time, Icons.bolt, Icons.show_chart, Icons.schedule, Icons.speed, Icons.insights, Icons.analytics, Icons.multiline_chart, Icons.timeline];

    final randomIcon = icons[displayIndex % icons.length];
    final randomTagIcon1 = tagIcons[(displayIndex + 1) % tagIcons.length];
    final randomTagIcon2 = tagIcons[(displayIndex + 2) % tagIcons.length];

    return Obx(() => CustomIndustryContainer(
      title: "K${index + 1}",
      description: _safeTranslate(item.description, fallback: 'Available for the selected one'),
      icon: randomIcon,
      isSelected: keyResultsViewModel.isSelected(originalIndex),
      onTap: () {
        keyResultsViewModel.toggleSelection(originalIndex);
        if (keyResultsViewModel.isSelected(originalIndex)) {
          constellationController.addIcon(randomIcon);
        } else {
          constellationController.removeIcon(randomIcon);
        }

        if (keyResultsViewModel.isSelectionComplete) {
          journeyController.completeStep(2);
        } else {
          journeyController.uncompleteStep(2);
        }
      },
      showTag1: true,
      tag1Icon: randomTagIcon1,
      tag1Text: _safeTranslate(item.tag1 ?? '', fallback: ''),
      showTag2: true,
      tag2Icon: randomTagIcon2,
      tag2Text: _safeTranslate(item.tag2 ?? '', fallback: ''),
    ));
  }

  Widget _buildCompleteButton(double screenWidth, bool isTablet, bool isDesktop) {
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 16.h, // Sticky at bottom
      child: Obx(() {
        final isEnabled = keyResultsViewModel.isSelectionComplete;

        return CustomButton2(
          text: _getButtonText(),
          height: 75,
          onPressed: isEnabled
              ? () async {
            // Complete the step
            journeyController.completeStep(2);

            final selectedKeyResults =
            keyResultsViewModel.getSelectedKeyResultsAsKeyResult();
            print('🎯 Navigating with ${selectedKeyResults.length} key results');

            await _saveKeyResultsForNextScreen(selectedKeyResults);

            // Navigate to FeedbackScreen
            Get.to(FeedbackScreen(selectedKeyResults: selectedKeyResults));
          }
              : null,
        );
      }),
    );
  }

  Future<void> _saveKeyResultsForNextScreen(List<KeyResult> selectedKeyResults) async {
    try {
      // Convert KeyResult objects to Map for JSON serialization
      final keyResultsMaps = selectedKeyResults.map((kr) => {
        'id': kr.id,
        'title': kr.title,
        'description': kr.description,
        // Add any other fields you need
      }).toList();

      final keyResultsJson = jsonEncode(keyResultsMaps);
      await SharedPrefs.saveString('selected_key_results', keyResultsJson);
      print('💾 Saved ${selectedKeyResults.length} key results for next screen');
    } catch (e) {
      print('❌ Error saving key results for next screen: $e');
    }
  }

  @override
  void dispose() {
    _keyResultsScrollController.dispose();
    super.dispose();
  }

  Color _getSubtitleColor() {
    if (_isRetryFromAnalysis) return AppColors.primaryRed;
    if (_isModifyFromContextual) return AppColors.primaryBlue;
    return AppColors.textSecondary;
  }

  FontWeight _getSubtitleFontWeight() {
    if (_isRetryFromAnalysis || _isModifyFromContextual) return FontWeight.w600;
    return FontWeight.normal;
  }

  String _safeTranslate(String? key, {String fallback = ''}) {
    if (key == null) return fallback;
    try {
      return key.tr;
    } catch (e) {
      return fallback;
    }
  }

  double _getResponsiveSpacing(double dimension, double factor) => dimension * factor;

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1200) return screenWidth * 0.06;
    if (screenWidth > 900) return screenWidth * 0.04;
    if (screenWidth > 600) return screenWidth * 0.03;
    return screenWidth * 0.02;
  }

  double _getContentPadding(double screenWidth, bool isTablet) =>
      isTablet ? screenWidth * 0.06 : screenWidth * 0.04;

  double _getButtonPadding(double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return screenWidth * 0.25;
    if (isTablet) return screenWidth * 0.15;
    return screenWidth * 0.1;
  }

  double _getTitleFontSize(double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return 10.sp;
    if (isTablet) return 18.sp;
    return 18.sp;
  }

  double _getSubtitleFontSize(double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) return 6.sp;
    if (isTablet) return 14.sp;
    return 14.sp;
  }
}