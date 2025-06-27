import 'package:app/services/music_player_service.dart';
import 'package:app/services/service_locator.dart';
import 'package:flutter/material.dart';
import '../../models/song.dart';

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Center(
        child: Text('Search results will be displayed here.'),
      ),
    );
  }
}

class SearchResults extends StatefulWidget {
  final List<Song> results;
  final void Function(Song song, List<Song> queue)? onSongSelected;
  const SearchResults({super.key, required this.results, this.onSongSelected});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleTap(Song song) async {
    serviceLocator.get<MusicPlayerService>()?.setSong(song);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.results.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: widget.results.length,
      separatorBuilder: (context, i) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final song = widget.results[i];
        return Material(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleTap(song),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: song.imageUrl != null && song.imageUrl!.isNotEmpty
                        ? Image.network(
                            song.imageUrl!,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _placeholder(theme),
                          )
                        : _placeholder(theme),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          song.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (song.duration.inSeconds > 0)
                          Text(
                            _formatDuration(song.duration),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.play_arrow_rounded, color: theme.colorScheme.primary, size: 28),
                    onPressed: () => _handleTap(song),
                    tooltip: 'Play',
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurfaceVariant, size: 24),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'add_to_playlist', child: Text('Add to Playlist')),
                      const PopupMenuItem(value: 'share', child: Text('Share')),
                    ],
                    onSelected: (value) {
                      // TODO: Implement actions
                    },
                    tooltip: 'More',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder(ThemeData theme, {double size = 54}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      child: Icon(Icons.music_note_rounded, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4), size: size * 0.7),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return "${d.inHours}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
    } else {
      return "${d.inMinutes}:${twoDigits(d.inSeconds % 60)}";
    }
  }
}
