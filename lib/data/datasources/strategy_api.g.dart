// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'strategy_api.dart';

class _StrategyApi implements StrategyApi {
  _StrategyApi(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;
  String? baseUrl;
  final ParseErrorLogger? errorLogger;

  @override
  Future<StrategyResponse> getRandomStrategy() async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/game/random-strategy')
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return StrategyResponse.fromJson(_result.data!);
  }

  @override
  Future<ObjectivesResponse> generateObjectives(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/objectives/generate', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return ObjectivesResponse.fromJson(_result.data!);
  }

  @override
  Future<ObjectivesResponse> fetchObjectivesByStrategyId(int strategyId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/objectives/fetch-strategy-id-based',
        queryParameters: {'strategyId': strategyId})
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return ObjectivesResponse.fromJson(_result.data!);
  }

  @override
  Future<ObjectivesResponse> fetchObjectivesForChallenge(int strategyId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/objectives/fetch-objective-for-challenge',
        queryParameters: {'strategyId': strategyId})
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return ObjectivesResponse.fromJson(_result.data!);
  }

  @override
  Future<List<KeyResultResponse>> getKeyResultsByStrategy(int strategyId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/key-result/by-strategy',
        queryParameters: {'strategyId': strategyId})
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<List<dynamic>>(_options);
    return _result.data!
        .map((i) => KeyResultResponse.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<KeyResultResponse>> createBatchKeyResults(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/key-result/batch', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<List<dynamic>>(_options);
    return _result.data!
        .map((i) => KeyResultResponse.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EvaluateKeyResultsResponse> evaluateKeyResults(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/team/keyresults/evaluate', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return EvaluateKeyResultsResponse.fromJson(_result.data!);
  }

  @override
  Future<AddInnovativeResponse> addInnovativeIdea(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/keywordbase-innovative', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return AddInnovativeResponse.fromJson(_result.data!);
  }

  @override
  Future<InnovativeIdeasResponse> fetchInnovativeIdeas(int strategyId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/keywordbase-innovative/strategy/$strategyId')
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return InnovativeIdeasResponse.fromJson(_result.data!);
  }

  @override
  Future<GenerateInitiativesResponse> evaluateInitiatives(GenerateInitiativesRequest body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/evaluate-initiatives', data: body.toJson())
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return GenerateInitiativesResponse.fromJson(_result.data!);
  }

  @override
  Future<TeamStrategyResponse> getTeamStrategy(GetTeamStrategyRequest body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/game/team-strategy', data: body.toJson())
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return TeamStrategyResponse.fromJson(_result.data!);
  }

  @override
  Future<ChallengeResponse> getChallenge(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/challenge', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return ChallengeResponse.fromJson(_result.data!);
  }

  @override
  Future<FinalEvaluationResponse> evaluateFinalChallenge(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/team-challenges/evaluation', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return FinalEvaluationResponse.fromJson(_result.data!);
  }

  @override
  Future<dynamic> submitFinalTeamScore(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/final-team-score', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<dynamic>(_options);
    return _result.data;
  }

  @override
  Future<dynamic> getFinalTeamScoreSummary(int teamId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/final-team-score/$teamId/summary')
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<dynamic>(_options);
    return _result.data;
  }

  @override
  Future<dynamic> getUserFinalScoreInTeam(int teamId, String userId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/final-team-score/$teamId/user/$userId/score')
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<dynamic>(_options);
    return _result.data;
  }

  @override
  Future<dynamic> getTeamRewardsSummary(int teamId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/final-team-score/team/$teamId/rewards-summary')
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<dynamic>(_options);
    return _result.data;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) return dioBaseUrl;
    final url = Uri.parse(baseUrl);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}