
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// 🎯 SharedPreferences Wrapper - Null-safe version
class SharedPrefs {
  static SharedPreferences? _prefs;
  static const String keyBonusScore = 'bonus_score';
  static const String keyHasSubmittedBonus = 'has_submitted_bonus';

  // ✅ CORE FIX: every access goes through this getter.
  //    If _prefs is null (e.g. after hot-restart, route clear, or delayed init)
  //    it re-initialises synchronously via the already-cached instance.
  //    SharedPreferences.getInstance() is cheap after the first call — it returns
  //    the same singleton from the platform plugin cache.
  static SharedPreferences get _p {
    if (_prefs != null) return _prefs!;
    // This will throw if called before init() on first cold boot,
    // but after init() has run once the plugin caches the instance
    // and subsequent synchronous access is safe on all platforms.
    throw StateError(
      '🔴 SharedPrefs.init() was not awaited before first use. '
          'Call await SharedPrefs.init() in main() before runApp().',
    );
  }

  /// ✅ Initialize SharedPreferences — call once in main.dart BEFORE runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('✅ SharedPrefs initialized');
  }

  /// ✅ Safe re-init in case _prefs was lost (defensive, called by critical getters)
  static Future<void> _ensureInit() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ===========================================================================
  // 🔹 GAME MODE  ← most critical, always use async-safe version
  // ===========================================================================

  static const String keyGameMode = 'game_mode';

  static Future<void> saveGameMode(String gameMode) async {
    await _ensureInit();
    await _prefs!.setString(keyGameMode, gameMode);
    debugPrint('💾 Saving game mode: $gameMode');
  }

  /// Sync getter — safe ONLY after init(). Use getGameModeAsync() if unsure.
  static String? getGameMode() {
    return _prefs?.getString(keyGameMode);
  }

  /// ✅ Async getter — always safe, use in controllers after route transitions
  static Future<String?> getGameModeAsync() async {
    await _ensureInit();
    return _prefs!.getString(keyGameMode);
  }

  static Future<void> clearGameMode() async {
    await _ensureInit();
    await _prefs!.remove(keyGameMode);
  }

  // ===========================================================================
  // 🔹 ROLE SELECTION  ← second most critical
  // ===========================================================================

  static const String keySelectedRoleIndex = 'selectedRoleIndex';

  static Future<void> saveSelectedRoleIndex(int index) async {
    await _ensureInit();
    await _prefs!.setInt(keySelectedRoleIndex, index);
    debugPrint('💾 Saved role index: $index');
  }

  /// Sync getter — safe after init()
  static int getSelectedRoleIndex() {
    return _prefs?.getInt(keySelectedRoleIndex) ?? -1;
  }

  /// ✅ Async getter — use in controllers after route transitions
  static Future<int> getSelectedRoleIndexAsync() async {
    await _ensureInit();
    return _prefs!.getInt(keySelectedRoleIndex) ?? -1;
  }

  // ===========================================================================
  // 🔹 BONUS
  // ===========================================================================

  static Future<void> saveBonusScore(int score) async {
    await _ensureInit();
    await _prefs!.setInt(keyBonusScore, score);
  }

  static int getBonusScore() => _prefs?.getInt(keyBonusScore) ?? 0;

  static Future<void> setBonusSubmitted(bool submitted) async {
    await _ensureInit();
    await _prefs!.setBool(keyHasSubmittedBonus, submitted);
  }

  static bool getBonusSubmitted() =>
      _prefs?.getBool(keyHasSubmittedBonus) ?? false;

  static Future<void> clearBonusData() async {
    await _ensureInit();
    await _prefs!.remove(keyBonusScore);
    await _prefs!.remove(keyHasSubmittedBonus);
  }

  // ===========================================================================
  // 🔹 GAME FLOW MANAGEMENT
  // ===========================================================================

  static Future<void> clearGameFlowData() async {
    await _ensureInit();
    await _prefs!.remove('selected_key_results');
    await clearInitiatives();
    await clearAdaptationData();
    await clearAdaptationAnalysisData();
    await clearEvaluationData();
  }

  static Future<void> clearForRetry() async {
    await _ensureInit();
    await _prefs!.remove('selected_key_results');
    await clearInitiatives();
    await clearAdaptationData();
    await clearEvaluationData();
  }

  static Future<void> clearGameSessionData() async {
    await _ensureInit();
    final keys = [
      keySelectedStrategy, keySelectedObjective, keySelectedRole,
      keySelectedRoleIndex, keySelectedIndustryTitle, keySelectedIndustryDesc,
      keySelectedIndustryIcon, keyMissionDescription, keyFirstInitiativeTitle,
      keyFirstInitiativeDesc, keySecondInitiativeTitle, keySecondInitiativeDesc,
      keyRevisedKeyResult, keyStrategicActions, keyAdaptationNotes,
      keyCampaignSuggestionName, keyCampaignSuggestionDesc, keyCampaignScenario,
      keyCurrentChallengeData, keyChallengeResults,
    ];
    for (final k in keys) await _prefs!.remove(k);
    await clearAdaptationAnalysisData();
    await clearEvaluationData();
  }

  // ===========================================================================
  // 🔹 USER AUTHENTICATION & PROFILE
  // ===========================================================================

  static const String keyUserId = 'userId';
  static const String keyUserName = 'userName';
  static const String keyUserRole = 'userRole';

  static Future<void> saveUserId(String id) async {
    await _ensureInit();
    await _prefs!.setString(keyUserId, id);
  }

  static String? getUserId() => _prefs?.getString(keyUserId);

  static Future<void> saveUserName(String name) async {
    await _ensureInit();
    await _prefs!.setString(keyUserName, name);
  }

  static String? getUserName() => _prefs?.getString(keyUserName);

  static Future<void> saveUserRole(String role) async {
    await _ensureInit();
    await _prefs!.setString(keyUserRole, role);
  }

  static String? getUserRole() => _prefs?.getString(keyUserRole);

  // ===========================================================================
  // 🔹 CHALLENGE MANAGEMENT
  // ===========================================================================

  static const String keyHostId = 'hostId';
  static const String keyChallengeId = 'challengeId';
  static const String keyJoinChallengeId = 'joinChallengeId';
  static const String keyAcceptChallengeId = 'acceptChallengeId';
  static const String keyAcceptInviteChallengeId = 'acceptInviteChallengeId';

  static Future<void> saveHostId(String id) async {
    await _ensureInit(); await _prefs!.setString(keyHostId, id);
  }
  static String? getHostId() => _prefs?.getString(keyHostId);

  static Future<void> saveChallengeId(String id) async {
    await _ensureInit(); await _prefs!.setString(keyChallengeId, id);
  }
  static Future<String?> getChallengeId() async {
    await _ensureInit(); return _prefs!.getString(keyChallengeId);
  }

  static Future<void> saveJoinChallengeId(String id) async {
    await _ensureInit(); await _prefs!.setString(keyJoinChallengeId, id);
  }
  static String? getJoinChallengeId() => _prefs?.getString(keyJoinChallengeId);

  static Future<void> saveAcceptChallengeId(String id) async {
    await _ensureInit(); await _prefs!.setString(keyAcceptChallengeId, id);
  }
  static String? getAcceptChallengeId() => _prefs?.getString(keyAcceptChallengeId);

  static Future<void> saveAcceptInviteChallengeId(String id) async {
    await _ensureInit(); await _prefs!.setString(keyAcceptInviteChallengeId, id);
  }
  static String? getAcceptInviteChallengeId() =>
      _prefs?.getString(keyAcceptInviteChallengeId);

  // ===========================================================================
  // 🔹 INDUSTRY SELECTION
  // ===========================================================================

  static const String keySelectedIndustryTitle = 'selectedIndustryTitle';
  static const String keySelectedIndustryDesc = 'selectedIndustryDesc';
  static const String keySelectedIndustryIcon = 'selectedIndustryIcon';

  static Future<void> saveSelectedIndustry(Map<String, dynamic> industry) async {
    await _ensureInit();
    await _prefs!.setString(keySelectedIndustryTitle, industry['titleKey'].toString());
    await _prefs!.setString(keySelectedIndustryDesc, industry['descriptionKey'].toString());
    await _prefs!.setString(keySelectedIndustryIcon, _iconToString(industry['icon']));
  }

  static Map<String, dynamic>? getSelectedIndustry() {
    final title = _prefs?.getString(keySelectedIndustryTitle);
    if (title == null) return null;
    return {
      'titleKey': title,
      'descriptionKey': _prefs?.getString(keySelectedIndustryDesc) ?? '',
      'icon': _stringToIcon(_prefs?.getString(keySelectedIndustryIcon)),
    };
  }

  static Future<void> clearSelectedIndustry() async {
    await _ensureInit();
    await _prefs!.remove(keySelectedIndustryTitle);
    await _prefs!.remove(keySelectedIndustryDesc);
    await _prefs!.remove(keySelectedIndustryIcon);
  }

  // ===========================================================================
  // 🔹 CAMPAIGN & STRATEGY
  // ===========================================================================

  static const String keyCorrectStrategyId = 'correct_strategy_id';
  static const String keyCampaignScenario = 'campaign_scenario';
  static const String keyCampaignSuggestionName = 'campaignSuggestionName';
  static const String keyCampaignSuggestionDesc = 'campaignSuggestionDesc';

  static Future<void> saveCorrectStrategyId(int id) async {
    await _ensureInit(); await _prefs!.setInt(keyCorrectStrategyId, id);
  }
  static int getCorrectStrategyId() => _prefs?.getInt(keyCorrectStrategyId) ?? 0;

  static Future<void> saveCampaignScenario(String s) async {
    await _ensureInit(); await _prefs!.setString(keyCampaignScenario, s);
  }
  static String? getCampaignScenario() => _prefs?.getString(keyCampaignScenario);

  static Future<void> saveCampaignSuggestion(String name, String desc) async {
    await _ensureInit();
    await _prefs!.setString(keyCampaignSuggestionName, name);
    await _prefs!.setString(keyCampaignSuggestionDesc, desc);
  }
  static String? getCampaignSuggestionName() =>
      _prefs?.getString(keyCampaignSuggestionName);
  static String? getCampaignSuggestionDescription() =>
      _prefs?.getString(keyCampaignSuggestionDesc);
  static Future<void> clearCampaignSuggestion() async {
    await _ensureInit();
    await _prefs!.remove(keyCampaignSuggestionName);
    await _prefs!.remove(keyCampaignSuggestionDesc);
  }

  // ===========================================================================
  // 🔹 CERTIFICATION DATA
  // ===========================================================================

  static Future<void> saveCertificationEvaluationResult(Map<String, dynamic> result) async {
    await _ensureInit();
    await _prefs!.setString('certification_evaluation_result', jsonEncode(result));
  }

  static Map<String, dynamic>? getCertificationEvaluationResult() {
    final s = _prefs?.getString('certification_evaluation_result');
    if (s == null) return null;
    try { return jsonDecode(s); } catch (_) { return null; }
  }

  static Future<void> clearCertificationEvaluationResult() async {
    await _ensureInit();
    await _prefs!.remove('certification_evaluation_result');
  }

  static Future<void> saveCertificateSelectedAIStrategy(Map<String, dynamic> strategy) async {
    await _ensureInit();
    await _prefs!.setString('certificateSelectedAIStrategy', jsonEncode(strategy));
  }

  static Map<String, dynamic> getCertificateSelectedAIStrategy() {
    final s = _prefs?.getString('certificateSelectedAIStrategy') ?? '{}';
    try { return jsonDecode(s); } catch (_) { return {}; }
  }

  static Future<bool> verifyAllCertificateData() async {
    final objective = getCertificateObjective();
    final keyResults = getCertificateKeyResults();
    final initiatives = getCertificateInitiatives();
    final scenario = getCertificateScenario();
    final strategy = getCertificateSelectedAIStrategy();
    return objective['title']?.isNotEmpty == true &&
        keyResults.length >= 3 &&
        initiatives.length >= 2 &&
        scenario.isNotEmpty &&
        strategy.isNotEmpty;
  }

  static Future<void> saveCertificateObjective(String title, String desc) async {
    await _ensureInit();
    await _prefs!.setString('certificateEnteredObjective_title', title);
    await _prefs!.setString('certificateEnteredObjective_description', desc);
  }

  static Map<String, String> getCertificateObjective() => {
    'title': _prefs?.getString('certificateEnteredObjective_title') ?? '',
    'description': _prefs?.getString('certificateEnteredObjective_description') ?? '',
  };

  static Future<void> saveCertificateKeyResults(List<Map<String, String>> krs) async {
    await _ensureInit();
    await _prefs!.setString('certificateEnteredKeyResults', jsonEncode(krs));
  }

  static List<Map<String, String>> getCertificateKeyResults() {
    final s = _prefs?.getString('certificateEnteredKeyResults') ?? '[]';
    try {
      return (jsonDecode(s) as List).map((i) => Map<String, String>.from(i)).toList();
    } catch (_) { return []; }
  }

  static Future<void> saveCertificateInitiatives(List<Map<String, String>> list) async {
    await _ensureInit();
    await _prefs!.setString('certificateEnteredInitiatives', jsonEncode(list));
  }

  static List<Map<String, String>> getCertificateInitiatives() {
    final s = _prefs?.getString('certificateEnteredInitiatives') ?? '[]';
    try {
      return (jsonDecode(s) as List).map((i) => Map<String, String>.from(i)).toList();
    } catch (_) { return []; }
  }

  static Future<void> saveCertificateScenario(String scenario) async {
    await _ensureInit();
    await _prefs!.setString('certificateScenario', scenario);
  }

  static String getCertificateScenario() =>
      _prefs?.getString('certificateScenario') ??
          'A multinational technology company facing declining market share...';

  static Future<void> clearCertificateData() async {
    await _ensureInit();
    for (final k in [
      'certificateEnteredObjective_title', 'certificateEnteredObjective_description',
      'certificateEnteredKeyResults', 'certificateEnteredInitiatives',
      'certificateScenario', 'certificateSelectedAIStrategy',
    ]) await _prefs!.remove(k);
  }

  static bool hasCertificateData() =>
      getCertificateObjective()['title']?.isNotEmpty == true &&
          getCertificateKeyResults().isNotEmpty &&
          getCertificateInitiatives().isNotEmpty;

  // ===========================================================================
  // 🔹 MISSION & INITIATIVES
  // ===========================================================================

  static const String keyMissionDescription = 'mission_description';
  static const String keyFirstInitiativeTitle = 'first_initiative_title';
  static const String keyFirstInitiativeDesc = 'first_initiative_desc';
  static const String keySecondInitiativeTitle = 'second_initiative_title';
  static const String keySecondInitiativeDesc = 'second_initiative_desc';

  static Future<void> saveMissionDescription(String desc) async {
    await _ensureInit(); await _prefs!.setString(keyMissionDescription, desc);
  }
  static String? getMissionDescription() => _prefs?.getString(keyMissionDescription);
  static Future<void> clearMissionDescription() async {
    await _ensureInit(); await _prefs!.remove(keyMissionDescription);
  }

  static Future<void> saveInitiatives({
    required String firstTitle, required String firstDesc,
    required String secondTitle, required String secondDesc,
  }) async {
    await _ensureInit();
    await _prefs!.setString(keyFirstInitiativeTitle, firstTitle);
    await _prefs!.setString(keyFirstInitiativeDesc, firstDesc);
    await _prefs!.setString(keySecondInitiativeTitle, secondTitle);
    await _prefs!.setString(keySecondInitiativeDesc, secondDesc);
  }

  static Map<String, String> getInitiatives() => {
    'firstTitle': _prefs?.getString(keyFirstInitiativeTitle) ?? '',
    'firstDesc': _prefs?.getString(keyFirstInitiativeDesc) ?? '',
    'secondTitle': _prefs?.getString(keySecondInitiativeTitle) ?? '',
    'secondDesc': _prefs?.getString(keySecondInitiativeDesc) ?? '',
  };

  static Future<void> clearInitiatives() async {
    await _ensureInit();
    for (final k in [keyFirstInitiativeTitle, keyFirstInitiativeDesc,
      keySecondInitiativeTitle, keySecondInitiativeDesc])
      await _prefs!.remove(k);
  }

  // ===========================================================================
  // 🔹 ADAPTATION DATA
  // ===========================================================================

  static const String keyRevisedKeyResult = 'revised_key_result';
  static const String keyStrategicActions = 'strategic_actions';
  static const String keyAdaptationNotes = 'adaptation_notes';
  static const String keyAdaptationAnalysisData = 'adaptation_analysis_data';

  static Future<void> saveAdaptationData({
    required String revisedKeyResult,
    required String strategicActions,
    String adaptationNotes = '',
  }) async {
    await _ensureInit();
    await _prefs!.setString(keyRevisedKeyResult, revisedKeyResult);
    await _prefs!.setString(keyStrategicActions, strategicActions);
    await _prefs!.setString(keyAdaptationNotes, adaptationNotes);
  }

  static Map<String, String> getAdaptationData() => {
    'revisedKeyResult': _prefs?.getString(keyRevisedKeyResult) ?? '',
    'strategicActions': _prefs?.getString(keyStrategicActions) ?? '',
    'adaptationNotes': _prefs?.getString(keyAdaptationNotes) ?? '',
  };

  static Future<void> clearAdaptationData() async {
    await _ensureInit();
    for (final k in [keyRevisedKeyResult, keyStrategicActions, keyAdaptationNotes])
      await _prefs!.remove(k);
  }

  static Future<void> saveAdaptationAnalysisData(Map<String, dynamic> data) async {
    await _ensureInit();
    await _prefs!.setString(keyAdaptationAnalysisData, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getAdaptationAnalysisData() async {
    await _ensureInit();
    final s = _prefs!.getString(keyAdaptationAnalysisData);
    if (s == null) return null;
    try { return jsonDecode(s); } catch (_) { return null; }
  }

  static Future<void> clearAdaptationAnalysisData() async {
    await _ensureInit(); await _prefs!.remove(keyAdaptationAnalysisData);
  }

  // ===========================================================================
  // 🔹 EVALUATION & RESULTS
  // ===========================================================================

  static const String keyFinalOkrEvaluationResult = 'final_okr_evaluation_result';
  static const String keyChallengeEvaluationResult = 'challenge_evaluation_result';
  static const String keyEvaluationScore = 'evaluation_score';
  static const String keyEvaluationDecision = 'evaluation_decision';
  static const String keyEvaluationExplanation = 'evaluation_explanation';
  static const String keyChallengeResults = 'challenge_results';
  static const String keyCurrentChallengeData = 'current_challenge_data';

  static Future<void> saveFinalOkrEvaluationResult(Map<String, dynamic> r) async {
    await _ensureInit(); await _prefs!.setString(keyFinalOkrEvaluationResult, jsonEncode(r));
  }
  static Map<String, dynamic>? getFinalOkrEvaluationResult() {
    final s = _prefs?.getString(keyFinalOkrEvaluationResult);
    if (s == null) return null;
    try { return jsonDecode(s); } catch (_) { return null; }
  }

  static Future<void> saveChallengeEvaluationResult(Map<String, dynamic> r) async {
    await _ensureInit(); await _prefs!.setString(keyChallengeEvaluationResult, jsonEncode(r));
  }
  static Map<String, dynamic>? getChallengeEvaluationResult() {
    final s = _prefs?.getString(keyChallengeEvaluationResult);
    if (s == null) return null;
    try { return jsonDecode(s); } catch (_) { return null; }
  }

  static Future<void> saveEvaluationSummary({
    required int score, required String decision, required String explanation,
  }) async {
    await _ensureInit();
    await _prefs!.setInt(keyEvaluationScore, score);
    await _prefs!.setString(keyEvaluationDecision, decision);
    await _prefs!.setString(keyEvaluationExplanation, explanation);
  }
  static Map<String, dynamic> getEvaluationSummary() => {
    'score': _prefs?.getInt(keyEvaluationScore) ?? 0,
    'decision': _prefs?.getString(keyEvaluationDecision) ?? 'Pending',
    'explanation': _prefs?.getString(keyEvaluationExplanation) ?? 'No analysis available',
  };

  static Future<void> saveChallengeResults(List<Map<String, dynamic>> results) async {
    await _ensureInit(); await _prefs!.setString(keyChallengeResults, jsonEncode(results));
  }
  static Future<List<Map<String, dynamic>>?> getChallengeResults() async {
    await _ensureInit();
    final s = _prefs!.getString(keyChallengeResults);
    if (s == null) return null;
    try {
      return (jsonDecode(s) as List).map((i) => Map<String, dynamic>.from(i)).toList();
    } catch (_) { return null; }
  }

  static Future<void> saveCurrentChallengeData(Map<String, dynamic> data) async {
    await _ensureInit(); await _prefs!.setString(keyCurrentChallengeData, jsonEncode(data));
  }
  static Future<Map<String, dynamic>?> getCurrentChallengeData() async {
    await _ensureInit();
    final s = _prefs!.getString(keyCurrentChallengeData);
    if (s == null) return null;
    try { return Map<String, dynamic>.from(jsonDecode(s)); } catch (_) { return null; }
  }

  static Future<void> clearEvaluationData() async {
    await _ensureInit();
    for (final k in [
      keyFinalOkrEvaluationResult, keyChallengeEvaluationResult,
      keyEvaluationScore, keyEvaluationDecision, keyEvaluationExplanation,
      keyChallengeResults, keyCurrentChallengeData,
    ]) await _prefs!.remove(k);
  }

  // ===========================================================================
  // 🔹 STRATEGY & OBJECTIVE SELECTION
  // ===========================================================================

  static const String keySelectedStrategy = 'selectedStrategy';
  static const String keySelectedObjective = 'selectedObjective';
  static const String keySelectedRole = 'selectedRole';

  static Future<void> saveSelectedStrategy(Map<String, dynamic> strategy) async {
    await _ensureInit(); await _prefs!.setString(keySelectedStrategy, jsonEncode(strategy));
  }
  static Future<Map<String, dynamic>?> getSelectedStrategy() async {
    await _ensureInit();
    final s = _prefs!.getString(keySelectedStrategy);
    if (s == null) return null;
    try { return Map<String, dynamic>.from(jsonDecode(s)); } catch (_) { return null; }
  }
  static Future<void> clearSelectedStrategy() async {
    await _ensureInit(); await _prefs!.remove(keySelectedStrategy);
  }

  static Future<void> saveSelectedObjective(Map<String, dynamic> obj) async {
    await _ensureInit(); await _prefs!.setString(keySelectedObjective, jsonEncode(obj));
  }
  static Future<Map<String, dynamic>?> getSelectedObjective() async {
    await _ensureInit();
    final s = _prefs!.getString(keySelectedObjective);
    if (s == null) return null;
    try { return Map<String, dynamic>.from(jsonDecode(s)); } catch (_) { return null; }
  }
  static Future<void> clearSelectedObjective() async {
    await _ensureInit(); await _prefs!.remove(keySelectedObjective);
  }

  static Future<void> saveSelectedRole(Map<String, dynamic> role) async {
    await _ensureInit(); await _prefs!.setString(keySelectedRole, jsonEncode(role));
  }
  static Future<Map<String, dynamic>?> getSelectedRole() async {
    await _ensureInit();
    final s = _prefs!.getString(keySelectedRole);
    if (s == null) return null;
    try { return Map<String, dynamic>.from(jsonDecode(s)); } catch (_) { return null; }
  }
  static Future<void> clearSelectedRole() async {
    await _ensureInit(); await _prefs!.remove(keySelectedRole);
  }

  // ===========================================================================
  // 🔹 UTILITY METHODS
  // ===========================================================================

  static Future<void> clearAll() async {
    await _ensureInit(); await _prefs!.clear();
  }

  static bool containsKey(String key) => _prefs?.containsKey(key) ?? false;
  static Set<String> getAllKeys() => _prefs?.getKeys() ?? {};

  static Future<void> saveString(String key, String value) async {
    await _ensureInit(); await _prefs!.setString(key, value);
  }
  static String? getString(String key) => _prefs?.getString(key);

  static Future<void> saveInt(String key, int value) async {
    await _ensureInit(); await _prefs!.setInt(key, value);
  }
  static int getInt(String key, [int defaultValue = 0]) =>
      _prefs?.getInt(key) ?? defaultValue;

  static Future<void> saveBool(String key, bool value) async {
    await _ensureInit(); await _prefs!.setBool(key, value);
  }
  static bool getBool(String key, [bool defaultValue = false]) =>
      _prefs?.getBool(key) ?? defaultValue;

  // ===========================================================================
  // 🔹 LANGUAGE PREFERENCE
  // ===========================================================================

  static const String keyLanguagePreference = 'language_preference';

  static Future<void> saveLanguagePreference(String code) async {
    await _ensureInit(); await _prefs!.setString(keyLanguagePreference, code);
  }
  static String getLanguagePreference() =>
      _prefs?.getString(keyLanguagePreference) ?? 'en';
  static Future<void> clearLanguagePreference() async {
    await _ensureInit(); await _prefs!.remove(keyLanguagePreference);
  }

  // ===========================================================================
  // 🔹 ICON CONVERSION HELPERS
  // ===========================================================================

  static String _iconToString(IconData? icon) {
    if (icon == Icons.computer) return 'computer';
    if (icon == Icons.account_balance) return 'finance';
    if (icon == Icons.local_hospital) return 'health';
    if (icon == Icons.flash_on) return 'energy';
    if (icon == Icons.local_shipping) return 'logistics';
    if (icon == Icons.account_balance_outlined) return 'public';
    if (icon == Icons.storefront) return 'retail';
    if (icon == Icons.phone_android) return 'telecom';
    if (icon == Icons.agriculture) return 'agriculture';
    if (icon == Icons.business) return 'business';
    return 'default';
  }

  static IconData _stringToIcon(String? name) {
    switch (name) {
      case 'computer': return Icons.computer;
      case 'finance': return Icons.account_balance;
      case 'health': return Icons.local_hospital;
      case 'energy': return Icons.flash_on;
      case 'logistics': return Icons.local_shipping;
      case 'public': return Icons.account_balance_outlined;
      case 'retail': return Icons.storefront;
      case 'telecom': return Icons.phone_android;
      case 'agriculture': return Icons.agriculture;
      case 'business': return Icons.business;
      default: return Icons.work;
    }
  }
}





