// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'team_api.dart';

class _TeamApi implements TeamApi {
  _TeamApi(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;
  String? baseUrl;
  final ParseErrorLogger? errorLogger;

  @override
  Future<Team> editTeam(int teamId, EditTeamRequest request) async {
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = Options(method: 'PATCH')
        .compose(_dio.options, '/team/$teamId', data: _data)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return Team.fromJson(_result.data!);
  }

  @override
  Future<TeamLobbyResponse> joinTeam(JoinTeamRequest request) async {
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/team/join', data: _data)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return TeamLobbyResponse.fromJson(_result.data!);
  }

  @override
  Future<TeamLobbyResponse> getTeamDetails(int teamId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/team/$teamId/details')
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return TeamLobbyResponse.fromJson(_result.data!);
  }

  @override
  Future<AddMemberResponse> addMember(int teamId, AddMemberRequest request) async {
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/team/$teamId/add-member', data: _data)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return AddMemberResponse.fromJson(_result.data!);
  }

  @override
  Future<List<AssignRoleResponse>> getTeamMembers(int teamId) async {
    final _options = Options(method: 'GET')
        .compose(_dio.options, '/team/$teamId/members')
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<List<dynamic>>(_options);
    return _result.data!
        .map((i) => AssignRoleResponse.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UpdateTeamMemberResponse> updateMemberRole(int teamId, UpdateTeamMemberRequest request) async {
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/team/$teamId/update-role', data: _data)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return UpdateTeamMemberResponse.fromJson(_result.data!);
  }

  @override
  Future<void> sendWsInvite(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/ws/invite', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> joinWsTeam(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/ws/join-team', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> sendWsMessage(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/ws/message', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    await _dio.fetch<void>(_options);
  }

  @override
  Future<void> sendNotification(Map<String, dynamic> body) async {
    final _options = Options(method: 'POST')
        .compose(_dio.options, '/notifications/send', data: body)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    await _dio.fetch<void>(_options);
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) return dioBaseUrl;
    final url = Uri.parse(baseUrl);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}