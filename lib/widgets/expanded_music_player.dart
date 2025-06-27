import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../services/music_player_service.dart';
import '../services/music_player_ui_service.dart';

class ExpandedMusicPlayer extends StatefulWidget {
  final VoidCallback? onClose;

  const ExpandedMusicPlayer({
    super.key,
    this.onClose,
  });

  @override
  State<ExpandedMusicPlayer> createState() => _ExpandedMusicPlayerState();
}

class _ExpandedMusicPlayerState extends State<ExpandedMusicPlayer>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _albumController;
  late Animation<double> _slideAnimation;
  late Animation<double> _albumAnimation;
  int _currentView = 0; // 0: Player, 1: Queue, 2: Lyrics
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _albumController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );
    _albumAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _albumController,
      curve: Curves.linear,
    ));
    _slideController.forward();
    final musicPlayer = MusicPlayerService();
    if (musicPlayer.isPlaying && !musicPlayer.isLoading) {
      _albumController.repeat();
    }
    // Listen to state changes
    MusicPlayerService().addListener(_handleMusicPlayerStateChange);
    MusicPlayerUIService().addListener(_handleMusicPlayerStateChange);
  }

  void _handleMusicPlayerStateChange() {
    final musicPlayer = MusicPlayerService();
    if (musicPlayer.isPlaying && !musicPlayer.isLoading) {
      if (!_albumController.isAnimating) {
        _albumController.repeat();
      }
    } else {
      if (_albumController.isAnimating) {
        _albumController.stop();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _albumController.dispose();
    MusicPlayerService().removeListener(_handleMusicPlayerStateChange);
    MusicPlayerUIService().removeListener(_handleMusicPlayerStateChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(ExpandedMusicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No need to handle album animation here anymore
  }

  void _toggleView(int view) {
    setState(() {
      _currentView = view;
    });
    HapticFeedback.lightImpact();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        MusicPlayerService(),
        MusicPlayerUIService(),
      ]),
      builder: (context, _) {
        final musicPlayer = MusicPlayerService();
        final song = musicPlayer.currentSong;
        if (song == null) return const SizedBox.shrink();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade900,
                  Colors.purple.shade800,
                  Colors.deepPurple.shade900,
                ],
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: Column(
                children: [
                  // Top bar
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: widget.onClose ?? () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'PLAYING FROM LIBRARY',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Liked Songs',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            },
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: _currentView == 0
                        ? _buildPlayerView(song, musicPlayer)
                        : _currentView == 1
                            ? _buildQueueView(musicPlayer)
                            : _buildLyricsView(),
                  ),
                  // Bottom controls
                  _buildBottomControls(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerView(Song song, MusicPlayerService musicPlayer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Album art with loading state
          GestureDetector(
            onTap: () => _toggleView(2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _albumAnimation,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: song.imageUrl != null && song.imageUrl!.isNotEmpty
                          ? Image.network(
                              song.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  _isImageLoading = false;
                                  return child;
                                }
                                _isImageLoading = true;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.shade300,
                                        Colors.purple.shade400,
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                _isImageLoading = false;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.shade300,
                                        Colors.purple.shade400,
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    color: Colors.white,
                                    size: 80,
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade300,
                                    Colors.purple.shade400,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.music_note_rounded,
                                color: Colors.white,
                                size: 80,
                              ),
                            ),
                    ),
                  ),
                ),
                if (musicPlayer.isLoading && !_isImageLoading)
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(flex: 1),
          // Song info
          Text(
            song.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            song.artist,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Progress slider
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: musicPlayer.progress,
                  onChanged: musicPlayer.seek,
                  onChangeStart: (_) => HapticFeedback.lightImpact(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(Duration(
                        milliseconds: (musicPlayer.progress * song.duration.inMilliseconds).round(),
                      )),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(song.duration),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  musicPlayer.previous();
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: musicPlayer.isLoading
                      ? null
                      : musicPlayer.isPlaying
                          ? musicPlayer.pause
                          : musicPlayer.play,
                  icon: musicPlayer.isLoading
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        )
                      : Icon(
                          musicPlayer.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.deepPurple,
                          size: 36,
                        ),
                ),
              ),
              IconButton(
                onPressed: () {
                  musicPlayer.next();
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildQueueView(MusicPlayerService musicPlayer) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Queue',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: musicPlayer.queue.length,
            itemBuilder: (context, index) {
              final song = musicPlayer.queue[index];
              final isCurrentSong = song.title == musicPlayer.currentSong?.title;
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isCurrentSong
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.music_note_rounded,
                    color: isCurrentSong ? Colors.white : Colors.white.withOpacity(0.7),
                    size: 24,
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isCurrentSong ? Colors.white : Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: isCurrentSong ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  song.artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                trailing: isCurrentSong
                    ? Icon(
                        musicPlayer.isPlaying ? Icons.volume_up_rounded : Icons.pause_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
                onTap: () {
                  HapticFeedback.lightImpact();
                  musicPlayer.setSong(song);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLyricsView() {
    // Demo lyrics
    const lyrics = [
      "Yeah, I feel like I'm just missing something",
      "when you're gone",
      "Yeah, I feel like I'm missing something",
      "when you're gone",
      "",
      "I've been running on empty",
      "I've been running on empty",
      "I've been running on empty",
      "",
      "So long, so long",
      "I've been running on empty",
      "So long, so long",
      "I've been running on empty",
      "",
      "I've been running on empty",
      "I've been running so long",
      "I've been running on empty",
      "Running on, running on empty",
      "",
      "So long, I've been running on empty",
      "So long, I've been running blind",
      "So long, I've been running on empty",
      "Running on, running on empty",
    ];
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      itemCount: lyrics.length,
      itemBuilder: (context, index) {
        final line = lyrics[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            line,
            style: TextStyle(
              color: line.isEmpty ? Colors.transparent : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => _toggleView(0),
            icon: Icon(
              Icons.music_note_rounded,
              color: _currentView == 0 ? Colors.white : Colors.white.withOpacity(0.5),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () => _toggleView(1),
            icon: Icon(
              Icons.queue_music_rounded,
              color: _currentView == 1 ? Colors.white : Colors.white.withOpacity(0.5),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              Icons.devices_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              Icons.share_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
