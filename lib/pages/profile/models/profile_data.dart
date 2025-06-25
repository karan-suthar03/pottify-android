class ProfileData {
  final String userName;
  final String userHandle;
  final String? avatarUrl;
  final int songsCount;
  final int friendsCount;
  final int favoritesCount;

  const ProfileData({
    required this.userName,
    required this.userHandle,
    this.avatarUrl,
    required this.songsCount,
    required this.friendsCount,
    required this.favoritesCount,
  });

  // Default profile data
  static const ProfileData defaultProfile = ProfileData(
    userName: 'Music Lover',
    userHandle: '@musiclover123',
    avatarUrl: null,
    songsCount: 1247,
    friendsCount: 24,
    favoritesCount: 247,
  );

  // Copy with method for updating profile data
  ProfileData copyWith({
    String? userName,
    String? userHandle,
    String? avatarUrl,
    int? songsCount,
    int? friendsCount,
    int? favoritesCount,
  }) {
    return ProfileData(
      userName: userName ?? this.userName,
      userHandle: userHandle ?? this.userHandle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      songsCount: songsCount ?? this.songsCount,
      friendsCount: friendsCount ?? this.friendsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
    );
  }
}
