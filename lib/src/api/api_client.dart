import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../state/session.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

/// REST client that attaches the Bearer token + X-Company-Id from [Session].
class ApiClient {
  final String baseUrl;
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Map<String, String> _headers({bool json = false, bool company = true}) {
    final s = Session.instance;
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (s.token != null) 'Authorization': 'Bearer ${s.token}',
      if (company && s.companyId != null) 'X-Company-Id': '${s.companyId}',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? q]) => Uri.parse('$baseUrl$path')
      .replace(queryParameters: q?.map((k, v) => MapEntry(k, '$v')));

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool company = true}) async {
    final res = await http
        .get(_uri(path, query), headers: _headers(company: company))
        .timeout(const Duration(seconds: 25));
    return _decode(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool company = true}) async {
    final res = await http
        .post(_uri(path), headers: _headers(json: true, company: company), body: jsonEncode(body))
        .timeout(const Duration(seconds: 30));
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    dynamic json;
    try {
      json = jsonDecode(res.body);
    } catch (_) {
      throw ApiException('Unexpected server response (${res.statusCode}).', res.statusCode);
    }
    if (res.statusCode >= 400) {
      final msg = (json is Map && json['message'] != null)
          ? json['message'].toString()
          : 'Request failed (${res.statusCode}).';
      throw ApiException(msg, res.statusCode);
    }
    return json;
  }
}
