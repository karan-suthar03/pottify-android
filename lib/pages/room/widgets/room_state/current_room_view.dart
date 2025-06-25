import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../room_details/widgets/room_info_card.dart';
import '../../room_details/widgets/members_list.dart';
import '../../room_details/widgets/room_actions.dart';

class CurrentRoomView extends StatelessWidget {
  final CurrentRoom room;
  final VoidCallback onShareRoom;
  final VoidCallback onCopyCode;
  final VoidCallback onLeaveRoom;
  
  const CurrentRoomView({
    super.key,
    required this.room,
    required this.onShareRoom,
    required this.onCopyCode,
    required this.onLeaveRoom,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room Info Card
        RoomInfoCard(
          roomName: room.name,
          roomCode: room.code,
          memberCount: room.members.length,
        ),
        
        const SizedBox(height: 24),
        
        // Room Actions
        RoomActions(
          onShare: onShareRoom,
          onCopyCode: onCopyCode,
          onLeave: onLeaveRoom,
        ),
        
        const SizedBox(height: 32),
        
        // Members Section
        Text(
          'Members (${room.members.length})',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Members List
        MembersList(members: room.members),
        
        const SizedBox(height: 32),
        
        // Currently Playing Section
        _buildCurrentlyPlayingSection(theme, colorScheme),
      ],
    );
  }
  
  Widget _buildCurrentlyPlayingSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            room.currentlyPlaying != null 
              ? Icons.music_note_rounded
              : Icons.music_off_rounded,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            room.currentlyPlaying ?? 'No music playing',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            room.currentlyPlaying != null
              ? 'Playing for ${room.onlineMemberCount} members'
              : 'Start playing music to share with everyone',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
