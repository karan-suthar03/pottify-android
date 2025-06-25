import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final ApiService _apiService = ApiService();
  SharedPreferences? _prefs;
  User? _currentUser;
  String? _currentToken;
  
  // Initialize the service
  Future<void> initialize() async {
    if (kDebugMode) {
      print('[AuthService] initialize() called');
    }
    _prefs = await SharedPreferences.getInstance();
    await _loadStoredAuth();
  }
  
  // Check if user is authenticated
  bool get isAuthenticated => _currentToken != null && _currentUser != null;
  
  // Get current user
  User? get currentUser => _currentUser;
  
  // Get current token
  String? get currentToken => _currentToken;
  
  // Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.loginEndpoint,
        body: {
          'email': email,
          'password': password,
        },
        fromJson: (json) => json, // <-- Fix: ensure data is parsed
      );
      
      if (response.isSuccess && response.data != null) {
        final authData = response.data!;
        final token = authData['token'] as String;
        final refreshToken = authData['refresh_token'] as String?;
        final userData = authData['user'] as Map<String, dynamic>;
        
        final user = User.fromJson(userData);
        
        await _saveAuthData(
          token: token,
          refreshToken: refreshToken,
          user: user,
        );
        return AuthResult.success(
          user: user,
          message: response.message ?? 'Login successful',
        );
      } else {
        return AuthResult.failure(
          error: response.error?.message ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResult.failure(error: 'Login failed: $e');
    }
  }
  
  // Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.registerEndpoint,
        body: {
          'email': email,
          'password': password,
          'username': username,
          'display_name': displayName ?? username,
        },
        fromJson: (json) => json, // <-- Fix: ensure data is parsed
      );
      
      if (response.isSuccess && response.data != null) {
        final authData = response.data!;
        final token = authData['token'] as String;
        final refreshToken = authData['refresh_token'] as String?;
        final userData = authData['user'] as Map<String, dynamic>;
        
        final user = User.fromJson(userData);
        
        await _saveAuthData(
          token: token,
          refreshToken: refreshToken,
          user: user,
        );
        return AuthResult.success(
          user: user,
          message: response.message ?? 'Registration successful',
        );
      } else {
        return AuthResult.failure(
          error: response.error?.message ?? 'Registration failed',
        );
      }
    } catch (e) {
      return AuthResult.failure(error: 'Registration failed: $e');
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logoutEndpoint);
    } catch (e) {
      if (kDebugMode) {
        print('Server logout failed: $e');
      }
    }
    await _clearAuthData();
  }
  
  // Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = _prefs?.getString(_refreshTokenKey);
      if (refreshToken == null) return false;
        final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.refreshTokenEndpoint,
        body: {'refresh_token': refreshToken},
      );
      
      if (response.isSuccess && response.data != null) {
        final authData = response.data!;
        final newToken = authData['token'] as String;
        final newRefreshToken = authData['refresh_token'] as String?;
        
        await _saveToken(newToken);
        if (newRefreshToken != null) {
          await _prefs?.setString(_refreshTokenKey, newRefreshToken);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      return false;
    }
  }
  
  // Update user profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? email,
    String? username,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['display_name'] = displayName;
      if (email != null) body['email'] = email;
      if (username != null) body['username'] = username;
        final response = await _apiService.put<Map<String, dynamic>>(
        ApiConfig.userProfileEndpoint,
        body: body,
        fromJson: (json) => json,
      );
      
      if (response.isSuccess && response.data != null) {
        final userData = response.data!['user'] as Map<String, dynamic>;
        final updatedUser = User.fromJson(userData);
        
        await _saveUser(updatedUser);
        
        return AuthResult.success(
          user: updatedUser,
          message: response.message ?? 'Profile updated successfully',
        );
      } else {
        return AuthResult.failure(
          error: response.error?.message ?? 'Profile update failed',
        );
      }
    } catch (e) {
      return AuthResult.failure(error: 'Profile update failed: $e');
    }
  }
  
  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {      final response = await _apiService.put<Map<String, dynamic>>(
        ApiConfig.changePasswordEndpoint,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      
      if (response.isSuccess) {
        return AuthResult.success(
          message: response.message ?? 'Password changed successfully',
        );
      } else {
        return AuthResult.failure(
          error: response.error?.message ?? 'Password change failed',
        );
      }
    } catch (e) {
      return AuthResult.failure(error: 'Password change failed: $e');
    }
  }
  
  // Reset password
  Future<AuthResult> resetPassword({required String email}) async {
    try {      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.resetPasswordEndpoint,
        body: {'email': email},
      );
      
      if (response.isSuccess) {
        return AuthResult.success(
          message: response.message ?? 'Password reset email sent',
        );
      } else {
        return AuthResult.failure(
          error: response.error?.message ?? 'Password reset failed',
        );
      }
    } catch (e) {
      return AuthResult.failure(error: 'Password reset failed: $e');
    }
  }
  
  // Private methods
  
  Future<void> _loadStoredAuth() async {
    final token = _prefs?.getString(_tokenKey);
    final userJson = _prefs?.getString(_userKey);
    if (kDebugMode) {
      print('[AuthService] _loadStoredAuth: token=$token, userJson=$userJson');
    }
    if (token != null && userJson != null) {
      try {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(userData);
        _currentToken = token;
        _apiService.setAuthToken(token);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load stored auth: $e');
        }
        await _clearAuthData();
      }
    }
  }
  
  Future<void> _saveAuthData({
    required String token,
    String? refreshToken,
    required User user,
  }) async {
    _currentToken = token;
    _currentUser = user;
    _apiService.setAuthToken(token);
    
    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
    
    if (refreshToken != null) {
      await _prefs?.setString(_refreshTokenKey, refreshToken);
    }
  }
  
  Future<void> _saveToken(String token) async {
    _currentToken = token;
    _apiService.setAuthToken(token);
    await _prefs?.setString(_tokenKey, token);
  }
  
  Future<void> _saveUser(User user) async {
    _currentUser = user;
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  Future<void> _clearAuthData() async {
    _currentToken = null;
    _currentUser = null;
    _apiService.clearAuthToken();
    
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_userKey);
    await _prefs?.remove(_refreshTokenKey);
  }
}

// User model
class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  User copyWith({
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// Authentication result
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? message;
  final String? error;
  
  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.message,
    this.error,
  });
  
  factory AuthResult.success({User? user, String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }
  
  factory AuthResult.failure({required String error}) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
  
  bool get isFailure => !isSuccess;
}
