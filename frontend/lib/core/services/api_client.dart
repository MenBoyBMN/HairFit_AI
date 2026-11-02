// ============================================================================
// File: lib/core/services/api_client.dart
// Mục đích: HTTP Client trung tâm kết nối Flutter Frontend với ASP.NET Core Web API.
// Kết cấu:
//  - Tự động đính kèm Firebase Auth ID Token (Bearer JWT).
//  - Hỗ trợ cấu hình API_BASE_URL từ .env hoặc tự động nhận diện theo nền tảng.
// ============================================================================

import 'dart:async';
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
/// Hỗ trợ Auto-Discovery "Cắm là chạy": Tự động phát hiện và chuyển đổi URL
/// phù hợp giữa Web (localhost), Android Emulator (10.0.2.2), Điện thoại thật (USB / Ngrok).
class ApiClient {
  final http.Client _httpClient;
  final FirebaseAuth? firebaseAuth;
  final String? customBaseUrl;

  /// URL phát hiện tự động hoạt động tốt nhất trong runtime
  static String? _discoveredBaseUrl;
  static bool _isProbing = false;

  /// URL Ngrok / Remote cố định mặc định cho trường hợp chạy từ xa qua 4G
  static const String defaultRemoteUrl =
      'https://clothing-similarly-delicacy.ngrok-free.dev';

  ApiClient({http.Client? httpClient, this.firebaseAuth, String? baseUrl})
    : _httpClient = httpClient ?? http.Client(),
      customBaseUrl = baseUrl;

  /// Lấy danh sách các ứng viên Base URL tiềm năng theo môi trường thực thi
  static List<String> getCandidateUrls() {
    String? envUrl;
    String? remoteEnv;
    try {
      envUrl = dotenv.maybeGet('API_BASE_URL')?.trim();
      remoteEnv = dotenv.maybeGet('REMOTE_API_BASE_URL')?.trim();
    } catch (_) {}

    String remoteUrl = defaultRemoteUrl;
    if (remoteEnv != null && remoteEnv.isNotEmpty) {
      remoteUrl = remoteEnv.replaceAll(RegExp(r'/$'), '');
    } else if (envUrl != null &&
        envUrl.isNotEmpty &&
        envUrl.toLowerCase() != 'auto' &&
        envUrl.startsWith('http') &&
        !envUrl.contains('localhost') &&
        !envUrl.contains('127.0.0.1') &&
        !envUrl.contains('10.0.2.2')) {
      remoteUrl = envUrl.replaceAll(RegExp(r'/$'), '');
    }

    final candidates = <String>[];

    // Nếu người dùng cấu hình URL cụ thể trong .env (khác 'auto')
    if (envUrl != null && envUrl.isNotEmpty && envUrl.toLowerCase() != 'auto') {
      final clean = envUrl.replaceAll(RegExp(r'/$'), '');
      candidates.add(clean);
    }

    if (kIsWeb) {
      candidates.addAll([
        'http://localhost:5000',
        'http://localhost:3000',
        remoteUrl,
      ]);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      candidates.addAll([
        'http://10.0.2.2:5000', // Android Emulator (.NET 8)
        'http://localhost:5000', // Real Device USB (adb reverse)
        'http://10.0.2.2:3000', // Android Emulator (Node.js)
        'http://localhost:3000', // Real Device USB (Node.js)
        remoteUrl, // 4G / Wi-Fi từ xa qua Ngrok
      ]);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      candidates.addAll([
        'http://localhost:5000', // iOS Simulator
        'http://localhost:3000',
        remoteUrl,
      ]);
    } else {
      // Windows, macOS, Linux Desktop
      candidates.addAll([
        'http://localhost:5000',
        'http://localhost:3000',
        remoteUrl,
      ]);
    }

    // Loại bỏ URL rỗng hoặc trùng lặp giữ nguyên thứ tự ưu tiên
    final unique = <String>[];
    for (final c in candidates) {
      final trimmed = c.trim().replaceAll(RegExp(r'/$'), '');
      if (trimmed.isNotEmpty && !unique.contains(trimmed)) {
        unique.add(trimmed);
      }
    }
    return unique;
  }

  /// Dò tìm endpoint hoạt động nhanh nhất trong nền (Fast Health Probe)
  static Future<String?> probe({
    http.Client? client,
    Duration timeout = const Duration(milliseconds: 600),
  }) async {
    if (_isProbing) return _discoveredBaseUrl;
    _isProbing = true;

    final candidates = getCandidateUrls();
    final testClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final completer = Completer<String?>();
      int pending = candidates.length;

      for (final url in candidates) {
        _checkCandidate(testClient, url, timeout)
            .then((isHealthy) {
              if (isHealthy && !completer.isCompleted) {
                completer.complete(url);
              } else {
                pending--;
                if (pending <= 0 && !completer.isCompleted) {
                  completer.complete(null);
                }
              }
            })
            .catchError((_) {
              pending--;
              if (pending <= 0 && !completer.isCompleted) {
                completer.complete(null);
              }
            });
      }

      final winner = await completer.future.timeout(
        timeout + const Duration(milliseconds: 250),
        onTimeout: () => null,
      );

      if (winner != null) {
        _discoveredBaseUrl = winner;
        debugPrint('⚡ [ApiClient] Auto-detected backend at: $winner');
      }
    } catch (e) {
      debugPrint('⚠️ [ApiClient] Auto-probe check: $e');
    } finally {
      _isProbing = false;
      if (shouldCloseClient) {
        testClient.close();
      }
    }

