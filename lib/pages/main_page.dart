import 'package:app/widgets/floating_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home/home_page.dart';
import 'room/room_page.dart';
import 'library/library_page.dart';
import 'profile/profile_page.dart';
import 'search/search_tab_page.dart';
import '../services/music_player_ui_service.dart';
import '../services/service_locator.dart';
import '../widgets/expanded_music_player.dart';
import '../services/music_player_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int num = 1;
  
  // Music player state
  late List<Widget> _pages;
  final MusicPlayerUIService _musicPlayerUIService = serviceLocator.getRequired<MusicPlayerUIService>();
  final MusicPlayerService _musicPlayerService = serviceLocator.getRequired<MusicPlayerService>();
  


  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();

    _pages = [
      const HomePage(),
      const RoomPage(),
      SearchTabPage(),
      const LibraryPage(),
      const ProfilePage(),
    ];
  }


  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _toggleMusicPlayer() {
    _musicPlayerUIService.toggle();
    num++;
  }

  void _showExpandedMusicPlayerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExpandedMusicPlayer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),          
              ),
              AnimatedBuilder(
                animation: _musicPlayerService,
                builder: (context, _) {
                  return AnimatedBuilder(
                    animation: _musicPlayerUIService,
                    builder: (context, __) {
                      return Positioned.fill(
                        bottom: 10,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _musicPlayerService.currentSong != null
                              ? FloatingMusicPlayer(
                                  isVisible: true,
                                  onTap: _showExpandedMusicPlayerSheet,
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: GestureDetector(
            onLongPress: _toggleMusicPlayer,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(         
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  showSelectedLabels: true,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  elevation: 0,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.people_outline_rounded),
                      activeIcon: Icon(Icons.people_rounded),
                      label: 'Room',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search_rounded),
                      activeIcon: Icon(Icons.search_rounded),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.library_music_outlined),
                      activeIcon: Icon(Icons.library_music_rounded),
                      label: 'Library',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      activeIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
