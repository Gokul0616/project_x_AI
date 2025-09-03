// lib/features/home/widgets/side_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/providers/theme_provider.dart';
import 'package:project_x/core/services/app_navigation_service.dart';

class SideNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const SideNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNavItem(Icons.home, "Home", 0, isDark),
              _buildNavItem(Icons.search, "Explore", 1, isDark),
              _buildNavItem(Icons.notifications, "Notifications", 2, isDark),
              _buildNavItem(Icons.mail, "Messages", 3, isDark),
              _buildNavItem(Icons.person, "Profile", 4, isDark),
              const SizedBox(height: 20),
              // Theme toggle
              _buildThemeToggle(context, themeProvider, isDark),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  AppNavigationService.showTweetComposer(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  "Post",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileTile(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    return ListTile(
      leading: Icon(
        icon,
        color: currentIndex == index ? AppColors.blue : AppColors.textPrimary(isDark),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: currentIndex == index ? AppColors.blue : AppColors.textPrimary(isDark),
          fontSize: 16,
          fontWeight: currentIndex == index
              ? FontWeight.w600
              : FontWeight.w400,
        ),
      ),
      onTap: () {
        if (index == 4) { // Profile
          AppNavigationService.navigateToProfile();
        } else {
          onItemSelected(index);
        }
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider, bool isDark) {
    return ListTile(
      leading: Icon(
        _getThemeIcon(themeProvider.themeMode),
        color: AppColors.textPrimary(isDark),
      ),
      title: Text(
        themeProvider.themeName,
        style: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () {
        _showThemeDialog(context, themeProvider);
      },
    );
  }

  Widget _buildProfileTile(bool isDark) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage('https://via.placeholder.com/32'),
      ),
      title: Text(
        "User Name",
        style: TextStyle(
          color: AppColors.textPrimary(isDark),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        "@username",
        style: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 13,
        ),
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
