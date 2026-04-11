import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback? onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = conversation.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? AppColors.primary.withOpacity(0.3) : AppColors.border,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: isUnread
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                  ],
                ),
                border: Border.all(
                  color: isUnread ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                image: conversation.otherUserAvatar != null
                    ? DecorationImage(
                  image: NetworkImage(conversation.otherUserAvatar!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: conversation.otherUserAvatar == null
                  ? Icon(
                Icons.person,
                color: AppColors.textPrimary,
                size: 28,
              )
                  : null,
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Last Message
                  Row(
                    children: [
                      if (conversation.lastMessageSenderId == currentUserId)
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                      if (conversation.lastMessageSenderId == currentUserId)
                        const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? 'No messages yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUnread
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Unread Badge
            if (isUnread)
              Container(
                width: 24,
                height: 24,
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
                child: Center(
                  child: Text(
                    conversation.unreadCount > 9 ? '9+' : '${conversation.unreadCount}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}