// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'auth_api.dart';

class _AuthApi implements AuthApi {
  _AuthApi(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;
  String? baseUrl;
  final ParseErrorLogger? errorLogger;

  @override
  Future<LoginResponse> login(Map<String, dynamic> request) async {
    final _data = <String, dynamic>{};
    _data.addAll(request);
    final _options = Options(method: 'POST')
        .compose(_dio.options, AppUrls.loginUrl, data: _data)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return LoginResponse.fromJson(_result.data!);
  }

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = Options(method: 'POST')
        .compose(_dio.options, AppUrls.signUpUrl, data: _data)
        .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    return RegisterResponse.fromJson(_result.data!);
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) return dioBaseUrl;
    final url = Uri.parse(baseUrl);
    if (url.isAbsolute) return url.toString();
    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}