import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userHandle;
  final String? avatarUrl;
  final VoidCallback onSettingsTap;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userHandle,
    this.avatarUrl,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.surface,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,              colors: [
                colorScheme.primary.withOpacity(0.8),
                colorScheme.primary.withOpacity(0.6),
                colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [                // Profile Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: colorScheme.onSurface,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: avatarUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                // User Name
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userHandle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onSettingsTap();
          },
          icon: const Icon(Icons.settings_outlined),
          color: Colors.white,
        ),
      ],
    );
  }
}
