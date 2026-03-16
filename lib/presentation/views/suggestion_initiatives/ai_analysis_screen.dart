import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_dimensions.dart';
import '../../../core/app_colors.dart';
import '../../../generated/models/requests/adaptation_analysis_model.dart';
import '../../../generated/models/responses/evaluate_initiative/evaluate_initiative_model.dart';
import '../../../services/shared_preference.dart';
import '../../../utils/snackbar_helper.dart';
import '../../../view_model/challange_view_models/adaptation_ai_analysis-viewmodel.dart';
import '../../routes/app_routes.dart';
import '../../widgets/Website/desktop_appbar.dart';
import '../../widgets/campaign_progress_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_home_navbar.dart';
import '../../widgets/custom_svg.dart';
import '../../widgets/screens_unique_parts/custom_background.dart';
import '../../widgets/screens_unique_parts/custom_header.dart';

class AIAnalysisShowScreen extends StatefulWidget {
  const AIAnalysisShowScreen({super.key});

  @override
  State<AIAnalysisShowScreen> createState() => _AIAnalysisShowScreenState();
}

class _AIAnalysisShowScreenState extends State<AIAnalysisShowScreen> {
  late final AdaptationAIAnalysisViewModel _viewModel;
  final int _maxRetries = 3;
  int _currentRetry = 0;
  bool _isNavigating = false;

  String _safeTranslate(String? key, {String fallback = ''}) {
    if (key == null) return fallback;
    try { return key.tr; } catch (_) { return fallback; }
  }

  @override
  void initState() {
    super.initState();
    _viewModel = Get.put(AdaptationAIAnalysisViewModel());
    _loadRetryCount();
    _handleAnalysisBasedOnSource();
  }

