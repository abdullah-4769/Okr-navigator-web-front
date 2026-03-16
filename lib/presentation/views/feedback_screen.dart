import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:game_app/generated/models/responses/key_results/key_results_response.dart'
as key_result_models;
import '../../generated/models/requests/campaign_mode/feedback_evaluation_model.dart';
import '../../services/shared_preference.dart';
import '../../view_model/bonus_score.dart';
import '../../view_model/campaign_mode/feedback_evaluation_view_model.dart';
import '../widgets/Website/desktop_appbar.dart';
import '../widgets/campaign_progress_service.dart';
import '../widgets/custom_button2.dart';
import '../widgets/custom_home_navbar.dart';
import '../widgets/custom_svg.dart';
import '../widgets/game_complete_widgets/custom_score_card.dart';
import '../widgets/screens_unique_parts/custom_background.dart';
import '../widgets/screens_unique_parts/custom_header.dart';
import 'suggestion_Initiatives/suggestion_initiatives_creen.dart';

// ─── Adaptive helpers ────────────────────────────────────────────────────────
double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
  if (sw >= 1024) return desktop ?? tablet ?? mobile;
  if (sw >= 768)  return tablet  ?? mobile;
  return mobile.sp;
}
double _d(double sw, double v)  => sw >= 768 ? v : v.w;
double _dh(double sw, double v) => sw >= 768 ? v : v.h;

class FeedbackScreen extends StatelessWidget {
  final List<key_result_models.KeyResult> selectedKeyResults;

  const FeedbackScreen({super.key, required this.selectedKeyResults});

