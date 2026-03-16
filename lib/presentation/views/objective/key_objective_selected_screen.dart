import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/utils/snackbar_helper.dart';
import 'package:get/get.dart';
import 'dart:developer';

import '../../../controllers/journey_controller.dart';
import '../../../controllers/key_objective_controller.dart';
import '../../../controllers/strategy_selection_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../generated/models/responses/objectives/objectives_response.dart';
import '../../../generated/models/responses/strategy/strategy_response.dart';
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

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class KeyObjectiveSelectedScreen extends StatefulWidget {
  const KeyObjectiveSelectedScreen({super.key});

  @override
  State<KeyObjectiveSelectedScreen> createState() =>
      _KeyObjectiveSelectedScreenState();
}

class _KeyObjectiveSelectedScreenState
    extends State<KeyObjectiveSelectedScreen> {
  late final Map<String, dynamic>? args;
  late final StrategyResponse? strategy;
  late final String? strategyDisplayTitle;
  late final int? strategyCardIndex;

  final TextEditingController searchController = TextEditingController();
  final RxList<Objective> filteredObjectives = RxList<Objective>();
  final KeyObjectiveController controller = Get.find<KeyObjectiveController>();
  final JourneyController journeyController = Get.find<JourneyController>();
  final StrategySelectionController strategyController =
  Get.find<StrategySelectionController>();

  final ScrollController _scrollController = ScrollController();

  bool _isInitialized   = false;
  bool _hasShownMessage = false;

  late final bool _isRetryFromAnalysis;
  late final bool _isModifyFromContextual;
  late final bool _isNormalFlow;

  @override
  void initState() {
    super.initState();

    args                 = Get.arguments as Map<String, dynamic>?;
    strategy             = args?['strategy'] as StrategyResponse?;
    strategyDisplayTitle = args?['strategyDisplayTitle'] as String?;
    strategyCardIndex    = args?['strategyCardIndex'] as int?;

    _isRetryFromAnalysis    = Get.parameters['isRetry'] == 'true';
    _isModifyFromContextual = Get.parameters['source'] == 'contextual_challenge';
    _isNormalFlow           = !_isRetryFromAnalysis && !_isModifyFromContextual;

    filteredObjectives.assignAll(controller.objectives);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initializeScreen());
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeScreen() {
    if (_isInitialized) return;
    _isInitialized = true;

    if (!_hasShownMessage) {
      _hasShownMessage = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isRetryFromAnalysis) {
          SnackbarHelper.info(
              'Please select a different objective to improve your initiatives');
        } else if (_isModifyFromContextual) {
          SnackbarHelper.info(
              'Select a new objective to adapt to the market challenge');
        }
      });
    }

    if (_isRetryFromAnalysis || _isModifyFromContextual) {
      controller.clearSelection();
    }

    ever(controller.objectives, (_) {
      if (mounted) {
        filteredObjectives.assignAll(controller.objectives);
        if (searchController.text.isNotEmpty) {
          filterObjectives(searchController.text);
        }
      }
    });

    _loadObjectivesIfNeeded();
  }

  void _loadObjectivesIfNeeded() {
    final selectedRole     = args?['selectedRole']     as Map<String, dynamic>?;
    final selectedIndustry = args?['selectedIndustry'] as Map<String, dynamic>?;
    final isCampaignMode   = args?['isCampaignMode']   as bool? ?? false;

    if (_isNormalFlow) {
      _fetchObjectives(selectedRole, selectedIndustry, isCampaignMode);
      return;
    }
    if (_isRetryFromAnalysis || _isModifyFromContextual) {
      if (controller.objectives.isNotEmpty) {
        filteredObjectives.assignAll(controller.objectives);
      } else {
        _fetchObjectives(selectedRole, selectedIndustry, isCampaignMode);
      }
    }
  }

  Future<void> _fetchObjectives(
      Map<String, dynamic>? selectedRole,
      Map<String, dynamic>? selectedIndustry,
      bool isCampaignMode,
      ) async {
    try {
      if (selectedRole != null && selectedIndustry != null) {
        await controller.getObjectives(selectedRole, selectedIndustry);
      } else {
        SnackbarHelper.error('Missing role or industry info.');
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(AppRoutes.selectStrategy, arguments: args);
      }
    } catch (e) {
      SnackbarHelper.error('Failed to load objectives');
    }
  }

  String _safeTranslate(String? key, {String fallback = ''}) {
    if (key == null) return fallback;
    try { return key.tr; } catch (_) { return fallback; }
  }

  void filterObjectives(String query) {
    if (!mounted) return;
    if (query.isEmpty) {
      filteredObjectives.assignAll(controller.objectives);
    } else {
      filteredObjectives.assignAll(
        controller.objectives.where((obj) {
          final t = obj.title?.tr ?? '';
          final d = obj.description?.tr ?? '';
          return t.toLowerCase().contains(query.toLowerCase()) ||
              d.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  String _getStrategyDisplayText() {
    if (strategyDisplayTitle != null && strategyDisplayTitle!.isNotEmpty) {
      return strategyDisplayTitle!;
    }
    final strategyFromController = strategyController.selectedStrategy.value;
    if (strategyFromController?.cardId != null) {
      final t = strategyController
          .getCardTitleFromBackendId(strategyFromController?.cardId);
      if (t != null && t.isNotEmpty) return t;
    }
    if (strategyCardIndex != null && strategyCardIndex! >= 0) {
      final t = strategyController.getCardTitle(strategyCardIndex!);
      if (t != null && t.isNotEmpty) return t;
    }
    final s = strategyController.selectedStrategy.value;
    if (s != null && s.title != null && s.title!.isNotEmpty) return s.title!;
    return 'No strategy selected'.tr;
  }

  String _getHeaderTitle() {
    if (_isRetryFromAnalysis)    return 'try_again_with_different'.tr;
    if (_isModifyFromContextual) return 'modify'.tr;
    return 'choose'.tr;
  }

  String _getHeaderHighlight() => 'objective'.tr;

  String _getSubtitleText() {
    if (_isRetryFromAnalysis)    return 'select_different_objective_retry'.tr;
    if (_isModifyFromContextual) return 'select_new_objective_for_challenge'.tr;
    return 'select_one_objective'.tr;
  }

  String _getButtonText() {
    if (_isModifyFromContextual) return 'save_changes'.tr;
    return 'complete_selection'.tr;
  }

  void _navigateToNextScreen() {
    if (_isModifyFromContextual) {
      Get.back(result: controller.selectedObjective.value);
      SnackbarHelper.success('Objective updated successfully');
    } else {
      Get.offAllNamed(AppRoutes.keyResultsScreen);
    }
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
                    padding: EdgeInsets.only(bottom: sh * 0.025),
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
                    BoxShadow(
                        color:        Colors.black.withOpacity(0.1),
                        blurRadius:   20,
                        spreadRadius: 4,
                        offset:       const Offset(0, 8))
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
              onTap: () {
                if (_isModifyFromContextual) {
                  Get.back();
                } else {
                  Get.offAllNamed(AppRoutes.selectStrategy, arguments: {
                    'selectedRole':     args?['selectedRole'],
                    'selectedIndustry': args?['selectedIndustry'],
                    'isCampaignMode':   args?['isCampaignMode'] ?? false,
                  });
                }
              },
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
        SizedBox(height: sw >= 768 ? 20.0 : sh * 0.03),

        // // ✅ FIX 1: Restored CustomHeader (was commented out in original)
        // CustomHeader(
        //   title:           _getHeaderTitle(),
        //   highlightedText: _getHeaderHighlight(),
        //   onBackTap: () {
        //     if (_isModifyFromContextual) {
        //       Get.back();
        //     } else {
        //       Get.offAllNamed(AppRoutes.selectStrategy, arguments: {
        //         'selectedRole':     args?['selectedRole'],
        //         'selectedIndustry': args?['selectedIndustry'],
        //         'isCampaignMode':   args?['isCampaignMode'] ?? false,
        //       });
        //     }
        //   },
        // ),

        SizedBox(height: sw >= 768 ? 16.0 : sh * 0.02),

        // Selected strategy container
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(sw)),
          child: CustomObjectiveContainer(
            title:      _safeTranslate('selected_strategy'),
            subtitle:   _getStrategyDisplayText(),
            icon:       Icons.emoji_objects,
            titleColor: AppColors.primaryRed,
          ),
        ),

        SizedBox(height: sw >= 768 ? 20.0 : sh * 0.025),

        // Title + subtitle + badges
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(sw)),
          child: Column(
            children: [
              Text(
                _safeTranslate('choose_your_objective'),
                style: TextStyle(
                  fontSize:   _getTitleFontSize(sw, isTablet, isDesktop),
                  fontWeight: FontWeight.bold,
                  color:      AppColors.primaryRed,
                  fontFamily: 'GothamBold',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sw >= 768 ? 8.0 : sh * 0.01),
              Text(
                _getSubtitleText(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:   _getSubtitleFontSize(sw, isTablet, isDesktop),
                  color:      _getSubtitleColor(),
                  fontFamily: 'Gotham',
                  height: 1.4,
                  fontWeight: _getSubtitleFontWeight(),
                ),
              ),
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

        SizedBox(height: sw >= 768 ? 16.0 : sh * 0.02),

        // Objectives list
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: _getContentPadding(sw, isTablet)),
          child: _buildObjectivesContent(sw, isTablet),
        ),

// Button with proper spacing
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _getButtonPadding(sw, isTablet, isDesktop),
            vertical: sw >= 768 ? 16.0 : 16.h, // ✅ fixed: no .h on desktop
          ),
          child: Obx(() {
            final isEnabled = controller.selectedObjective.value != null;
            return Opacity(
              opacity: isEnabled ? 1.0 : 0.5, // ✅ always visible, just dimmed
              child: CustomButton2(
                text: _getButtonText(),
                onPressed: isEnabled ? _navigateToNextScreen : () {}, // ✅ never null
              ),
            );
          }),
        ),

// Journey map (hide for modify flow)
        if (!_isModifyFromContextual) ...[
          SizedBox(height: sw >= 768 ? 16.0 : 16.h), // ✅ fixed
          Obx(() => CustomJourneyMap(
            progress:       journeyController.progress.value,
            steps:          journeyController.steps,
            completedSteps: journeyController.completedSteps,
            onToggle:       journeyController.toggleJourneyDetails,
            showDetails:    journeyController.showDetails.value,
          )),
          SizedBox(height: sw >= 768 ? 24.0 : 24.h), // ✅ fixed
        ],

      ],
    );
  }

  // ── Badge helper ──────────────────────────────────────────────────────────
  Widget _badge(String text, Color color, double sw) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: _d(sw, 12), vertical: _dh(sw, 6)),
    decoration: BoxDecoration(
      color:        color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(_d(sw, 8)),
      border:       Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text,
        style: TextStyle(
            fontSize:   _fs(sw, 12, desktop: 13),
            color:      color,
            fontWeight: FontWeight.w600)),
  );

  // ── Objectives content ────────────────────────────────────────────────────
  Widget _buildObjectivesContent(double sw, bool isTablet) {
    return Obx(() {
      if (controller.loading.value && _isNormalFlow) {
        return SizedBox(
          height: sw >= 768 ? 200.0 : 200.h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryRed),
                SizedBox(height: sw >= 768 ? 16.0 : 16.h),
                Text('Choosing Objectives for You...',
                    style: TextStyle(
                        color:    AppColors.textSecondary,
                        fontSize: _fs(sw, 14, desktop: 14))),
              ],
            ),
          ),
        );
      }

      if (controller.loading.value && controller.objectives.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.objectives.isEmpty) {
        return Center(
          child: Text('No objectives available',
              style: TextStyle(
                  color:    AppColors.textSecondary,
                  fontSize: _fs(sw, 16, desktop: 15))),
        );
      }

      return _buildObjectivesList(sw);
    });
  }

  // ✅ FIX 3: Always ListView — no GridView, no staggered/gallery layout
  Widget _buildObjectivesList(double sw) {
    final double listHeight = sw >= 768 ? 380.0 : 400.h;

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(_d(sw, 12)),
        border:       Border.all(color: AppColors.primaryRed, width: 2),
      ),
      constraints: BoxConstraints(maxHeight: listHeight),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scrollbar(
          controller:      _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness:       6,
          radius:          const Radius.circular(20),
          child: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics:    const AlwaysScrollableScrollPhysics(),
            padding:    const EdgeInsets.only(bottom: 8),
            itemCount:  filteredObjectives.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child:   _buildObjectiveItem(i),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getObjectiveIcon(int index) {
    const icons = [
      Icons.flag,               Icons.star,
      Icons.rocket_launch,      Icons.trending_up,
      Icons.lightbulb,          Icons.auto_awesome,
      Icons.bolt,               Icons.workspace_premium,
      Icons.emoji_events,       Icons.assignment_turned_in,
    ];
    return icons[index % icons.length];
  }

  Widget _buildObjectiveItem(int index) {
    final obj = filteredObjectives[index];
    return Obx(() {
      final isSelected = controller.isSelected(obj);
      return CustomIndustryContainer(
        title:       _safeTranslate(obj.title,       fallback: 'Title'.tr),
        description: _safeTranslate(obj.description, fallback: 'Available'.tr),
        icon:        _getObjectiveIcon(index),
        isSelected:  isSelected,
        onTap: () {
          controller.selectObjective(obj);
          if (controller.isSelected(obj)) {
            journeyController.completeStep(1);
          } else {
            journeyController.uncompleteStep(1);
          }
        },
      );
    });
  }

  // ── Responsive helpers ────────────────────────────────────────────────────
  Color _getSubtitleColor() =>
      _isRetryFromAnalysis    ? AppColors.primaryRed  :
      _isModifyFromContextual ? AppColors.primaryBlue :
      AppColors.textSecondary;

  FontWeight _getSubtitleFontWeight() =>
      (_isRetryFromAnalysis || _isModifyFromContextual)
          ? FontWeight.w600 : FontWeight.normal;

  double _getHorizontalPadding(double sw) {
    if (sw > 1200) return sw * 0.08;
    if (sw > 900)  return sw * 0.06;
    if (sw > 600)  return sw * 0.05;
    return sw * 0.04;
  }

  double _getContentPadding(double sw, bool isTablet) =>
      isTablet ? sw * 0.07 : sw * 0.03;

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
    if (isDesktop) return (sw * 0.0022).sp;
    if (isTablet)  return (sw * 0.0026).sp;
    return (sw * 0.0038).sp;
  }
}