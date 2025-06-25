import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickAccessSection extends StatelessWidget {
  final VoidCallback onCreatePlaylist;
  final VoidCallback onLikedSongs;
  final VoidCallback onDownloads;

  const QuickAccessSection({
    super.key,
    required this.onCreatePlaylist,
    required this.onLikedSongs,
    required this.onDownloads,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            children: [
              // Create Playlist Button
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.add_rounded,
                  title: 'Create Playlist',
                  subtitle: 'Make your own mix',
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onCreatePlaylist();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Liked Songs Button
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.favorite_rounded,
                  title: 'Liked Songs',
                  subtitle: 'Your favorites',
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onLikedSongs();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Downloads Button
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.download_rounded,
                  title: 'Downloads',
                  subtitle: 'Offline music',
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDownloads();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Recently Added Button
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.access_time_rounded,
                  title: 'Recently Added',
                  subtitle: 'New additions',
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.purple.shade600,
                    ],
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Implement recently added
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
