class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? imageUrl;
  final String? audioUrl;
  final DateTime? releaseDate;
  final String? genre;
  final bool isFavorite;
  final int? trackNumber;
  final String? artistId;
  final String? albumId;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.imageUrl,
    this.audioUrl,
    this.releaseDate,
    this.genre,
    this.isFavorite = false,
    this.trackNumber,
    this.artistId,
    this.albumId,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    // Support duration as seconds (int), or as string (e.g. '3:29:51' or '03:29')
    Duration parseDuration(dynamic value) {
      if (value == null) return Duration.zero;
      if (value is int) return Duration(seconds: value);
      if (value is String) {
        final parts = value.split(':').map(int.tryParse).toList();
        if (parts.length == 3) {
          // HH:MM:SS
          return Duration(hours: parts[0] ?? 0, minutes: parts[1] ?? 0, seconds: parts[2] ?? 0);
        } else if (parts.length == 2) {
          // MM:SS
          return Duration(minutes: parts[0] ?? 0, seconds: parts[1] ?? 0);
        } else if (int.tryParse(value) != null) {
          return Duration(seconds: int.parse(value));
        }
      }
      return Duration.zero;
    }
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String? ?? '',
      duration: parseDuration(json['duration']),
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      releaseDate: json['releaseDate'] != null ? DateTime.tryParse(json['releaseDate']) : null,
      genre: json['genre'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      trackNumber: json['trackNumber'] as int?,
      artistId: json['artistId'] as String?,
      albumId: json['albumId'] as String?,
    );
  }
}
