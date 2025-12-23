import 'package:flutter/material.dart';
import '../models/user_models.dart';

class UserProfileWidget extends StatelessWidget {
  final User user;
  final bool showStats;
  final bool showVerificationBadges;
  final VoidCallback? onTap;

  const UserProfileWidget({
    super.key,
    required this.user,
    this.showStats = false,
    this.showVerificationBadges = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameRow(context),
                  const SizedBox(height: 4),
                  _buildUsernameRow(context),
                  if (showStats && user.stats != null) ...[
                    const SizedBox(height: 8),
                    _buildStatsRow(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
      child: user.avatar == null
          ? Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildNameRow(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            user.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showVerificationBadges) ...[
          const SizedBox(width: 8),
          ..._buildVerificationBadges(),
        ],
      ],
    );
  }

  Widget _buildUsernameRow(BuildContext context) {
    return Text(
      '@${user.username}',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final stats = user.stats!;
    return Row(
      children: [
        _buildStatItem(context, 'Posts', stats.posts),
        const SizedBox(width: 16),
        _buildStatItem(context, 'Likes', stats.likes),
        const SizedBox(width: 16),
        _buildStatItem(context, 'Comments', stats.comments),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildVerificationBadges() {
    final badges = <Widget>[];

    if (user.kycVerified) {
      badges.add(_buildVerificationBadge(
        icon: Icons.verified_user,
        color: Colors.blue,
        tooltip: 'KYC Verified',
      ));
    }

    if (user.kybVerified) {
      badges.add(_buildVerificationBadge(
        icon: Icons.business,
        color: Colors.green,
        tooltip: 'KYB Verified',
      ));
    }

    if (user.amlVerified) {
      badges.add(_buildVerificationBadge(
        icon: Icons.security,
        color: Colors.orange,
        tooltip: 'AML Verified',
      ));
    }

    return badges;
  }

  Widget _buildVerificationBadge({
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }
}

class UserAvatarWidget extends StatelessWidget {
  final User user;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    required this.user,
    this.radius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
        child: user.avatar == null
            ? Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: radius * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
