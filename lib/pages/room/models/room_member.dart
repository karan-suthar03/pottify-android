class RoomMember {
  final String id;
  final String name;
  final String avatar;
  final bool isHost;
  final bool isOnline;
  
  RoomMember({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isHost,
    required this.isOnline,
  });
  
  RoomMember copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isHost,
    bool? isOnline,
  }) {
    return RoomMember(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isHost: isHost ?? this.isHost,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
