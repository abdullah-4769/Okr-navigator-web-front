import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/journey_controller.dart';
import '../../../core/app_dimensions.dart';
import '../../../core/app_colors.dart';
import '../../../generated/models/responses/ai_analysis_model/suggetive_initiative_viewmodel.dart';
import '../../../generated/models/responses/key_results/key_results_response.dart' hide Text;
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_ai_strategy_container.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_initiative_input.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import '../../../services/shared_preference.dart';

class SuggestionInitiativesScreen extends StatefulWidget {
  final List<KeyResult> selectedKeyResults;

  const SuggestionInitiativesScreen({super.key, required this.selectedKeyResults});

  @override
  State<SuggestionInitiativesScreen> createState() =>
      _SuggestionInitiativesScreenState();
}

class _SuggestionInitiativesScreenState
    extends State<SuggestionInitiativesScreen> {
  final JourneyController journeyController = Get.find<JourneyController>();
  final viewModel = Get.put(SuggestionInitiativesViewModel());

  final bool _isModifyFromContextual =
      Get.parameters['source'] == 'contextual_challenge';
  final bool _isNormalFlow = !Get.parameters.containsKey('source');

  DisplayData? _displayData;

  @override
  void initState() {
    super.initState();
    _loadDisplayData();
  }

  Future<void> _loadDisplayData() async {
    final data = await _getDisplayData();
    setState(() => _displayData = data);
  }

  Future<DisplayData> _getDisplayData() async {
    if (widget.selectedKeyResults.isNotEmpty) {
      final rk = _getRandomKeyResult();
      if (rk != null) {
        return DisplayData(
          title: rk.title?.tr ?? '',
          description: rk.description?.tr ?? '',
          source: 'key_results',
        );
      }
    }
    return await _getDataFromSharedPreferences();
  }

  Future<DisplayData> _getDataFromSharedPreferences() async {
    try {
      final gameMode = await SharedPrefs.getGameModeAsync() ?? 'solo';
      final strategyData = await SharedPrefs.getSelectedStrategy();
      if (strategyData != null && strategyData['title'] != null) {
        return DisplayData(
          title: strategyData['title'].toString(),
          description: strategyData['description']?.toString() ?? '',
          source: 'shared_prefs_strategy',
        );
      }
      final objectiveData = await SharedPrefs.getSelectedObjective();
      if (objectiveData != null && objectiveData['title'] != null) {
        return DisplayData(
          title: objectiveData['title'].toString(),
          description: objectiveData['description']?.toString() ?? '',
          source: 'shared_prefs_objective',
        );
      }
      final userName = await SharedPrefs.getUserName();
      if (userName != null && userName.isNotEmpty) {
        return DisplayData(
          title: 'Strategic Initiatives for $userName',
          description: 'Create initiatives to achieve your goals',
          source: 'shared_prefs_user',
        );
      }
    } catch (e) {
      debugPrint('❌ Error reading SharedPreferences: $e');
    }
    return DisplayData(
      title: 'strategic_initiative'.tr,
      description: 'add_initiatives_to_continue'.tr,
      source: 'default',
    );
  }

  KeyResult? _getRandomKeyResult() {
    if (widget.selectedKeyResults.isEmpty) return null;
    final shuffled = List<KeyResult>.from(widget.selectedKeyResults)..shuffle();
    return shuffled.first;
  }

  String _getContainerTitle(String source) {
    switch (source) {
      case 'key_results':           return 'selected_key_result'.tr;
      case 'shared_prefs_strategy': return 'selected_strategy'.tr;
      case 'shared_prefs_objective':return 'selected_objective'.tr;
      case 'shared_prefs_user':     return 'user_initiatives'.tr;
      default:                      return 'current_focus'.tr;
    }
  }

  String _getHeaderTitle() =>
      _isModifyFromContextual ? 'review'.tr : 'suggestion'.tr;
  String _getHeaderHighlight() =>
      _isModifyFromContextual ? 'initiatives'.tr : 'of_initiatives'.tr;

  String _getButtonText(bool isSubmitting) {
    if (isSubmitting) return 'submitting'.tr;
    if (_isModifyFromContextual) return 'continue_to_adaptation'.tr;
    return 'submit_analysis'.tr;
  }

  void _handleSubmit(SuggestionInitiativesViewModel vm) {
    if (_isModifyFromContextual) {
      Get.toNamed(AppRoutes.contextualChallenge);
    } else {
      journeyController.completeStep(3);
      vm.submitInitiatives(widget.selectedKeyResults);
    }
  }

  double _getHorizontalPadding(double sw) {
    if (sw > 1200) return sw * 0.06;
    if (sw > 900)  return sw * 0.04;
    if (sw > 600)  return sw * 0.03;
    return sw * 0.02;
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    return sw < 768
        ? _buildMobileLayout(context, sw)
        : _buildDesktopLayout(context, sw);
  }

  // ── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, double sw) {
    final double sh = MediaQuery.of(context).size.height;
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: AppDimensions.d18.h),
                  child: Column(
                    children: [
                      SizedBox(height: sh * 0.03),
                      CustomHeader(
                        title: _getHeaderTitle(),
                        highlightedText: _getHeaderHighlight(),
                        onBackTap: () => Get.back(),
                      ),
                      SizedBox(height: sh * 0.02),
                      _buildObjectiveCard(sw, isDesktop: false),
                      SizedBox(height: sh * 0.02),
                      _buildInitiativeInputs(isDesktop: false),
                      SizedBox(height: AppDimensions.d12.h),
                      const CustomAIStrategyContainer(),
                      SizedBox(height: AppDimensions.d28.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.d40.w),
                        child: _buildSubmitButton(),
                      ),
                      SizedBox(height: AppDimensions.d28.h),
                      if (!_isModifyFromContextual) _buildJourneyMap(),
                      SizedBox(height: AppDimensions.d28.h),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: sw * -0.07,
                top: MediaQuery.of(context).size.height * 0.50,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DESKTOP ────────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(BuildContext context, double sw) {
    final double sh = MediaQuery.of(context).size.height;
    final double containerWidth = sw > 1200 ? 860.0 : sw * 0.78;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/web_background.png',
                  fit: BoxFit.cover),
            ),
          ),

          // AppBar
          Positioned(
            top: 0, left: 0, right: 0,
            child: DesktopAppBar(
              screenWidth: sw,
              screenHeight: sh,
              title: _getHeaderTitle(),
              subtitle: _getHeaderHighlight(),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildObjectiveCard(sw, isDesktop: true),
                      const SizedBox(height: 20),

                      // Initiative inputs side by side on desktop
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _isModifyFromContextual
                            ? [
                          Expanded(child: CustomInitiativeInput(
                            numberText: 'first_initiative'.tr,
                            titleController: viewModel.firstInitiativeTitle,
                            descController: viewModel.firstInitiativeDesc,
                            isEnabled: false,
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: CustomInitiativeInput(
                            numberText: 'second_initiative'.tr,
                            titleController: viewModel.secondInitiativeTitle,
                            descController: viewModel.secondInitiativeDesc,
                            isEnabled: false,
                          )),
                        ]
                            : [
                          Expanded(child: CustomInitiativeInput(
                            numberText: 'first_initiative'.tr,
                            titleController: viewModel.firstInitiativeTitle,
                            descController: viewModel.firstInitiativeDesc,
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: CustomInitiativeInput(
                            numberText: 'second_initiative'.tr,
                            titleController: viewModel.secondInitiativeTitle,
                            descController: viewModel.secondInitiativeDesc,
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const CustomAIStrategyContainer(),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: 320,
                          child: _buildSubmitButton(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_isModifyFromContextual) _buildJourneyMap(),
                      const SizedBox(height: 16),
                    ],
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

  Widget _buildObjectiveCard(double sw, {required bool isDesktop}) {
    if (_displayData != null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 0 : _getHorizontalPadding(sw),
        ),
        child: CustomObjectiveContainer(
          icon: Icons.flag,
          title: _getContainerTitle(_displayData!.source).tr,
          subtitle: _displayData!.title.tr,
          description: _displayData!.description.tr,
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : _getHorizontalPadding(sw),
      ),
      child: Container(
        padding: isDesktop ? const EdgeInsets.all(16) : EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: isDesktop ? 16 : 16.w),
            Text('loading_data'.tr),
          ],
        ),
      ),
    );
  }

  Widget _buildInitiativeInputs({required bool isDesktop}) {
    if (_isModifyFromContextual) {
      return Column(children: [
        CustomInitiativeInput(
          numberText: 'first_initiative'.tr,
          titleController: viewModel.firstInitiativeTitle,
          descController: viewModel.firstInitiativeDesc,
          isEnabled: false,
        ),
        CustomInitiativeInput(
          numberText: 'second_initiative'.tr,
          titleController: viewModel.secondInitiativeTitle,
          descController: viewModel.secondInitiativeDesc,
          isEnabled: false,
        ),
      ]);
    }
    return Column(children: [
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
    ]);
  }

  Widget _buildSubmitButton() {
    return Obx(() => CustomButton2(
      text: _getButtonText(viewModel.isSubmitting.value),
      onPressed: viewModel.isSubmitting.value
          ? () {}
          : () => _handleSubmit(viewModel),
    ));
  }

  Widget _buildJourneyMap() {
    return Obx(() => CustomJourneyMap(
      progress: journeyController.progress.value,
      steps: journeyController.steps,
      completedSteps: journeyController.completedSteps,
      onToggle: journeyController.toggleJourneyDetails,
      showDetails: journeyController.showDetails.value,
    ));
  }
}

class DisplayData {
  final String title;
  final String description;
  final String source;
  DisplayData({required this.title, required this.description, required this.source});
}





// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../../../controllers/journey_controller.dart';
// import '../../../controllers/key_results_controller.dart';
// import '../../../core/app_dimensions.dart';
// import '../../../core/app_colors.dart';
// import '../../../generated/models/responses/ai_analysis_model/suggetive_initiative_viewmodel.dart';
// import '../../../generated/models/responses/key_results/key_results_response.dart' hide Text;
// import '../../routes/app_routes.dart';
// import '../../widgets/custom_ai_strategy_container.dart';
// import '../../widgets/custom_button2.dart';
// import '../../widgets/custom_home_navbar.dart';
// import '../../widgets/custom_initiative_input.dart';
// import '../../widgets/custom_journey_map.dart';
// import '../../widgets/custom_objective_container.dart';
// import '../../widgets/screens_unique_parts/custom_background.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
// import '../../../services/shared_preference.dart';
//
// class SuggestionInitiativesScreen extends StatefulWidget {
//   final List<KeyResult> selectedKeyResults;
//
//   const SuggestionInitiativesScreen({super.key, required this.selectedKeyResults});
//
//   @override
//   State<SuggestionInitiativesScreen> createState() => _SuggestionInitiativesScreenState();
// }
//
// class _SuggestionInitiativesScreenState extends State<SuggestionInitiativesScreen> {
//   final JourneyController journeyController = Get.find<JourneyController>();
//   final viewModel = Get.put(SuggestionInitiativesViewModel());
//
//   // ✅ Track source
//   final bool _isModifyFromContextual = Get.parameters['source'] == 'contextual_challenge';
//   final bool _isNormalFlow = !Get.parameters.containsKey('source');
//
//   // Store display data
//   DisplayData? _displayData;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDisplayData();
//   }
//
//   /// ✅ Load display data asynchronously
//   Future<void> _loadDisplayData() async {
//     final data = await _getDisplayData();
//     setState(() {
//       _displayData = data;
//     });
//   }
//
//   /// ✅ NEW: Get display data from key results or fallback to SharedPreferences
//   Future<DisplayData> _getDisplayData() async {
//     // First try to get from selected key results
//     if (widget.selectedKeyResults.isNotEmpty) {
//       final randomKeyResult = _getRandomKeyResult();
//       if (randomKeyResult != null) {
//         return DisplayData(
//           title: randomKeyResult.title?.tr ?? 'No Title',
//           description: randomKeyResult.description?.tr ?? '',
//           source: 'key_results',
//         );
//       }
//     }
//
//     // If no key results, try to get from SharedPreferences based on game mode
//     return await _getDataFromSharedPreferences();
//   }
//
//   /// ✅ NEW: Get data from SharedPreferences as fallback
//   Future<DisplayData> _getDataFromSharedPreferences() async {
//     try {
//       // Get game mode to determine what data to show
//       final gameMode = await SharedPrefs.getGameMode() ?? 'solo';
//
//       print('🔄 No key results found. Checking SharedPreferences for game mode: $gameMode');
//
//       // Try to get selected strategy
//       final strategyData = await SharedPrefs.getSelectedStrategy();
//       if (strategyData != null && strategyData['title'] != null) {
//         return DisplayData(
//           title: strategyData['title'].toString(),
//           description: strategyData['description']?.toString() ?? 'Selected Strategy',
//           source: 'shared_prefs_strategy',
//         );
//       }
//
//       // Try to get selected objective
//       final objectiveData = await SharedPrefs.getSelectedObjective();
//       if (objectiveData != null && objectiveData['title'] != null) {
//         return DisplayData(
//           title: objectiveData['title'].toString(),
//           description: objectiveData['description']?.toString() ?? 'Selected Objective',
//           source: 'shared_prefs_objective',
//         );
//       }
//
//       // Try to get user name
//       final userName = await SharedPrefs.getUserName();
//       if (userName != null && userName.isNotEmpty) {
//         return DisplayData(
//           title: 'Strategic Initiatives for $userName',
//           description: 'Create initiatives to achieve your goals',
//           source: 'shared_prefs_user',
//         );
//       }
//
//       // Fallback to default data
//       return DisplayData(
//         title: 'strategic_initiative'.tr,
//         description: 'add_initiatives_to_continue'.tr,
//         source: 'default',
//       );
//
//     } catch (e) {
//       print('❌ Error reading from SharedPreferences: $e');
//       // Fallback to default data
//       return DisplayData(
//         title: 'strategic_initiative'.tr,
//         description: 'add_initiatives_to_continue'.tr,
//         source: 'default',
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//
//     print('🎯 Initiatives Screen Source:');
//     print('   - Modify from Contextual: $_isModifyFromContextual');
//     print('   - Normal Flow: $_isNormalFlow');
//     if (_displayData != null) {
//       print('   - Display Data Source: ${_displayData!.source}');
//     }
//
//     return Scaffold(
//       body: CustomBackground(
//         child: SafeArea(
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: EdgeInsets.only(bottom: AppDimensions.d18.h),
//                   child: Column(
//                     children: [
//                       SizedBox(height: screenHeight * 0.03),
//
//                       // ✅ DYNAMIC HEADER BASED ON SOURCE
//                       CustomHeader(
//                         title: _getHeaderTitle(),
//                         highlightedText: _getHeaderHighlight(),
//                         onBackTap: () {
//                           if (_isModifyFromContextual) {
//                             // Return to contextual challenge screen
//                             Get.back();
//                           } else {
//                             // Normal navigation back
//                             Get.back();
//                           }
//                         },
//                       ),
//
//                       SizedBox(height: screenHeight * 0.02),
//
//                       /// ✅ UPDATED: Show display data (from key results or SharedPreferences)
//                       if (_displayData != null)
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: _getHorizontalPadding(screenWidth),
//                           ),
//                           child: CustomObjectiveContainer(
//
//                             icon: Icons.flag,
//                             title: _getContainerTitle(_displayData!.source).tr,
//                             subtitle: _displayData!.title.tr,
//                             description: _displayData!.description.tr,
//                           ),
//                         )
//                       else
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: _getHorizontalPadding(screenWidth),
//                           ),
//                           child: Container(
//                             padding: EdgeInsets.all(16.w),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12.r),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 8.r,
//                                   offset: Offset(0, 2.h),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 CircularProgressIndicator(),
//                                 SizedBox(width: 16.w),
//                                 Text('loading_data'.tr),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                       SizedBox(height: screenHeight * 0.02),
//
//                       /// ✅ UPDATED: Show different initiative inputs based on source
//                       if (_isModifyFromContextual) ...[
//                         // For contextual challenge - show user's existing initiatives
//                         _buildContextualInitiativeInputs(),
//                       ] else ...[
//                         // For normal flow - show normal initiative inputs
//                         CustomInitiativeInput(
//                           numberText: 'first_initiative'.tr,
//                           titleController: viewModel.firstInitiativeTitle,
//                           descController: viewModel.firstInitiativeDesc,
//                         ),
//                         CustomInitiativeInput(
//                           numberText: 'second_initiative'.tr,
//                           titleController: viewModel.secondInitiativeTitle,
//                           descController: viewModel.secondInitiativeDesc,
//                         ),
//
//
//                       ],
//
//                       SizedBox(height: AppDimensions.d12.h),
//                       const CustomAIStrategyContainer(),
//
//                       SizedBox(height: AppDimensions.d28.h),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: AppDimensions.d40.w),
//                         child: Obx(
//                               () => CustomButton2(
//                             text: _getButtonText(viewModel.isSubmitting.value),
//                             onPressed: viewModel.isSubmitting.value
//                                 ? () {}
//                                 : () => _handleSubmit(viewModel),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: AppDimensions.d28.h),
//
//                       // ✅ HIDE JOURNEY MAP FOR MODIFICATION FLOW
//                       if (!_isModifyFromContextual) ...[
//                         Obx(
//                               () => CustomJourneyMap(
//                             progress: journeyController.progress.value,
//                             steps: journeyController.steps,
//                             completedSteps: journeyController.completedSteps,
//                             onToggle: journeyController.toggleJourneyDetails,
//                             showDetails: journeyController.showDetails.value,
//                           ),
//                         ),
//                       ],
//
//
//                       SizedBox(height: AppDimensions.d28.h),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 right: screenWidth * -0.07,
//                 top: screenHeight * 0.50,
//                 child: const CustomHomeNavBar(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// ✅ NEW: Get appropriate container title based on data source
//   String _getContainerTitle(String source) {
//     switch (source) {
//       case 'key_results':
//         return 'selected_key_result'.tr;
//       case 'shared_prefs_strategy':
//         return 'selected_strategy'.tr;
//       case 'shared_prefs_objective':
//         return 'selected_objective'.tr;
//       case 'shared_prefs_user':
//         return 'user_initiatives'.tr;
//       default:
//         return 'current_focus'.tr;
//     }
//   }
//
//   /// ✅ NEW: Build initiative inputs for contextual challenge flow
//   Widget _buildContextualInitiativeInputs() {
//     return Column(
//       children: [
//
//         CustomInitiativeInput(
//           numberText: 'first_initiative'.tr,
//           titleController: viewModel.firstInitiativeTitle,
//           descController: viewModel.firstInitiativeDesc,
//           isEnabled: false, // Make read-only for viewing
//         ),
//         CustomInitiativeInput(
//           numberText: 'second_initiative'.tr,
//           titleController: viewModel.secondInitiativeTitle,
//           descController: viewModel.secondInitiativeDesc,
//           isEnabled: false, // Make read-only for viewing
//         ),
//       ],
//     );
//   }
//
//   // ✅ DYNAMIC HEADER & MESSAGES BASED ON SOURCE
//   String _getHeaderTitle() {
//     if (_isModifyFromContextual) {
//       return 'review'.tr;
//     }
//     return 'suggestion'.tr;
//   }
//
//   String _getHeaderHighlight() {
//     if (_isModifyFromContextual) {
//       return 'initiatives'.tr;
//     }
//     return 'of_initiatives'.tr;
//   }
//
//   // ✅ Get appropriate button text
//   String _getButtonText(bool isSubmitting) {
//     if (isSubmitting) {
//       return 'submitting'.tr;
//     }
//     if (_isModifyFromContextual) {
//       return 'continue_to_adaptation'.tr;
//     }
//     return 'submit_analysis'.tr;
//   }
// // In _handleSubmit method
//   void _handleSubmit(SuggestionInitiativesViewModel viewModel) {
//     if (_isModifyFromContextual) {
//       // For contextual challenge - just navigate to adaptation screen
//       Get.toNamed(AppRoutes.contextualChallenge);
//     } else {
//       // Normal submission flow - mark initiatives step as complete
//       journeyController.completeStep(3);
//       viewModel.submitInitiatives(widget.selectedKeyResults);
//     }
//   }
//
//   /// Get a random key result from the selected ones
//   KeyResult? _getRandomKeyResult() {
//     if (widget.selectedKeyResults.isEmpty) return null;
//
//     // Shuffle the list and take the first one
//     final shuffled = List<KeyResult>.from(widget.selectedKeyResults)..shuffle();
//     final randomKeyResult = shuffled.first;
//
//     print('🎲 Random key result selected: ${randomKeyResult.title}');
//     return randomKeyResult;
//   }
//
//   double _getHorizontalPadding(double screenWidth) {
//     if (screenWidth > 1200) return screenWidth * 0.06;
//     if (screenWidth > 900) return screenWidth * 0.04;
//     if (screenWidth > 600) return screenWidth * 0.03;
//     return screenWidth * 0.02;
//   }
// }
//
// /// ✅ NEW: Data structure to hold display information
// class DisplayData {
//   final String title;
//   final String description;
//   final String source; // 'key_results', 'shared_prefs_strategy', 'shared_prefs_objective', 'default'
//
//   DisplayData({
//     required this.title,
//     required this.description,
//     required this.source,
//   });
// }
//
//
//
