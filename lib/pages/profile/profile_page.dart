import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats_row.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/sign_out_button.dart';
import 'utils/profile_dialogs.dart';
import 'models/profile_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Profile data
  ProfileData profileData = ProfileData.defaultProfile;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Profile Header
            ProfileHeader(
              userName: profileData.userName,
              userHandle: profileData.userHandle,
              avatarUrl: profileData.avatarUrl,
              onSettingsTap: () {
                // TODO: Open settings
              },
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    ProfileStatsRow(
                      songsCount: profileData.songsCount,
                      friendsCount: profileData.friendsCount,
                      favoritesCount: profileData.favoritesCount,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Profile Menu Items
                    ProfileMenuItem(
                      icon: Icons.edit_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Update your profile information',
                      onTap: () {
                        // TODO: Navigate to edit profile
                      },
                    ),
                    
                    ProfileMenuItem(
                      icon: Icons.people_rounded,
                      title: 'Friends',
                      subtitle: 'Connect with other music lovers',
                      onTap: () {
                        // TODO: Navigate to friends
                      },
                    ),
                    
                    ProfileMenuItem(
                      icon: Icons.share_rounded,
                      title: 'Share Profile',
                      subtitle: 'Let others discover your music taste',
                      onTap: () {
                        // TODO: Share profile
                      },
                    ),
                    
                    const SizedBox(height: 24),
                      // Divider
                    Divider(
                      color: colorScheme.onSurface.withOpacity(0.1),
                      thickness: 1,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // App Settings & Features
                    ProfileMenuItem(
                      icon: Icons.feedback_rounded,
                      title: 'Send Feedback',
                      subtitle: 'Help us improve the app',
                      onTap: () => ProfileDialogs.showFeedbackDialog(context),
                    ),
                    
                    ProfileMenuItem(
                      icon: Icons.favorite_border_rounded,
                      title: 'Donate',
                      subtitle: 'Support the development',
                      onTap: () => ProfileDialogs.showDonateDialog(context),
                    ),
                    
                    ProfileMenuItem(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Settings',
                      subtitle: 'Control your data and privacy',
                      onTap: () {
                        // TODO: Navigate to privacy settings
                      },
                    ),
                    
                    ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact us',
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    
                    ProfileMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'App version, terms & privacy',
                      onTap: () => ProfileDialogs.showAboutDialog(context),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign Out Button
                    SignOutButton(
                      onTap: () => ProfileDialogs.showSignOutDialog(context),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
