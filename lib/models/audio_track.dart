class AudioTrack {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String url;
  final Duration duration;
  final String? imageUrl;

  AudioTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.url,
    required this.duration,
    this.imageUrl,
  });
} 