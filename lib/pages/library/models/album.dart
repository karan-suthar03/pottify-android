import 'song.dart';

class Album {
  final String id;
  final String name;
  final String artist;
  final String coverImage;
  final List<Song> songs;
  final DateTime releaseDate;
  final String genre;
  
  Album({
    required this.id,
    required this.name,
    required this.artist,
    required this.coverImage,
    required this.songs,
    required this.releaseDate,
    required this.genre,
  });
  
  Album copyWith({
    String? id,
    String? name,
    String? artist,
    String? coverImage,
    List<Song>? songs,
    DateTime? releaseDate,
    String? genre,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      coverImage: coverImage ?? this.coverImage,
      songs: songs ?? this.songs,
      releaseDate: releaseDate ?? this.releaseDate,
      genre: genre ?? this.genre,
    );
  }
  
  Duration get totalDuration {
    return songs.fold(Duration.zero, (total, song) => total + song.duration);
  }
  
  String get totalDurationString {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  int get songCount => songs.length;
  
  String get releaseYear => releaseDate.year.toString();
}
