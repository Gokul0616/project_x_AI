import 'package:flutter/material.dart';
import 'package:project_x/core/models/user_model.dart';
import 'package:project_x/core/utils/responsive_utils.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onEditProfile;
  final VoidCallback? onFollow;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEditProfile,
    this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = true; // TODO: Implement proper current user check
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface,
      ),
      child: Column(
        children: [
          // Banner image
          _buildBannerImage(context),
          // Profile content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image and action button
                  _buildProfileImageAndAction(context, isCurrentUser),
                  const SizedBox(height: 12),
                  // User info
                  _buildUserInfo(context),
                  const SizedBox(height: 12),
                  // Bio
                  if (user.bio != null) _buildBio(context),
                  const SizedBox(height: 8),
                  // Location and website
                  _buildLocationAndWebsite(context),
                  const SizedBox(height: 12),
                  // Follow stats
                  _buildFollowStats(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerImage(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        image: user.bannerImageUrl != null
            ? DecorationImage(
                image: NetworkImage(user.bannerImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: user.bannerImageUrl == null
          ? Center(
              child: Icon(
                Icons.image,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
    );
  }

  Widget _buildProfileImageAndAction(BuildContext context, bool isCurrentUser) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Profile image
        Transform.translate(
          offset: const Offset(0, -30),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 4,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? Text(
                      user.displayName[0].toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const Spacer(),
        // Action button
        Transform.translate(
          offset: const Offset(0, -15),
          child: isCurrentUser
              ? OutlinedButton(
                  onPressed: onEditProfile,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.isMobile(context) ? 16 : 24,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Edit profile'),
                )
              : ElevatedButton(
                  onPressed: onFollow,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.isMobile(context) ? 16 : 24,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Follow'),
                ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              user.displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.verified,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '@${user.username}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBio(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      user.bio!,
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _buildLocationAndWebsite(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (user.location != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                user.location!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        if (user.website != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.link,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                user.website!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Joined ${_formatJoinDate(user.joinedDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFollowStats(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _buildStatItem(context, '${user.following}', 'Following'),
        const SizedBox(width: 16),
        _buildStatItem(context, '${user.followers}', 'Followers'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String count, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatJoinDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}