  void _loadRetryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentRetry = prefs.getInt('analysis_retry_count') ?? 0;
    } catch (_) { _currentRetry = 0; }
  }

  void _saveRetryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('analysis_retry_count', _currentRetry);
    } catch (_) {}
  }

  void _resetRetryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('analysis_retry_count', 0);
      _currentRetry = 0;
    } catch (_) {}
  }

  void _handleAnalysisBasedOnSource() async {
    try {
      final dynamic args = Get.arguments;
      final source = args is Map<String, dynamic> ? args['source'] ?? '' : '';
      final adaptationRequest =
      args is Map<String, dynamic> ? args['adaptationRequest'] : null;
      if (source == 'challenge_adjustment' && adaptationRequest != null) {
        await _runAdaptationAnalysis(adaptationRequest);
      }
    } catch (e) { debugPrint('❌ Error in analysis handling: $e'); }
  }

  Future<void> _runAdaptationAnalysis(dynamic req) async {
    try {
      if (req is AdaptationAnalysisRequest) {
        await _viewModel.submitAdaptationAnalysis(
          strategy: req.strategy,
          objective: req.objective,
          keyResult: req.keyResult,
          challenge: req.challenge,
          proposal: req.proposal ?? 'Strategic adaptations',
        );
      } else if (req is Map<String, dynamic>) {
        await _viewModel.submitAdaptationAnalysis(
          strategy:  req['strategy']?.toString()  ?? await _getDefaultStrategy(),
          objective: req['objective']?.toString() ?? await _getDefaultObjective(),
          keyResult: req['keyResult']?.toString() ?? 'Adapted Key Result',
          challenge: req['challenge']?.toString() ?? 'Market Challenge',
          proposal:  req['proposal']?.toString()  ?? 'Strategic adaptations',
        );
      } else {
        await _viewModel.submitAdaptationAnalysis(
          strategy:  await _getDefaultStrategy(),
          objective: await _getDefaultObjective(),
          keyResult: 'Adapted Key Result',
          challenge: 'Market Challenge',
          proposal:  'Strategic adaptations to address market changes',
        );
      }
    } catch (e) { debugPrint('❌ Error running adaptation analysis: $e'); }
  }

  Future<String> _getDefaultStrategy() async {
    try {
      final d = await SharedPrefs.getSelectedStrategy();
      return d?['title']?.toString() ?? 'CEO Strategy';
    } catch (_) { return 'CEO Strategy'; }
  }

  Future<String> _getDefaultObjective() async {
    try {
      final d = await SharedPrefs.getSelectedObjective();
      return d?['title']?.toString() ?? 'Business Growth Objective';
    } catch (_) { return 'Business Growth Objective'; }
  }

  void _navigateBasedOnDecisionAndMode({
    required String decision,
    required String source,
    required bool hasData,
  }) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      final savedMode = await SharedPrefs.getGameModeAsync() ?? 'solo';
      final isAccepted = _isDecisionAccepted(decision);

      if (!isAccepted) {
        _currentRetry++;
        _saveRetryCount();
        if (_currentRetry >= _maxRetries) {
          await _showMaxRetriesDialog();
          _resetRetryCount();
          _navigateToHomeScreen();
        } else {
          await _showRetryDialog();
        }
        return;
      }
      _resetRetryCount();
      await _proceedWithAcceptedDecision(savedMode, source);
    } catch (e) {
      Get.snackbar('Navigation Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      _isNavigating = false;
    }
  }

  bool _isDecisionAccepted(String decision) {
    final d = decision.toLowerCase();
    return d.contains('accepted') ||
        d.contains('approved') ||
        (d.contains('review') && !d.contains('rejected'));
  }

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
            onPressed: () { Get.back(); _navigateToKeyObjectiveScreen(); },
            child: Text('try_again'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showMaxRetriesDialog() async {
    await Get.dialog(
      AlertDialog(
        title: Text('max_retries_reached'.tr),
        content: Text('${'max_retries_exceeded'.tr}\n\n${'returning_to_home_screen'.tr}'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('understand'.tr)),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _navigateToKeyObjectiveScreen() {
    Get.offAllNamed(AppRoutes.keyObjectiveScreen,
        parameters: {'isRetry': 'true'}, arguments: Get.arguments);
  }

  void _navigateToHomeScreen() {
    Get.offAllNamed(AppRoutes.home);
    Future.delayed(const Duration(milliseconds: 500), () {
      SnackbarHelper.info(
          'You have completed all 3 attempts. Please try again with a new strategy!');
    });
  }

  Future<void> _proceedWithAcceptedDecision(String savedMode, String source) async {
    switch (savedMode) {
      case 'solo':
        Get.offAllNamed(AppRoutes.gameCompleteScreen);
        break;
      case 'challenge':
        await _navigateChallengeMode();
        break;
      case 'campaign':
        await _navigateCampaignMode(source);
        break;
      default:
        Get.offAllNamed(AppRoutes.gameCompleteScreen);
    }
  }

  Future<void> _navigateChallengeMode() async {
    final challengeId = await SharedPrefs.getChallengeId();
    final userId = SharedPrefs.getUserId();
    if (challengeId == null || challengeId.isEmpty || userId == null || userId.isEmpty) {
      Get.snackbar('Error', 'Challenge data not found',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    Get.offAllNamed(AppRoutes.gameResultScreen, arguments: {
      'challengeId': challengeId,
      'userId': userId,
      'source': 'challenge_mode',
    });
  }

  Future<void> _navigateCampaignMode(String source) async {
    if (source == 'contextual_challenge' || source == 'challenge_adjustment') {
      final currentLevel = await _getCurrentCampaignLevel();
      if (currentLevel > 0 && currentLevel <= 3) {
        await CampaignProgressService.completeLevel(currentLevel);
      }
      Get.offAllNamed(AppRoutes.campaignModeScreen);
    } else {
      Get.offAllNamed(AppRoutes.campaignModeScreen);
    }
  }

  Future<int> _getCurrentCampaignLevel() async {
    try {
      final s = await SharedPrefs.getString('current_campaign_level');
      return int.tryParse(s ?? '1') ?? 1;
    } catch (_) { return 1; }
  }

  String _getDecisionFromScore(int score) {
    if (score >= 80) return 'Accepted'.tr;
    if (score >= 50) return 'Review Required'.tr;
    return 'Rejected'.tr;
  }

  String _getHeaderTitle(String source) =>
      source == 'challenge_adjustment' ? 'adaptation'.tr : 'suggestion'.tr;

  String _getHeaderHighlight(String source) =>
      source == 'challenge_adjustment' ? 'analysis'.tr : 'of_initiatives'.tr;

  String _getAnalysisTitle(String source) =>
      source == 'challenge_adjustment'
          ? 'Adaptation Analysis Results'
          : 'Initiative Analysis Results';

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
                  child: Obx(() => _buildContent(sw, sh, isDesktop: false)),
                ),
              ),
              Positioned(
                right: sw * -0.07,
                top: sh * 0.50,
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
    final double containerWidth = sw > 1200 ? 820.0 : sw * 0.76;

    return Scaffold(
      backgroundColor: Colors.white,
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
            child: Builder(builder: (_) {
              // ✅ Get.arguments is NOT reactive — must NOT be inside Obx
              final args = Get.arguments;
              final source = args is Map<String, dynamic>
                  ? args['source'] ?? 'initiative_analysis'
                  : 'initiative_analysis';
              return DesktopAppBar(
                screenWidth: sw,
                screenHeight: sh,
                title: _getHeaderTitle(source),
                subtitle: _getHeaderHighlight(source),
              );
            }),
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
                  child: Obx(() => _buildContent(sw, sh, isDesktop: true)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: CustomSvg(assetPath: 'assets/images/left.svg', semanticsLabel: ''),
            ),
          ),
          Positioned(
            bottom: 20, left: 0, right: -30,
            child: const Center(child: CustomHomeNavBar()),
          ),
        ],
      ),
    );
  }

  // ── SHARED CONTENT ─────────────────────────────────────────────────────────

  Widget _buildContent(double sw, double sh, {required bool isDesktop}) {
    // ✅ Read args ONCE outside Obx — Get.arguments is not reactive,
    //    wrapping it inside Obx was causing unnecessary rebuilds and
    //    potential null reads on re-renders after navigation.
    final dynamic args = Get.arguments;
    EvaluateInitiativeModel? evaluationData;
    String source = 'initiative_analysis';

    if (args is EvaluateInitiativeModel) {
      evaluationData = args;
    } else if (args is Map<String, dynamic>) {
      // ✅ Read viewModel.evaluationData.value INSIDE the calling Obx,
      //    not here — but since _buildContent is already called from
      //    inside Obx(() => ...) in both layouts, this is safe.
      if (_viewModel.evaluationData.value != null) {
        final ad = _viewModel.evaluationData.value!;
        evaluationData = EvaluateInitiativeModel(
          score: ad.score,
          decision: _getDecisionFromScore(ad.score),
          explanation: ad.feedback,
        );
        source = 'challenge_adjustment';
      } else if (args['analysisData'] != null) {
        evaluationData = args['analysisData'];
        source = args['source'] ?? 'challenge_adjustment';
      }
    }

    final bool hasData =
        evaluationData != null || _viewModel.evaluationData.value != null;
    final int score = evaluationData?.score ??
        _viewModel.evaluationData.value?.score ?? 0;
    final String decision =
        evaluationData?.decision ?? _getDecisionFromScore(score);
    final String explanation = evaluationData?.explanation ??
        _viewModel.evaluationData.value?.feedback ?? 'No analysis available';
    final bool isAccepted = _isDecisionAccepted(decision);
    final bool isHighScore = score >= 80;
    final bool isMediumScore = score >= 50 && score < 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isDesktop) ...[
          SizedBox(height: sh * 0.03),
          CustomHeader(
            title: _getHeaderTitle(source),
            highlightedText: _getHeaderHighlight(source),
            subtitle: '',
            onBackTap: () => Get.back(),
          ),
          SizedBox(height: sh * 0.02),
        ],

        // Analysis card — constrained width on desktop
        _viewModel.isSubmitting.value
            ? _buildLoadingCard(isDesktop: isDesktop)
            : hasData
            ? _buildAnalysisCard(
          percentage: score,
          decision: decision,
          explanation: explanation,
          isAccepted: isAccepted,
          isHighScore: isHighScore,
          isMediumScore: isMediumScore,
          source: source,
          isDesktop: isDesktop,
        )
            : _buildLoadingCard(isDesktop: isDesktop),

        SizedBox(height: isDesktop ? 20 : sh * 0.02),

        // Navigation button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 20.w),
          child: isDesktop
              ? Center(
            child: SizedBox(
              width: 320,
              child: _buildNavigationButton(
                source: source, hasData: hasData,
                decision: decision, isAccepted: isAccepted,
              ),
            ),
          )
              : _buildNavigationButton(
            source: source, hasData: hasData,
            decision: decision, isAccepted: isAccepted,
          ),
        ),
        SizedBox(height: isDesktop ? 8 : sh * 0.001),
      ],
    );
  }

  // ── WIDGETS ────────────────────────────────────────────────────────────────

  Widget _buildNavigationButton({
    required String source,
    required bool hasData,
    required String decision,
    required bool isAccepted,
  }) {
    if (_viewModel.isSubmitting.value) {
      return CustomButton(text: 'analyzing'.tr, onPressed: () {});
    }
    if (!isAccepted) {
      return CustomButton(
        text: 'try_again'.tr,
        backgroundColor: AppColors.primaryRed,
        onPressed: () => _navigateBasedOnDecisionAndMode(
            decision: decision, source: source, hasData: hasData),
      );
    }
    switch (source) {
      case 'initiative_analysis':
        return CustomButton(
          text: 'check_contextual_challenge'.tr,
          onPressed: hasData
              ? () => Get.toNamed(AppRoutes.contextualChallenge, arguments: {
            'analysisData': Get.arguments,
            'source': 'initiative_analysis',
          })
              : () {},
        );
      case 'challenge_adjustment':
        return CustomButton(
          text: 'proceed_to_results'.tr,
          onPressed: () => _navigateBasedOnDecisionAndMode(
              decision: decision, source: source, hasData: hasData),
        );
      default:
        return CustomButton(
          text: 'continue'.tr,
          onPressed: () => _navigateBasedOnDecisionAndMode(
              decision: decision, source: source, hasData: hasData),
        );
    }
  }

  Widget _buildAnalysisCard({
    required int percentage,
    required String decision,
    required String explanation,
    required bool isAccepted,
    required bool isHighScore,
    required bool isMediumScore,
    required String source,
    required bool isDesktop,
  }) {
    Color containerColor;
    IconData statusIcon;

    if (isHighScore) {
      containerColor = const Color(0xff8DC046);
      statusIcon = Icons.sentiment_very_satisfied;
    } else if (isMediumScore) {
      containerColor = Colors.orange;
      statusIcon = Icons.sentiment_neutral;
    } else {
      containerColor = Colors.red.shade400;
      statusIcon = Icons.sentiment_dissatisfied;
    }

    final double hPad = isDesktop ? 0 : 16.w;
    final double innerPad = isDesktop ? 20 : 20.w;
    final double radius = isDesktop ? 24 : 24.r;
    final double imgSize = isDesktop ? 80 : 100.h;
    final double scoreFSize = isDesktop ? 28 : 32.sp;
    final double iconFSize = isDesktop ? 28 : 32.sp;
    final double textFSize = isDesktop ? 13 : 14.sp;
    final double titleFSize = isDesktop ? 18 : 20.sp;
    final double expFSize = isDesktop ? 13 : 15.sp;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xff8DC046),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          children: [
            // Header — robot + title
            Container(
              color: const Color(0xff8DC046),
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 24 : 32.h),
              child: Column(
                children: [
                  Image.asset('assets/images/robort.png',
                      height: imgSize, width: imgSize),
                  SizedBox(height: isDesktop ? 8 : 8.h),
                  Text(
                    _getAnalysisTitle(source),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 16 : 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isAccepted) ...[
                    SizedBox(height: isDesktop ? 8 : 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 12 : 12.w,
                        vertical: isDesktop ? 4 : 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 12.r),
                      ),
                      child: Text(
                        '${'retry'.tr} $_currentRetry ${'of'.tr} $_maxRetries',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 11 : 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Score bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 14 : 16.h),
              color: const Color(0xffC8CD37),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(statusIcon, color: Colors.black, size: iconFSize),
                  SizedBox(width: isDesktop ? 10 : 12.w),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: scoreFSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Threshold label
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isDesktop ? 10 : 12.h),
              color: const Color(0xffC8CD37),
              child: Text(
                '${_safeTranslate('relevance_threshold')}: >80%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: textFSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Explanation card
            Padding(
              padding: EdgeInsets.all(innerPad),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(innerPad),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isDesktop ? 16 : 16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 8 : 8.w),
                          decoration: BoxDecoration(
                            color: containerColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAccepted
                                ? Icons.lightbulb
                                : Icons.warning_amber_rounded,
                            color: containerColor,
                            size: isDesktop ? 22 : 24.sp,
                          ),
                        ),
                        SizedBox(width: isDesktop ? 10 : 12.w),
                        Expanded(
                          child: Text(
                            decision,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: titleFSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isDesktop ? 14 : 16.h),
                    Text(
                      explanation,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: expFSize,
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

  Widget _buildLoadingCard({required bool isDesktop}) {
    final double hPad = isDesktop ? 0 : 16.w;
    final double pad = isDesktop ? 32 : 40.w;
    final double imgSize = isDesktop ? 80 : 100.h;
    final double radius = isDesktop ? 24 : 24.r;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: const Color(0xFFBFD200),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          children: [
            SvgPicture.asset('assets/images/robot.svg',
                height: imgSize, width: imgSize),
            SizedBox(height: isDesktop ? 16 : 20.h),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: isDesktop ? 16 : 20.h),
            Text(
              _viewModel.isSubmitting.value
                  ? 'Running Adaptation Analysis...'
                  : _safeTranslate('loading_analysis',
                  fallback: 'Analyzing initiatives...'),
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 14 : 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../core/app_dimensions.dart';
// import '../../../core/app_colors.dart';
// import '../../../data/network/network_api_services.dart';
// import '../../../data/response/api_response.dart';
// import '../../../generated/models/requests/adaptation_analysis_model.dart';
// import '../../../generated/models/responses/evaluate_initiative/evaluate_initiative_model.dart';
// import '../../../services/shared_preference.dart';
// import '../../../utils/snackbar_helper.dart';
// import '../../../view_model/challange_view_models/adaptation_ai_analysis-viewmodel.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/campaign_progress_service.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_home_navbar.dart';
// import '../../widgets/screens_unique_parts/custom_background.dart';
// import '../../widgets/screens_unique_parts/custom_header.dart';
//
// class AIAnalysisShowScreen extends StatefulWidget {
//   const AIAnalysisShowScreen({super.key});
//
//   @override
//   State<AIAnalysisShowScreen> createState() => _AIAnalysisShowScreenState();
// }
//
//
// class _AIAnalysisShowScreenState extends State<AIAnalysisShowScreen> {
//   late final AdaptationAIAnalysisViewModel _viewModel;
//   final int _maxRetries = 3;
//   int _currentRetry = 0;
//   bool _isNavigating = false;
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
//   @override
//   void initState() {
//     super.initState();
//     _viewModel = Get.put(AdaptationAIAnalysisViewModel());
//     _loadRetryCount();
//     _handleAnalysisBasedOnSource();
//   }
//
//   /// Load current retry count from SharedPreferences
//   void _loadRetryCount() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _currentRetry = prefs.getInt('analysis_retry_count') ?? 0;
//       print('🔄 Current retry count: $_currentRetry/$_maxRetries');
//     } catch (e) {
//       print('❌ Error loading retry count: $e');
//       _currentRetry = 0;
//     }
//   }
//
//   /// Save retry count to SharedPreferences
//   void _saveRetryCount() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('analysis_retry_count', _currentRetry);
//       print('💾 Saved retry count: $_currentRetry');
//     } catch (e) {
//       print('❌ Error saving retry count: $e');
//     }
//   }
//
//   /// Reset retry count
//   void _resetRetryCount() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('analysis_retry_count', 0);
//       _currentRetry = 0;
//       print('🔄 Retry count reset to 0');
//     } catch (e) {
//       print('❌ Error resetting retry count: $e');
//     }
//   }
//
//   void _handleAnalysisBasedOnSource() async {
//     try {
//       final dynamic arguments = Get.arguments;
//       final source = arguments is Map<String, dynamic>
//           ? arguments['source'] ?? ''
//           : '';
//       final adaptationRequest = arguments is Map<String, dynamic>
//           ? arguments['adaptationRequest']
//           : null;
//
//       print('📍 Analysis Source: $source');
//       print('📦 Has Adaptation Request: ${adaptationRequest != null}');
//
//       // Handle BOTH sources properly
//       if (source == 'challenge_adjustment' && adaptationRequest != null) {
//         print('🔄 Running adaptation analysis from challenge adjustment...');
//         await _runAdaptationAnalysis(adaptationRequest);
//       } else if (source == 'contextual_challenge') {
//         print('🔄 Analysis from contextual challenge - skipping adaptation');
//       } else {
//         print('ℹ️ No adaptation analysis needed for source: $source');
//       }
//     } catch (e) {
//       print('❌ Error in analysis handling: $e');
//     }
//   }
//   Future<void> _runAdaptationAnalysis(dynamic adaptationRequest) async {
//     try {
//       // ✅ FIXED: Extract parameters from adaptationRequest and call the new method
//       if (adaptationRequest is AdaptationAnalysisRequest) {
//         await _viewModel.submitAdaptationAnalysis(
//           strategy: adaptationRequest.strategy,
//           objective: adaptationRequest.objective,
//           keyResult: adaptationRequest.keyResult,
//           challenge: adaptationRequest.challenge,
//           proposal: adaptationRequest.proposal ?? 'Strategic adaptations', // Provide default
//         );
//       } else if (adaptationRequest is Map<String, dynamic>) {
//         // Handle if it's a map instead of the model
//         await _viewModel.submitAdaptationAnalysis(
//           strategy: adaptationRequest['strategy']?.toString() ?? await _getDefaultStrategy(),
//           objective: adaptationRequest['objective']?.toString() ?? await _getDefaultObjective(),
//           keyResult: adaptationRequest['keyResult']?.toString() ?? 'Adapted Key Result',
//           challenge: adaptationRequest['challenge']?.toString() ?? 'Market Challenge',
//           proposal: adaptationRequest['proposal']?.toString() ?? 'Strategic adaptations',
//         );
//       } else {
//         // Fallback with default values
//         print('⚠️ Adaptation request type not recognized, using default values');
//         await _viewModel.submitAdaptationAnalysis(
//           strategy: await _getDefaultStrategy(),
//           objective: await _getDefaultObjective(),
//           keyResult: 'Adapted Key Result',
//           challenge: 'Market Challenge',
//           proposal: 'Strategic adaptations to address market changes',
//         );
//       }
//       print('✅ Adaptation analysis completed');
//     } catch (e) {
//       print('❌ Error running adaptation analysis: $e');
//     }
//   }
//
// // ✅ Add these helper methods to get default values
//   Future<String> _getDefaultStrategy() async {
//     try {
//       final strategyData = await SharedPrefs.getSelectedStrategy();
//       return strategyData?['title']?.toString() ?? 'CEO Strategy';
//     } catch (e) {
//       return 'CEO Strategy';
//     }
//   }
//
//   Future<String> _getDefaultObjective() async {
//     try {
//       final objectiveData = await SharedPrefs.getSelectedObjective();
//       return objectiveData?['title']?.toString() ?? 'Business Growth Objective';
//     } catch (e) {
//       return 'Business Growth Objective';
//     }
//   }
//   void _navigateBasedOnDecisionAndMode({
//     required String decision,
//     required String source,
//     required bool hasData,
//   }) async {
//     if (_isNavigating) return;
//     _isNavigating = true;
//
//     try {
//       final savedMode = await SharedPrefs.getGameMode() ?? 'solo';
//       final isDecisionAccepted = _isDecisionAccepted(decision);
//
//       print('🎯 Navigation Decision:');
//       print('   - Decision: $decision (Accepted: $isDecisionAccepted)');
//       print('   - Game Mode: $savedMode');
//       print('   - Source: $source');
//       print('   - Retry Count: $_currentRetry/$_maxRetries');
//
//       // 🚫 HANDLE REJECTED DECISION
//       if (!isDecisionAccepted) {
//         _currentRetry++;
//         _saveRetryCount();
//
//         if (_currentRetry >= _maxRetries) {
//           print(
//             '❌ Max retries reached ($_maxRetries). Navigating to home screen.',
//           );
//           await _showMaxRetriesDialog();
//           _resetRetryCount();
//           _navigateToHomeScreen(); // ✅ Navigate to home screen
//         } else {
//           print('🔄 Decision rejected. Retry $_currentRetry/$_maxRetries');
//           await _showRetryDialog();
//         }
//         return;
//       }
//
//       // ✅ HANDLE ACCEPTED DECISION - Reset retry count and proceed
//       _resetRetryCount();
//       await _proceedWithAcceptedDecision(savedMode, source);
//     } catch (e) {
//       print('❌ Error in navigation: $e');
//       Get.snackbar(
//         'Navigation Error',
//         'Failed to navigate: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       _isNavigating = false;
//     }
//   }
//
//   /// Check if decision is accepted
//   bool _isDecisionAccepted(String decision) {
//     final lowerDecision = decision.toLowerCase();
//     return lowerDecision.contains('accepted') ||
//         lowerDecision.contains('approved') ||
//         (lowerDecision.contains('review') &&
//             !lowerDecision.contains('rejected'));
//   }
//
//   /// Show retry dialog for rejected decisions
//   Future<void> _showRetryDialog() async {
//     await Get.dialog(
//       AlertDialog(
//         title: Text('initiative_rejected'.tr),
//         content: Text(
//           '${'initiative_needs_improvement'.tr}\n\n'
//           '${'retry_count'.tr}: $_currentRetry/$_maxRetries\n'
//           '${'suggest_improve_initiatives'.tr}',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back();
//               _navigateToKeyObjectiveScreen();
//             },
//             child: Text('try_again'.tr),
//           ),
//         ],
//       ),
//       barrierDismissible: false,
//     );
//   }
//
//   /// Show max retries reached dialog
//   Future<void> _showMaxRetriesDialog() async {
//     await Get.dialog(
//       AlertDialog(
//         title: Text('max_retries_reached'.tr),
//         content: Text(
//           '${'max_retries_exceeded'.tr}\n\n'
//           '${'returning_to_home_screen'.tr}',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back();
//             },
//             child: Text('understand'.tr),
//           ),
//         ],
//       ),
//       barrierDismissible: false,
//     );
//   }
//
//   /// Navigate to key objective screen for retry
//   void _navigateToKeyObjectiveScreen() {
//     print('🔄 Navigating back to Key Objective Screen for retry');
//
//     // Get current arguments to pass them back
//     final currentArgs = Get.arguments;
//
//     Get.offAllNamed(
//       AppRoutes.keyObjectiveScreen,
//       parameters: {'isRetry': 'true'},
//       arguments: currentArgs,
//     );
//   }
//
//   /// ✅ NEW: Navigate to home screen when max retries reached
//   void _navigateToHomeScreen() {
//     print('🏠 Max retries reached - Navigating to home screen');
//
//     // Clear all navigation stack and go to home
//     Get.offAllNamed(AppRoutes.home); // Replace with your actual home route
//
//     // Optional: Show a completion message
//     Future.delayed(const Duration(milliseconds: 500), () {
//       SnackbarHelper.info(
//         'You have completed all 3 attempts. Please try again with a new strategy!',
//       );
//     });
//   }
//
//   /// ✅ PROCEED WITH ACCEPTED DECISION - Different paths for each mode
//   Future<void> _proceedWithAcceptedDecision(
//     String savedMode,
//     String source,
//   ) async {
//     print('✅ Decision accepted! Proceeding with navigation...');
//
//     switch (savedMode) {
//       case 'solo':
//         print('➡️ Solo Mode: Navigating to Game Complete Screen');
//         Get.offAllNamed(AppRoutes.gameCompleteScreen);
//         break;
//
//       case 'challenge':
//         print('➡️ Challenge Mode: Navigating to Game Result Screen');
//         await _navigateChallengeMode();
//         break;
//
//       case 'campaign':
//         print('➡️ Campaign Mode: Source - $source');
//         await _navigateCampaignMode(source);
//         break;
//
//       default:
//         print('➡️ Default Mode: Navigating to Game Complete Screen');
//         Get.offAllNamed(AppRoutes.gameCompleteScreen);
//         break;
//     }
//   }
//
//   /// 🎮 Challenge Mode Navigation
//   Future<void> _navigateChallengeMode() async {
//     final challengeId = await SharedPrefs.getChallengeId();
//     final userId = SharedPrefs.getUserId();
//
//     if (challengeId == null ||
//         challengeId.isEmpty ||
//         userId == null ||
//         userId.isEmpty) {
//       print('❌ Challenge ID or User ID not found');
//       Get.snackbar(
//         'Error',
//         'Challenge data not found',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }
//
//     print('✅ Challenge ID: $challengeId, User ID: $userId');
//     Get.offAllNamed(
//       AppRoutes.gameResultScreen,
//       arguments: {
//         'challengeId': challengeId,
//         'userId': userId,
//         'source': 'challenge_mode',
//       },
//     );
//   }
//
//   // In AIAnalysisShowScreen - replace _navigateCampaignMode method
//   Future<void> _navigateCampaignMode(String source) async {
//     print('🏆 Campaign Mode Navigation - Source: $source');
//
//     if (source == 'contextual_challenge' || source == 'challenge_adjustment') {
//       print('➡️ Campaign Mode: Completing current level and navigating...');
//
//       // Get current campaign level
//       final currentLevel = await _getCurrentCampaignLevel();
//       print('🎯 Current campaign level: $currentLevel');
//
//       // Complete the current level
//       if (currentLevel > 0 && currentLevel <= 3) {
//         await CampaignProgressService.completeLevel(currentLevel);
//         print('✅ Level $currentLevel marked as completed');
//       }
//
//
//       // Navigate back to campaign screen
//       print('➡️ Returning to Campaign Mode Screen');
//       Get.offAllNamed(AppRoutes.campaignModeScreen);
//     } else {
//       print('➡️ Campaign Mode: Default navigation to Campaign Mode Screen');
//       Get.offAllNamed(AppRoutes.campaignModeScreen);
//     }
//   }
//
// // ✅ ADD THIS HELPER METHOD
//   Future<int> _getCurrentCampaignLevel() async {
//     try {
//       final levelStr = await SharedPrefs.getString('current_campaign_level');
//       return int.tryParse(levelStr ?? '1') ?? 1;
//     } catch (e) {
//       print('❌ Error getting current campaign level: $e');
//       return 1;
//     }
//   }
//   //
//   // /// 🏆 Campaign Mode Navigation
//   // Future<void> _navigateCampaignMode(String source) async {
//   //   if (source == 'contextual_challenge' || source == 'challenge_adjustment') {
//   //     print(
//   //       '➡️ Campaign Mode: Completing levels and navigating to Game Complete',
//   //     );
//   //     await CampaignProgressService.completeLevel(1);
//   //     await CampaignProgressService.completeLevel(2);
//   //     await CampaignProgressService.completeLevel(3);
//   //     Get.offAllNamed(AppRoutes.gameCompleteScreen);
//   //   } else {
//   //     print('➡️ Campaign Mode: Default navigation to Campaign Mode Screen');
//   //     Get.offAllNamed(AppRoutes.campaignModeScreen);
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
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
//                   child: Obx(() {
//                     final dynamic arguments = Get.arguments;
//
//                     EvaluateInitiativeModel? evaluationData;
//                     String source = 'initiative_analysis';
//
//                     if (arguments is EvaluateInitiativeModel) {
//                       evaluationData = arguments;
//                       source = 'initiative_analysis';
//                     } else if (arguments is Map<String, dynamic>) {
//                       if (_viewModel.evaluationData.value != null) {
//                         final adaptationData = _viewModel.evaluationData.value!;
//                         evaluationData = EvaluateInitiativeModel(
//                           score: adaptationData.score,
//                           decision: _getDecisionFromScore(adaptationData.score),
//                           explanation: adaptationData.feedback,
//                         );
//                         source = 'challenge_adjustment';
//                       } else if (arguments['analysisData'] != null) {
//                         evaluationData = arguments['analysisData'];
//                         source = arguments['source'] ?? 'challenge_adjustment';
//                       }
//                     }
//
//                     final bool hasData =
//                         evaluationData != null ||
//                         _viewModel.evaluationData.value != null;
//                     final int score =
//                         evaluationData?.score ??
//                         _viewModel.evaluationData.value?.score ??
//                         0;
//                     final String decision =
//                         evaluationData?.decision ??
//                         _getDecisionFromScore(score);
//                     final String explanation =
//                         evaluationData?.explanation ??
//                         _viewModel.evaluationData.value?.feedback ??
//                         'No analysis available';
//                     final bool isAccepted = _isDecisionAccepted(decision);
//                     final bool isHighScore = score >= 80;
//                     final bool isMediumScore = score >= 50 && score < 80;
//                     final int percentage = score;
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         SizedBox(height: screenHeight * 0.03),
//                         CustomHeader(
//                           title: _getHeaderTitle(source),
//                           highlightedText: _getHeaderHighlight(source),
//                           subtitle: '',
//                           onBackTap: () => Get.back(),
//                         ),
//                         SizedBox(height: screenHeight * 0.02),
//                         if (_viewModel.isSubmitting.value)
//                           _buildLoadingCard()
//                         else if (hasData)
//                           _buildAnalysisContainer(
//                             percentage: percentage,
//                             decision: decision,
//                             explanation: explanation,
//                             isAccepted: isAccepted,
//                             isHighScore: isHighScore,
//                             isMediumScore: isMediumScore,
//                             source: source,
//                             retryCount: '$_currentRetry/$_maxRetries',
//                           )
//                         else
//                           _buildLoadingCard(),
//                         SizedBox(height: screenHeight * 0.02),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 20.w),
//                           child: _buildNavigationButton(
//                             source: source,
//                             hasData: hasData,
//                             decision: decision,
//                             isAccepted: isAccepted,
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.001),
//                         // SizedBox(height: screenHeight * 0.001),
//                         // SizedBox(height: screenHeight * 0.001),
//                         // CustomButton(
//                         //   text: "phase_retry_test".tr,
//                         //   onPressed: () {
//                         //     Get.toNamed(AppRoutes.contextualChallenge);
//                         //   },
//                         // ),
//                         SizedBox(height: screenHeight * 0.001),
//                       ],
//                     );
//                   }),
//                 ),
//               ),
//
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
//   String _getDecisionFromScore(int score) {
//     if (score >= 80) return 'Accepted'.tr;
//     if (score >= 50) return 'Review Required'.tr;
//     return 'Rejected'.tr;
//   }
//
//   String _getHeaderTitle(String source) {
//     switch (source) {
//       case 'challenge_adjustment':
//         return 'adaptation'.tr;
//       case 'initiative_analysis':
//       default:
//         return 'suggestion'.tr;
//     }
//   }
//
//   String _getHeaderHighlight(String source) {
//     switch (source) {
//       case 'challenge_adjustment':
//         return 'analysis'.tr;
//       case 'initiative_analysis':
//       default:
//         return 'of_initiatives'.tr;
//     }
//   }
//
//   /// 🎯 UPDATED: Navigation button based on decision and mode
//   Widget _buildNavigationButton({
//     required String source,
//     required bool hasData,
//     required String decision,
//     required bool isAccepted,
//   }) {
//     if (_viewModel.isSubmitting.value) {
//       return CustomButton(text: 'analyzing'.tr, onPressed: () {});
//     }
//
//     // 🚫 REJECTED DECISION - Show Try Again button
//     if (!isAccepted) {
//       return CustomButton(
//         text: 'try_again'.tr,
//         onPressed: () => _navigateBasedOnDecisionAndMode(
//           decision: decision,
//           source: source,
//           hasData: hasData,
//         ),
//         backgroundColor: AppColors.primaryRed,
//       );
//     }
//
//     // ✅ ACCEPTED DECISION - Show appropriate button based on source
//     switch (source) {
//       case 'initiative_analysis':
//         return CustomButton(
//           text: 'check_contextual_challenge'.tr,
//           onPressed: hasData
//               ? () => Get.toNamed(
//                   AppRoutes.contextualChallenge,
//                   arguments: {
//                     'analysisData': Get.arguments,
//                     'source': 'initiative_analysis',
//                   },
//                 )
//               : () {},
//         );
//       case 'challenge_adjustment':
//         return CustomButton(
//           text: 'proceed_to_results'.tr,
//           onPressed: () => _navigateBasedOnDecisionAndMode(
//             decision: decision,
//             source: source,
//             hasData: hasData,
//           ),
//         );
//       default:
//         return CustomButton(
//           text: 'continue'.tr,
//           onPressed: () => _navigateBasedOnDecisionAndMode(
//             decision: decision,
//             source: source,
//             hasData: hasData,
//           ),
//         );
//     }
//   }
//
//   Widget _buildAnalysisContainer({
//     required int percentage,
//     required String decision,
//     required String explanation,
//     required bool isAccepted,
//     required bool isHighScore,
//     required bool isMediumScore,
//     required String source,
//     required String retryCount,
//   }) {
//     Color containerColor;
//     Color percentageBarColor;
//     Color iconColor;
//     IconData statusIcon;
//
//     if (isHighScore) {
//       containerColor = const Color(0xff8DC046);
//       percentageBarColor = const Color(0xFFA3B800);
//       iconColor = const Color(0xFF2D5016);
//       statusIcon = Icons.sentiment_very_satisfied;
//     } else if (isMediumScore) {
//       containerColor = Colors.orange;
//       percentageBarColor = Colors.orange.shade700;
//       iconColor = Colors.orange.shade900;
//       statusIcon = Icons.sentiment_neutral;
//     } else {
//       containerColor = Colors.red.shade400;
//       percentageBarColor = Colors.red.shade700;
//       iconColor = Colors.red.shade900;
//       statusIcon = Icons.sentiment_dissatisfied;
//     }
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: const Color(0xff8DC046),
//           borderRadius: BorderRadius.circular(24.r),
//         ),
//         child: Column(
//           children: [
//             Container(
//               decoration: const BoxDecoration(color: Color(0xff8DC046)),
//               padding: EdgeInsets.symmetric(vertical: 32.h),
//               child: Column(
//                 children: [
//                   Image.asset("assets/images/robort.png",height: 100,width: 100,),
//                   // SvgPicture.asset(
//                   //   "assets/images/robot.svg",
//                   //   height: 100.h,
//                   //   width: 100.w,
//                   // ),
//                   SizedBox(height: 8.h),
//                   Text(
//                     _getAnalysisTitle(source),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   if (!isAccepted) ...[
//                     SizedBox(height: 8.h),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 4.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade600,
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Text(
//                         '${'retry'.tr} $_currentRetry ${'of'.tr} $_maxRetries',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(vertical: 16.h),
//               decoration: const BoxDecoration(color: Color(0xffC8CD37)),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(statusIcon, color: Colors.black, size: 32.sp),
//                   SizedBox(width: 12.w),
//                   Text(
//                     '$percentage%',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 32.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(vertical: 12.h),
//               decoration: const BoxDecoration(color: Color(0xffC8CD37)),
//               child: Text(
//                 _safeTranslate('relevance_threshold') + ': >80%',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(16.w),
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(20.w),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16.r),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(8.w),
//                           decoration: BoxDecoration(
//                             color: containerColor.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             isAccepted
//                                 ? Icons.lightbulb
//                                 : Icons.warning_amber_rounded,
//                             color: containerColor,
//                             size: 24.sp,
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Expanded(
//                           child: Text(
//                             decision,
//                             style: TextStyle(
//                               color: Colors.black87,
//                               fontSize: 20.sp,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16.h),
//                     Text(
//                       explanation,
//                       style: TextStyle(
//                         color: Colors.black54,
//                         fontSize: 15.sp,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getAnalysisTitle(String source) {
//     switch (source) {
//       case 'challenge_adjustment':
//         return 'Adaptation Analysis Results';
//       case 'initiative_analysis':
//       default:
//         return 'Initiative Analysis Results';
//     }
//   }
//
//   Widget _buildLoadingCard() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(40.w),
//         decoration: BoxDecoration(
//           color: const Color(0xFFBFD200),
//           borderRadius: BorderRadius.circular(24.r),
//         ),
//         child: Column(
//           children: [
//             SvgPicture.asset(
//               "assets/images/robot.svg",
//               height: 100.h,
//               width: 100.w,
//             ),
//             SizedBox(height: 20.h),
//             const CircularProgressIndicator(
//               color: Colors.white,
//               strokeWidth: 3,
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               _viewModel.isSubmitting.value
//                   ? 'Running Adaptation Analysis...'
//                   : _safeTranslate(
//                       'loading_analysis',
//                       fallback: 'Analyzing initiatives...',
//                     ),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }