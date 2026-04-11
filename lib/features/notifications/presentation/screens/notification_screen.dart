// lib/features/notifications/presentation/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/notification.dart' as domain;
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadAllNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(theme),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.hasError && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load notifications',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage ?? 'Unknown error',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.loadAllNotifications(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllNotifications(),
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationCard(
                  context,
                  notification,
                  provider,
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Notifications',
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.unreadCount > 0) {
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context,
      domain.Notification notification,
      NotificationProvider provider,
      ) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          provider.markAsRead(notification.id);
        }
        _handleNotificationTap(context, notification);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isRead
                  ? AppColors.surface.withOpacity(0.6)
                  : AppColors.surface,
              isRead
                  ? AppColors.surface.withOpacity(0.4)
                  : AppColors.surface.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead
                ? AppColors.border
                : _getNotificationColor(notification.type).withOpacity(0.3),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: isRead
              ? null
              : [
            BoxShadow(
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getNotificationColor(notification.type).withOpacity(0.2),
                    _getNotificationColor(notification.type).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getNotificationColor(notification.type).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isRead ? AppColors.textTertiary : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
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

            // Unread indicator
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, domain.Notification notification) {
    switch (notification.type) {
      case domain.NotificationType.application:
      case domain.NotificationType.applicationUpdate:
      // Navigate to applications
        break;
      case domain.NotificationType.message:
      // Navigate to chat
        break;
      case domain.NotificationType.teamInvite:
      // Navigate to team invites
        break;
      default:
        break;
    }
  }

  IconData _getNotificationIcon(domain.NotificationType type) {
    switch (type) {
      case domain.NotificationType.application:
      case domain.NotificationType.applicationUpdate:
        return Icons.description;
      case domain.NotificationType.message:
        return Icons.chat_bubble;
      case domain.NotificationType.teamInvite:
        return Icons.group_add;
      case domain.NotificationType.postInterest:
        return Icons.favorite;
      case domain.NotificationType.system:
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(domain.NotificationType type) {
    switch (type) {
      case domain.NotificationType.application:
      case domain.NotificationType.applicationUpdate:
        return AppColors.accentBlue;
      case domain.NotificationType.message:
        return AppColors.primary;
      case domain.NotificationType.teamInvite:
        return AppColors.success;
      case domain.NotificationType.postInterest:
        return AppColors.accent;
      case domain.NotificationType.system:
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}