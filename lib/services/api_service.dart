import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import '../models/song.dart';

class ApiService {
  static String get _baseUrl => ApiConfig.baseUrl;
  static Duration get _timeout => ApiConfig.requestTimeout;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  late http.Client _client;
  String? _authToken;
  
  void initialize() {
    _client = http.Client();
  }
  
  void dispose() {
    _client.close();
  }
  
  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }
    // Get common headers
  Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      if (kDebugMode) {
        print('GET: $uri');
        print('Headers: \\n$_headers');
      }
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_timeout);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }
  
  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final jsonBody = body != null ? jsonEncode(body) : null;
      if (kDebugMode) {
        print('POST: $uri');
        print('Headers: \\n$_headers');
        print('Body: $jsonBody');
      }
      final response = await _client
          .post(uri, headers: _headers, body: jsonBody)
          .timeout(_timeout);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }
  
  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final jsonBody = body != null ? jsonEncode(body) : null;
      if (kDebugMode) {
        print('PUT: $uri');
        print('Headers: \\n$_headers');
        print('Body: $jsonBody');
      }
      final response = await _client
          .put(uri, headers: _headers, body: jsonBody)
          .timeout(_timeout);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }
  
  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      if (kDebugMode) {
        print('DELETE: $uri');
        print('Headers: \\n$_headers');
      }
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(_timeout);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }
  
  // Search songs by query
  Future<ApiResponse<List<Song>>> searchSongs(String query, {int limit = 20, int offset = 0}) async {
    return get<List<Song>>(
      '/api/search',
      queryParams: {'q': query, 'limit': limit, 'offset': offset},
      fromJson: (json) {
        final results = json['results'] as List?;
        if (results == null) return <Song>[];
        return results.map((item) => Song.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }
  
  /// Fetches the MP3 URL for a song by its ID.
  Future<String?> fetchMp3Url(String songId) async {
    final response = await get<Map<String, dynamic>>(
      '/api/song/$songId/url',
      fromJson: (json) => json,
    );
    if (response.isSuccess && response.data != null) {
      // Adjust the key below to match your API's response structure
      return response.data!['url'] as String?;
    }
    return null;
  }
  
  // Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$endpoint');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }
    
    return uri;
  }
  
  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    if (kDebugMode) {
      print('Response Status:  033[1m${response.statusCode} 033[0m');
      print('Response Headers:  033[36m${response.headers} 033[0m');
      print('Response Body:  033[36m${response.body} 033[0m');
    }
    final Map<String, dynamic> responseData;
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return ApiResponse.error(ApiError(
        code: 'PARSE_ERROR',
        message: 'Failed to parse response: ${response.body}',
        statusCode: response.statusCode,
      ));
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      T? data;
      // Use 'data' if present, else 'results' if present (for search)
      final dynamic payload = responseData['data'] ?? responseData['results'];
      if (fromJson != null && payload != null) {
        try {
          if (payload is List) {
            // For endpoints like search returning a list
            data = fromJson({'results': payload});
          } else if (payload is Map<String, dynamic>) {
            data = fromJson(payload);
          }
        } catch (e) {
          return ApiResponse.error(ApiError(
            code: 'SERIALIZATION_ERROR',
            message: 'Failed to serialize response data: $e',
            statusCode: response.statusCode,
          ));
        }
      }
      return ApiResponse.success(
        data: data,
        message: responseData['message'] as String?,
      );
    } else {
      return ApiResponse.error(ApiError(
        code: responseData['code'] as String? ?? 'API_ERROR',
        message: responseData['message'] as String? ?? 'Unknown error occurred',
        statusCode: response.statusCode,
        details: responseData['details'],
      ));
    }
  }
  
  // Handle errors
  ApiError _handleError(dynamic error) {
    if (kDebugMode) {
      print('API Error: $error');
    }
    
    if (error is http.ClientException) {
      return ApiError(
        code: 'NETWORK_ERROR',
        message: 'Network error: ${error.message}',
      );
    } else if (error is FormatException) {
      return ApiError(
        code: 'FORMAT_ERROR',
        message: 'Data format error: ${error.message}',
      );
    } else {
      return ApiError(
        code: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred: $error',
      );
    }
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final ApiError? error;
  
  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.message,
    this.error,
  });
  
  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      message: message,
    );
  }
  
  factory ApiResponse.error(ApiError error) {
    return ApiResponse._(
      isSuccess: false,
      error: error,
    );
  }
  
  bool get isError => !isSuccess;
}

// API Error model
class ApiError {
  final String code;
  final String message;
  final int? statusCode;
  final dynamic details;
  
  const ApiError({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
  });
  
  @override
  String toString() {
    return 'ApiError(code: $code, message: $message, statusCode: $statusCode)';
  }
}
