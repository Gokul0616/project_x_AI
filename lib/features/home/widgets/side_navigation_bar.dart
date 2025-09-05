import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor1,
        border: Border(
          right: BorderSide(color: AppColors.borderColor1, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Logo/Brand
          Icon(
            Icons.close, // Using X icon for Twitter/X
            size: 32,
            color: AppColors.white,
          ),
          const SizedBox(height: 40),

          // Navigation Items
          _buildNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.search_outlined,
            selectedIcon: Icons.search,
            label: 'Explore',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: 'Notifications',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.mail_outline,
            selectedIcon: Icons.mail,
            label: 'Messages',
            index: 3,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
            index: 4,
          ),

          const SizedBox(height: 40),

          // Tweet Button (for larger screens)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle tweet compose
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Tweet', style: TextStyles.buttonLarge),
            ),
          ),

          const Spacer(),

          // User Profile Section
          _buildUserProfile(),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onItemSelected(index),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isSelected
                ? AppColors.blue.withOpacity(0.2)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 26,
                color: isSelected ? AppColors.blue : AppColors.white,
              ),
              const SizedBox(width: 20),
              Text(
                label,
                style: TextStyles.titleMedium.copyWith(
                  color: isSelected ? AppColors.blue : AppColors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You',
                  style: TextStyles.titleSmall.copyWith(color: AppColors.white),
                ),
                Text(
                  '@you',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.midGray,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: AppColors.midGray),
        ],
      ),
    );
  }
}
