// key_objective_selected_screen.dart

import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/views/key_results/key_results_screen.dart';
import 'package:game_app/utils/snackbar_helper.dart';
import 'package:get/get.dart';

import '../../../controllers/journey_controller.dart';
import '../../../controllers/key_objective_controller.dart';
import '../../../controllers/strategy_selection_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../generated/models/responses/objectives/objectives_response.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/custom_button2.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_industry_container.dart';
import '../../widgets/custom_journey_map.dart';
import '../../widgets/custom_objective_container.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class KeyObjectiveSelectedScreen extends StatefulWidget {
  const KeyObjectiveSelectedScreen({super.key});

  @override
  State<KeyObjectiveSelectedScreen> createState() => _KeyObjectiveSelectedScreenState();
}

class _KeyObjectiveSelectedScreenState extends State<KeyObjectiveSelectedScreen> {
  final TextEditingController searchController = TextEditingController();
  final RxList<Objective> filteredObjectives = RxList<Objective>();
  final KeyObjectiveController controller = Get.find<KeyObjectiveController>();
  final JourneyController journeyController = Get.find<JourneyController>();
  final StrategySelectionController strategyController = Get.find<StrategySelectionController>();

  // Source detection
  final bool _isRetryFromAnalysis = Get.parameters['isRetry'] == 'true';
  final bool _isModifyFromContextual = Get.parameters['source'] == 'contextual_challenge';
  final bool _isNormalFlow = !Get.parameters.containsKey('isRetry') && !Get.parameters.containsKey('source');