  @override
  Widget build(BuildContext context) {
    final viewModel       = Get.put(FeedbackEvaluationViewModel());
    final bonusController = Get.put(BonusScoreController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      viewModel.evaluateSelectedKeyResults(selectedKeyResults);
      final shouldSubmitBonus = await bonusController.shouldSubmitBonusScore();
      if (shouldSubmitBonus) {
        print('🎯 Bonus mode detected - will submit bonus score after evaluation');
      }
    });

    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    if (sw >= 768) return _buildDesktopLayout(context, sw, sh, viewModel, bonusController);
    return _buildMobileLayout(context, sw, sh, viewModel, bonusController);
  }

  // ==========================================================================
  // MOBILE LAYOUT — unchanged from original
  // ==========================================================================
  Widget _buildMobileLayout(
      BuildContext context,
      double sw,
      double sh,
      FeedbackEvaluationViewModel viewModel,
      BonusScoreController bonusController,
      ) {
    return Scaffold(
      body: CustomBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 14.w),
                child: _buildContent(sw, sh, viewModel, bonusController),
              ),
            ),
            Positioned(
              right: sw * -0.07,
              top:   sh * 0.50,
              child: OverflowBox(
                alignment: Alignment.centerRight,
                maxWidth: double.infinity,
                child: const CustomHomeNavBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT — matches established web pattern exactly
  // ==========================================================================
  Widget _buildDesktopLayout(
      BuildContext context,
      double sw,
      double sh,
      FeedbackEvaluationViewModel viewModel,
      BonusScoreController bonusController,
      ) {
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
              title:    'okr'.tr,
              subtitle: 'feedback'.tr,
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
                  child: _buildContent(sw, sh, viewModel, bonusController),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
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
  // SHARED CONTENT — all original logic preserved exactly
  // ==========================================================================
  Widget _buildContent(
      double sw,
      double sh,
      FeedbackEvaluationViewModel viewModel,
      BonusScoreController bonusController,
      ) {
    return Column(
      children: [
        SizedBox(height: sw >= 768 ? 12.0 : 14.w),
        //
        // CustomHeader(
        //   title:           'okr'.tr,
        //   highlightedText: 'feedback'.tr,
        //   onBackTap:       () => Get.back(),
        // ),

        SizedBox(height: sw >= 768 ? 20.0 : 20.h),

        Obx(() {
          if (viewModel.isLoadingData) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: sw >= 768 ? 80.0 : 100.h),
                child: const CircularProgressIndicator(),
              ),
            );
          }

          if (!viewModel.hasData) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: sw >= 768 ? 80.0 : 100.h),
                child: Text('no_feedback_data_available'.tr),
              ),
            );
          }

          final feedback = viewModel.evaluationResult!;

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final shouldSubmit = await bonusController.shouldSubmitBonusScore();
            if (shouldSubmit && !bonusController.isLoading.value) {
              _submitBonusScore(bonusController, feedback);
            }
          });

          return Column(
            children: [
              // Bonus mode indicator — exact from original
              Obx(() {
                if (bonusController.isLoading.value) {
                  return _bonusBanner(sw, [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width:  sw >= 768 ? 16.0 : 16.w,
                          height: sw >= 768 ? 16.0 : 16.h,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        ),
                        SizedBox(width: sw >= 768 ? 8.0 : 8.w),
                        Text('submitting_bonus_score'.tr,
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: _fs(sw, 14, desktop: 14))),
                      ],
                    ),
                  );
                }

                if (bonusController.hasSubmittedBonus.value) {
                  return _bonusBanner(sw, [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stars, color: Colors.white,
                            size: sw >= 768 ? 20.0 : 20.sp),
                        SizedBox(width: sw >= 768 ? 8.0 : 8.w),
                        Text(
                          'bonus_score_submitted'
                              .trParams({'score': feedback.overallScore.toString()}),
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: _fs(sw, 14, desktop: 14)),
                        ),
                      ],
                    ),
                  );
                }

                return FutureBuilder<bool>(
                  future: bonusController.isBonusMode(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true &&
                        !bonusController.hasSubmittedBonus.value) {
                      return _bonusBanner(sw, [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.stars, color: Colors.white,
                                size: sw >= 768 ? 20.0 : 20.sp),
                            SizedBox(width: sw >= 768 ? 8.0 : 8.w),
                            Text('bonus_mode_active'.tr,
                                style: TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _fs(sw, 14, desktop: 14))),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }),

              CustomScoreCard(
                title:          '',
                score:          feedback.overallScore,
                showBackground: false,
              ),

              SizedBox(height: sw >= 768 ? 4.0 : 4.h),

              Padding(
                padding: EdgeInsets.all(sw >= 768 ? 8.0 : 8.w),
                child: _buildScoreBreakdown(feedback, sw),
              ),

              SizedBox(height: sw >= 768 ? 4.0 : 4.h),

              Padding(
                padding: EdgeInsets.all(sw >= 768 ? 12.0 : 12.w),
                child: _buildFeedbackCard(feedback, sw),
              ),

              SizedBox(height: sw >= 768 ? 24.0 : 24.h),

              Padding(
                padding: EdgeInsets.all(sw >= 768 ? 16.0 : 16.w),
                child: CustomButton2(
                  text:      'continue'.tr,
                  onPressed: () => _navigateBasedOnGameMode(),
                ),
              ),

              SizedBox(height: sw >= 768 ? 20.0 : 20.h),
            ],
          );
        }),
      ],
    );
  }

  // ── Bonus banner helper ───────────────────────────────────────────────────
  Widget _bonusBanner(double sw, List<Color> colors, {required Widget child}) =>
      Container(
        margin: EdgeInsets.symmetric(
            horizontal: sw >= 768 ? 16.0 : 16.w,
            vertical:   sw >= 768 ? 8.0  : 8.h),
        padding: EdgeInsets.all(sw >= 768 ? 12.0 : 12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(sw >= 768 ? 12.0 : 12.r),
        ),
        child: child,
      );

  // ── All original helper methods — exact copy ──────────────────────────────
  void _submitBonusScore(BonusScoreController bonusController,
      FeedbackEvaluationModel feedback) async {
    try {
      final breakdown = feedback.breakdown;

      final strategyScore30 = (breakdown.strategyAlignment.score * 30 / 30).round();
      final objectiveScore30 = (breakdown.objectiveAlignment.score * 30 / 30).round();
      final keyResultScore30 = (breakdown.keyResultQuality.score * 30 / 40).round();
      final overallScore30 =
      ((strategyScore30 + objectiveScore30 + keyResultScore30) * 30 / 90).round();

      final normalizedScore = '$overallScore30/30';
      String points;
      if (overallScore30 >= 25)      points = "3/3";
      else if (overallScore30 >= 20) points = "2/3";
      else                           points = "1/3";

      String title;
      if (overallScore30 >= 27)      title = "Perfect".tr;
      else if (overallScore30 >= 24) title = "Excellent".tr;
      else if (overallScore30 >= 21) title = "Good".tr;
      else if (overallScore30 >= 18) title = "Average".tr;
      else                           title = "Needs Improvement".tr;

      await bonusController.submitBonusScore(
        overallScore: overallScore30,
        normalizedScore: normalizedScore,
        points: points,
        title:  title,
        feedback: feedback.feedback,
        strategyAlignmentTitle:      breakdown.strategyAlignment.title,
        strategyAlignmentScore:      strategyScore30,
        strategyAlignmentSuggestion: breakdown.strategyAlignment.suggestion,
        objectiveAlignmentTitle:      breakdown.objectiveAlignment.title,
        objectiveAlignmentScore:      objectiveScore30,
        objectiveAlignmentSuggestion: breakdown.objectiveAlignment.suggestion,
        keyResultQualityTitle:       breakdown.keyResultQuality.title,
        keyResultQualityScore:       keyResultScore30,
        keyResultQualitySuggestion:  breakdown.keyResultQuality.suggestion,
      );
    } catch (e) { print('❌ Error in bonus score submission: $e'); }
  }

  void _markLevelComplete() async {
    try {
      final savedMode = await SharedPrefs.getGameModeAsync();
      if (savedMode == 'campaign') {
        final currentLevelStr =
            SharedPrefs.getString('current_campaign_level') ?? '1';
        final currentLevel = int.tryParse(currentLevelStr) ?? 1;
        await CampaignProgressService.completeLevel(currentLevel);
        Get.snackbar(
          "Level Completed!".tr,
          "Organization ${currentLevel == 1 ? 'A' : currentLevel == 2 ? 'B' : 'C'} completed!".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) { print('❌ Error marking level complete: $e'); }
  }
  void _navigateBasedOnGameMode() async {
    try {
      final savedMode = await SharedPrefs.getGameModeAsync();

      if (savedMode == 'campaign') _markLevelComplete();

      if (savedMode == 'bonus') {
        Get.snackbar(
          "bonus_mode_completed".tr,
          "bonus_mode_completion_message".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFD700),
          colorText: Colors.black,
          duration: const Duration(seconds: 3),
        );
        Future.delayed(const Duration(seconds: 2),
                () => Get.offAllNamed(AppRoutes.home));
        return;
      }

      // ✅ Save key results to SharedPrefs BEFORE navigating
      final json = jsonEncode(selectedKeyResults.map((kr) => {
        'id': kr.id,
        'title': kr.title,
        'description': kr.description,
      }).toList());
      await SharedPrefs.saveString('selected_key_results', json);

      switch (savedMode) {
        case 'solo':
        case 'challenge':
          Get.to(() => SuggestionInitiativesScreen(
            selectedKeyResults: selectedKeyResults,
          ));
          break;
        case 'campaign':
          Get.offAllNamed(AppRoutes.campaignModeScreen);
          break;
        default:
          Get.to(() => SuggestionInitiativesScreen(
            selectedKeyResults: selectedKeyResults,
          ));
          break;
      }
    } catch (_) {
      Get.to(() => SuggestionInitiativesScreen(
        selectedKeyResults: selectedKeyResults,
      ));
    }
  }

  Widget _buildScoreBreakdown(FeedbackEvaluationModel feedback, double sw) {
    final breakdown      = feedback.breakdown;
    final normalizedScore = feedback.normalizedScore;

    final scores = [
      {'score': '${breakdown.strategyAlignment.score}/30', 'label': 'strategy_alignment'.tr},
      {'score': '${breakdown.objectiveAlignment.score}/30', 'label': 'objective_alignment'.tr},
      {'score': '${breakdown.keyResultQuality.score}/40',  'label': 'key_result_quality'.tr},
    ];

    return Column(
      children: [
        Text(
          'score'.tr.replaceFirst('${0}', normalizedScore.toString()),
          style: TextStyle(
            fontFamily: 'GothamBold',
            fontSize:   _fs(sw, 18, desktop: 18),
            fontWeight: FontWeight.bold,
            color:      const Color(0xFF1E3A8A),
          ),
        ),
        SizedBox(height: sw >= 768 ? 12.0 : 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: scores.map((item) => Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: sw >= 768 ? 4.0 : 4.w),
              padding: EdgeInsets.symmetric(
                  vertical:   sw >= 768 ? 16.0 : 16.h,
                  horizontal: sw >= 768 ? 4.0  : 4.w),
              decoration: BoxDecoration(
                color:        const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(sw >= 768 ? 16.0 : 16.r),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['score']!,
                      style: TextStyle(
                          fontFamily: 'GothamBold',
                          fontSize:   _fs(sw, 18, desktop: 16),
                          fontWeight: FontWeight.bold,
                          color:      const Color(0xFF1E3A8A))),
                  SizedBox(height: sw >= 768 ? 6.0 : 6.h),
                  Text(item['label']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Gotham',
                          fontSize: _fs(sw, 9, desktop: 10),
                          color:    Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(FeedbackEvaluationModel feedback, double sw) {
    final breakdown = feedback.breakdown;

    return Container(
      padding: EdgeInsets.all(sw >= 768 ? 20.0 : 20.w),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(sw >= 768 ? 20.0 : 20.r),
        border: Border.all(color: const Color(0xFFCC4A2E), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(sw >= 768 ? 8.0 : 8.w),
                decoration: const BoxDecoration(
                    color: Color(0xFFCC4A2E), shape: BoxShape.circle),
                child: Icon(Icons.thumb_up, color: Colors.white,
                    size: sw >= 768 ? 20.0 : 20.sp),
              ),
              SizedBox(width: sw >= 768 ? 8.0 : 8.w),
              Text('okr_evaluation_feedback'.tr,
                  style: TextStyle(
                      fontFamily: 'GothamBold',
                      fontSize:   _fs(sw, 16, desktop: 15),
                      fontWeight: FontWeight.bold,
                      color:      const Color(0xFF1E3A8A))),
            ],
          ),
          SizedBox(height: sw >= 768 ? 20.0 : 20.h),
          Text(feedback.feedback.tr,
              style: TextStyle(
                  fontFamily: 'Gotham',
                  fontSize: _fs(sw, 14, desktop: 14),
                  color:    Colors.black54,
                  height:   1.5)),
          SizedBox(height: sw >= 768 ? 20.0 : 20.h),
          _buildFeedbackItem(
            title: 'strategy_alignment'.tr,
            rating: breakdown.strategyAlignment.title.tr,
            ratingColor: _getRatingColor(breakdown.strategyAlignment.title),
            description: breakdown.strategyAlignment.suggestion,
            sw: sw,
          ),
          SizedBox(height: sw >= 768 ? 16.0 : 16.h),
          _buildFeedbackItem(
            title: 'objective_alignment'.tr,
            rating: breakdown.objectiveAlignment.title,
            ratingColor: _getRatingColor(breakdown.objectiveAlignment.title),
            description: breakdown.objectiveAlignment.suggestion,
            sw: sw,
          ),
          SizedBox(height: sw >= 768 ? 16.0 : 16.h),
          _buildFeedbackItem(
            title: 'key_result_quality'.tr,
            rating: breakdown.keyResultQuality.title,
            ratingColor: _getRatingColor(breakdown.keyResultQuality.title),
            description: breakdown.keyResultQuality.suggestion,
            sw: sw,
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(String rating) {
    final r = rating.toLowerCase().trim();
    if (r == 'perfect'.tr)   return const Color(0xFFCC4A2E);
    if (r == 'excellent'.tr) return const Color(0xFF4CAF50);
    if (r == 'good'.tr)      return const Color(0xFF2196F3);
    if (r == 'average'.tr)   return const Color(0xFFFF9800);
    return const Color(0xFF9E9E9E);
  }

  Widget _buildFeedbackItem({
    required String title,
    required String rating,
    required Color ratingColor,
    required String description,
    required double sw,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.tr,
                style: TextStyle(
                    fontFamily: 'GothamBold',
                    fontSize:   _fs(sw, 16, desktop: 15),
                    fontWeight: FontWeight.bold,
                    color:      Colors.black87)),
            SizedBox(height: sw >= 768 ? 4.0 : 4.h),
            Text(rating.tr,
                style: TextStyle(
                    fontFamily: 'GothamBold',
                    fontSize:   _fs(sw, 14, desktop: 14),
                    fontWeight: FontWeight.bold,
                    color:      ratingColor)),
          ],
        ),
        SizedBox(height: sw >= 768 ? 8.0 : 8.h),
        Text(description,
            style: TextStyle(
                fontFamily: 'Gotham',
                fontSize: _fs(sw, 14, desktop: 14),
                color:    Colors.black54,
                height:   1.5)),
      ],
    );
  }
}








// // lib/presentation/views/feedback_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:game_app/presentation/routes/app_routes.dart';
// import 'package:get/get.dart';
// import 'package:game_app/generated/models/responses/key_results/key_results_response.dart'
// as key_result_models;
// import '../../generated/models/requests/campaign_mode/feedback_evaluation_model.dart';
// import '../../services/shared_preference.dart';
// import '../../view_model/bonus_score.dart';
// import '../../view_model/campaign_mode/feedback_evaluation_view_model.dart';
// import '../widgets/Website/desktop_appbar.dart';
// import '../widgets/campaign_progress_service.dart';
// import '../widgets/custom_button2.dart';
// import '../widgets/custom_home_navbar.dart';
// import '../widgets/custom_svg.dart';
// import '../widgets/game_complete_widgets/custom_score_card.dart';
// import '../widgets/screens_unique_parts/custom_background.dart';
//
// // ─── Adaptive helpers ─────────────────────────────────────────────────────────
// double _fs(double sw, double mobile, {double? tablet, double? desktop}) {
//   if (sw >= 1024) return desktop ?? tablet ?? mobile;
//   if (sw >= 768) return tablet ?? mobile;
//   return mobile.sp;
// }
// double _d(double sw, double v) => sw >= 768 ? v : v.w;
// double _dh(double sw, double v) => sw >= 768 ? v : v.h;
//
// class FeedbackScreen extends StatelessWidget {
//   final List<key_result_models.KeyResult> selectedKeyResults;
//
//   const FeedbackScreen({super.key, required this.selectedKeyResults});
//
//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Get.put(FeedbackEvaluationViewModel());
//     final bonusController = Get.put(BonusScoreController());
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       viewModel.evaluateSelectedKeyResults(selectedKeyResults);
//       await bonusController.shouldSubmitBonusScore();
//     });
//
//     final sw = MediaQuery.of(context).size.width;
//     final sh = MediaQuery.of(context).size.height;
//
//     if (sw >= 768) {
//       return _buildDesktopLayout(context, sw, sh, viewModel, bonusController);
//     }
//     return _buildMobileLayout(context, sw, sh, viewModel, bonusController);
//   }
//
//   // ============================================================
//   // MOBILE LAYOUT
//   // ============================================================
//   Widget _buildMobileLayout(
//       BuildContext context,
//       double sw,
//       double sh,
//       FeedbackEvaluationViewModel viewModel,
//       BonusScoreController bonusController,
//       ) {
//     return Scaffold(
//       body: CustomBackground(
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(vertical: 14.w),
//                 child: _buildContent(sw, sh, viewModel, bonusController),
//               ),
//             ),
//             Positioned(
//               right: sw * -0.07,
//               top: sh * 0.50,
//               child: const CustomHomeNavBar(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // DESKTOP LAYOUT
//   // ============================================================
//   Widget _buildDesktopLayout(
//       BuildContext context,
//       double sw,
//       double sh,
//       FeedbackEvaluationViewModel viewModel,
//       BonusScoreController bonusController,
//       ) {
//     final double containerWidth = sw > 1200 ? 720.0 : sw * 0.72;
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background
//           Positioned.fill(
//             child: Opacity(
//               opacity: 0.1,
//               child: Image.asset(
//                 'assets/images/web_background.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Top app bar
//           Positioned(
//             top: 0, left: 0, right: 0,
//             child: DesktopAppBar(
//               screenWidth: sw,
//               screenHeight: sh,
//               title: 'okr'.tr,
//               subtitle: 'feedback'.tr,
//             ),
//           ),
//           // Scrollable content card
//           Positioned(
//             top: 110, left: 0, right: 0, bottom: 80,
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
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.all(36),
//                   child: _buildContent(sw, sh, viewModel, bonusController),
//                 ),
//               ),
//             ),
//           ),
//           // Back button
//           Positioned(
//             bottom: 20, left: 0,
//             child: GestureDetector(
//               onTap: () => Get.back(),
//               child: CustomSvg(
//                 assetPath: 'assets/images/left.svg',
//                 semanticsLabel: '',
//               ),
//             ),
//           ),
//           // Nav bar
//           Positioned(
//             bottom: 20, left: 0, right: -30,
//             child: Center(child: const CustomHomeNavBar()),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ============================================================
//   // SHARED CONTENT
//   // ============================================================
//   Widget _buildContent(
//       double sw,
//       double sh,
//       FeedbackEvaluationViewModel viewModel,
//       BonusScoreController bonusController,
//       ) {
//     return Column(
//       children: [
//         SizedBox(height: sw >= 768 ? 12.0 : 14.w),
//
//         SizedBox(height: sw >= 768 ? 20.0 : 20.h),
//
//         Obx(() {
//           if (viewModel.isLoadingData) {
//             return SizedBox(
//               height: sw >= 768 ? 200.0 : 200.h,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const CircularProgressIndicator(),
//                     SizedBox(height: sw >= 768 ? 16.0 : 16.h),
//                     Text(
//                       'Evaluating your OKRs...',
//                       style: TextStyle(
//                         fontSize: _fs(sw, 14, desktop: 14),
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           if (!viewModel.hasData) {
//             return Center(
//               child: Padding(
//                 padding: EdgeInsets.only(top: sw >= 768 ? 80.0 : 100.h),
//                 child: Text('no_feedback_data_available'.tr),
//               ),
//             );
//           }
//
//           final feedback = viewModel.evaluationResult!;
//
//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             final shouldSubmit = await bonusController.shouldSubmitBonusScore();
//             if (shouldSubmit && !bonusController.isLoading.value) {
//               _submitBonusScore(bonusController, feedback);
//             }
//           });
//
//           return Column(
//             children: [
//               // Bonus mode indicator
//               Obx(() {
//                 if (bonusController.isLoading.value) {
//                   return _bonusBanner(
//                     sw,
//                     [const Color(0xFFFFD700), const Color(0xFFFFA500)],
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           width: sw >= 768 ? 16.0 : 16.w,
//                           height: sw >= 768 ? 16.0 : 16.h,
//                           child: const CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor:
//                             AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         ),
//                         SizedBox(width: sw >= 768 ? 8.0 : 8.w),
//                         Text(
//                           'submitting_bonus_score'.tr,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: _fs(sw, 14, desktop: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 if (bonusController.hasSubmittedBonus.value) {
//                   return _bonusBanner(
//                     sw,
//                     [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.stars,
//                             color: Colors.white,
//                             size: sw >= 768 ? 20.0 : 20.sp),
//                         SizedBox(width: sw >= 768 ? 8.0 : 8.w),
//                         Text(
//                           'bonus_score_submitted'.trParams(
//                               {'score': feedback.overallScore.toString()}),
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: _fs(sw, 14, desktop: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return FutureBuilder<bool>(
//                   future: bonusController.isBonusMode(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData &&
//                         snapshot.data == true &&
//                         !bonusController.hasSubmittedBonus.value) {
//                       return _bonusBanner(
//                         sw,
//                         [const Color(0xFFFFD700), const Color(0xFFFFA500)],
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.stars,
//                                 color: Colors.white,
//                                 size: sw >= 768 ? 20.0 : 20.sp),
//                             SizedBox(width: sw >= 768 ? 8.0 : 8.w),
//                             Text(
//                               'bonus_mode_active'.tr,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: _fs(sw, 14, desktop: 14),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 );
//               }),
//
//               // ✅ Score card — constrained on desktop
//               Center(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxWidth: sw >= 768 ? 220.0 : double.infinity,
//                   ),
//                   child: CustomScoreCard(
//                     title: '',
//                     score: feedback.overallScore,
//                     showBackground: false,
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: sw >= 768 ? 4.0 : 4.h),
//
//               Padding(
//                 padding:
//                 EdgeInsets.all(sw >= 768 ? 8.0 : 8.w),
//                 child: _buildScoreBreakdown(feedback, sw),
//               ),
//
//               SizedBox(height: sw >= 768 ? 4.0 : 4.h),
//
//               Padding(
//                 padding:
//                 EdgeInsets.all(sw >= 768 ? 12.0 : 12.w),
//                 child: _buildFeedbackCard(feedback, sw),
//               ),
//
//               SizedBox(height: sw >= 768 ? 24.0 : 24.h),
//
//               // Continue button
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: sw >= 768 ? 40.0 : 16.w,
//                   vertical: sw >= 768 ? 8.0 : 8.h,
//                 ),
//                 child: CustomButton2(
//                   text: 'continue'.tr,
//                   onPressed: () => _navigateBasedOnGameMode(),
//                 ),
//               ),
//
//               SizedBox(height: sw >= 768 ? 20.0 : 20.h),
//             ],
//           );
//         }),
//       ],
//     );
//   }
//
//   // ── Bonus banner ─────────────────────────────────────────────────────────
//   Widget _bonusBanner(double sw, List<Color> colors,
//       {required Widget child}) =>
//       Container(
//         margin: EdgeInsets.symmetric(
//           horizontal: sw >= 768 ? 16.0 : 16.w,
//           vertical: sw >= 768 ? 8.0 : 8.h,
//         ),
//         padding: EdgeInsets.all(sw >= 768 ? 12.0 : 12.w),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(colors: colors),
//           borderRadius:
//           BorderRadius.circular(sw >= 768 ? 12.0 : 12.r),
//         ),
//         child: child,
//       );
//
//   // ── Score breakdown ───────────────────────────────────────────────────────
//   Widget _buildScoreBreakdown(FeedbackEvaluationModel feedback, double sw) {
//     final breakdown = feedback.breakdown;
//     final normalizedScore = feedback.normalizedScore;
//
//     final scores = [
//       {
//         'score': '${breakdown.strategyAlignment.score}/30',
//         'label': 'strategy_alignment'.tr
//       },
//       {
//         'score': '${breakdown.objectiveAlignment.score}/30',
//         'label': 'objective_alignment'.tr
//       },
//       {
//         'score': '${breakdown.keyResultQuality.score}/40',
//         'label': 'key_result_quality'.tr
//       },
//     ];
//
//     return Column(
//       children: [
//         Text(
//           'score'.tr.replaceFirst('${0}', normalizedScore.toString()),
//           style: TextStyle(
//             fontFamily: 'GothamBold',
//             fontSize: _fs(sw, 18, desktop: 18),
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF1E3A8A),
//           ),
//         ),
//         SizedBox(height: sw >= 768 ? 12.0 : 12.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: scores
//               .map((item) => Flexible(
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                   horizontal: sw >= 768 ? 4.0 : 4.w),
//               padding: EdgeInsets.symmetric(
//                 vertical: sw >= 768 ? 16.0 : 16.h,
//                 horizontal: sw >= 768 ? 4.0 : 4.w,
//               ),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(
//                     sw >= 768 ? 16.0 : 16.r),
//                 border: Border.all(
//                     color: const Color(0xFFE0E0E0), width: 1),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     item['score']!,
//                     style: TextStyle(
//                       fontFamily: 'GothamBold',
//                       fontSize: _fs(sw, 18, desktop: 16),
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF1E3A8A),
//                     ),
//                   ),
//                   SizedBox(height: sw >= 768 ? 6.0 : 6.h),
//                   Text(
//                     item['label']!,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontFamily: 'Gotham',
//                       fontSize: _fs(sw, 9, desktop: 10),
//                       color: Colors.black87,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ))
//               .toList(),
//         ),
//       ],
//     );
//   }
//
//   // ── Feedback card ─────────────────────────────────────────────────────────
//   Widget _buildFeedbackCard(FeedbackEvaluationModel feedback, double sw) {
//     final breakdown = feedback.breakdown;
//
//     return Container(
//       padding: EdgeInsets.all(sw >= 768 ? 20.0 : 20.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//         BorderRadius.circular(sw >= 768 ? 20.0 : 20.r),
//         border: Border.all(color: const Color(0xFFCC4A2E), width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(sw >= 768 ? 8.0 : 8.w),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFCC4A2E),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.thumb_up,
//                     color: Colors.white,
//                     size: sw >= 768 ? 20.0 : 20.sp),
//               ),
//               SizedBox(width: sw >= 768 ? 8.0 : 8.w),
//               Text(
//                 'okr_evaluation_feedback'.tr,
//                 style: TextStyle(
//                   fontFamily: 'GothamBold',
//                   fontSize: _fs(sw, 16, desktop: 15),
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF1E3A8A),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: sw >= 768 ? 20.0 : 20.h),
//           Text(
//             feedback.feedback.tr,
//             style: TextStyle(
//               fontFamily: 'Gotham',
//               fontSize: _fs(sw, 14, desktop: 14),
//               color: Colors.black54,
//               height: 1.5,
//             ),
//           ),
//           SizedBox(height: sw >= 768 ? 20.0 : 20.h),
//           _buildFeedbackItem(
//             title: 'strategy_alignment'.tr,
//             rating: breakdown.strategyAlignment.title.tr,
//             ratingColor: _getRatingColor(breakdown.strategyAlignment.title),
//             description: breakdown.strategyAlignment.suggestion,
//             sw: sw,
//           ),
//           SizedBox(height: sw >= 768 ? 16.0 : 16.h),
//           _buildFeedbackItem(
//             title: 'objective_alignment'.tr,
//             rating: breakdown.objectiveAlignment.title,
//             ratingColor: _getRatingColor(breakdown.objectiveAlignment.title),
//             description: breakdown.objectiveAlignment.suggestion,
//             sw: sw,
//           ),
//           SizedBox(height: sw >= 768 ? 16.0 : 16.h),
//           _buildFeedbackItem(
//             title: 'key_result_quality'.tr,
//             rating: breakdown.keyResultQuality.title,
//             ratingColor: _getRatingColor(breakdown.keyResultQuality.title),
//             description: breakdown.keyResultQuality.suggestion,
//             sw: sw,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getRatingColor(String rating) {
//     final r = rating.toLowerCase().trim();
//     if (r == 'perfect') return const Color(0xFFCC4A2E);
//     if (r == 'excellent') return const Color(0xFF4CAF50);
//     if (r == 'good') return const Color(0xFF2196F3);
//     if (r == 'average') return const Color(0xFFFF9800);
//     return const Color(0xFF9E9E9E);
//   }
//
//   Widget _buildFeedbackItem({
//     required String title,
//     required String rating,
//     required Color ratingColor,
//     required String description,
//     required double sw,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title.tr,
//           style: TextStyle(
//             fontFamily: 'GothamBold',
//             fontSize: _fs(sw, 16, desktop: 15),
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         SizedBox(height: sw >= 768 ? 4.0 : 4.h),
//         Text(
//           rating.tr,
//           style: TextStyle(
//             fontFamily: 'GothamBold',
//             fontSize: _fs(sw, 14, desktop: 14),
//             fontWeight: FontWeight.bold,
//             color: ratingColor,
//           ),
//         ),
//         SizedBox(height: sw >= 768 ? 8.0 : 8.h),
//         Text(
//           description,
//           style: TextStyle(
//             fontFamily: 'Gotham',
//             fontSize: _fs(sw, 14, desktop: 14),
//             color: Colors.black54,
//             height: 1.5,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Navigation & bonus logic (unchanged from your mobile) ────────────────
//   void _submitBonusScore(
//       BonusScoreController bonusController,
//       FeedbackEvaluationModel feedback) async {
//     try {
//       final breakdown = feedback.breakdown;
//       final strategyScore30 =
//       (breakdown.strategyAlignment.score * 30 / 30).round();
//       final objectiveScore30 =
//       (breakdown.objectiveAlignment.score * 30 / 30).round();
//       final keyResultScore30 =
//       (breakdown.keyResultQuality.score * 30 / 40).round();
//       final overallScore30 =
//       ((strategyScore30 + objectiveScore30 + keyResultScore30) * 30 / 90)
//           .round();
//
//       String points;
//       if (overallScore30 >= 25) points = "3/3";
//       else if (overallScore30 >= 20) points = "2/3";
//       else points = "1/3";
//
//       String title;
//       if (overallScore30 >= 27) title = "Perfect".tr;
//       else if (overallScore30 >= 24) title = "Excellent".tr;
//       else if (overallScore30 >= 21) title = "Good".tr;
//       else if (overallScore30 >= 18) title = "Average".tr;
//       else title = "Needs Improvement".tr;
//
//       await bonusController.submitBonusScore(
//         overallScore: overallScore30,
//         normalizedScore: '$overallScore30/30',
//         points: points,
//         title: title,
//         feedback: feedback.feedback,
//         strategyAlignmentTitle: breakdown.strategyAlignment.title,
//         strategyAlignmentScore: strategyScore30,
//         strategyAlignmentSuggestion: breakdown.strategyAlignment.suggestion,
//         objectiveAlignmentTitle: breakdown.objectiveAlignment.title,
//         objectiveAlignmentScore: objectiveScore30,
//         objectiveAlignmentSuggestion: breakdown.objectiveAlignment.suggestion,
//         keyResultQualityTitle: breakdown.keyResultQuality.title,
//         keyResultQualityScore: keyResultScore30,
//         keyResultQualitySuggestion: breakdown.keyResultQuality.suggestion,
//       );
//     } catch (e) {
//       debugPrint('❌ Error in bonus score submission: $e');
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
//           "Level Completed!".tr,
//           "Organization ${currentLevel == 1 ? 'A' : currentLevel == 2 ? 'B' : 'C'} completed!"
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
//   void _navigateBasedOnGameMode() async {
//     try {
//       final savedMode = await SharedPrefs.getGameMode();
//
//       if (savedMode == 'campaign') _markLevelComplete();
//
//       if (savedMode == 'bonus') {
//         Get.snackbar(
//           "bonus_mode_completed".tr,
//           "bonus_mode_completion_message".tr,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: const Color(0xFFFFD700),
//           colorText: Colors.black,
//           duration: const Duration(seconds: 3),
//         );
//         Future.delayed(
//             const Duration(seconds: 2), () => Get.offAllNamed(AppRoutes.home));
//         return;
//       }
//
//       switch (savedMode) {
//         case 'solo':
//         case 'challenge':
//         // ✅ Always pass arguments so route builder never gets null
//           Get.toNamed(
//             AppRoutes.suggestionInitiativeScreen,
//             arguments: {'selectedKeyResults': []},  // ← THIS IS THE FIX
//           );
//           break;
//         case 'campaign':
//           Get.offAllNamed(AppRoutes.campaignModeScreen);
//           break;
//         default:
//           Get.toNamed(
//             AppRoutes.suggestionInitiativeScreen,
//             arguments: {'selectedKeyResults': []},  // ← AND HERE
//           );
//           break;
//       }
//     } catch (e) {
//       debugPrint('❌ Navigation error: $e');
//       Get.offAllNamed(AppRoutes.home);
//     }
//   }
// }