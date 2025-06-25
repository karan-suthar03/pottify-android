import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/models.dart';
import 'services/room_service.dart';
import 'dialogs/room_dialogs.dart';
import 'widgets/room_header.dart';
import 'widgets/room_state/room_selection_view.dart';
import 'widgets/room_state/current_room_view.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // Room state management
  CurrentRoom? _currentRoom;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Room Actions
  Future<void> _createRoom() async {
    HapticFeedback.mediumImpact();
    final roomName = await RoomDialogs.showCreateRoomDialog(context);
    
    if (roomName != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentRoom = RoomService.createRoom(roomName);
      });
    }
  }

  void _joinRoom(String roomCode) {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentRoom = RoomService.joinRoom(roomCode);
    });
  }
    void _shareRoom() {
    if (_currentRoom == null) return;
    HapticFeedback.mediumImpact();
    // Room link shared silently
  }
  
  void _copyRoomCode() {
    if (_currentRoom == null) return;
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _currentRoom!.code));
    // Room code copied silently
  }
    Future<void> _leaveRoom() async {
    if (_currentRoom == null) return;
    
    HapticFeedback.mediumImpact();
    final shouldLeave = await RoomDialogs.showLeaveRoomDialog(
      context, 
      _currentRoom!.name,
    );
    
    if (shouldLeave) {
      setState(() {
        _currentRoom = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Header
              RoomHeader(currentRoom: _currentRoom),
              
              // Animated main content
              ScaleTransition(
                scale: _scaleAnimation,
                child: _currentRoom == null 
                  ? RoomSelectionView(
                      onCreateRoom: _createRoom,
                      onJoinRoom: _joinRoom,
                    )
                  : CurrentRoomView(
                      room: _currentRoom!,
                      onShareRoom: _shareRoom,
                      onCopyCode: _copyRoomCode,
                      onLeaveRoom: _leaveRoom,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