  @override
  void initState() {
    super.initState();
    filteredObjectives.assignAll(controller.objectives);

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

      if (_isNormalFlow) {
        final args = Get.arguments as Map<String, dynamic>?;
        final role = args?['selectedRole'];
        final industry = args?['selectedIndustry'];
        final isCampaign = args?['isCampaignMode'] ?? false;
        controller.getObjectives(role, industry);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterObjectives(String query) {
    if (query.isEmpty) {
      filteredObjectives.assignAll(controller.objectives);
    } else {
      filteredObjectives.assignAll(
        controller.objectives.where((obj) {
          final title = (obj.title?.tr ?? '').toLowerCase();
          final desc = (obj.description?.tr ?? '').toLowerCase();
          return title.contains(query.toLowerCase()) || desc.contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  String _getHeaderTitle() => _isRetryFromAnalysis
      ? 'try_again_with_different'.tr
      : _isModifyFromContextual
      ? 'modify'.tr
      : 'choose'.tr;

  String _getHeaderHighlight() => 'objective'.tr;

  String _getSubtitleText() => _isRetryFromAnalysis
      ? 'select_different_objective_retry'.tr
      : _isModifyFromContextual
      ? 'select_new_objective_for_challenge'.tr
      : 'select_one_objective'.tr;

  String _getButtonText() => _isModifyFromContextual ? 'save_changes'.tr : 'complete_selection'.tr;

  void _navigateToNextScreen() {
    if (_isModifyFromContextual) {
      Get.back(result: controller.selectedObjective.value);
      SnackbarHelper.success('Objective updated successfully');
    } else {
      Get.offAndToNamed(AppRoutes.keyResultsScreen);
    }
  }

  Color _getSubtitleColor() => _isRetryFromAnalysis
      ? AppColors.primaryRed
      : _isModifyFromContextual
      ? AppColors.primaryBlue
      : AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 768;

        return isMobile
            ? _buildMobileLayout()
            : _buildDesktopLayout(width);
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100.h),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        _buildHeader(),
                        SizedBox(height: 20.h),
                        _buildStrategyCard(),
                        SizedBox(height: 20.h),
                        _buildTitleSection(),
                        SizedBox(height: 20.h),
                        _buildObjectivesList(),
                        if (!_isModifyFromContextual) ...[
                          SizedBox(height: 30.h),
                          Obx(() => CustomJourneyMap(
                            progress: journeyController.progress.value,
                            steps: journeyController.steps,
                            completedSteps: journeyController.completedSteps,
                            onToggle: journeyController.toggleJourneyDetails,
                            showDetails: journeyController.showDetails.value,
                          )),
                        ],
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),

              // Fixed Bottom Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5)),
                    ],
                  ),
                  child: Obx(() => CustomButton2(
                    text: _getButtonText(),
                    onPressed: controller.isButtonEnabled ? _navigateToNextScreen : null,
                    isLoading: controller.loading.value,
                  )),
                ),
              ),

              // Floating NavBar
              Positioned(
                right: -30.w,
                top: MediaQuery.of(context).size.height * 0.5,
                child: const CustomHomeNavBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(double screenWidth) {
    final containerWidth = screenWidth > 1200 ? 700.0 : screenWidth * 0.75;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(opacity: 0.1, child: Image.asset('assets/images/web_background.png', fit: BoxFit.cover)),
          ),
          // Positioned(top: 0, left: 0, right: 0, child: DesktopAppBar(title: _getHeaderTitle(), subtitle: _getHeaderHighlight())),
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 100,
            child: Center(
              child: Container(
                width: containerWidth,
                padding: EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: Offset(0, 10))],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStrategyCard(),
                      SizedBox(height: 30.h),
                      _buildTitleSection(),
                      SizedBox(height: 30.h),
                      _buildObjectivesList(),
                      SizedBox(height: 40.h),
                      Obx(() => CustomButton2(
                        text: _getButtonText(),
                        onPressed: controller.isButtonEnabled ? _navigateToNextScreen : null,
                        isLoading: controller.loading.value,
                      )),
                      SizedBox(height: 30.h),
                      if (!_isModifyFromContextual)
                        Obx(() => CustomJourneyMap(
                          progress: journeyController.progress.value,
                          steps: journeyController.steps,
                          completedSteps: journeyController.completedSteps,
                          onToggle: journeyController.toggleJourneyDetails,
                          showDetails: journeyController.showDetails.value,
                        )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(bottom: 30, left: 40, child: _buildBackButton()),
          Positioned(bottom: 20, child: Center(child: const CustomHomeNavBar())),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return CustomHeader(
      title: _getHeaderTitle(),
      highlightedText: _getHeaderHighlight(),
      onBackTap: () => Get.back(),
      showDashboardIcon: true,
    );
  }

  Widget _buildStrategyCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() => CustomObjectiveContainer(
        title: 'selected_strategy'.tr,
        subtitle: strategyController.selectedStrategy.value?.title?.tr ?? '—',
        icon: Icons.emoji_objects,
        titleColor: AppColors.primaryRed,
      )),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Text(
            'choose_your_objective'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
          ),
          SizedBox(height: 12.h),
          Text(
            _getSubtitleText(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.sp, color: _getSubtitleColor(), height: 1.5),
          ),
          if (_isRetryFromAnalysis || _isModifyFromContextual) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: (_isRetryFromAnalysis ? AppColors.primaryRed : AppColors.primaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: (_isRetryFromAnalysis ? AppColors.primaryRed : AppColors.primaryBlue).withOpacity(0.3)),
              ),
              child: Text(
                _isRetryFromAnalysis ? 'retry_attempt'.tr : 'adapting_to_challenge'.tr,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _isRetryFromAnalysis ? AppColors.primaryRed : AppColors.primaryBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildObjectivesList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.3), width: 2),
        ),
        child: Obx(() {
          if (controller.loading.value && controller.objectives.isEmpty) {
            return SizedBox(height: 200.h, child: Center(child: CircularProgressIndicator(color: AppColors.primaryRed)));
          }

          if (controller.objectives.isEmpty) {
            return Center(child: Text('no_objectives_available'.tr, style: TextStyle(fontSize: 16.sp)));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredObjectives.length,
            itemBuilder: (context, index) {
              final obj = filteredObjectives[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildObjectiveItem(obj, index),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildObjectiveItem(Objective obj, int index) {
    final icons = [Icons.flag, Icons.star, Icons.rocket_launch, Icons.trending_up, Icons.lightbulb, Icons.bolt];

    return Obx(() {
      final isSelected = controller.isSelected(obj);

      return CustomIndustryContainer(
        title: obj.title?.tr ?? '',
        description: obj.description?.tr ?? '',
        icon: icons[index % icons.length],
        isSelected: isSelected,
        onTap: () {
          controller.selectObjective(obj);
          if (isSelected) journeyController.completeStep(1);
        },
      );
    });
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Icon(Icons.arrow_back_ios_new_rounded, size: 32, color: AppColors.primaryRed),
    );
  }
}
// import 'dart:math' hide log;
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:game_app/presentation/views/key_results/key_results_screen.dart';
// import 'package:game_app/utils/snackbar_helper.dart';
// import 'package:get/get.dart';
// import 'dart:developer';
//
// import '../../../controllers/journey_controller.dart';
// import '../../../controllers/key_objective_controller.dart';
// import '../../../controllers/strategy_selection_controller.dart';
// import '../../../core/app_colors.dart';
// import '../../../core/app_dimensions.dart';
// import '../../../generated/models/responses/objectives/objectives_response.dart';
// import '../../../services/shared_preference.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/Website/desktop_appbar.dart';
// import '../../widgets/custom_button2.dart';
// import '../../widgets/custom_home_navbar.dart';
// import '../../widgets/custom_industry_container.dart';
// import '../../widgets/custom_journey_map.dart';
// import '../../widgets/custom_objective_container.dart';
// import '../../widgets/custom_svg.dart';
// import '../../widgets/screens_unique_parts/custom_background.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
//
// class KeyObjectiveSelectedScreen extends StatefulWidget {
//   const KeyObjectiveSelectedScreen({super.key});
//
//   @override
//   State<KeyObjectiveSelectedScreen> createState() => _KeyObjectiveSelectedScreenState();
// }
//
// class _KeyObjectiveSelectedScreenState extends State<KeyObjectiveSelectedScreen> {
//   final TextEditingController searchController = TextEditingController();
//   final RxList<Objective> filteredObjectives = RxList<Objective>();
//   final KeyObjectiveController controller = Get.find<KeyObjectiveController>();
//   final JourneyController journeyController = Get.find<JourneyController>();
//   final StrategySelectionController strategyController = Get.find<StrategySelectionController>();
//
//   // ✅ Track initialization state and source
//   bool _isInitialized = false;
//   bool _hasShownMessage = false;
//
//   // ✅ Different sources with different behaviors
//   final bool _isRetryFromAnalysis = Get.parameters['isRetry'] == 'true';
//   final bool _isModifyFromContextual = Get.parameters['source'] == 'contextual_challenge';
//   final bool _isNormalFlow = !Get.parameters.containsKey('isRetry') && !Get.parameters.containsKey('source');
//
//   @override
//   void initState() {
//     super.initState();
//
//     print('🎯 Objective Screen Source:');
//     print('   - Retry from Analysis: $_isRetryFromAnalysis');
//     print('   - Modify from Contextual: $_isModifyFromContextual');
//     print('   - Normal Flow: $_isNormalFlow');
//
//     // Initialize filtered objectives
//     filteredObjectives.assignAll(controller.objectives);
//
//     // Use delayed initialization to avoid build phase conflicts
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeScreen();
//     });
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }
//
//   void _initializeScreen() {
//     if (_isInitialized) return;
//
//     _isInitialized = true;
//
//     // Handle different scenarios with appropriate messages
//     if (!_hasShownMessage) {
//       _hasShownMessage = true;
//
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (_isRetryFromAnalysis) {
//           SnackbarHelper.info(
//               'Please select a different objective to improve your initiatives'
//           );
//         } else if (_isModifyFromContextual) {
//           SnackbarHelper.info(
//               'Select a new objective to adapt to the market challenge'
//           );
//         }
//         // No message for normal flow
//       });
//     }
//
//     // Clear previous selection for retry/modify scenarios
//     if (_isRetryFromAnalysis || _isModifyFromContextual) {
//       controller.clearSelection();
//     }
//
//     // Set up objectives listener - safely after build
//     ever(controller.objectives, (_) {
//       if (mounted) {
//         filteredObjectives.assignAll(controller.objectives);
//         if (searchController.text.isNotEmpty) {
//           filterObjectives(searchController.text);
//         }
//       }
//     });
//
//     // Load objectives if needed
//     _loadObjectivesIfNeeded();
//   }
//
//   void _loadObjectivesIfNeeded() {
//     final args = Get.arguments as Map<String, dynamic>?;
//     final selectedRole = args?['selectedRole'] as Map<String, dynamic>?;
//     final selectedIndustry = args?['selectedIndustry'] as Map<String, dynamic>?;
//     final isCampaignMode = args?['isCampaignMode'] as bool? ?? false;
//
//     // ✅ ONLY FETCH FOR NORMAL FLOW (from strategy screen)
//     if (_isNormalFlow) {
//       print('🔄 Normal flow detected - Fetching fresh objectives from API');
//       _fetchObjectives(selectedRole, selectedIndustry, isCampaignMode);
//       return;
//     }
//
//     // ✅ FOR RETRY/MODIFY - Use existing objectives
//     if (_isRetryFromAnalysis || _isModifyFromContextual) {
//       if (controller.objectives.isNotEmpty) {
//         print('♻️ Reusing existing ${controller.objectives.length} objectives for ${_isRetryFromAnalysis ? "retry" : "modify"} scenario');
//         filteredObjectives.assignAll(controller.objectives);
//         return;
//       } else {
//         // Fallback: If somehow objectives are empty, fetch them
//         print('⚠️ No existing objectives found, fetching as fallback...');
//         _fetchObjectives(selectedRole, selectedIndustry, isCampaignMode);
//       }
//     }
//   }
//
//   Future<void> _fetchObjectives(
//       Map<String, dynamic>? selectedRole,
//       Map<String, dynamic>? selectedIndustry,
//       bool isCampaignMode,
//       ) async {
//     try {
//       // Show loading message only for normal flow
//       if (_isNormalFlow) {
//         print('📥 Fetching objectives from API...');
//       }
//
//       if (isCampaignMode) {
//         if (selectedRole != null && selectedIndustry != null) {
//           await controller.getObjectives(selectedRole, selectedIndustry);
//           print('✅ Campaign objectives loaded: ${controller.objectives.length}');
//         } else {
//           SnackbarHelper.error('Missing campaign data. Please restart the campaign.');
//         }
//       } else {
//         if (selectedRole != null && selectedIndustry != null) {
//           await controller.getObjectives(selectedRole, selectedIndustry);
//           print('✅ Solo objectives loaded: ${controller.objectives.length}');
//         } else {
//           SnackbarHelper.error('Please select both a role and an industry.');
//           await Future.delayed(const Duration(seconds: 1));
//           Get.offAllNamed(AppRoutes.selectStrategy, arguments: {
//             'selectedRole': selectedRole,
//             'selectedIndustry': selectedIndustry,
//             'isCampaignMode': isCampaignMode,
//           });
//         }
//       }
//     } catch (e) {
//       print('❌ Error fetching objectives: $e');
//       SnackbarHelper.error('Failed to load objectives');
//     }
//   }
//
//   String _safeTranslate(String? key, {String fallback = ''}) {
//     if (key == null) return fallback;
//     try {
//       return key.tr;
//     } catch (e) {
//       return fallback;
//     }
//   }
//
//   void filterObjectives(String query) {
//     if (!mounted) return;
//
//     if (query.isEmpty) {
//       filteredObjectives.assignAll(controller.objectives);
//     } else {
//       filteredObjectives.assignAll(
//         controller.objectives.where((obj) {
//           final translatedTitle = obj.title?.tr ?? '';
//           final translatedDescription = obj.description?.tr ?? '';
//           return translatedTitle.toLowerCase().contains(query.toLowerCase()) ||
//               translatedDescription.toLowerCase().contains(query.toLowerCase());
//         }).toList(),
//       );
//     }
//   }
//
//   String _getStrategyDisplayText() {
//     final strategy = strategyController.selectedStrategy.value;
//     if (strategy == null) {
//       return 'No strategy selected'.tr;
//     }
//     return strategy.title ?? 'Unknown Strategy';
//   }
//
//   // ✅ DYNAMIC HEADER & MESSAGES BASED ON SOURCE
//   String _getHeaderTitle() {
//     if (_isRetryFromAnalysis) {
//       return 'try_again_with_different'.tr;
//     } else if (_isModifyFromContextual) {
//       return 'modify'.tr;
//     }
//     return 'choose'.tr;
//   }
//
//   String _getHeaderHighlight() {
//     if (_isRetryFromAnalysis) {
//       return 'objective'.tr;
//     } else if (_isModifyFromContextual) {
//       return 'objective'.tr;
//     }
//     return 'objective'.tr;
//   }
//
//   String _getSubtitleText() {
//     if (_isRetryFromAnalysis) {
//       return 'select_different_objective_retry'.tr;
//     } else if (_isModifyFromContextual) {
//       return 'select_new_objective_for_challenge'.tr;
//     }
//     return 'select_one_objective'.tr;
//   }
//
//   // ✅ Get appropriate button text
//   String _getButtonText() {
//     if (_isModifyFromContextual) {
//       return 'save_changes'.tr;
//     }
//     return 'complete_selection'.tr;
//   }
//
//   // ✅ Get navigation destination - FIXED NAVIGATION
//   void _navigateToNextScreen() {
//     if (_isModifyFromContextual) {
//       // Return to contextual challenge screen with updated objective
//       Get.back(result: controller.selectedObjective.value);
//       SnackbarHelper.success('Objective updated successfully');
//     } else {
//       // Normal flow - go to key results
//       Get.offAllNamed(AppRoutes.keyResultsScreen);
//     }
//   }
//
//   // ✅ Helper methods for dynamic styling
//   Color _getSubtitleColor() {
//     if (_isRetryFromAnalysis) return AppColors.primaryRed;
//     if (_isModifyFromContextual) return AppColors.primaryBlue;
//     return AppColors.textSecondary;
//   }
//
//   FontWeight _getSubtitleFontWeight() {
//     if (_isRetryFromAnalysis || _isModifyFromContextual) return FontWeight.w600;
//     return FontWeight.normal;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double screenWidth = constraints.maxWidth;
//         final double screenHeight = constraints.maxHeight;
//
//         final bool isMobile = screenWidth < 768;
//         final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
//         final bool isDesktop = screenWidth >= 1024;
//
//         // Responsive font helpers
//         double headerFont(double mobile, double tablet, double desktop) =>
//             isMobile ? mobile : isTablet ? tablet : desktop;
//         double bodyFont(double mobile, double tablet, double desktop) =>
//             isMobile ? mobile : isTablet ? tablet : desktop;
//         double buttonFont(double mobile, double tablet, double desktop) =>
//             isMobile ? mobile : isTablet ? tablet : desktop;
//
//         double containerPadding() => isMobile ? 20 : isTablet ? 30 : 40;
//         double containerWidth() => isMobile
//             ? screenWidth * 0.9
//             : isTablet
//             ? screenWidth * 0.7
//             : 600;
//
//         if (isMobile) {
//           return _buildMobileLayout(
//             context, headerFont, bodyFont, buttonFont, isTablet, isDesktop,
//           );
//         } else {
//           return _buildDesktopWebLayout(
//             context, headerFont, bodyFont, buttonFont,
//             containerPadding(), containerWidth(), isTablet, isDesktop,
//           );
//         }
//       },
//     );
//   }
//
//   /// ----------------- Mobile Layout -----------------
//   Widget _buildMobileLayout(
//       BuildContext context,
//       double Function(double, double, double) headerFont,
//       double Function(double, double, double) bodyFont,
//       double Function(double, double, double) buttonFont,
//       bool isTablet,
//       bool isDesktop,
//       ) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       body: CustomBackground(
//         child: SafeArea(
//           child: Stack(
//             children: [
//               /// Scrollable Content
//               Positioned.fill(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.only(
//                       bottom: _getResponsiveSpacing(screenHeight, 0.12),
//                     ),
//                     child: Column(
//                       children: [
//                         SizedBox(height: screenHeight * 0.03),
//
//                         /// Custom Header
//                         _buildMobileHeader(),
//
//                         SizedBox(height: screenHeight * 0.02),
//
//                         /// Selected Strategy Container
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: _getHorizontalPadding(screenWidth),
//                           ),
//                           child: Obx(() {
//                             return CustomObjectiveContainer(
//                               title: _safeTranslate('selected_strategy'),
//                               subtitle: _getStrategyDisplayText(),
//                               icon: Icons.emoji_objects,
//                               titleColor: AppColors.primaryRed,
//                             );
//                           }),
//                         ),
//
//                         SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
//
//                         /// Title and subtitle section
//                         _buildTitleSection(screenWidth, screenHeight, isTablet, isDesktop),
//
//                         SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
//
//                         /// Objectives List
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: _getContentPadding(screenWidth, isTablet),
//                           ),
//                           child: _buildObjectivesContent(),
//                         ),
//
//                         SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
//
//                         /// Journey Map (hide for modification flow)
//                         if (!_isModifyFromContextual) ...[
//                           Obx(() => CustomJourneyMap(
//                             progress: journeyController.progress.value,
//                             steps: journeyController.steps,
//                             completedSteps: journeyController.completedSteps,
//                             onToggle: journeyController.toggleJourneyDetails,
//                             showDetails: journeyController.showDetails.value,
//                           )),
//                           SizedBox(height: _getResponsiveSpacing(screenHeight, 0.03)),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               /// Fixed Button at Bottom
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   width: screenWidth,
//                   padding: EdgeInsets.all(16.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         spreadRadius: 2,
//                         offset: const Offset(0, -5),
//                       ),
//                     ],
//                   ),
//                   child: Obx(() {
//                     print('🎯 BUTTON DEBUG - Mobile:');
//                     print('   isButtonEnabled: ${controller.isButtonEnabled}');
//                     print('   selectedObjective: ${controller.selectedObjective.value != null}');
//                     print('   loading: ${controller.loading.value}');
//
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Debug info
//                         Container(
//                           padding: EdgeInsets.all(8),
//                           margin: EdgeInsets.only(bottom: 10),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 controller.isButtonEnabled ? Icons.check_circle : Icons.error,
//                                 color: controller.isButtonEnabled ? Colors.green : Colors.orange,
//                                 size: 16,
//                               ),
//                               SizedBox(width: 8),
//                               Text(
//                                 'Button enabled: ${controller.isButtonEnabled}',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: controller.isButtonEnabled ? Colors.green : Colors.orange,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Button
//                         CustomButton2(
//                           text: _getButtonText(),
//                           onPressed: controller.isButtonEnabled
//                               ? () {
//                             print('🚀 NAVIGATING TO KEY RESULTS');
//                             _navigateToNextScreen();
//                           }
//                               : null,
//                         ),
//                       ],
//                     );
//                   }),
//                 ),
//               ),
//
//               /// Floating Navigation Bar
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
//   /// ----------------- Desktop/Web Layout -----------------
//   Widget _buildDesktopWebLayout(
//       BuildContext context,
//       double Function(double, double, double) headerFont,
//       double Function(double, double, double) bodyFont,
//       double Function(double, double, double) buttonFont,
//       double padding,
//       double containerWidth,
//       bool isTablet,
//       bool isDesktop,
//       ) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           /// Background Image
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
//           /// Desktop App Bar
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: DesktopAppBar(
//               screenWidth: screenWidth,
//               screenHeight: screenHeight,
//               title: _getHeaderTitle(),
//               subtitle: _getHeaderHighlight(),
//             ),
//           ),
//
//           /// Scrollable Content Container
//           Positioned(
//             top: 120,
//             left: 0,
//             right: 0,
//             bottom: 100,
//             child: Center(
//               child: Container(
//                 width: containerWidth,
//                 constraints: BoxConstraints(
//                   maxHeight: screenHeight * 0.8,
//                 ),
//                 padding: EdgeInsets.all(padding),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 20,
//                       spreadRadius: 5,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(height: screenHeight * 0.03),
//
//                       /// Selected Strategy Container
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: _getHorizontalPadding(screenWidth),
//                         ),
//                         child: Obx(() {
//                           return CustomObjectiveContainer(
//                             title: _safeTranslate('selected_strategy'),
//                             subtitle: _getStrategyDisplayText(),
//                             icon: Icons.emoji_objects,
//                             titleColor: AppColors.primaryRed,
//                           );
//                         }),
//                       ),
//
//                       SizedBox(height: _getResponsiveSpacing(screenHeight, 0.025)),
//
//                       /// Title and subtitle section
//                       _buildTitleSection(screenWidth, screenHeight, isTablet, isDesktop),
//
//                       SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
//
//
//                       /// Objectives List
//                       SizedBox(height: 50.h,),
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: _getContentPadding(screenWidth, isTablet),
//                         ),
//                         child: _buildObjectivesContent(),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 18.0),
//                         child: CustomButton2(
//                           text: _getButtonText(),
//                           onPressed: controller.isButtonEnabled
//                               ? () {
//                             print('🚀 NAVIGATING TO KEY RESULTS');
//                             _navigateToNextScreen();
//                           }
//                               : null,
//                         ),
//                       ),
//                       SizedBox(height: 30.h,),
//                       SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
//
//                       /// Journey Map (hide for modification flow)
//                       if (!_isModifyFromContextual) ...[
//                         Obx(() => CustomJourneyMap(
//                           progress: journeyController.progress.value,
//                           steps: journeyController.steps,
//                           completedSteps: journeyController.completedSteps,
//                           onToggle: journeyController.toggleJourneyDetails,
//                           showDetails: journeyController.showDetails.value,
//                         )),
//                         SizedBox(height: _getResponsiveSpacing(screenHeight, 0.02)),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           /// Fixed Button at Bottom
//           Positioned(
//             bottom: 20,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 width: containerWidth,
//                 padding: EdgeInsets.symmetric(horizontal: padding),
//                 child: Obx(() {
//                   print('🎯 BUTTON DEBUG - Desktop:');
//                   print('   isButtonEnabled: ${controller.isButtonEnabled}');
//                   print('   selectedObjective: ${controller.selectedObjective.value != null}');
//                   print('   loading: ${controller.loading.value}');
//
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//
//
//
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//
//           /// Back Button
//           Positioned(
//             bottom: 20,
//             left: 20,
//             child: GestureDetector(
//               onTap: () {
//                 final args = Get.arguments as Map<String, dynamic>?;
//
//                 if (_isModifyFromContextual) {
//                   // Just go back to contextual challenge
//                   Get.back();
//                 } else {
//                   // Normal navigation back
//                   Get.offAllNamed(
//                     AppRoutes.selectStrategy,
//                     arguments: {
//                       'selectedRole': args?['selectedRole'],
//                       'selectedIndustry': args?['selectedIndustry'],
//                       'isCampaignMode': args?['isCampaignMode'] ?? false,
//                     },
//                   );
//                 }
//               },
//               child: CustomSvg(
//                 assetPath: 'assets/images/left.svg',
//                 semanticsLabel: '',
//               ),
//             ),
//           ),
//
//           /// Home Navbar
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
//   // ✅ Build mobile header
//   Widget _buildMobileHeader() {
//     return CustomHeader(
//       title: _getHeaderTitle(),
//       highlightedText: _getHeaderHighlight(),
//       onBackTap: () {
//         final args = Get.arguments as Map<String, dynamic>?;
//
//         if (_isModifyFromContextual) {
//           // Just go back to contextual challenge
//           Get.back();
//         } else {
//           // Normal navigation back
//           Get.offAllNamed(
//             AppRoutes.selectStrategy,
//             arguments: {
//               'selectedRole': args?['selectedRole'],
//               'selectedIndustry': args?['selectedIndustry'],
//               'isCampaignMode': args?['isCampaignMode'] ?? false,
//             },
//           );
//         }
//       },
//       showDashboardIcon: true,
//     );
//   }
//
//   // ✅ Build title section with dynamic content
//   Widget _buildTitleSection(double screenWidth, double screenHeight, bool isTablet, bool isDesktop) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: _getHorizontalPadding(screenWidth),
//       ),
//       child: Column(
//         children: [
//           Text(
//             _safeTranslate('choose_your_objective'),
//             style: TextStyle(
//               fontSize: _getTitleFontSize(screenWidth, isTablet, isDesktop),
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryRed,
//               fontFamily: 'GothamBold',
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: screenHeight * 0.01),
//           Text(
//             _getSubtitleText(),
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: _getSubtitleFontSize(screenWidth, isTablet, isDesktop),
//               color: _getSubtitleColor(),
//               fontFamily: 'Gotham',
//               height: 1.4,
//               fontWeight: _getSubtitleFontWeight(),
//             ),
//           ),
//
//           // ✅ SHOW DIFFERENT BADGES BASED ON SOURCE
//           if (_isRetryFromAnalysis) ...[
//             SizedBox(height: screenHeight * 0.01),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryRed.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8.r),
//                 border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
//               ),
//               child: Text(
//                 'retry_attempt'.tr,
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: AppColors.primaryRed,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ] else if (_isModifyFromContextual) ...[
//             SizedBox(height: screenHeight * 0.01),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryBlue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8.r),
//                 border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
//               ),
//               child: Text(
//                 'adapting_to_challenge'.tr,
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: AppColors.primaryBlue,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ✅ SAFE: Build objectives content without nested reactive calls
//   Widget _buildObjectivesContent() {
//     return Obx(() {
//       // Show loader when fetching objectives for normal flow
//       if (controller.loading.value && _isNormalFlow) {
//         return Container(
//           height: 200.h,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(
//                   color: AppColors.primaryRed,
//                 ),
//                 SizedBox(height: 16.h),
//                 Text(
//                   'Choosing Objectives for You...',
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 6.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }
//
//       if (controller.loading.value && controller.objectives.isEmpty) {
//         return const Center(child: CircularProgressIndicator());
//       }
//
//       if (controller.objectives.isEmpty) {
//         return Center(
//           child: Text(
//             'No objectives available',
//             style: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 16.sp,
//             ),
//           ),
//         );
//       }
//
//       return _buildObjectivesList(
//         MediaQuery.of(Get.context!).size.width,
//       );
//     });
//   }
//
//   // ✅ Build objectives list with ListView
//   Widget _buildObjectivesList(double screenWidth) {
//     final maxWidth = screenWidth > 1200 ? 1200.0 : screenWidth;
//
//     return Container(
//         constraints: BoxConstraints(maxWidth: maxWidth),
//         child: Column(
//           children: [
//             SizedBox(height: 2.h),
//             Container(
//               decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12.r),
//                   border: Border.all(color: AppColors.primaryRed, width: 2.w)
//               ),
//               constraints: BoxConstraints(maxHeight: 400.h),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Obx(() => ListView.builder(
//                   shrinkWrap: true,
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   padding: EdgeInsets.only(bottom: 8.h),
//                   itemCount: filteredObjectives.length,
//                   itemBuilder: (context, index) => Padding(
//                     padding: EdgeInsets.only(bottom: 8.h),
//                     child: _buildObjectiveItem(index),
//                   ),
//                 )),
//               ),
//             ),
//           ],
//         )
//     );
//   }
//
//   IconData _getObjectiveIcon(int index) {
//     final icons = [
//       Icons.flag,
//       Icons.star,
//       Icons.rocket_launch,
//       Icons.trending_up,
//       Icons.lightbulb,
//       Icons.auto_awesome,
//       Icons.bolt,
//       Icons.workspace_premium,
//       Icons.emoji_events,
//       Icons.assignment_turned_in,
//     ];
//     return icons[index % icons.length];
//   }
//
//   Widget _buildObjectiveItem(int index) {
//     final obj = filteredObjectives[index];
//     final titleKey = obj.title;
//     final descriptionKey = obj.description;
//
//     return Obx(() {
//       final isSelected = controller.isSelected(obj);
//
//       print('🎯 Objective Item $index: isSelected = $isSelected');
//
//       return Container(
//         margin: EdgeInsets.only(bottom: 2.h),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? AppColors.primaryRed : Colors.transparent,
//             width: isSelected ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: CustomIndustryContainer(
//           title: _safeTranslate(titleKey, fallback: 'Title'),
//           description: _safeTranslate(descriptionKey, fallback: 'Available'),
//           icon: _getObjectiveIcon(index),
//           isSelected: isSelected,
//           onTap: () {
//             print('🟢 Tapping objective $index: ${obj.title}');
//             controller.selectObjective(obj);
//
//             if (controller.isSelected(obj)) {
//               print('✅ Objective selected: ${obj.title}');
//               journeyController.completeStep(1);
//             } else {
//               print('❌ Objective deselected');
//               journeyController.uncompleteStep(1);
//             }
//           },
//         ),
//       );
//     });
//   }
//
//   // Responsive helper methods
//   double _getResponsiveSpacing(double dimension, double factor) => dimension * factor;
//
//   double _getHorizontalPadding(double screenWidth) {
//     if (screenWidth > 1200) return screenWidth * 0.08;
//     if (screenWidth > 900) return screenWidth * 0.06;
//     if (screenWidth > 600) return screenWidth * 0.05;
//     return screenWidth * 0.04;
//   }
//
//   double _getContentPadding(double screenWidth, bool isTablet) =>
//       isTablet ? screenWidth * 0.07 : screenWidth * 0.03;
//
//   double _getButtonPadding(double screenWidth, bool isTablet, bool isDesktop) {
//     if (isDesktop) return screenWidth * 0.25;
//     if (isTablet) return screenWidth * 0.15;
//     return screenWidth * 0.1;
//   }
//
//   double _getTitleFontSize(double screenWidth, bool isTablet, bool isDesktop) {
//     if (isDesktop) return (screenWidth * 0.005).sp;
//     if (isTablet) return (screenWidth * 0.04).sp;
//     return (screenWidth * 0.055).sp;
//   }
//
//   double _getSubtitleFontSize(double screenWidth, bool isTablet, bool isDesktop) {
//     if (isDesktop) return (screenWidth * 0.002).sp;
//     if (isTablet) return (screenWidth * 0.026).sp;
//     return (screenWidth * 0.038).sp;
//   }
// }