import 'package:flutter/material.dart';
import '../create_room_card.dart';
import '../join_room_section.dart';

class RoomSelectionView extends StatelessWidget {
  final VoidCallback onCreateRoom;
  final Function(String) onJoinRoom;
  
  const RoomSelectionView({
    super.key,
    required this.onCreateRoom,
    required this.onJoinRoom,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        // Create Room Card
        CreateRoomCard(onTap: onCreateRoom),
        const SizedBox(height: 32),
        
        // OR Divider
        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Join Room Section
        JoinRoomSection(onJoinRoom: onJoinRoom),
      ],
    );
  }
}
