import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'music_player_ui_service.dart';
import 'music_player_service.dart';

/// A simple service locator for managing app-wide services.
class ServiceLocator {
  ServiceLocator._internal();
  static final ServiceLocator instance = ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  bool _initialized = false;

  /// Initializes core services.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (kDebugMode) print('Initializing services...');
      final apiService = ApiService();
      apiService.initialize();
      _services[ApiService] = apiService;

      final authService = AuthService();
      await authService.initialize();
      _services[AuthService] = authService;

      final musicPlayerUIService = MusicPlayerUIService();
      _services[MusicPlayerUIService] = musicPlayerUIService;

      final musicPlayerService = MusicPlayerService();
      _services[MusicPlayerService] = musicPlayerService;

      if (kDebugMode) print('Services initialized successfully');
      _initialized = true;
    } catch (e) {
      if (kDebugMode) print('Failed to initialize services: $e');
      rethrow;
    }
  }

  /// Gets a registered service of type [T], or null if not found.
  T? get<T>() => _services[T] as T?;

  /// Gets a registered service of type [T], or throws if not found.
  T getRequired<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered. Did you forget to initialize?');
    }
    return service as T;
  }

  /// Registers a service instance of type [T].
  void register<T>(T service) => _services[T] = service;

  /// Unregisters a service of type [T].
  void unregister<T>() => _services.remove(T);

  /// Disposes and clears all services.
  void clear() {
    try {
      (_services[ApiService] as ApiService?)?.dispose();
    } catch (e) {
      if (kDebugMode) print('Error disposing API service: $e');
    }
    _services.clear();
    _initialized = false;
  }

  /// Checks if a service of type [T] is registered.
  bool isRegistered<T>() => _services.containsKey(T);

  /// Returns a list of all registered service types.
  List<Type> get registeredServices => _services.keys.toList();
}

/// Global singleton instance for convenience.
final serviceLocator = ServiceLocator.instance;