import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/application_model.dart';
import 'application_status_badge.dart';

/// Reusable Application Card Widget
///
/// Displays application information in a beautiful card
class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onWithdraw;
  final bool showActions;
  final bool isSentApplication;

  const ApplicationCard({
    super.key,
    required this.application,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onWithdraw,
    this.showActions = false,
    this.isSentApplication = false,
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
          color: _getStatusBorderColor(application.status),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusBorderColor(application.status).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                // Header with avatar and status
                _buildHeader(theme),

                const SizedBox(height: 16),

                // Post title
                if (application.postTitle != null)
                  _buildPostTitle(theme),

                const SizedBox(height: 12),

                // Message
                _buildMessage(theme),

                // Response message (if any)
                if (application.responseMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildResponseMessage(theme),
                ],

                const SizedBox(height: 16),

                // Footer with date and actions
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
            image: _getAvatarImage() != null
                ? DecorationImage(
              image: NetworkImage(_getAvatarImage()!),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: _getAvatarImage() == null
              ? const Icon(
            Icons.person,
            color: AppColors.textSecondary,
            size: 24,
          )
              : null,
        ),

        const SizedBox(width: 12),

        // Name and info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getName(),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                _getSubtitle(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // Status badge
        ApplicationStatusBadge(status: application.status),
      ],
    );
  }

  Widget _buildPostTitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (application.postType != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              application.postType!,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          application.postTitle!,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPLICATION MESSAGE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            application.message,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusBorderColor(application.status).withOpacity(0.1),
            _getStatusBorderColor(application.status).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusBorderColor(application.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            color: _getStatusBorderColor(application.status),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              application.responseMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getStatusBorderColor(application.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(application.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),

        const Spacer(),

        // Action buttons
        if (showActions && application.status == ApplicationStatus.pending) ...[
          if (isSentApplication && onWithdraw != null)
            _buildActionButton(
              'Withdraw',
              Icons.close,
              AppColors.error,
              onWithdraw!,
            )
          else if (!isSentApplication) ...[
            _buildActionButton(
              'Reject',
              Icons.close,
              AppColors.error,
              onReject ?? () {},
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              'Accept',
              Icons.check,
              AppColors.success,
              onAccept ?? () {},
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildActionButton(
      String label,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getName() {
    if (isSentApplication) {
      // For sent applications, show post author name
      return application.postTitle ?? 'Unknown';
    } else {
      // For received applications, show applicant name
      return application.applicantName ?? 'Unknown';
    }
  }

  String _getSubtitle() {
    if (isSentApplication) {
      return application.postType ?? 'Project';
    } else {
      final dept = application.applicantDepartment ?? '';
      final year = application.applicantYear?.toString() ?? '';
      return '$dept ${year.isNotEmpty ? '• Year $year' : ''}';
    }
  }

  String? _getAvatarImage() {
    if (isSentApplication) {
      // For sent applications, we don't have author image readily available
      return null;
    } else {
      return application.applicantImage;
    }
  }

  Color _getStatusBorderColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.withdrawn:
        return AppColors.textTertiary;
      default:
        return AppColors.warning;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}