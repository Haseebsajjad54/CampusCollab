import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/match_suggestion.dart';
import 'match_score_indicator.dart';

/// Match Card Widget
///
/// Displays a single match suggestion with score and details
class MatchCard extends StatelessWidget {
  final MatchSuggestion match;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getScoreBorderColor(match.matchScore),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getScoreBorderColor(match.matchScore).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar and score
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUserInfo(theme),
                    ),
                    MatchScoreIndicator(
                      score: match.matchScore,
                      size: 70,
                      showLabel: false,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bio
                if (match.bio != null && match.bio!.isNotEmpty) ...[
                  Text(
                    match.bio!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],

                // Match reasons chips
                if (match.sharedSkills.isNotEmpty ||
                    match.sharedInterests.isNotEmpty) ...[
                  _buildMatchReasons(),
                  const SizedBox(height: 16),
                ],

                // Stats row
                _buildStatsRow(),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildViewProfileButton(),
                    ),
                    const SizedBox(width: 12),
                    _buildMessageButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          image: match.profilePictureUrl != null
              ? DecorationImage(
            image: NetworkImage(match.profilePictureUrl!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: match.profilePictureUrl == null
            ? const Icon(
          Icons.person,
          color: AppColors.textSecondary,
          size: 30,
        )
            : null,
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                match.fullName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (match.isAvailable) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (match.department != null) ...[
              Icon(
                Icons.school,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                match.department!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
            if (match.yearOfStudy != null) ...[
              const SizedBox(width: 12),
              Text(
                '• Year ${match.yearOfStudy}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
            if (match.cgpa != null) ...[
              const SizedBox(width: 12),
              Text(
                '• ${match.cgpa!.toStringAsFixed(2)} CGPA',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMatchReasons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (match.sharedSkills.isNotEmpty)
          _buildReasonChip(
            '${match.sharedSkills.length} Shared Skills',
            Icons.code,
            AppColors.primary,
          ),
        if (match.sharedInterests.isNotEmpty)
          _buildReasonChip(
            '${match.sharedInterests.length} Shared Interests',
            Icons.favorite,
            AppColors.error,
          ),
        if (match.matchReasons['department'] != null)
          _buildReasonChip(
            'Same Department',
            Icons.school,
            AppColors.accentBlue,
          ),
        if (match.matchReasons['year'] != null)
          _buildReasonChip(
            match.matchReasons['year'],
            Icons.people,
            AppColors.accent,
          ),
      ],
    );
  }

  Widget _buildReasonChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem(Icons.article_outlined, '${match.totalPosts} Posts'),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.workspace_premium,
          match.matchQuality,
        ),
        if (match.preferredTeamSize != null) ...[
          const SizedBox(width: 16),
          _buildStatItem(
            Icons.group,
            'Team of ${match.preferredTeamSize}',
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildViewProfileButton() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'View Profile',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onMessage,
        icon: const Icon(
          Icons.chat_bubble_outline,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Color _getScoreBorderColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.accentBlue;
    if (score >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}