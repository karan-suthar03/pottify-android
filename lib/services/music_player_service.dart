import 'package:app/services/api_service.dart';
import 'package:app/services/audio_playback_service.dart';
import 'package:app/services/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MusicPlayerService extends ChangeNotifier {
  static final MusicPlayerService _instance = MusicPlayerService._internal();
  factory MusicPlayerService() => _instance;
  MusicPlayerService._internal();

  static final AudioPlaybackService? _audioPlayer = serviceLocator.get<AudioPlaybackService>();

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  bool _isLoading = true;
  double _progress = 0.0;
  Duration? _duration;

  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  double get progress => _progress;
  Duration? get duration => _duration;

  void setSong(Song song) {
    _currentSong = song;
    _isLoading = true;
    notifyListeners();
    setUpAudioPlayer(song);
  }

  void setUpAudioPlayer(Song song) async{
    ApiService? apiService = serviceLocator.get<ApiService>();
    apiService?.fetchMp3Url(song.id).then((mp3Url) {
      if (mp3Url == null) {
        setLoading(true);
      } else {
        _audioPlayer?.load(mp3Url);
        _audioPlayer?.stateStream.listen((state) {
          final isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
          setLoading(isLoading);
        });
        _audioPlayer?.positionStream.listen((position) {
          final duration = this.duration;
          if(duration != null){
            setProgressByAudioService(position.inMilliseconds / duration.inMilliseconds);
          }
        });
        _audioPlayer?.durationStream.listen((duration){
          setDuration(duration);
        });
      }
    });
  }

  void setQueue(List<Song> queue) {
    _queue = queue;
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    _audioPlayer?.play();
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    _audioPlayer?.pause();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setProgressByAudioService(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void setProgress(double progress) {
    _progress = progress;
    _audioPlayer?.seek(Duration(milliseconds: (progress * _duration!.inMilliseconds).toInt()));
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

  void setDuration(Duration? duration) {
    _duration = duration;
    notifyListeners();
  }
} 