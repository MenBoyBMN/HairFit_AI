// ============================================================================
// File: lib/core/services/api_client.dart
// Mục đích: HTTP Client trung tâm kết nối Flutter Frontend với ASP.NET Core Web API.
// Kết cấu:
//  - Tự động đính kèm Firebase Auth ID Token (Bearer JWT).
//  - Hỗ trợ cấu hình API_BASE_URL từ .env hoặc tự động nhận diện theo nền tảng.
// ============================================================================

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Ngoại lệ chuẩn hóa khi gọi REST API thất bại
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic> data;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.data = const {},
  });

  @override
  String toString() => message;
}

/// Dịch vụ HTTP Client giao tiếp với ASP.NET Core Web API Backend
class ApiClient {
  final http.Client _httpClient;
  final FirebaseAuth? firebaseAuth;
  final String? customBaseUrl;

  ApiClient({http.Client? httpClient, this.firebaseAuth, String? baseUrl})
    : _httpClient = httpClient ?? http.Client(),
      customBaseUrl = baseUrl;

  /// Xác định URL gốc của ASP.NET Core Web API
  String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.trim().isNotEmpty) {
      return customBaseUrl!.trim().replaceAll(RegExp(r'/$'), '');
    }

    try {
      final envUrl = dotenv.maybeGet('API_BASE_URL');
      if (envUrl != null && envUrl.trim().isNotEmpty) {
        return envUrl.trim().replaceAll(RegExp(r'/$'), '');
      }
    } catch (_) {}

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  FirebaseAuth? get _safeAuth {
    if (firebaseAuth != null) return firebaseAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Xây dựng HTTP Headers bao gồm Firebase JWT Bearer Token (nếu đã đăng nhập)
  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    try {
      final user = _safeAuth?.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {}

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final cleanQuery = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        cleanQuery[key] = value.toString();
      }
    });

    return uri.replace(queryParameters: cleanQuery);
  }

  dynamic _handleResponse(http.Response response) {
    final bodyStr = utf8.decode(response.bodyBytes);
    dynamic decoded;
    if (bodyStr.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(bodyStr);
      } catch (_) {
        decoded = bodyStr;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String code = 'HTTP_${response.statusCode}';
    String message = 'Lỗi máy chủ (${response.statusCode})';
    Map<String, dynamic> errorMap = const {};

    if (decoded is Map) {
      errorMap = Map<String, dynamic>.from(decoded);
      code = errorMap['code']?.toString() ?? code;
      message =
          errorMap['message']?.toString() ??
          errorMap['title']?.toString() ??
          message;
    } else if (decoded is String && decoded.isNotEmpty) {
      message = decoded;
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: code,
      message: message,
      data: errorMap,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _buildHeaders();
    final response = await _httpClient.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _buildHeaders();
    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _buildHeaders();
    final response = await _httpClient.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _buildHeaders();
    final response = await _httpClient.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _buildHeaders();
    final response = await _httpClient.delete(uri, headers: headers);
    return _handleResponse(response);
  }
}

// CreBy: MenBoyBMN
