import 'package:flutter/foundation.dart';

class MusicPlayerUIService extends ChangeNotifier {
  static final MusicPlayerUIService _instance = MusicPlayerUIService._internal();
  factory MusicPlayerUIService() => _instance;
  MusicPlayerUIService._internal();

  bool _isVisible = true;
  bool get isVisible => _isVisible;

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void showExpanded() {
    if (!_isExpanded) {
      _isExpanded = true;
      notifyListeners();
    }
  }

  void hideExpanded() {
    if (_isExpanded) {
      _isExpanded = false;
      notifyListeners();
    }
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
} 