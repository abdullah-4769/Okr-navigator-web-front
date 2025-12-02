// lib/presentation/views/feedback/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:game_app/presentation/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:game_app/generated/models/responses/key_results/key_results_response.dart' as key_result_models;
import '../../generated/models/requests/campaign_mode/feedback_evaluation_model.dart';
import '../../services/shared_preference.dart';
import '../../view_model/campaign_mode/feedback_evaluation_view_model.dart';
import '../widgets/campaign_progress_service.dart';
import '../widgets/custom_button2.dart';
import '../widgets/custom_home_navbar.dart';
import '../widgets/game_complete_widgets/custom_score_card.dart';
import '../widgets/screens_unique_parts/custom_background.dart';
import '../widgets/screens_unique_parts/custom_header.dart';

class FeedbackScreen extends StatelessWidget {
  final List<key_result_models.KeyResult> selectedKeyResults;

  const FeedbackScreen({super.key, required this.selectedKeyResults});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(FeedbackEvaluationViewModel());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.evaluateSelectedKeyResults(selectedKeyResults);
    });

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CustomBackground(
        child: Stack(
          children: [
            // 1️⃣ Scrollable content
            Padding(
              padding: EdgeInsets.only(bottom: 80.h), // leave space for button
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 14.w, horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomHeader(
                      title: 'okr'.tr,
                      highlightedText: "feedback".tr,
                      onBackTap: () => Get.back(),
                    ),
                    SizedBox(height: 20.h),

                    // FIXED: Better Obx usage with proper reactive variables
                    _buildContent(viewModel),
                  ],
                ),
              ),
            ),

            // 2️⃣ Sticky bottom button
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: _buildContinueButton(),
            ),

            // 3️⃣ Side Home Navbar
            Positioned(
              right: 0,
              top: screenHeight * 0.5 - 50.h, // adjust to vertical center
              child: const CustomHomeNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: Extract content building to separate method with proper Obx usage
  Widget _buildContent(FeedbackEvaluationViewModel viewModel) {
    return Obx(() {
      // Make sure these are observable variables in your ViewModel
      if (viewModel.isLoadingData) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (!viewModel.hasData) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: Text('no_feedback_data_available'.tr),
          ),
        );
      }

      final feedback = viewModel.evaluationResult;
      if (feedback == null) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: Text('no_feedback_data_available'.tr),
          ),
        );
      }

      return Column(
        children: [
          CustomScoreCard(
            title: "",
            score: feedback.overallScore,
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: _buildScoreBreakdown(feedback),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: _buildFeedbackCard(feedback),
          ),
          SizedBox(height: 20.h),
        ],
      );
    });
  }

  // FIXED: Extract button to separate widget
  Widget _buildContinueButton() {
    return Obx(() {
      final viewModel = Get.find<FeedbackEvaluationViewModel>();
      final isEnabled = viewModel.hasData && !viewModel.isLoadingData;

      return CustomButton2(
        height: 75,
        width: 100.h,
        text: 'continue'.tr,
        onPressed: isEnabled ? () => _navigateBasedOnGameMode() : null,
      );
    });
  }

  // In your FeedbackScreen, add this when level is completed
  void _markLevelComplete() async {
    try {
      // Check if we're in campaign mode
      final savedMode = await SharedPrefs.getGameMode();
      if (savedMode == 'campaign') {
        // Get current level from storage or default to 1
        final currentLevelStr = await SharedPrefs.getString('current_campaign_level') ?? '1';
        final currentLevel = int.tryParse(currentLevelStr) ?? 1;

        // Mark level as completed
        await CampaignProgressService.completeLevel(currentLevel);

        print('✅ Campaign Level $currentLevel marked as completed!');

        // Show completion message
        Get.snackbar(
          "Level Completed!".tr,
          "Organization ${currentLevel == 1 ? 'A' : currentLevel == 2 ? 'B' : 'C'} completed!".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error marking level complete: $e');
    }
  }

  // Call this method when user completes the feedback screen
  // Add this to your Continue button logic or when evaluation is successful
  void _navigateBasedOnGameMode() async {
    try {
      final savedMode = await SharedPrefs.getGameMode();

      if (savedMode == 'campaign') {
        // Mark level as complete before navigating
        _markLevelComplete();
      }

      // Rest of your navigation logic...
      switch (savedMode) {
        case 'solo':
        case 'challenge':
          Get.toNamed(AppRoutes.suggestionInitiativeScreen);
          break;
        case 'campaign':
        // Go back to campaign screen to show updated progress
          Get.offAllNamed(AppRoutes.campaignModeScreen);
          break;
        default:
          Get.toNamed(AppRoutes.suggestionInitiativeScreen);
          break;
      }
    } catch (e) {
      print('❌ Error in navigation: $e');
      Get.toNamed(AppRoutes.suggestionInitiativeScreen);
    }
  }

  Widget _buildScoreBreakdown(FeedbackEvaluationModel feedback) {
    final breakdown = feedback.breakdown;

    // Use normalized score for display
    final normalizedScore = feedback.normalizedScore;

    final scores = [
      {'score': '${breakdown.strategyAlignment.score}/40', 'label': 'strategy_alignment'.tr},
      {'score': '${breakdown.objectiveAlignment.score}/40', 'label': 'objective_alignment'.tr},
      {'score': '${breakdown.keyResultQuality.score}/40', 'label': 'key_result_quality'.tr},
    ];

    return Column(
      children: [
        // Overall normalized score
        Text(
          'score'.tr.replaceFirst('${0}', normalizedScore.toString()),
          style: TextStyle(
            fontFamily: 'GothamBold',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        SizedBox(height: 12.h),

        // FIXED: Breakdown scores - Use Wrap or Flexible to prevent overflow
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: scores.map((item) {
            return Flexible( // FIX: Use Flexible to allow wrapping
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w), // Reduced margin
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w), // Reduced padding
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['score']!,
                      style: TextStyle(
                        fontFamily: 'GothamBold',
                        fontSize: 18.sp, // Slightly smaller font
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item['label']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Gotham',
                        fontSize: 9.sp, // Smaller font
                        color: Colors.black87,
                      ),
                      maxLines: 2, // Allow text to wrap
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(FeedbackEvaluationModel feedback) {
    final breakdown = feedback.breakdown;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFCC4A2E),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFCC4A2E),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.thumb_up,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'okr_evaluation_feedback'.tr,
                style: TextStyle(
                  fontFamily: 'GothamBold',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Overall Feedback
          Text(
            feedback.feedback,
            style: TextStyle(
              fontFamily: 'Gotham',
              fontSize: 14.sp,
              color: Colors.black54,
              height: 1.5,
            ),
          ),

          SizedBox(height: 20.h),

          // Strategy Alignment
          _buildFeedbackItem(
            title: 'strategy_alignment'.tr,
            rating: breakdown.strategyAlignment.title,
            ratingColor: _getRatingColor(breakdown.strategyAlignment.title),
            description: breakdown.strategyAlignment.suggestion,
          ),

          SizedBox(height: 16.h),

          // Objective Alignment
          _buildFeedbackItem(
            title: 'objective_alignment'.tr,
            rating: breakdown.objectiveAlignment.title,
            ratingColor: _getRatingColor(breakdown.objectiveAlignment.title),
            description: breakdown.objectiveAlignment.suggestion,
          ),

          SizedBox(height: 16.h),

          // Key Result Quality
          _buildFeedbackItem(
            title: 'key_result_quality'.tr,
            rating: breakdown.keyResultQuality.title,
            ratingColor: _getRatingColor(breakdown.keyResultQuality.title),
            description: breakdown.keyResultQuality.suggestion,
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'perfect':
        return Color(0xFFCC4A2E);
      case 'excellent':
        return Color(0xFF4CAF50);
      case 'good':
        return Color(0xFF2196F3);
      case 'average':
        return Color(0xFFFF9800);
      default:
        return Color(0xFF9E9E9E);
    }
  }

  Widget _buildFeedbackItem({
    required String title,
    required String rating,
    required Color ratingColor,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'GothamBold',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              rating,
              style: TextStyle(
                fontFamily: 'GothamBold',
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: ratingColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Gotham',
            fontSize: 14.sp,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to certification test
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFCC4A2E),
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCC4A2E).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'start_certification_test'.tr,
              style: TextStyle(
                fontFamily: 'GothamBold',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}