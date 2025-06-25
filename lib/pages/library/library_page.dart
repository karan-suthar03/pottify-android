import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/models.dart';
import 'widgets/library_header.dart';
import 'widgets/quick_access_section.dart';
import 'sections/recently_played_section.dart';
import 'sections/playlists_section.dart';
import 'sections/albums_section.dart';
import 'sections/artists_section.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Mock data - replace with actual data management
  List<Song> _recentlyPlayed = [];
  List<Playlist> _playlists = [];
  List<Album> _albums = [];
  List<String> _artists = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMockData();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }
  
  void _loadMockData() {
    // Mock recently played songs
    _recentlyPlayed = [
      Song(
        id: '1',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        albumArt: '🌟',
        duration: const Duration(minutes: 3, seconds: 20),
        isFavorite: true,
        addedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Song(
        id: '2',
        title: 'Watermelon Sugar',
        artist: 'Harry Styles',
        album: 'Fine Line',
        albumArt: '🍉',
        duration: const Duration(minutes: 2, seconds: 54),
        isFavorite: false,
        addedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Song(
        id: '3',
        title: 'Levitating',
        artist: 'Dua Lipa',
        album: 'Future Nostalgia',
        albumArt: '✨',
        duration: const Duration(minutes: 3, seconds: 23),
        isFavorite: true,
        addedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    
    // Mock playlists
    _playlists = [
      Playlist(
        id: '1',
        name: 'My Favorites',
        description: 'Songs I can\'t stop listening to',
        coverImage: '❤️',
        songs: _recentlyPlayed.where((song) => song.isFavorite).toList(),
      ),
      Playlist(
        id: '2',
        name: 'Workout Mix',
        description: 'High energy songs for the gym',
        coverImage: '💪',
        songs: _recentlyPlayed,
      ),
      Playlist(
        id: '3',
        name: 'Chill Vibes',
        description: 'Relaxing music for studying',
        coverImage: '🌙',
        songs: _recentlyPlayed.take(2).toList(),
      ),
    ];
    
    // Mock albums
    _albums = [
      Album(
        id: '1',
        name: 'After Hours',
        artist: 'The Weeknd',
        coverImage: '🌃',
        songs: [_recentlyPlayed[0]],
        releaseDate: DateTime(2020, 3, 20),
        genre: 'R&B',
      ),
      Album(
        id: '2',
        name: 'Future Nostalgia',
        artist: 'Dua Lipa',
        coverImage: '🎭',
        songs: [_recentlyPlayed[2]],
        releaseDate: DateTime(2020, 3, 27),
        genre: 'Pop',
      ),
    ];
    
    // Mock artists
    _artists = ['The Weeknd', 'Harry Styles', 'Dua Lipa', 'Billie Eilish', 'Taylor Swift'];
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
    void _onSongTap(Song song) {
    HapticFeedback.lightImpact();
    // TODO: Implement song playback
  }
  
  void _onPlaylistTap(Playlist playlist) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to playlist detail page
  }
  
  void _onAlbumTap(Album album) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to album detail page
  }
    void _onArtistTap(String artist) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to artist detail page
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: CustomScrollView(slivers: [
                // Header
                const SliverToBoxAdapter(
                  child: LibraryHeader(),
                ),
                
                // Quick Access Section
                SliverToBoxAdapter(
                  child: QuickAccessSection(                    onCreatePlaylist: () {
                      HapticFeedback.mediumImpact();
                      // TODO: Implement create playlist
                    },
                    onLikedSongs: () {
                      HapticFeedback.lightImpact();
                      // TODO: Navigate to liked songs
                    },
                    onDownloads: () {
                      HapticFeedback.lightImpact();
                      // TODO: Navigate to downloads
                    },
                  ),
                ),
                
                // Recently Played Section
                SliverToBoxAdapter(
                  child: RecentlyPlayedSection(
                    songs: _recentlyPlayed,
                    onSongTap: _onSongTap,
                  ),
                ),
                
                // Playlists Section
                SliverToBoxAdapter(
                  child: PlaylistsSection(
                    playlists: _playlists,
                    onPlaylistTap: _onPlaylistTap,
                  ),
                ),
                
                // Albums Section
                SliverToBoxAdapter(
                  child: AlbumsSection(
                    albums: _albums,
                    onAlbumTap: _onAlbumTap,
                  ),
                ),
                
                // Artists Section
                SliverToBoxAdapter(
                  child: ArtistsSection(
                    artists: _artists,
                    onArtistTap: _onArtistTap,
                  ),
                ),                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
