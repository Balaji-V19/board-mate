import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../error/exceptions.dart';

/// Thin HTTP client used by future REST endpoints. Most data lives in
/// Firestore, but per CLAUDE.md we never call `http` directly outside this
/// class.
class ApiClient {
  ApiClient({
    required String baseUrl,
    http.Client? httpClient,
    FirebaseAuth? auth,
  })  : _baseUrl = baseUrl,
        _client = httpClient ?? http.Client(),
        _auth = auth ?? FirebaseAuth.instance;

  final String _baseUrl;
  final http.Client _client;
  final FirebaseAuth _auth;

  Future<Map<String, String>> _headers({bool requireAuth = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final user = _auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    } else if (requireAuth) {
      throw AuthException('Not signed in');
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<dynamic> getJson(String path, {bool requireAuth = false}) async {
    final res = await _client.get(_uri(path), headers: await _headers(requireAuth: requireAuth));
    return _decode(res);
  }

  Future<dynamic> postJson(String path, Object body, {bool requireAuth = true}) async {
    final res = await _client.post(
      _uri(path),
      headers: await _headers(requireAuth: requireAuth),
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw AuthException('Unauthorized');
    }
    if (res.statusCode == 404) {
      throw NotFoundException();
    }
    throw ServerException('HTTP ${res.statusCode}');
  }
}
