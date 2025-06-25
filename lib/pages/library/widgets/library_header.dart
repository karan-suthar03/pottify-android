import 'package:flutter/material.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.library_music_rounded,
                color: colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Your Library',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement search
                },
                icon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement more options
                },
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'All your music in one place',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
