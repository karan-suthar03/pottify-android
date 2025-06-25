class ApiConfig {
  // Base URLs for different environments
  static const String _prodBaseUrl = 'https://api.pottify.com';
  static const String _devBaseUrl = 'https://dev-api.pottify.com';
  static const String _localBaseUrl = 'https://promising-worry-demonstrates-treatment.trycloudflare.com';
  
  // Current environment (change this based on your setup)
  static const Environment currentEnvironment = Environment.local;
  
  // Get base URL based on current environment
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.production:
        return _prodBaseUrl;
      case Environment.development:
        return _devBaseUrl;
      case Environment.local:
        return _localBaseUrl;
    }
  }
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  
  // User endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String changePasswordEndpoint = '/user/password';
  
  // Music endpoints
  static const String songsEndpoint = '/songs';
  static const String playlistsEndpoint = '/playlists';
  static const String albumsEndpoint = '/albums';
  static const String artistsEndpoint = '/artists';
  
  // Room endpoints
  static const String roomsEndpoint = '/rooms';
  static const String joinRoomEndpoint = '/rooms/join';
  static const String leaveRoomEndpoint = '/rooms/leave';
  
  // API Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-App-Version': '1.0.0',
    'X-Platform': 'flutter',
  };
}

enum Environment {
  production,
  development,
  local,
}
