import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MadeForYouSection extends StatelessWidget {
  const MadeForYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Made For You',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),        const SizedBox(height: 16),
        SizedBox(
          height: 204,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final playlists = [
                'Discover Weekly',
                'Release Radar',
                'Daily Mix 1',
                'Your Top Songs',
              ];
              return _buildPlaylistCard(
                playlists[index],
                'Curated for you',
                colorScheme,
                context,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistCard(String title, String subtitle, ColorScheme colorScheme, BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle playlist tap
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.tertiary.withOpacity(0.7),
                      colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.playlist_play_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
