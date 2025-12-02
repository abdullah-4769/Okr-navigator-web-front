import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/widgets/screens_unique_parts/custom_background.dart';
import 'package:get/get.dart';

import '../../../controllers/journey_controller.dart';
import '../../../controllers/key_results_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../generated/models/responses/ai_analysis_model/suggetive_initiative_viewmodel.dart';
import '../../../generated/models/responses/key_results/key_results_response.dart' hide Text;
import '../../../services/shared_preference.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_ai_strategy_container.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_initiative_input.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class SuggestionInitiativesScreen extends StatefulWidget {
  final List<KeyResult> selectedKeyResults;

  const SuggestionInitiativesScreen({super.key, required this.selectedKeyResults});

  @override
  State<SuggestionInitiativesScreen> createState() => _SuggestionInitiativesScreenState();
}

class _SuggestionInitiativesScreenState extends State<SuggestionInitiativesScreen> {
  final JourneyController journeyController = Get.find<JourneyController>();
  final viewModel = Get.put(SuggestionInitiativesViewModel());

  // ✅ Track source
  final bool _isModifyFromContextual = Get.parameters['source'] == 'contextual_challenge';
  final bool _isNormalFlow = !Get.parameters.containsKey('source');

  // Store display data
  DisplayData? _displayData;

  @override
  void initState() {
    super.initState();
    _loadDisplayData();
  }

  /// ✅ Load display data asynchronously
  Future<void> _loadDisplayData() async {
    final data = await _getDisplayData();
    setState(() {
      _displayData = data;
    });
  }

  /// ✅ Get display data from key results or fallback to SharedPreferences
  Future<DisplayData> _getDisplayData() async {
    // First try to get from selected key results
    if (widget.selectedKeyResults.isNotEmpty) {
      final randomKeyResult = _getRandomKeyResult();
      if (randomKeyResult != null) {
        return DisplayData(
          title: randomKeyResult.title?.tr ?? 'No Title',
          description: randomKeyResult.description?.tr ?? '',
          source: 'key_results',
        );
      }
    }

    // If no key results, try to get from SharedPreferences based on game mode
    return await _getDataFromSharedPreferences();
  }

  /// ✅ Get data from SharedPreferences as fallback
  Future<DisplayData> _getDataFromSharedPreferences() async {
    try {
      // Get game mode to determine what data to show
      final gameMode = await SharedPrefs.getGameMode() ?? 'solo';

      print('🔄 No key results found. Checking SharedPreferences for game mode: $gameMode');

      // Try to get selected strategy
      final strategyData = await SharedPrefs.getSelectedStrategy();
      if (strategyData != null && strategyData['title'] != null) {
        return DisplayData(
          title: strategyData['title'].toString(),
          description: strategyData['description']?.toString() ?? 'Selected Strategy',
          source: 'shared_prefs_strategy',
        );
      }

      // Try to get selected objective
      final objectiveData = await SharedPrefs.getSelectedObjective();
      if (objectiveData != null && objectiveData['title'] != null) {
        return DisplayData(
          title: objectiveData['title'].toString(),
          description: objectiveData['description']?.toString() ?? 'Selected Objective',
          source: 'shared_prefs_objective',
        );
      }

      // Try to get user data or other available data
      final userName = await SharedPrefs.getUserName();
      if (userName != null && userName.isNotEmpty) {
        return DisplayData(
          title: 'Strategic Initiatives for $userName',
          description: 'Create initiatives to achieve your goals',
          source: 'shared_prefs_user',
        );
      }

      // Fallback to default data
      return DisplayData(
        title: 'strategic_initiative'.tr,
        description: 'add_initiatives_to_continue'.tr,
        source: 'default',
      );

    } catch (e) {
      print('❌ Error reading from SharedPreferences: $e');
      // Fallback to default data
      return DisplayData(
        title: 'strategic_initiative'.tr,
        description: 'add_initiatives_to_continue'.tr,
        source: 'default',
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        final bool isMobile = screenWidth < 768;
        final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
        final bool isDesktop = screenWidth >= 1024;

        // Responsive font helpers
        double headerFont(double mobile, double tablet, double desktop) =>
            isMobile ? mobile : isTablet ? tablet : desktop;
        double bodyFont(double mobile, double tablet, double desktop) =>
            isMobile ? mobile : isTablet ? tablet : desktop;
        double buttonFont(double mobile, double tablet, double desktop) =>
            isMobile ? mobile : isTablet ? tablet : desktop;

        double containerPadding() => isMobile ? 20 : isTablet ? 30 : 40;
        double containerWidth() =>
            isMobile
                ? screenWidth * 0.9
                : isTablet
                ? screenWidth * 0.7
                : 600;

        if (isMobile) {
          return _buildMobileLayout(
              context, headerFont, bodyFont, buttonFont, isTablet, isDesktop);
        } else {
          return _buildDesktopWebLayout(
              context,
              headerFont,
              bodyFont,
              buttonFont,
              containerPadding(),
              containerWidth(),
              isTablet,
              isDesktop);
        }
      },
    );
  }

