import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';

class FloatingMusicPlayer extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Song? currentSong;
  final bool isPlaying;
  final double progress;
  final bool isLoading;

  const FloatingMusicPlayer({
    super.key,
    this.isVisible = true,
    this.onTap,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.currentSong,
    this.isPlaying = false,
    this.progress = 0.0,
    this.isLoading = false,
  });

  @override
  State<FloatingMusicPlayer> createState() => _FloatingMusicPlayerState();
}

class _FloatingMusicPlayerState extends State<FloatingMusicPlayer>
    with TickerProviderStateMixin {  late AnimationController _slideController;
  late AnimationController _playButtonController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _playButtonAnimation;
  
  Song? get _currentSong => widget.currentSong;
  bool get _isPlaying => widget.isPlaying;
  double get _progress => widget.progress;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
      _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _playButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _playButtonController,      curve: Curves.easeInOut,
    ));
    
    if (widget.isVisible) {
      _slideController.forward();
    }
  }

  @override
  void didUpdateWidget(FloatingMusicPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    }
  }  @override
  void dispose() {
    _slideController.dispose();
    _playButtonController.dispose();
    super.dispose();
  }

  void _onPrevious() {
    widget.onPrevious?.call();
    HapticFeedback.lightImpact();
  }

  void _onNext() {
    widget.onNext?.call();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    if (_currentSong == null) {
      return const Center(
        child: Text(
          'Not playing',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }
    final imageUrl = _currentSong?.imageUrl;
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withValues(alpha: 0.9),
              Colors.purple.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar (seekbar)
                  Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: _progress,
                          onChanged: (v) {},
                          activeColor: Colors.white.withOpacity(0.9),
                          inactiveColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  
                  // Main player content
                  Row(
                    children: [
                      // Album art
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.deepPurple.shade300,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.deepPurple.shade300,
                                  child: const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Song info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentSong!.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentSong!.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Control buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [                          // Previous button
                          IconButton(
                            onPressed: _onPrevious,
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 28,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                          
                          // Play/Pause or Loading button
                          ScaleTransition(
                            scale: _playButtonAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: widget.isLoading ? null : widget.onPlayPause,
                                icon: widget.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: _isPlaying
                                            ? Icon(
                                                Icons.pause_rounded,
                                                key: const ValueKey('pause'),
                                                color: Colors.deepPurple.shade700,
                                                size: 24,
                                              )
                                            : Icon(
                                                Icons.play_arrow_rounded,
                                                key: const ValueKey('play'),
                                                color: Colors.deepPurple.shade700,
                                                size: 24,
                                              ),
                                      ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                            ),
                          ),
                            // Next button
                          IconButton(
                            onPressed: _onNext,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 28,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
