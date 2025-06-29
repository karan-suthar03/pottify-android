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

  static final AudioPlaybackService _audioPlayer = serviceLocator.get<AudioPlaybackService>()!;

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _progress = Duration.zero;
  Duration _duration = Duration.zero;

  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get progress => _progress;
  Duration get duration => _duration;

  void setSong(Song song) {
    _currentSong = song;
    _isLoading = true;
    _isPlaying = false;
    _progress = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
    setUpAudioPlayer(song);
  }

  void setUpAudioPlayer(Song song) async {
    // Reset audio player state
    _audioPlayer.stop();
    _audioPlayer.pause();
    
    // Set loading to true when starting to load new song
    setLoading(true);

    ApiService apiService = serviceLocator.get<ApiService>()!;
    apiService.fetchMp3Url(song.id).then((mp3Url) {
      if (mp3Url == null) {
        setLoading(false);
        // Handle error case - maybe show a message to user
      } else {
        _audioPlayer.load(mp3Url);
        _audioPlayer.stateStream.listen((state) {
          final isLoading = state.processingState == ProcessingState.loading;
          setLoading(isLoading);
        });
        _audioPlayer.positionStream.listen((position) {
            setProgressByAudioService(position);
        });
        _audioPlayer.durationStream.listen((duration){
          setDuration(duration ?? Duration.zero);
        });
      }
    }).catchError((error) {
      setLoading(false);
      // Handle error case
    });
  }

  void setQueue(List<Song> queue) {
    _queue = queue;
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    _audioPlayer.play();
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    _audioPlayer.pause();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setProgressByAudioService(Duration progress) {
    _progress = progress;
    notifyListeners();
  }

  void setProgress(Duration progress) {
    _progress = progress;
    _audioPlayer.seek(progress);
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

  void seek(Duration progress) {
    setProgress(progress);
  }

  void setDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }
} 