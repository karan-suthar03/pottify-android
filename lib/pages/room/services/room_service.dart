import '../models/models.dart';

class RoomService {
  static String generateRoomCode() {
    // Generate a 6-character room code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    
    return code;
  }
  
  static CurrentRoom createRoom(String roomName) {
    final roomCode = generateRoomCode();
    final members = [
      RoomMember(
        id: 'current_user',
        name: 'You',
        avatar: '🎵',
        isHost: true,
        isOnline: true,
      ),
    ];
    
    return CurrentRoom(
      name: roomName,
      code: roomCode,
      members: members,
    );
  }
  
  static CurrentRoom joinRoom(String roomCode) {
    // In a real app, this would make an API call
    final members = [
      RoomMember(
        id: 'host_user',
        name: 'Alex',
        avatar: '🎸',
        isHost: true,
        isOnline: true,
      ),
      RoomMember(
        id: 'current_user',
        name: 'You',
        avatar: '🎵',
        isHost: false,
        isOnline: true,
      ),
      RoomMember(
        id: 'user_2',
        name: 'Sarah',
        avatar: '🎤',
        isHost: false,
        isOnline: false,
      ),
    ];
    
    return CurrentRoom(
      name: 'Music Room', // In real app, get from server
      code: roomCode,
      members: members,
    );
  }
  
  static List<String> getAvailableAvatars() {
    return ['🎵', '🎸', '🎤', '🎧', '🎹', '🥁', '🎺', '🎻', '🎷', '🪗'];
  }
}
