import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/views/suggestion_Initiatives/suggestion_initiatives_creen.dart';
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
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_industry_container.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import '../feedback_screen.dart';


// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class KeyResultsScreen extends StatefulWidget {
  const KeyResultsScreen({super.key});

  @override
  State<KeyResultsScreen> createState() => _KeyResultsScreenState();
}

class _KeyResultsScreenState extends State<KeyResultsScreen> {
  final KeyResultsLatestViewModel keyResultsViewModel =
  Get.find<KeyResultsLatestViewModel>();
  final OKRConstellationController constellationController =
  Get.find<OKRConstellationController>();
  final JourneyController journeyController = Get.find<JourneyController>();
  final KeyObjectiveController objectiveController =
  Get.find<KeyObjectiveController>();
  final StrategySelectionController strategyController =
  Get.find<StrategySelectionController>();
  final LanguageController languageController =
  Get.find<LanguageController>();
  final ScrollController _keyResultsScrollController = ScrollController();

  bool _isInitialized   = false;
  bool _hasShownMessage = false;

  final bool _isRetryFromAnalysis =
      Get.parameters['isRetry'] == 'true';
  final bool _isModifyFromContextual =
      Get.parameters['source'] == 'contextual_challenge';
  late final bool _isNormalFlow;

  @override
  void initState() {
    super.initState();
    _isNormalFlow = !_isRetryFromAnalysis && !_isModifyFromContextual;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initializeScreen());
  }

  // ── All original logic — unchanged ────────────────────────────────────────
  void _initializeScreen() {
    if (_isInitialized) return;
    _isInitialized = true;

    if (!_hasShownMessage) {
      _hasShownMessage = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isRetryFromAnalysis) {
          Get.snackbar('Try Again', 'Please select different key results to improve your initiatives',
              backgroundColor: AppColors.primaryRed, colorText: Colors.white);
        } else if (_isModifyFromContextual) {
          Get.snackbar('Modify Key Results', 'Select new key results to adapt to the market challenge',
              backgroundColor: AppColors.primaryBlue, colorText: Colors.white);
        }
      });
    }

    if (_isRetryFromAnalysis || _isModifyFromContextual) {
      keyResultsViewModel.clearSelection();
    }

    if (_isNormalFlow) {
      _initializeKeyResults();
    }
  }

  void _initializeKeyResults() async {
    try {
      final selectedRole     = await _getSelectedRole();
      final selectedStrategy = await _getSelectedStrategy();
      final selectedObjectives = await _getSelectedObjectives();
      final selectedLanguage = await _getSelectedLanguage();

      if (selectedObjectives.isEmpty || selectedStrategy == null || selectedRole == null) {
        Get.snackbar('Error', 'Missing required data. Please go back and try again.',
            backgroundColor: AppColors.primaryRed, colorText: Colors.white);
        return;
      }

      await keyResultsViewModel.generateKeyResults(
        strategy:   selectedStrategy,
        objectives: selectedObjectives,
        role:       selectedRole,
        language:   selectedLanguage,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate key results. Please try again.',
          backgroundColor: AppColors.primaryRed, colorText: Colors.white);
    }
  }

  Future<List<String>> _getSelectedObjectives() async {
    try {
      final objectives = <String>[];
      final selectedObjective = objectiveController.selectedObjective.value;
      if (selectedObjective?.title != null && selectedObjective!.title!.isNotEmpty) {
        objectives.add(selectedObjective.title!);
      }
      final aiObjectives = await _getAIGeneratedObjectives();
      for (final o in aiObjectives) {
        if (objectives.length < 8 && !objectives.contains(o)) objectives.add(o);
        if (objectives.length >= 8) break;
      }
      if (objectives.length < 8) {
        final fallback = await _getFallbackObjectives();
        for (final o in fallback) {
          if (objectives.length < 8 && !objectives.contains(o)) objectives.add(o);
          if (objectives.length >= 8) break;
        }
      }
      return objectives;
    } catch (_) {
      return _getFallbackObjectives();
    }
  }

  Future<List<String>> _getAIGeneratedObjectives() async {
    try {
      final objectives = <String>[];
      final savedStrategy = await SharedPrefs.getSelectedStrategy();
      if (savedStrategy != null && savedStrategy['title'] != null) {
        objectives.add('Implement ${savedStrategy['title']} Strategy');
      }
      if (objectiveController.selectedObjective.value?.title != null) {
        final main = objectiveController.selectedObjective.value!.title!;
        objectives.addAll([
          'Optimize $main Implementation',
          'Enhance $main Efficiency',
          'Scale $main Across Organization',
        ]);
      }
      final industryData = await SharedPrefs.getSelectedIndustry();
      if (industryData != null && industryData['titleKey'] != null) {
        objectives.add('Align ${industryData['titleKey']} Best Practices');
      }
      return objectives;
    } catch (_) { return []; }
  }

  Future<List<String>> _getFallbackObjectives() async {
    final main = objectiveController.selectedObjective.value?.title ?? 'HR Technology';
    final list = [
      'Improve Employee Retention in $main',
      'Enhance Training and Development Programs for $main',
      'Boost Employee Morale and Engagement through $main',
      'Develop Leadership Pipeline for $main',
      'Improve Work-Life Balance Initiatives with $main',
      'Enhance Diversity and Inclusion in $main',
      'Strengthen Employer Brand through $main',
      'Optimize Performance Management System with $main',
    ];
    return (List<String>.from(list)..shuffle()).take(8).toList();
  }

  Future<String?> _getSelectedRole() async {
    try {
      final roleData = await SharedPrefs.getSelectedRole();
      if (roleData != null && roleData['titleKey'] != null) return roleData['titleKey'].toString();
      final args = Get.arguments as Map<String, dynamic>?;
      final roleFromArgs = args?['selectedRole'] as Map<String, dynamic>?;
      if (roleFromArgs != null && roleFromArgs['titleKey'] != null) return roleFromArgs['titleKey'].toString();
      final userRole = SharedPrefs.getUserRole();
      if (userRole != null) return userRole;
      return 'Manager';
    } catch (_) { return 'Manager'; }
  }

  Future<String?> _getSelectedStrategy() async {
    try {
      final strategy = strategyController.selectedStrategy.value;
      if (strategy?.title != null && strategy!.title!.isNotEmpty) return strategy.title!;
      final strategyData = await SharedPrefs.getSelectedStrategy();
      if (strategyData != null && strategyData['title'] != null) return strategyData['title'].toString();
      final certStrategy = SharedPrefs.getCertificateSelectedAIStrategy();
      if (certStrategy.isNotEmpty && certStrategy['title'] != null) return certStrategy['title'].toString();
      return 'Default Strategy';
    } catch (_) { return 'Default Strategy'; }
  }

  Future<String> _getSelectedLanguage() async {
    try { return languageController.selectedLanguage.value.name; } catch (_) { return 'English'; }
  }

  String _getHeaderTitle() {
    if (_isRetryFromAnalysis)    return 'try_again_with'.tr;
    if (_isModifyFromContextual) return 'modify'.tr;
    return 'select'.tr;
  }

  String _getHeaderHighlight()   => 'key_results'.tr;
  String _getSubtitleText() {
    if (_isRetryFromAnalysis)    return 'choose_3_outcomes_retry'.tr;
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
      Get.snackbar('Success', 'Key results updated successfully',
          backgroundColor: AppColors.primaryGreen, colorText: Colors.white);
    } else {
      final selectedKeyResults = keyResultsViewModel.getSelectedKeyResultsAsKeyResult();
      Get.to(() => SuggestionInitiativesScreen(selectedKeyResults: selectedKeyResults));
    }
  }

  void _showBackConfirmationDialog() {
    if (_isModifyFromContextual) { Get.back(); return; }
    Get.dialog(
      AlertDialog(
        backgroundColor:  AppColors.white,
        surfaceTintColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('exit_selection'.tr,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold,
                color: AppColors.primaryRed, fontFamily: 'GothamBold'),
            textAlign: TextAlign.center),
        content: Text('exit_selection_confirmation'.tr,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary,
                fontFamily: 'Gotham', height: 1.4),
            textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('no'.tr,
                style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () { Get.back(); Get.offAllNamed(AppRoutes.home); },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text('yes'.tr,
                style: TextStyle(fontSize: 16.sp, color: AppColors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceAround,
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _saveKeyResultsForNextScreen(
      List<KeyResult> selectedKeyResults) async {
    try {
      final json = jsonEncode(selectedKeyResults.map((kr) => {
        'id':          kr.id,
        'title':       kr.title,
        'description': kr.description,
      }).toList());
      await SharedPrefs.saveString('selected_key_results', json);
    } catch (_) {}
  }

  @override
  void dispose() {
    _keyResultsScrollController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    if (sw >= 768) return _buildDesktopLayout(sw, sh);
    return _buildMobileLayout(sw, sh);
  }

  // ==========================================================================
  // MOBILE LAYOUT — unchanged from original
  // ==========================================================================
  Widget _buildMobileLayout(double sw, double sh) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.03),
                    child: _buildContent(sw, sh),
                  ),
                ),
              ),
              Positioned(
                right: sw * -0.07,
                top:   sh * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT — matches established web pattern exactly
  // ==========================================================================
  Widget _buildDesktopLayout(double sw, double sh) {
    final double containerWidth = sw > 1200 ? 720.0 : sw * 0.72;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/web_background.png',
                  fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth:  sw,
              screenHeight: sh,
              title:    _getHeaderTitle(),
              subtitle: _getHeaderHighlight(),
            ),
          ),
          Positioned(
            top: 110, left: 0, right: 0, bottom: 80,
            child: Center(
              child: Container(
                width: containerWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1),
                        blurRadius: 20, spreadRadius: 4,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(36),
                  child: _buildContent(sw, sh),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => _showBackConfirmationDialog(),
              child: CustomSvg(
                  assetPath: 'assets/images/left.svg', semanticsLabel: ''),
            ),
          ),
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SHARED CONTENT
  // ==========================================================================
  Widget _buildContent(double sw, double sh) {
    final isTablet  = sw > 600;
    final isDesktop = sw > 900;

    return Column(
      children: [
        SizedBox(height: sw >= 768 ? 20.0 : sh * 0.02),

        // CustomHeader(
        //   title:           _getHeaderTitle(),
        //   highlightedText: _getHeaderHighlight(),
        //   onBackTap:       _showBackConfirmationDialog,
        //   showDashboardIcon: true,
        // ),

        SizedBox(height: sw >= 768 ? 14.0 : sh * 0.015),

        // Selected objective
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(sw)),
          child: Obx(() {
            final selectedObjective =
                Get.find<KeyObjectiveController>().selectedObjective.value;
            return CustomObjectiveContainer(
              icon:     Icons.flag,
              title:    _safeTranslate('selected_objective'),
              subtitle: selectedObjective?.title?.tr ?? 'No objective selected',
              description: selectedObjective?.description?.tr ?? '',
            );
          }),
        ),

        SizedBox(height: sw >= 768 ? 18.0 : sh * 0.02),

        // Title + subtitle + loading + badges
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(sw)),
          child: Column(
            children: [
              Text(
                _safeTranslate('select_key_results'),
                style: TextStyle(
                  fontSize:   _getTitleFontSize(sw, isTablet, isDesktop),
                  fontWeight: FontWeight.bold,
                  color:      AppColors.primaryRed,
                  fontFamily: 'GothamExtraBold',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sw >= 768 ? 8.0 : sh * 0.01),
              Obx(() {
                final isLoading =
                    keyResultsViewModel.loading.value && _isNormalFlow;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width:  sw >= 768 ? 16.0 : 16.w,
                        height: sw >= 768 ? 16.0 : 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryRed),
                        ),
                      ),
                      SizedBox(width: sw >= 768 ? 12.0 : 12.w),
                      Text('please_wait'.tr,
                          style: TextStyle(
                            fontSize: _getSubtitleFontSize(sw, isTablet, isDesktop),
                            color:    AppColors.primaryRed,
                            fontFamily: 'Gotham',
                          )),
                    ],
                  )
                      : Text(
                    '${_getSubtitleText()} '
                        '(${keyResultsViewModel.selectedCount}/${keyResultsViewModel.requiredCount})',
                    key: ValueKey<int>(keyResultsViewModel.selectedCount),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _getSubtitleFontSize(sw, isTablet, isDesktop),
                      color: keyResultsViewModel.selectedCount >=
                          keyResultsViewModel.requiredCount
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
                SizedBox(height: sw >= 768 ? 8.0 : sh * 0.01),
                _badge('retry_attempt'.tr, AppColors.primaryRed, sw),
              ] else if (_isModifyFromContextual) ...[
                SizedBox(height: sw >= 768 ? 8.0 : sh * 0.01),
                _badge('adapting_to_challenge'.tr, AppColors.primaryBlue, sw),
              ],
            ],
          ),
        ),

        SizedBox(height: sw >= 768 ? 20.0 : sh * 0.025),

        // Key results list
        Padding(
          padding:
          EdgeInsets.symmetric(horizontal: _getContentPadding(sw, isTablet)),
          child: Obx(() {
            final isLoading =
                keyResultsViewModel.loading.value && _isNormalFlow;

            if (isLoading) {
              return SizedBox(
                height: sw >= 768 ? 200.0 : 200.h,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryRed)),
                      SizedBox(height: sw >= 768 ? 16.0 : 16.h),
                      Text('generating_key_results'.tr,
                          style: TextStyle(
                              fontSize: _fs(sw, 16, desktop: 15),
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }

            if (keyResultsViewModel.allKeyResults.isEmpty) {
              return Column(
                children: [
                  SizedBox(height: sw >= 768 ? 40.0 : sh * 0.05),
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  SizedBox(height: sw >= 768 ? 16.0 : 16.h),
                  Text('No Key Results Available',
                      style: TextStyle(
                          fontSize: _fs(sw, 18, desktop: 17),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: sw >= 768 ? 8.0 : 8.h),
                  Text('Please check your configuration',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: _fs(sw, 14, desktop: 13),
                          color: Colors.grey[500])),
                  if (_isNormalFlow) ...[
                    SizedBox(height: sw >= 768 ? 16.0 : 16.h),
                    ElevatedButton(
                      onPressed: _initializeKeyResults,
                      child: const Text('Retry Generation'),
                    ),
                  ],
                ],
              );
            }

            return _buildKeyResultsList(sw, isTablet);
          }),
        ),

        SizedBox(height: sw >= 768 ? 24.0 : sh * 0.03),

        // Button
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: _getButtonPadding(sw, isTablet, isDesktop)),
          child: Obx(() => CustomButton2(
            text:      _getButtonText(),
            onPressed: keyResultsViewModel.isSelectionComplete
                ? () async {
              journeyController.completeStep(2);
              final selectedKeyResults =
              keyResultsViewModel.getSelectedKeyResultsAsKeyResult();
              await _saveKeyResultsForNextScreen(selectedKeyResults);
              Get.to(() => FeedbackScreen(
                  selectedKeyResults: selectedKeyResults));
            }
                : null,
          )),
        ),

        SizedBox(height: sw >= 768 ? 24.0 : sh * 0.03),

        // Journey map (hide for modify flow)
        if (!_isModifyFromContextual) ...[
          Obx(() => CustomJourneyMap(
            progress:       journeyController.progress.value,
            steps:          journeyController.steps,
            completedSteps: journeyController.completedSteps,
            onToggle:       journeyController.toggleJourneyDetails,
            showDetails:    journeyController.showDetails.value,
          )),
          SizedBox(height: sw >= 768 ? 24.0 : sh * 0.03),
        ],
      ],
    );
  }

  // ── Badge ─────────────────────────────────────────────────────────────────
  Widget _badge(String text, Color color, double sw) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: _d(sw, 12), vertical: _dh(sw, 6)),
    decoration: BoxDecoration(
      color:  color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(_d(sw, 8)),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text,
        style: TextStyle(
            fontSize: _fs(sw, 12, desktop: 13),
            color:      color,
            fontWeight: FontWeight.w600)),
  );

  // ── Key results list ──────────────────────────────────────────────────────
  Widget _buildKeyResultsList(double sw, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(_d(sw, 12)),
        border: Border.all(color: AppColors.accentRed.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1),
              blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      padding: EdgeInsets.all(_d(sw, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _dh(sw, 16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('available_key_results'.tr,
                    style: TextStyle(
                        fontSize: _fs(sw, 16, desktop: 15),
                        fontWeight: FontWeight.bold,
                        color:      AppColors.primaryRed,
                        fontFamily: 'GothamBold')),
                Obx(() => Text(
                    '${keyResultsViewModel.allKeyResults.length} available'.tr,
                    style: TextStyle(
                        fontSize: _fs(sw, 14, desktop: 13),
                        color:     AppColors.textSecondary))),
              ],
            ),
          ),
          _buildKeyResultsGrid(sw, isTablet),
        ],
      ),
    );
  }

  Widget _buildKeyResultsGrid(double sw, bool isTablet) {
    final shuffled = List.from(keyResultsViewModel.allKeyResults)..shuffle();
    final visibleHeight = sw >= 768 ? 320.0 : 320.h;

    return SizedBox(
      height: visibleHeight,
      child: Scrollbar(
        controller:      _keyResultsScrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _keyResultsScrollController,
          physics:    const BouncingScrollPhysics(),
          itemCount:  shuffled.length,
          itemBuilder: (_, index) => Padding(
            padding: EdgeInsets.only(bottom: _dh(sw, 16)),
            child:   _buildKeyResultItem(shuffled[index], index),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyResultItem(KeyResultLatest item, int displayIndex) {
    final originalIndex = keyResultsViewModel.allKeyResults.indexOf(item);
    const flagIcon = Icons.flag;

    return Obx(() => CustomIndustryContainer(
      title: 'K${displayIndex + 1}',
      description: _safeTranslate(item.description,
          fallback: 'Available for the selected one'),
      icon:       flagIcon,
      isSelected: keyResultsViewModel.isSelected(originalIndex),
      onTap: () {
        keyResultsViewModel.toggleSelection(originalIndex);
        if (keyResultsViewModel.isSelected(originalIndex)) {
          constellationController.addIcon(flagIcon);
        } else {
          constellationController.removeIcon(flagIcon);
        }
        if (keyResultsViewModel.isSelectionComplete) {
          journeyController.completeStep(2);
        } else {
          journeyController.uncompleteStep(2);
        }
      },
      showTag1: false,
      showTag2: false,
    ));
  }

  String _safeTranslate(String? key, {String fallback = ''}) {
    if (key == null) return fallback;
    try { return key.tr; } catch (_) { return fallback; }
  }

  // ── Responsive helpers (same as original) ─────────────────────────────────
  Color _getSubtitleColor() =>
      _isRetryFromAnalysis ? AppColors.primaryRed :
      _isModifyFromContextual ? AppColors.primaryBlue : AppColors.textSecondary;

  FontWeight _getSubtitleFontWeight() =>
      (_isRetryFromAnalysis || _isModifyFromContextual)
          ? FontWeight.w600 : FontWeight.normal;

  double _getHorizontalPadding(double sw) {
    if (sw > 1200) return sw * 0.06;
    if (sw > 900)  return sw * 0.04;
    if (sw > 600)  return sw * 0.03;
    return sw * 0.02;
  }

  double _getContentPadding(double sw, bool isTablet) =>
      isTablet ? sw * 0.06 : sw * 0.04;

  double _getButtonPadding(double sw, bool isTablet, bool isDesktop) {
    if (isDesktop) return sw * 0.10; // was 0.25 — way too much
    if (isTablet)  return sw * 0.08; // was 0.15
    return sw * 0.06;                // was 0.1
  }

  double _getTitleFontSize(double sw, bool isTablet, bool isDesktop) {
    if (isDesktop) return (sw * 0.0035).sp;
    if (isTablet)  return (sw * 0.004).sp;
    return (sw * 0.0055).sp;
  }

  double _getSubtitleFontSize(double sw, bool isTablet, bool isDesktop) {
    if (isDesktop) return (sw * 0.0026).sp;
    if (isTablet)  return (sw * 0.0030).sp;
    return (sw * 0.0039).sp;
  }
}