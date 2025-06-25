import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';

class ExpandedMusicPlayer extends StatefulWidget {
  final Song currentSong;
  final List<Song> queue;
  final bool isPlaying;
  final bool isLoading;
  final double progress;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Function(double)? onSeek;

  const ExpandedMusicPlayer({
    super.key,
    required this.currentSong,
    required this.queue,
    this.isPlaying = false,
    this.isLoading = false,
    this.progress = 0.0,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onSeek,
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
    
    if (widget.isPlaying && !widget.isLoading) {
      _albumController.repeat();
    }
  }

  @override
  void didUpdateWidget(ExpandedMusicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying || widget.isLoading != oldWidget.isLoading) {
      if (widget.isPlaying && !widget.isLoading) {
        _albumController.repeat();
      } else {
        _albumController.stop();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _albumController.dispose();
    super.dispose();
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
                        onPressed: () => Navigator.pop(context),
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
                              color: Colors.white.withValues(alpha: 0.7),
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
                    ? _buildPlayerView()
                    : _currentView == 1
                        ? _buildQueueView()
                        : _buildLyricsView(),
              ),
              
              // Bottom controls
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerView() {
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
                      child: widget.currentSong.imageUrl != null && widget.currentSong.imageUrl!.isNotEmpty
                          ? Image.network(
                              widget.currentSong.imageUrl!,
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
                if (widget.isLoading && !_isImageLoading)
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
            widget.currentSong.title,
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
            widget.currentSong.artist,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
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
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: widget.progress,
                  onChanged: widget.onSeek,
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
                        milliseconds: (widget.progress * widget.currentSong.duration.inMilliseconds).round(),
                      )),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(widget.currentSong.duration),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
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
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(
                  Icons.shuffle_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: widget.isLoading ? null : widget.onPrevious,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: widget.isLoading ? Colors.white.withOpacity(0.5) : Colors.white,
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
                  onPressed: widget.isLoading ? null : () {
                    widget.onPlayPause?.call();
                    HapticFeedback.lightImpact();
                  },
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        )
                      : Icon(
                          widget.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.deepPurple,
                          size: 36,
                        ),
                ),
              ),
              IconButton(
                onPressed: widget.isLoading ? null : widget.onNext,
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: widget.isLoading ? Colors.white.withOpacity(0.5) : Colors.white,
                  size: 40,
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(
                  Icons.repeat_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildQueueView() {
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
            itemCount: widget.queue.length,
            itemBuilder: (context, index) {
              final song = widget.queue[index];
              final isCurrentSong = song.title == widget.currentSong.title;
              
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isCurrentSong 
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.music_note_rounded,
                    color: isCurrentSong ? Colors.white : Colors.white.withValues(alpha: 0.7),
                    size: 24,
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isCurrentSong ? Colors.white : Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: isCurrentSong ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  song.artist,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                trailing: isCurrentSong
                    ? Icon(
                        widget.isPlaying ? Icons.volume_up_rounded : Icons.pause_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Switch to selected song
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _toggleView(0),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Lyrics',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lyrics.map((line) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    line,
                    style: TextStyle(
                      color: line.isEmpty ? Colors.transparent : Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
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
              color: _currentView == 0 ? Colors.white : Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () => _toggleView(1),
            icon: Icon(
              Icons.queue_music_rounded,
              color: _currentView == 1 ? Colors.white : Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              Icons.devices_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            icon: Icon(
              Icons.share_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
