import 'package:flutter/foundation.dart';
import '../models/song.dart';

class MusicPlayerService extends ChangeNotifier {
  static final MusicPlayerService _instance = MusicPlayerService._internal();
  factory MusicPlayerService() => _instance;
  MusicPlayerService._internal();

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  bool _isLoading = false;
  double _progress = 0.0;

  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  double get progress => _progress;

  void setSong(Song song) {
    _currentSong = song;
    _progress = 0.0;
    notifyListeners();
  }

  void setQueue(List<Song> queue) {
    _queue = queue;
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void next() {
    if (_queue.isNotEmpty) {
      final currentIndex = _queue.indexWhere((s) => s.id == _currentSong?.id);
      if (currentIndex != -1 && currentIndex < _queue.length - 1) {
        setSong(_queue[currentIndex + 1]);
      }
    }
  }

  void previous() {
    if (_queue.isNotEmpty) {
      final currentIndex = _queue.indexWhere((s) => s.id == _currentSong?.id);
      if (currentIndex > 0) {
        setSong(_queue[currentIndex - 1]);
      }
    }
  }

  void seek(double progress) {
    setProgress(progress);
  }
} 