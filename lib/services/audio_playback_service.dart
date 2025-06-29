import 'package:just_audio/just_audio.dart';

class AudioPlaybackService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> load(String url) async {
    await _player.setUrl(url);
  }

  Stream<PlayerState> get stateStream => _player.playerStateStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<Duration?> get bufferedPositionStream => _player.bufferedPositionStream;
  
  void play() => _player.play();
  void pause() => _player.pause();
  void seek(Duration position) => _player.seek(position);

  Stream<Duration> get positionStream => _player.positionStream;

  void dispose() => _player.dispose();

  void stop() {
    _player.stop();
  }
}