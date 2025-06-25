import 'package:flutter/material.dart';

class ProfileStatsRow extends StatelessWidget {
  final int songsCount;
  final int friendsCount;
  final int favoritesCount;

  const ProfileStatsRow({
    super.key,
    required this.songsCount,
    required this.friendsCount,
    required this.favoritesCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          context,
          icon: Icons.music_note_rounded,
          count: _formatCount(songsCount),
          label: 'Songs',
          color: colorScheme.primary,
        ),        
        _buildStatItem(
          context,
          icon: Icons.people_rounded,
          count: _formatCount(friendsCount),
          label: 'Friends',
          color: colorScheme.secondary,
        ),
        _buildStatItem(
          context,
          icon: Icons.favorite_rounded,
          count: _formatCount(favoritesCount),
          label: 'Favorites',
          color: colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String count,    required String label,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }
}
