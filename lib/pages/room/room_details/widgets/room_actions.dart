import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoomActions extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onCopyCode;
  final VoidCallback onLeave;
  
  const RoomActions({
    super.key,
    required this.onShare,
    required this.onCopyCode,
    required this.onLeave,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        // Share Room Button
        Expanded(
          child: _ActionButton(
            icon: Icons.share_rounded,
            label: 'Share Room',
            onTap: () {
              HapticFeedback.lightImpact();
              onShare();
            },
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Copy Code Button
        Expanded(
          child: _ActionButton(
            icon: Icons.copy_rounded,
            label: 'Copy Code',
            onTap: () {
              HapticFeedback.lightImpact();
              onCopyCode();
            },
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Leave Room Button
        _ActionButton(
          icon: Icons.exit_to_app_rounded,
          label: 'Leave',
          onTap: () {
            HapticFeedback.mediumImpact();
            onLeave();
          },
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          isCompact: true,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isCompact;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
    this.isCompact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 20,
            vertical: 16,
          ),
          child: isCompact 
            ? Icon(
                icon,
                color: foregroundColor,
                size: 20,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: foregroundColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
