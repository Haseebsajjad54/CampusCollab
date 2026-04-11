import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/notification.dart' as domain;

/// Notification Tile Widget
///
/// Displays a single notification item
class NotificationTile extends StatelessWidget {
  final domain.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : AppColors.primary.withOpacity(0.2),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: [
            if (!notification.isRead)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon/Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _getGradientForType(notification.type),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getColorForType(notification.type)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        notification.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          notification.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Body
                        Text(
                          notification.body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Time
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.timeAgo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Unread indicator
                  if (!notification.isRead)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForType(domain.NotificationType type) {
    switch (type) {
      case domain.NotificationType.application:
        return AppColors.primary;
      case domain.NotificationType.applicationUpdate:
        return AppColors.success;
      case domain.NotificationType.message:
        return AppColors.accentBlue;
      case domain.NotificationType.postInterest:
        return AppColors.accent;
      case domain.NotificationType.teamInvite:
        return AppColors.warning;
      case domain.NotificationType.system:
        return AppColors.textSecondary;
      case domain.NotificationType.applicationRejected:
        // TODO: Handle this case.
        throw UnimplementedError();
      case domain.NotificationType.applicationReceived:
        // TODO: Handle this case.
        throw UnimplementedError();
      case domain.NotificationType.applicationAccepted:
        // TODO: Handle this case.
        throw UnimplementedError();
      case domain.NotificationType.newMatch:
        // TODO: Handle this case.
        throw UnimplementedError();
      case domain.NotificationType.newMessage:
        // TODO: Handle this case.
        throw UnimplementedError();
      case domain.NotificationType.deadlineReminder:
        // TODO: Handle this case.
        throw UnimplementedError();
      case domain.NotificationType.projectUpdate:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Gradient _getGradientForType(domain.NotificationType type) {
    final color = _getColorForType(type);
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}