import 'package:flutter/material.dart';
import 'package:project_x/core/models/community_model.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onTap;

  const CommunityCard({
    super.key,
    required this.community,
    this.onJoin,
    this.onLeave,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderColor, width: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => _navigateToCommunity(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 12),
              _buildStats(),
              const SizedBox(height: 12),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Community avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.darkGray,
          backgroundImage: community.avatar.isNotEmpty
              ? CachedNetworkImageProvider(community.avatar)
              : null,
          child: community.avatar.isEmpty
              ? Text(
                  community.name.isNotEmpty ? community.name[0].toUpperCase() : 'C',
                  style: TextStyles.titleMedium.copyWith(color: AppColors.white),
                )
              : null,
        ),
        const SizedBox(width: 12),
        
        // Community info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      community.name,
                      style: TextStyles.titleSmall.copyWith(color: AppColors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (community.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.blue,
                    ),
                  ],
                  if (community.isPrivate) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.midGray,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    community.category,
                    style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
                  ),
                  const Text(' • ', style: TextStyle(color: AppColors.midGray)),
                  Text(
                    '${_formatMemberCount(community.memberCount)} members',
                    style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    if (community.description.isEmpty) return const SizedBox.shrink();
    
    return Text(
      community.description,
      style: TextStyles.bodyMedium.copyWith(color: AppColors.white),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats() {
    return Wrap(
      spacing: 16,
      children: [
        _buildStatItem(
          Icons.post_add_outlined,
          '${community.stats.totalPosts}',
          'posts',
        ),
        if (community.stats.weeklyGrowth > 0)
          _buildStatItem(
            Icons.trending_up,
            '+${community.stats.weeklyGrowth.toStringAsFixed(1)}%',
            'growth',
          ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.midGray),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyles.bodySmall.copyWith(color: AppColors.midGray),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (community.isMember) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onLeave,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Leave'),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(community.requireApproval ? 'Request to Join' : 'Join'),
        ),
      );
    }
  }

  String _formatMemberCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _navigateToCommunity(BuildContext context) {
    // TODO: Navigate to community detail screen
    print('Navigate to community: ${community.name}');
  }
}