    return _discoveredBaseUrl;
  }

  static Future<bool> _checkCandidate(
    http.Client client,
    String url,
    Duration timeout,
  ) async {
    try {
      final uri = Uri.parse('$url/api/health');
      final res = await client.get(uri).timeout(timeout);
      if (res.statusCode >= 200 && res.statusCode < 500) {
        return true;
      }
    } catch (_) {
      try {
        final uri = Uri.parse('$url/health');
        final res = await client.get(uri).timeout(timeout);
        if (res.statusCode >= 200 && res.statusCode < 500) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  /// Thiết lập cưỡng bức URL tự động nhận diện (dùng trong test)
  static void setDiscoveredBaseUrl(String? url) {
    _discoveredBaseUrl = url?.trim().replaceAll(RegExp(r'/$'), '');
  }

  /// Reset URL tự động nhận diện về trạng thái ban đầu
  static void resetDiscoveredBaseUrl() {
    _discoveredBaseUrl = null;
  }

  /// Lấy URL đã tự động nhận diện hiện thời (nếu có)
  static String? get discoveredBaseUrl => _discoveredBaseUrl;

  /// Xác định URL gốc của ASP.NET Core Web API
  String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.trim().isNotEmpty) {
      return customBaseUrl!.trim().replaceAll(RegExp(r'/$'), '');
    }

    if (_discoveredBaseUrl != null && _discoveredBaseUrl!.isNotEmpty) {
      return _discoveredBaseUrl!;
    }

    try {
      final envUrl = dotenv.maybeGet('API_BASE_URL');
      if (envUrl != null &&
          envUrl.trim().isNotEmpty &&
          envUrl.trim().toLowerCase() != 'auto') {
        final cleanUrl = envUrl.trim().replaceAll(RegExp(r'/$'), '');
        // Tự động chuyển đổi localhost/127.0.0.1 sang 10.0.2.2 khi chạy trên Android Emulator
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          if (cleanUrl.contains('localhost')) {
            return cleanUrl.replaceAll('localhost', '10.0.2.2');
          }
          if (cleanUrl.contains('127.0.0.1')) {
            return cleanUrl.replaceAll('127.0.0.1', '10.0.2.2');
          }
        }
        return cleanUrl;
      }
    } catch (_) {}

    final candidates = getCandidateUrls();
    if (candidates.isNotEmpty) {
      return candidates.first;
    }

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
      'ngrok-skip-browser-warning': 'true',
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
      // Hỗ trợ tự động bóc tách vỏ bọc envelope { status: 'success', data: [...] } nếu có từ Express API
      if (decoded is Map &&
          decoded.containsKey('data') &&
          decoded.containsKey('status')) {
        return decoded['data'];
      }
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

  Future<http.Response> _executeWithAutoFailover(
    String path,
    Map<String, dynamic>? queryParameters,
    Future<http.Response> Function(Uri uri, Map<String, String> headers)
    makeCall,
  ) async {
    const timeoutDuration = Duration(seconds: 15);
    final headers = await _buildHeaders();

    // 1. Thử gửi với baseUrl hiện tại
    try {
      final uri = _buildUri(path, queryParameters);
      return await makeCall(uri, headers).timeout(timeoutDuration);
    } catch (_) {
      // 2. Nếu thất bại và không phải customBaseUrl cố định, thử chuyển nhanh sang candidate khả dĩ tiếp theo
      if (customBaseUrl == null) {
        final candidates = getCandidateUrls();
        final current = baseUrl;
        final nextCandidates = candidates.where((c) => c != current).toList();

        for (final candidate in nextCandidates) {
          try {
            final isAlive = await _checkCandidate(
              _httpClient,
              candidate,
              const Duration(milliseconds: 700),
            );
            if (isAlive) {
              _discoveredBaseUrl = candidate;
              debugPrint(
                '🔄 [ApiClient] Auto-failover switched backend to: $candidate',
              );
              final newUri = _buildUri(path, queryParameters);
              return await makeCall(newUri, headers).timeout(timeoutDuration);
            }
          } catch (_) {}
        }
      }

      // Thử lại lần cuối với baseUrl hiện tại (đề phòng sóng 4G chập chờn)
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final retryUri = _buildUri(path, queryParameters);
      return await makeCall(retryUri, headers).timeout(timeoutDuration);
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _executeWithAutoFailover(
      path,
      queryParameters,
      (uri, headers) => _httpClient.get(uri, headers: headers),
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _executeWithAutoFailover(
      path,
      queryParameters,
      (uri, headers) => _httpClient.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _executeWithAutoFailover(
      path,
      queryParameters,
      (uri, headers) => _httpClient.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _executeWithAutoFailover(
      path,
      queryParameters,
      (uri, headers) => _httpClient.patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _executeWithAutoFailover(
      path,
      queryParameters,
      (uri, headers) => _httpClient.delete(uri, headers: headers),
    );
    return _handleResponse(response);
  }
}

// CreBy: MenBoyBMN