  /// ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      bool isTablet,
      bool isDesktop,) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // 🔹 Main Content
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: AppDimensions.d18.h),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.03),

                      /// 🔹 DYNAMIC HEADER BASED ON SOURCE
                      CustomHeader(
                        title: _getHeaderTitle(),
                        highlightedText: _getHeaderHighlight(),
                        subtitle: 'add_initiatives_subtitle'.tr,
                        onBackTap: _handleBackNavigation,
                        showDashboardIcon: true,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      /// 🔹 UPDATED: Show display data (from key results or SharedPreferences)
                      if (_displayData != null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getHorizontalPadding(screenWidth),
                          ),
                          child: CustomObjectiveContainer(
                            icon: Icons.flag,
                            title: _getContainerTitle(_displayData!.source).tr,
                            subtitle: _displayData!.title.tr,
                            description: _displayData!.description.tr,
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getHorizontalPadding(screenWidth),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(child: CircularProgressIndicator()),
                                SizedBox(width: 16.w),
                                Text('loading_data'.tr),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: screenHeight * 0.02),

                      /// 🔹 UPDATED: Show different initiative inputs based on source
                      if (_isModifyFromContextual) ...[
                        // For contextual challenge - show user's existing initiatives
                        _buildContextualInitiativeInputs(screenWidth),
                      ] else ...[
                        // For normal flow - show normal initiative inputs
                        CustomInitiativeInput(
                          numberText: 'first_initiative'.tr,
                          titleController: viewModel.firstInitiativeTitle,
                          descController: viewModel.firstInitiativeDesc,
                        ),
                        CustomInitiativeInput(
                          numberText: 'second_initiative'.tr,
                          titleController: viewModel.secondInitiativeTitle,
                          descController: viewModel.secondInitiativeDesc,
                        ),
                      ],

                      SizedBox(height: AppDimensions.d12.h),

                      /// 🔹 AI Strategy Suggestion
                      const CustomAIStrategyContainer(),

                      SizedBox(height: AppDimensions.d28.h),

                      Obx(() => CustomButton2(
                        text: viewModel.isSubmitting.value
                            ? 'submitting'.tr
                            : _isModifyFromContextual
                            ? 'continue_to_adaptation'.tr
                            : 'submit_analysis'.tr,
                        onPressed: viewModel.isSubmitting.value
                            ? null
                            : () => _handleSubmit(viewModel),
                        isLoading: viewModel.isSubmitting.value,
                      )),

                      SizedBox(height: AppDimensions.d28.h),

                      /// 🔹 HIDE JOURNEY MAP FOR MODIFICATION FLOW
                      if (!_isModifyFromContextual) ...[
                        Obx(
                              () => CustomJourneyMap(
                            progress: journeyController.progress.value,
                            steps: journeyController.steps,
                            completedSteps: journeyController.completedSteps,
                            onToggle: journeyController.toggleJourneyDetails,
                            showDetails: journeyController.showDetails.value,
                          ),
                        ),
                        SizedBox(height: AppDimensions.d28.h),
                      ],
                    ],
                  ),
                ),
              ),

              /// Floating Navigation Bar
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

  /// ----------------- Desktop/Web Layout -----------------
  Widget _buildDesktopWebLayout(BuildContext context,
      double Function(double, double, double) headerFont,
      double Function(double, double, double) bodyFont,
      double Function(double, double, double) buttonFont,
      double padding,
      double containerWidth,
      bool isTablet,
      bool isDesktop,) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/web_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DesktopAppBar(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              title: _getHeaderTitle(),
              subtitle: _getHeaderHighlight(),
            ),
          ),

          /// Scrollable white container
          Center(
            child: Container(
              width: containerWidth,
              height: screenHeight * 0.85,
              margin: const EdgeInsets.only(top: 120),
              padding: EdgeInsets.all(padding),
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
                padding: EdgeInsets.only(bottom: AppDimensions.d18.h),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.02),

                    /// 🔹 UPDATED: Show display data (from key results or SharedPreferences)
                    if (_displayData != null)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getHorizontalPadding(screenWidth),
                        ),
                        child: CustomObjectiveContainer(
                          icon: Icons.flag,
                          title: _getContainerTitle(_displayData!.source).tr,
                          subtitle: _displayData!.title.tr,
                          description: _displayData!.description.tr,
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getHorizontalPadding(screenWidth),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.1),
                            //     blurRadius: 8.r,
                            //     offset: Offset(0, 2.h),
                            //   ),
                            // ],
                          ),
                          // child: Row(
                          //   children: [
                          //     Center(child: CircularProgressIndicator()),
                          //
                          //   ],
                          // ),
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.02),

                    /// 🔹 UPDATED: Show different initiative inputs based on source
                    if (_isModifyFromContextual) ...[
                      // For contextual challenge - show user's existing initiatives
                      _buildContextualInitiativeInputs(screenWidth),
                    ] else ...[
                      // For normal flow - show normal initiative inputs
                      CustomInitiativeInput(
                        numberText: 'first_initiative'.tr,
                        titleController: viewModel.firstInitiativeTitle,
                        descController: viewModel.firstInitiativeDesc,
                      ),
                      CustomInitiativeInput(
                        numberText: 'second_initiative'.tr,
                        titleController: viewModel.secondInitiativeTitle,
                        descController: viewModel.secondInitiativeDesc,
                      ),
                    ],

                    SizedBox(height: AppDimensions.d12.h),

                    /// 🔹 AI Strategy Suggestion
                    const CustomAIStrategyContainer(),

                    SizedBox(height: AppDimensions.d28.h),

                    /// 🔹 Complete Button
                    Obx(() => SizedBox(
                      width: 400.w,
                      height: 66.h,
                      child: ElevatedButton(
                        onPressed: viewModel.isSubmitting.value ? null : () => _handleSubmit(viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          elevation: 6,
                        ),
                        child: viewModel.isSubmitting.value
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                            SizedBox(width: 12.w),
                            Text('submitting'.tr, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w300)),
                          ],
                        )
                            : Text(
                          _isModifyFromContextual ? 'continue_to_adaptation'.tr : 'submit_analysis'.tr,
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w300),
                        ),
                      ),
                    )),

                    SizedBox(height: AppDimensions.d28.h),

                    /// 🔹 HIDE JOURNEY MAP FOR MODIFICATION FLOW
                    if (!_isModifyFromContextual) ...[
                      Obx(
                            () => CustomJourneyMap(
                          progress: journeyController.progress.value,
                          steps: journeyController.steps,
                          completedSteps: journeyController.completedSteps,
                          onToggle: journeyController.toggleJourneyDetails,
                          showDetails: journeyController.showDetails.value,
                        ),
                      ),
                      SizedBox(height: AppDimensions.d28.h),
                    ],
                  ],
                ),
              ),
            ),
          ),

          /// Home Navbar
          Positioned(
            bottom: 20,
            left: 0,
            child: CustomSvg(
              assetPath: 'assets/images/left.svg',
              semanticsLabel: '',
            ),
          ),

          /// Home Navbar
          Positioned(
            bottom: 20,
            left: 0,
            right: -30,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  /// ✅ NEW: Get appropriate container title based on data source
  String _getContainerTitle(String source) {
    switch (source) {
      case 'key_results':
        return 'selected_key_result'.tr;
      case 'shared_prefs_strategy':
        return 'selected_strategy'.tr;
      case 'shared_prefs_objective':
        return 'selected_objective'.tr;
      case 'shared_prefs_user':
        return 'user_initiatives'.tr;
      default:
        return 'Current Focus'.tr;
    }
  }

  /// ✅ NEW: Build initiative inputs for contextual challenge flow
  Widget _buildContextualInitiativeInputs(double screenWidth) {
    return Column(
      children: [
        // Show user's existing initiatives (read-only or editable based on your needs)
        CustomInitiativeInput(
          numberText: 'first_initiative'.tr,
          titleController: viewModel.firstInitiativeTitle,
          descController: viewModel.firstInitiativeDesc,
          // isEnabled: false, // Make read-only for viewing
        ),
        CustomInitiativeInput(
          numberText: 'second_initiative'.tr,
          titleController: viewModel.secondInitiativeTitle,
          descController: viewModel.secondInitiativeDesc,
          // isEnabled: false, // Make read-only for viewing
        ),
      ],
    );
  }

  // ✅ DYNAMIC HEADER & MESSAGES BASED ON SOURCE
  String _getHeaderTitle() {
    if (_isModifyFromContextual) {
      return 'review'.tr;
    }
    return 'suggestion'.tr;
  }

  String _getHeaderHighlight() {
    if (_isModifyFromContextual) {
      return 'initiatives'.tr;
    }
    return 'of_initiatives'.tr;
  }

  // ✅ Get appropriate button text


  // ✅ Handle back navigation based on source
  void _handleBackNavigation() {
    if (_isModifyFromContextual) {
      // Return to contextual challenge screen
      Get.back();
    } else {
      // Normal navigation back
      Get.back();
    }
  }

  // ✅ Handle submit based on source
  void _handleSubmit(SuggestionInitiativesViewModel viewModel) {
    if (_isModifyFromContextual) {
      // For contextual challenge - just navigate to adaptation screen
      Get.toNamed(AppRoutes.contextualChallenge);
    } else {
      // Normal submission flow - mark initiatives step as complete
      journeyController.completeStep(3);
      viewModel.submitInitiatives(widget.selectedKeyResults);
    }
  }

  /// Get a random key result from the selected ones
  KeyResult? _getRandomKeyResult() {
    if (widget.selectedKeyResults.isEmpty) return null;

    // Shuffle the list and take the first one
    final shuffled = List<KeyResult>.from(widget.selectedKeyResults)..shuffle();
    final randomKeyResult = shuffled.first;

    print('🎲 Random key result selected: ${randomKeyResult.title}');
    return randomKeyResult;
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1200) return screenWidth * 0.06;
    if (screenWidth > 900) return screenWidth * 0.04;
    if (screenWidth > 600) return screenWidth * 0.03;
    return screenWidth * 0.02;
  }
}

/// ✅ NEW: Data structure to hold display information
class DisplayData {
  final String title;
  final String description;
  final String source; // 'key_results', 'shared_prefs_strategy', 'shared_prefs_objective', 'default'

  DisplayData({
    required this.title,
    required this.description,
    required this.source,
  });
}