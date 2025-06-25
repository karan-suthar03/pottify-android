import 'room_member.dart';

class CurrentRoom {
  final String name;
  final String code;
  final List<RoomMember> members;
  final String? currentlyPlaying;
  final DateTime createdAt;
  
  CurrentRoom({
    required this.name,
    required this.code,
    required this.members,
    this.currentlyPlaying,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  CurrentRoom copyWith({
    String? name,
    String? code,
    List<RoomMember>? members,
    String? currentlyPlaying,
    DateTime? createdAt,
  }) {
    return CurrentRoom(
      name: name ?? this.name,
      code: code ?? this.code,
      members: members ?? this.members,
      currentlyPlaying: currentlyPlaying ?? this.currentlyPlaying,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Helper getters
  bool get hasCurrentUser => members.any((member) => member.id == 'current_user');
  bool get isCurrentUserHost => members.firstWhere(
    (member) => member.id == 'current_user',
    orElse: () => RoomMember(id: '', name: '', avatar: '', isHost: false, isOnline: false),
  ).isHost;
  int get onlineMemberCount => members.where((member) => member.isOnline).length;
}
