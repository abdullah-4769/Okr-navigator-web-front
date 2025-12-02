import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/custom_ai_startegy_controller.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_dimensions.dart';
import '../../../data/network/network_api_services.dart';
import '../../../data/response/api_response.dart';
import '../../../generated/models/requests/adaptation_analysis_model.dart';
import '../../../generated/models/responses/evaluate_initiative/evaluate_initiative_model.dart';
import '../../../services/shared_preference.dart';
import '../../../utils/snackbar_helper.dart';
import '../../../view_model/challange_view_models/adaptation_ai_analysis-viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';
import '../../widgets/Website/desktop_appbar.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  final AdaptationAIAnalysisViewModel _viewModel = Get.find();
  final int _maxRetries = 3;
  int _currentRetry = 0;
  bool _isNavigating = false;

  String _safeTranslate(String? key, {String fallback = ''}) {
    if (key == null) return fallback;
    try {
      return key.tr;
    } catch (e) {
      return fallback;
    }
  }

  @override
  // void initState() {
  //   super.initState();
  //   _viewModel = Get.put(AdaptationAIAnalysisViewModel());
  //   _loadRetryCount();
  //   _handleAnalysisBasedOnSource();
  // }

  /// Load current retry count from SharedPreferences
  void _loadRetryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentRetry = prefs.getInt('analysis_retry_count') ?? 0;
      print('🔄 Current retry count: $_currentRetry/$_maxRetries');
    } catch (e) {
      print('❌ Error loading retry count: $e');
      _currentRetry = 0;
    }
  }

  /// Save retry count to SharedPreferences
  void _saveRetryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('analysis_retry_count', _currentRetry);
      print('💾 Saved retry count: $_currentRetry');
    } catch (e) {
      print('❌ Error saving retry count: $e');
    }
  }

  /// Reset retry count
  void _resetRetryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('analysis_retry_count', 0);
      _currentRetry = 0;
      print('🔄 Retry count reset to 0');
    } catch (e) {
      print('❌ Error resetting retry count: $e');
    }
  }

  void _handleAnalysisBasedOnSource() async {
    try {
      final dynamic arguments = Get.arguments;
      final source = arguments is Map<String, dynamic>
          ? arguments['source'] ?? ''
          : '';
      final adaptationRequest = arguments is Map<String, dynamic>
          ? arguments['adaptationRequest']
          : null;

      print('📍 Analysis Source: $source');
      print('📦 Has Adaptation Request: ${adaptationRequest != null}');

      // Handle BOTH sources properly
      if (source == 'challenge_adjustment' && adaptationRequest != null) {
        print('🔄 Running adaptation analysis from challenge adjustment...');
        await _runAdaptationAnalysis(adaptationRequest);
      } else if (source == 'contextual_challenge') {
        print('🔄 Analysis from contextual challenge - skipping adaptation');
      } else {
        print('ℹ️ No adaptation analysis needed for source: $source');
      }
    } catch (e) {
      print('❌ Error in analysis handling: $e');
    }
  }

  Future<void> _runAdaptationAnalysis(dynamic adaptationRequest) async {
    try {
      // ✅ FIXED: Extract parameters from adaptationRequest and call the new method
      if (adaptationRequest is AdaptationAnalysisRequest) {
        await _viewModel.submitAdaptationAnalysis(
          strategy: adaptationRequest.strategy,
          objective: adaptationRequest.objective,
          keyResult: adaptationRequest.keyResult,
          challenge: adaptationRequest.challenge,
          proposal: adaptationRequest.proposal ?? 'Strategic adaptations', // Provide default
        );
      } else if (adaptationRequest is Map<String, dynamic>) {
        // Handle if it's a map instead of the model
        await _viewModel.submitAdaptationAnalysis(
          strategy: adaptationRequest['strategy']?.toString() ?? await _getDefaultStrategy(),
          objective: adaptationRequest['objective']?.toString() ?? await _getDefaultObjective(),
          keyResult: adaptationRequest['keyResult']?.toString() ?? 'Adapted Key Result',
          challenge: adaptationRequest['challenge']?.toString() ?? 'Market Challenge',
          proposal: adaptationRequest['proposal']?.toString() ?? 'Strategic adaptations',
        );
      } else {
        // Fallback with default values
        print('⚠️ Adaptation request type not recognized, using default values');
        await _viewModel.submitAdaptationAnalysis(
          strategy: await _getDefaultStrategy(),
          objective: await _getDefaultObjective(),
          keyResult: 'Adapted Key Result',
          challenge: 'Market Challenge',
          proposal: 'Strategic adaptations to address market changes',
        );
      }
      print('✅ Adaptation analysis completed');
    } catch (e) {
      print('❌ Error running adaptation analysis: $e');
    }
  }

  // ✅ Add these helper methods to get default values
  Future<String> _getDefaultStrategy() async {
    try {
      final strategyData = await SharedPrefs.getSelectedStrategy();
      return strategyData?['title']?.toString() ?? 'CEO Strategy';
    } catch (e) {
      return 'CEO Strategy';
    }
  }

  Future<String> _getDefaultObjective() async {
    try {
      final objectiveData = await SharedPrefs.getSelectedObjective();
      return objectiveData?['title']?.toString() ?? 'Business Growth Objective';
    } catch (e) {
      return 'Business Growth Objective';
    }
  }

  void _navigateBasedOnDecisionAndMode({
    required String decision,
    required String source,
    required bool hasData,
  }) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      final savedMode = await SharedPrefs.getGameMode() ?? 'solo';
      final isDecisionAccepted = _isDecisionAccepted(decision);

      print('🎯 Navigation Decision:');
      print('   - Decision: $decision (Accepted: $isDecisionAccepted)');
      print('   - Game Mode: $savedMode');
      print('   - Source: $source');
      print('   - Retry Count: $_currentRetry/$_maxRetries');

      // 🚫 HANDLE REJECTED DECISION
      if (!isDecisionAccepted) {
        _currentRetry++;
        _saveRetryCount();

        if (_currentRetry >= _maxRetries) {
          print(
            '❌ Max retries reached ($_maxRetries). Navigating to home screen.',
          );
          await _showMaxRetriesDialog();
          _resetRetryCount();
          _navigateToHomeScreen(); // ✅ Navigate to home screen
        } else {
          print('🔄 Decision rejected. Retry $_currentRetry/$_maxRetries');
          await _showRetryDialog();
        }
        return;
      }

      // ✅ HANDLE ACCEPTED DECISION - Reset retry count and proceed
      _resetRetryCount();
      await _proceedWithAcceptedDecision(savedMode, source);
    } catch (e) {
      print('❌ Error in navigation: $e');
      Get.snackbar(
        'Navigation Error',
        'Failed to navigate: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isNavigating = false;
    }
  }

  /// Check if decision is accepted
  bool _isDecisionAccepted(String decision) {
    final lowerDecision = decision.toLowerCase();
    return lowerDecision.contains('accepted') ||
        lowerDecision.contains('approved') ||
        (lowerDecision.contains('review') &&
            !lowerDecision.contains('rejected'));
  }

  /// Show retry dialog for rejected decisions
  Future<void> _showRetryDialog() async {
    await Get.dialog(
      AlertDialog(
        title: Text('initiative_rejected'.tr),
        content: Text(
          '${'initiative_needs_improvement'.tr}\n\n'
              '${'retry_count'.tr}: $_currentRetry/$_maxRetries\n'
              '${'suggest_improve_initiatives'.tr}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _navigateToKeyObjectiveScreen();
            },
            child: Text('try_again'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Show max retries reached dialog
  Future<void> _showMaxRetriesDialog() async {
    await Get.dialog(
      AlertDialog(
        title: Text('max_retries_reached'.tr),
        content: Text(
          '${'max_retries_exceeded'.tr}\n\n'
              '${'returning_to_home_screen'.tr}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('understand'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Navigate to key objective screen for retry
  void _navigateToKeyObjectiveScreen() {
    print('🔄 Navigating back to Key Objective Screen for retry');

    // Get current arguments to pass them back
    final currentArgs = Get.arguments;

    Get.offAllNamed(
      AppRoutes.keyObjectiveScreen,
      parameters: {'isRetry': 'true'},
      arguments: currentArgs,
    );
  }

  /// ✅ NEW: Navigate to home screen when max retries reached
  void _navigateToHomeScreen() {
    print('🏠 Max retries reached - Navigating to home screen');

    // Clear all navigation stack and go to home
    Get.offAllNamed(AppRoutes.home);

    // Optional: Show a completion message
    Future.delayed(const Duration(milliseconds: 500), () {
      SnackbarHelper.info(
        'You have completed all 3 attempts. Please try again with a new strategy!',
      );
    });
  }

  /// ✅ PROCEED WITH ACCEPTED DECISION - Different paths for each mode
  Future<void> _proceedWithAcceptedDecision(
      String savedMode,
      String source,
      ) async {
    print('✅ Decision accepted! Proceeding with navigation...');

    switch (savedMode) {
      case 'solo':
        print('➡️ Solo Mode: Navigating to Game Complete Screen');
        Get.offAllNamed(AppRoutes.gameCompleteScreen);
        break;

      case 'challenge':
        print('➡️ Challenge Mode: Navigating to Game Result Screen');
        await _navigateChallengeMode();
        break;

      case 'campaign':
        print('➡️ Campaign Mode: Source - $source');
        await _navigateCampaignMode(source);
        break;

      default:
        print('➡️ Default Mode: Navigating to Game Complete Screen');
        Get.offAllNamed(AppRoutes.gameCompleteScreen);
        break;
    }
  }

  /// 🎮 Challenge Mode Navigation
  Future<void> _navigateChallengeMode() async {
    final challengeId = await SharedPrefs.getChallengeId();
    final userId = SharedPrefs.getUserId();

    if (challengeId == null ||
        challengeId.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      print('❌ Challenge ID or User ID not found');
      Get.snackbar(
        'Error',
        'Challenge data not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('✅ Challenge ID: $challengeId, User ID: $userId');
  }

  Future<void> _navigateCampaignMode(String source) async {
    print('🏆 Campaign Mode Navigation - Source: $source');

    if (source == 'contextual_challenge' || source == 'challenge_adjustment') {
      print('➡️ Campaign Mode: Completing current level and navigating...');

      // Get current campaign level
      final currentLevel = await _getCurrentCampaignLevel();
      print('🎯 Current campaign level: $currentLevel');

      // Complete the current level
      if (currentLevel > 0 && currentLevel <= 3) {
        print('✅ Level $currentLevel marked as completed');
      }

      // Navigate back to campaign screen
      print('➡️ Returning to Campaign Mode Screen');
      Get.offAllNamed(AppRoutes.campaignModeScreen);
    } else {
      print('➡️ Campaign Mode: Default navigation to Campaign Mode Screen');
      Get.offAllNamed(AppRoutes.campaignModeScreen);
    }
  }

  // ✅ ADD THIS HELPER METHOD
  Future<int> _getCurrentCampaignLevel() async {
    try {
      final levelStr = await SharedPrefs.getString('current_campaign_level');
      return int.tryParse(levelStr ?? '1') ?? 1;
    } catch (e) {
      print('❌ Error getting current campaign level: $e');
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    if (isMobile) {
      return _buildMobileLayout(context, screenWidth, screenHeight);
    } else {
      return _buildDesktopWebLayout(context, screenWidth, screenHeight);
    }
  }

  /// ----------------- Mobile Layout -----------------
  Widget _buildMobileLayout(BuildContext context, double screenWidth, double screenHeight) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: AppDimensions.d18.h),
                  // child: _buildMobileContent(screenWidth, screenHeight),
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

  /// ----------------- Desktop/Web Layout -----------------
  Widget _buildDesktopWebLayout(BuildContext context, double screenWidth, double screenHeight) {
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
              title: _getHeaderTitle(_getCurrentSource()),
              subtitle: _getHeaderHighlight(_getCurrentSource()),
            ),
          ),

          /// Scrollable white container
          Center(
            child: Container(
              width: 800,
              height: screenHeight * 0.85,
              margin: const EdgeInsets.only(top: 120),
              padding: EdgeInsets.all(40.w),
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
                child: _buildDesktopContent(screenWidth, screenHeight),
              ),
            ),
          ),

          /// Home Navbar
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(child: const CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  /// ----------------- Desktop Content -----------------
  Widget _buildDesktopContent(double screenWidth, double screenHeight) {
    return Obx(() {
      final dynamic arguments = Get.arguments;

      EvaluateInitiativeModel? evaluationData;
      String source = 'initiative_analysis';

      if (arguments is EvaluateInitiativeModel) {
        evaluationData = arguments;
        source = 'initiative_analysis';
      } else if (arguments is Map<String, dynamic>) {
        if (_viewModel.evaluationData.value != null) {
          final adaptationData = _viewModel.evaluationData.value!;
          evaluationData = EvaluateInitiativeModel(
            score: adaptationData.score,
            decision: _getDecisionFromScore(adaptationData.score),
            explanation: adaptationData.feedback,
          );
          source = 'challenge_adjustment';
        } else if (arguments['analysisData'] != null) {
          evaluationData = arguments['analysisData'];
          source = arguments['source'] ?? 'challenge_adjustment';
        }
      }

      final bool hasData =
          evaluationData != null ||
              _viewModel.evaluationData.value != null;
      final int score =
          evaluationData?.score ??
              _viewModel.evaluationData.value?.score ??
              0;
      final String decision =
          evaluationData?.decision ??
              _getDecisionFromScore(score);
      final String explanation =
          evaluationData?.explanation ??
              _viewModel.evaluationData.value?.feedback ??
              'No analysis available';
      final bool isAccepted = _isDecisionAccepted(decision);
      final bool isHighScore = score >= 80;
      final bool isMediumScore = score >= 50 && score < 80;
      final int percentage = score;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.02),

          /// Desktop Header
          _buildDesktopHeader(source),

          SizedBox(height: screenHeight * 0.03),

          if (_viewModel.isSubmitting.value)
            _buildDesktopLoadingCard()
          else if (hasData)
            _buildDesktopAnalysisContainer(
              percentage: percentage,
              decision: decision,
              explanation: explanation,
              isAccepted: isAccepted,
              isHighScore: isHighScore,
              isMediumScore: isMediumScore,
              source: source,
              retryCount: '$_currentRetry/$_maxRetries',
            )
          else
            _buildDesktopLoadingCard(),

          SizedBox(height: screenHeight * 0.03),

          _buildDesktopNavigationButton(
            source: source,
            hasData: hasData,
            decision: decision,
            isAccepted: isAccepted,
          ),

          SizedBox(height: screenHeight * 0.02),
        ],
      );
    });
  }


  /// ----------------- Desktop Specific Widgets -----------------
  Widget _buildDesktopHeader(String source) {
    return Column(
      children: [
        Text(
          _getHeaderTitle(source),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        SizedBox(height: 8.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _getHeaderHighlight(source),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopAnalysisContainer({
    required int percentage,
    required String decision,
    required String explanation,
    required bool isAccepted,
    required bool isHighScore,
    required bool isMediumScore,
    required String source,
    required String retryCount,
  }) {
    Color containerColor;
    Color percentageBarColor;
    Color iconColor;
    IconData statusIcon;

    if (isHighScore) {
      containerColor = const Color(0xff8DC046);
      percentageBarColor = const Color(0xFFA3B800);
      iconColor = const Color(0xFF2D5016);
      statusIcon = Icons.sentiment_very_satisfied;
    } else if (isMediumScore) {
      containerColor = Colors.orange;
      percentageBarColor = Colors.orange.shade700;
      iconColor = Colors.orange.shade900;
      statusIcon = Icons.sentiment_neutral;
    } else {
      containerColor = Colors.red.shade400;
      percentageBarColor = Colors.red.shade700;
      iconColor = Colors.red.shade900;
      statusIcon = Icons.sentiment_dissatisfied;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff8DC046),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          // Robot and Title Section
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff8DC046),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
            child: Column(
              children: [
                SvgPicture.asset(
                  "assets/images/robot.svg",
                  height: 80.h,
                  width: 80.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  _getAnalysisTitle(source),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isAccepted) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${'retry'.tr} $_currentRetry ${'of'.tr} $_maxRetries',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Percentage Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: const BoxDecoration(color: Color(0xffC8CD37)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, color: Colors.black, size: 28.sp),
                SizedBox(width: 16.w),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Threshold Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: const BoxDecoration(color: Color(0xffC8CD37)),
            child: Text(
              '${_safeTranslate('relevance_threshold')}: >80%',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Explanation Section
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: containerColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAccepted
                              ? Icons.lightbulb
                              : Icons.warning_amber_rounded,
                          color: containerColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          decision,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    explanation,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.sp,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigationButton({
    required String source,
    required bool hasData,
    required String decision,
    required bool isAccepted,
  }) {
    if (_viewModel.isSubmitting.value) {
      return SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: 'analyzing'.tr,
          onPressed: () {},
        ),
      );
    }

    // 🚫 REJECTED DECISION - Show Try Again button
    if (!isAccepted) {
      return SizedBox(
        width: double.infinity,
        child: CustomButton(
          text: 'try_again'.tr,
          onPressed: () => _navigateBasedOnDecisionAndMode(
            decision: decision,
            source: source,
            hasData: hasData,
          ),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }

    // ✅ ACCEPTED DECISION - Show appropriate button based on source
    switch (source) {
      case 'initiative_analysis':
        return SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'check_contextual_challenge'.tr,
            onPressed: hasData
                ? () => Get.toNamed(
              AppRoutes.contextualChallenge,
              arguments: {
                'analysisData': Get.arguments,
                'source': 'initiative_analysis',
              },
            )
                : () {},
          ),
        );
      case 'challenge_adjustment':
        return SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'proceed_to_results'.tr,
            onPressed: () => _navigateBasedOnDecisionAndMode(
              decision: decision,
              source: source,
              hasData: hasData,
            ),
          ),
        );
      default:
        return SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'continue'.tr,
            onPressed: () => _navigateBasedOnDecisionAndMode(
              decision: decision,
              source: source,
              hasData: hasData,
            ),
          ),
        );
    }
  }

  Widget _buildDesktopLoadingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: const Color(0xFFBFD200),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/images/robot.svg",
            height: 80.h,
            width: 80.w,
          ),
          SizedBox(height: 24.h),
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          SizedBox(height: 24.h),
          Text(
            _viewModel.isSubmitting.value
                ? 'Running Adaptation Analysis...'
                : _safeTranslate(
              'loading_analysis',
              fallback: 'Analyzing initiatives...',
            ),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// ----------------- Mobile Specific Widgets -----------------
  Widget _buildMobileAnalysisContainer({
    required int percentage,
    required String decision,
    required String explanation,
    required bool isAccepted,
    required bool isHighScore,
    required bool isMediumScore,
    required String source,
    required String retryCount,
  }) {
    Color containerColor;
    Color percentageBarColor;
    Color iconColor;
    IconData statusIcon;

    if (isHighScore) {
      containerColor = const Color(0xff8DC046);
      percentageBarColor = const Color(0xFFA3B800);
      iconColor = const Color(0xFF2D5016);
      statusIcon = Icons.sentiment_very_satisfied;
    } else if (isMediumScore) {
      containerColor = Colors.orange;
      percentageBarColor = Colors.orange.shade700;
      iconColor = Colors.orange.shade900;
      statusIcon = Icons.sentiment_neutral;
    } else {
      containerColor = Colors.red.shade400;
      percentageBarColor = Colors.red.shade700;
      iconColor = Colors.red.shade900;
      statusIcon = Icons.sentiment_dissatisfied;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xff8DC046),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xff8DC046)),
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Column(
                children: [
                  SvgPicture.asset(
                    "assets/images/robot.svg",
                    height: 100.h,
                    width: 100.w,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _getAnalysisTitle(source),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isAccepted) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${'retry'.tr} $_currentRetry ${'of'.tr} $_maxRetries',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: const BoxDecoration(color: Color(0xffC8CD37)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(statusIcon, color: Colors.black, size: 32.sp),
                  SizedBox(width: 12.w),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: const BoxDecoration(color: Color(0xffC8CD37)),
              child: Text(
                _safeTranslate('relevance_threshold') + ': >80%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: containerColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAccepted
                                ? Icons.lightbulb
                                : Icons.warning_amber_rounded,
                            color: containerColor,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            decision,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      explanation,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.sp,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavigationButton({
    required String source,
    required bool hasData,
    required String decision,
    required bool isAccepted,
  }) {
    if (_viewModel.isSubmitting.value) {
      return CustomButton(text: 'analyzing'.tr, onPressed: () {});
    }

    // 🚫 REJECTED DECISION - Show Try Again button
    if (!isAccepted) {
      return CustomButton(
        text: 'try_again'.tr,
        onPressed: () => _navigateBasedOnDecisionAndMode(
          decision: decision,
          source: source,
          hasData: hasData,
        ),
        backgroundColor: AppColors.primaryRed,
      );
    }

    // ✅ ACCEPTED DECISION - Show appropriate button based on source
    switch (source) {
      case 'initiative_analysis':
        return CustomButton(
          text: 'check_contextual_challenge'.tr,
          onPressed: hasData
              ? () => Get.toNamed(
            AppRoutes.contextualChallenge,
            arguments: {
              'analysisData': Get.arguments,
              'source': 'initiative_analysis',
            },
          )
              : () {},
        );
      case 'challenge_adjustment':
        return CustomButton(
          text: 'proceed_to_results'.tr,
          onPressed: () => _navigateBasedOnDecisionAndMode(
            decision: decision,
            source: source,
            hasData: hasData,
          ),
        );
      default:
        return CustomButton(
          text: 'continue'.tr,
          onPressed: () => _navigateBasedOnDecisionAndMode(
            decision: decision,
            source: source,
            hasData: hasData,
          ),
        );
    }
  }

  Widget _buildMobileLoadingCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: const Color(0xFFBFD200),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              "assets/images/robot.svg",
              height: 100.h,
              width: 100.w,
            ),
            SizedBox(height: 20.h),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 20.h),
            Text(
              _viewModel.isSubmitting.value
                  ? 'Running Adaptation Analysis...'
                  : _safeTranslate(
                'loading_analysis',
                fallback: 'Analyzing initiatives...',
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ----------------- Helper Methods -----------------
  String _getCurrentSource() {
    final dynamic arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      return arguments['source'] ?? 'initiative_analysis';
    }
    return 'initiative_analysis';
  }

  String _getDecisionFromScore(int score) {
    if (score >= 80) return 'Accepted'.tr;
    if (score >= 50) return 'Review Required'.tr;
    return 'Rejected'.tr;
  }

  String _getHeaderTitle(String source) {
    switch (source) {
      case 'challenge_adjustment':
        return 'adaptation'.tr;
      case 'initiative_analysis':
      default:
        return 'suggestion'.tr;
    }
  }

  String _getHeaderHighlight(String source) {
    switch (source) {
      case 'challenge_adjustment':
        return 'analysis'.tr;
      case 'initiative_analysis':
      default:
        return 'of_initiatives'.tr;
    }
  }

  String _getAnalysisTitle(String source) {
    switch (source) {
      case 'challenge_adjustment':
        return 'Adaptation Analysis Results';
      case 'initiative_analysis':
      default:
        return 'Initiative Analysis Results';
    }
  }
}