import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings and privacy',
          style: TextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.backgroundColor1,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSection('Your account', [
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Account information',
              subtitle:
                  'See your account information like your phone number and email address.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.security,
              title: 'Change your password',
              subtitle: 'Change your password at any time.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.download_outlined,
              title: 'Download an archive of your data',
              subtitle:
                  'Get insights into the type of information stored for your account.',
              onTap: () {},
            ),
          ]),

          _buildSection('Security and account access', [
            _buildSettingsItem(
              icon: Icons.security,
              title: 'Security',
              subtitle: 'Manage your account\'s security.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.apps,
              title: 'Apps and sessions',
              subtitle:
                  'See information about when you logged into your account and the apps you connected to it.',
              onTap: () {},
            ),
          ]),

          _buildSection('Privacy and safety', [
            _buildSettingsItem(
              icon: Icons.visibility_outlined,
              title: 'Audience and tagging',
              subtitle:
                  'Manage what information you allow other people on X to see.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.content_copy,
              title: 'Your Tweets',
              subtitle: 'Manage the information associated with your Tweets.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.location_on_outlined,
              title: 'Location information',
              subtitle: 'Manage how X uses location information.',
              onTap: () {},
            ),
          ]),

          _buildSection('Notifications', [
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Filters',
              subtitle:
                  'Choose the notifications you\'d like to see — and those you don\'t.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.email_outlined,
              title: 'Preferences',
              subtitle: 'Select your preferences by notification type.',
              onTap: () {},
            ),
          ]),

          _buildSection('Accessibility, display, and languages', [
            _buildSettingsItem(
              icon: Icons.accessibility,
              title: 'Accessibility',
              subtitle:
                  'Manage aspects of your X experience such as limiting color contrast and motion.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.display_settings,
              title: 'Display',
              subtitle:
                  'Manage your font size, color, and background. These settings affect all the X accounts on this browser.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.language,
              title: 'Languages',
              subtitle:
                  'Manage which languages are used to personalize your X experience.',
              onTap: () {},
            ),
          ]),

          _buildSection('Additional resources', [
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle:
                  'Visit our Help Center to read articles and contact our support team.',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Privacy Policy, Terms of Service and more.',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyles.titleMedium.copyWith(color: AppColors.white),
          ),
        ),
        ...items,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.white),
      title: Text(
        title,
        style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.midGray),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
