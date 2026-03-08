import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/message.dart';

/// Message Bubble Widget
///
/// Displays a single message in the chat
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for other user
          if (!isMe && showAvatar) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ] else if (!isMe && !showAvatar)
            const SizedBox(width: 40),

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: isMe
                    ? AppColors.primaryGradient
                    : null,
                color: isMe ? null : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                border: isMe
                    ? null
                    : Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  if (isMe)
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Time and read status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.formattedTime,
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withOpacity(0.8)
                              : AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all
                              : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? AppColors.accent
                              : Colors.white.withOpacity(0.8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Avatar for current user (hidden but maintains spacing)
          if (isMe && showAvatar)
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue,
            AppColors.accent,
          ],
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          image: message.senderAvatar != null
              ? DecorationImage(
            image: NetworkImage(message.senderAvatar!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: message.senderAvatar == null
            ? Icon(
          Icons.person,
          color: AppColors.textSecondary,
          size: 18,
        )
            : null,
      ),
    );
  }
}