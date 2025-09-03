// lib/features/home/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/constants/app_constants.dart';
import 'package:project_x/core/services/app_navigation_service.dart';
import 'package:project_x/core/providers/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Drawer(
          backgroundColor: AppColors.backgroundColor(isDark),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile info
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage('https://via.placeholder.com/48'),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@johndoe',
                        style: TextStyle(
                          color: AppColors.textSecondary(isDark),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Row(
                        children: [
                          _buildFollowCount('240', 'Following', isDark),
                          const SizedBox(width: AppConstants.paddingM),
                          _buildFollowCount('1.2K', 'Followers', isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Divider(color: AppColors.borderColor(isDark), height: 1),
                
                // Menu items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                          AppNavigationService.navigateToProfile();
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.list_alt_outlined,
                        title: 'Lists',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.bookmark_border,
                        title: 'Bookmarks',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.groups_outlined,
                        title: 'Communities',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_add_outlined,
                        title: 'Creator Studio',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.monetization_on_outlined,
                        title: 'Monetization',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Divider(color: AppColors.borderColor(isDark), height: 1),
                      _buildDrawerItem(
                        icon: _getThemeIcon(themeProvider.themeMode),
                        title: 'Theme: ${themeProvider.themeName}',
                        isDark: isDark,
                        onTap: () {
                          _showThemeDialog(context, themeProvider);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings and privacy',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                          AppNavigationService.navigateToSettings();
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                // Bottom logout
                Divider(color: AppColors.borderColor(isDark), height: 1),
                _buildDrawerItem(
                  icon: Icons.logout_outlined,
                  title: 'Log out',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    // Handle logout
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowCount(String count, String label, bool isDark) {
    return Row(
      children: [
        Text(
          count,
          style: TextStyle(
            color: AppColors.textPrimary(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(isDark),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary(isDark),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: 2,
      ),
    );
  }
  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
