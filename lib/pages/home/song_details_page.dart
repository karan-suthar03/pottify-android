import 'package:flutter/material.dart';
import '../../models/song.dart';

class SongDetailsPage extends StatelessWidget {
  final Song song;
  const SongDetailsPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
        backgroundColor: colorScheme.surface,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: song.imageUrl != null
                  ? Image.network(
                      song.imageUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.music_note_rounded, size: 100),
                    )
                  : const Icon(Icons.music_note_rounded, size: 100),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(song.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(song.artist, style: TextStyle(fontSize: 18, color: colorScheme.primary)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(song.album, style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.7))),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 18, color: colorScheme.onSurface.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(_formatDuration(song.duration)),
              const SizedBox(width: 16),
              if (song.genre != null) ...[
                Icon(Icons.music_note, size: 18, color: colorScheme.onSurface.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(song.genre!),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (song.releaseDate != null)
            Center(
              child: Text('Released: ${_formatDate(song.releaseDate!)}', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
            ),
          const SizedBox(height: 16),
          if (song.isFavorite)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Favorite', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Play'),
            onPressed: () {
              // TODO: Implement playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Playback not implemented in mock UI')),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}' ;
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
