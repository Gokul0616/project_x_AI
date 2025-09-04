import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/services/auth_service.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/models/user_model.dart';
import 'package:project_x/features/profile/profile_screen.dart';
import 'package:project_x/features/communities/communities_screen.dart';
import 'package:project_x/features/settings/settings_screen.dart';
import 'package:project_x/features/authentication/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildMenuItems(context)),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current user info
              if (user != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: user.avatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(user.avatarUrl)
                          : const AssetImage(
                                  'assets/images/placeholder_avatar.png',
                                )
                                as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.username,
                                style: TextStyles.titleSmall.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              if (user.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: AppColors.blue,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '@${user.username}',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.midGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showAccountSwitcher(context),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem('${user.followingCount}', 'Following'),
                    const SizedBox(width: 16),
                    _buildStatItem('${user.followersCount}', 'Followers'),
                  ],
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Sign in to X',
                        style: TextStyles.titleMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String count, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: count,
            style: TextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          TextSpan(
            text: ' $label',
            style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildMenuItem(
          context,
          icon: Icons.person_outline,
          title: 'Profile',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  username:
                      context.read<AuthService>().currentUser?.username ?? '',
                ),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.group_outlined,
          title: 'Communities',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CommunitiesScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.bookmark_border,
          title: 'Bookmarks',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to bookmarks
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.list_alt,
          title: 'Lists',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to lists
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.person_add_outlined,
          title: 'Twitter Blue',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to Twitter Blue
          },
        ),
        const Divider(color: AppColors.borderColor),
        _buildMenuItem(
          context,
          icon: Icons.settings_outlined,
          title: 'Settings and privacy',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.help_outline,
          title: 'Help Center',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to help
          },
        ),
        if (context.watch<AuthService>().isAuthenticated) ...[
          const Divider(color: AppColors.borderColor),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Log out',
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.white, size: 24),
      title: Text(
        title,
        style: TextStyles.bodyLarge.copyWith(color: AppColors.white),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // TODO: Toggle theme
            },
            icon: const Icon(Icons.brightness_6, color: AppColors.midGray),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show QR code
            },
            icon: const Icon(Icons.qr_code, color: AppColors.midGray),
          ),
        ],
      ),
    );
  }

  void _showAccountSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => const AccountSwitcherBottomSheet(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: Text(
          'Log out of X?',
          style: TextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
        content: Text(
          'You can always log back in at any time.',
          style: TextStyles.bodyMedium.copyWith(color: AppColors.midGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyles.buttonMedium.copyWith(color: AppColors.midGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Close drawer
              context.read<AuthService>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class AccountSwitcherBottomSheet extends StatelessWidget {
  const AccountSwitcherBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Switch account',
                    style: TextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current account
              if (authService.currentUser != null) ...[
                Text(
                  'Current account',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.midGray,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAccountItem(
                  context,
                  authService.currentUser!,
                  isCurrentAccount: true,
                ),
                const SizedBox(height: 16),
              ],

              // Other accounts
              if (authService.accounts.length > 1) ...[
                Text(
                  'Other accounts',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.midGray,
                  ),
                ),
                const SizedBox(height: 8),
                ...authService.accounts
                    .where(
                      (account) => account.id != authService.currentUser?.id,
                    )
                    .map((account) => _buildAccountItem(context, account)),
                const SizedBox(height: 16),
              ],

              // Add account button
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: const Icon(Icons.add, color: AppColors.blue),
                ),
                title: Text(
                  'Add an existing account',
                  style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountItem(
    BuildContext context,
    User account, {
    bool isCurrentAccount = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: account.avatarUrl.isNotEmpty
            ? CachedNetworkImageProvider(account.avatarUrl)
            : const AssetImage('assets/images/placeholder_avatar.png')
                  as ImageProvider,
      ),
      title: Row(
        children: [
          Text(
            account.username,
            style: TextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          if (account.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 16, color: AppColors.blue),
          ],
          if (isCurrentAccount) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Current',
                style: TextStyles.caption.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '@${account.username}',
        style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
      ),
      trailing: isCurrentAccount
          ? null
          : PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: AppColors.midGray),
              color: AppColors.surfaceColor,
              onSelected: (value) {
                if (value == 'switch') {
                  context.read<AuthService>().switchAccount(account);
                  Navigator.pop(context);
                } else if (value == 'remove') {
                  _showRemoveAccountDialog(context, account);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'switch',
                  child: Text(
                    'Switch to this account',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    'Remove from list',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
      onTap: isCurrentAccount
          ? null
          : () {
              context.read<AuthService>().switchAccount(account);
              Navigator.pop(context);
            },
    );
  }

  void _showRemoveAccountDialog(BuildContext context, User account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: Text(
          'Remove account?',
          style: TextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
        content: Text(
          'This will remove @${account.username} from your account list. You can add it back anytime.',
          style: TextStyles.bodyMedium.copyWith(color: AppColors.midGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyles.buttonMedium.copyWith(color: AppColors.midGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthService>().removeAccount(account);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
