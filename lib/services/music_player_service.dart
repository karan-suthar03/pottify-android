import 'package:app/services/api_service.dart';
import 'package:app/services/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';

class MusicPlayerService extends ChangeNotifier {
  static final MusicPlayerService _instance = MusicPlayerService._internal();
  factory MusicPlayerService() => _instance;
  MusicPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _progress = Duration.zero;
  Duration _duration = Duration.zero;
  ProcessingState _processingState = ProcessingState.idle;

  Song? get currentSong => _currentSong;
  List<Song> get queue => List.unmodifiable(_queue);
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get progress => _progress;
  Duration get duration => _duration;
  ProcessingState get processingState => _processingState;

  // Helper getters for notification state
  bool get isBuffering => _processingState == ProcessingState.buffering;
  bool get isReady => _processingState == ProcessingState.ready;
  bool get isCompleted => _processingState == ProcessingState.completed;
  bool get hasError => _processingState == ProcessingState.idle;

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
    await _audioPlayer.stop();
    
    // Set loading to true when starting to load new song
    setLoading(true);

    ApiService apiService = serviceLocator.get<ApiService>()!;
    apiService.fetchMp3Url(song.id).then((mp3Url) {
      if (mp3Url == null) {
        setLoading(false);
        // Handle error case - maybe show a message to user
      } else {
        _loadSongWithBackgroundSupport(song, mp3Url);
      }
    }).catchError((error) {
      setLoading(false);
      // Handle error case
    });
  }

  Future<void> _loadSongWithBackgroundSupport(Song song, String mp3Url) async {
    try {
      // Create MediaItem for notification
      final mediaItem = MediaItem(
        id: song.id,
        album: song.album,
        title: song.title,
        artist: song.artist,
        duration: song.duration,
        artUri: song.imageUrl != null ? Uri.parse(song.imageUrl!) : null,
        playable: true,
      );

      // Load audio with background support
      final audioSource = AudioSource.uri(
        Uri.parse(mp3Url),
        tag: mediaItem,
      );
      
      // Set initial state
      _isPlaying = false;
      _isLoading = true;
      notifyListeners();
      
      await _audioPlayer.setAudioSource(audioSource);
      
      // Set up listeners for audio player
      _audioPlayer.playerStateStream.listen((state) {
        _processingState = state.processingState;
        _isPlaying = state.playing;
        
        // Handle ready state explicitly
        if (state.processingState == ProcessingState.ready) {
          setLoading(false);
        } else {
          final isLoading = state.processingState == ProcessingState.loading ||
                           state.processingState == ProcessingState.buffering;
          setLoading(isLoading);
        }
        
        notifyListeners();
      });
      
      _audioPlayer.positionStream.listen((position) {
        setProgressByAudioService(position);
      });
      
      _audioPlayer.durationStream.listen((duration) {
        setDuration(duration ?? Duration.zero);
      });
      
    } catch (e) {
      setLoading(false);
      print('Error loading song with background support: $e');
    }
  }

  void setQueue(List<Song> queue) {
    _queue = queue;
    notifyListeners();
  }

  void play() async {
    if (_processingState == ProcessingState.ready && !_isPlaying) {
      _isPlaying = true;
      notifyListeners();
      await _audioPlayer.play();
    }
  }

  void pause() async {
    if (_isPlaying) {
      _isPlaying = false;
      notifyListeners();
      await _audioPlayer.pause();
    }
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 