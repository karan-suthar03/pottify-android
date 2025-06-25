import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Pottify',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Handle notifications
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurface,
              ),
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Handle profile
              },
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
