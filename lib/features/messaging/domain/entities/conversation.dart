import 'package:equatable/equatable.dart';

/// Conversation Entity
///
/// Represents a chat conversation between users
class Conversation extends Equatable {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? otherUserDepartment;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.otherUserDepartment,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if has unread messages
  bool get hasUnread => unreadCount > 0;

  /// Check if last message is from me
  bool isLastMessageFromMe(String currentUserId) {
    return lastMessageSenderId == currentUserId;
  }

  /// Get time ago for last message
  String get lastMessageTimeAgo {
    if (lastMessageTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }

  /// Get formatted last message time
  String get formattedLastMessageTime {
    if (lastMessageTime == null) return '';

    final now = DateTime.now();
    final messageDate = lastMessageTime!;

    // Today - show time
    if (messageDate.day == now.day &&
        messageDate.month == now.month &&
        messageDate.year == now.year) {
      final hour = messageDate.hour.toString().padLeft(2, '0');
      final minute = messageDate.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    // Yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (messageDate.day == yesterday.day &&
        messageDate.month == yesterday.month &&
        messageDate.year == yesterday.year) {
      return 'Yesterday';
    }

    // This week - show day
    if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[messageDate.weekday - 1];
    }

    // Older - show date
    return '${messageDate.day}/${messageDate.month}/${messageDate.year}';
  }

  Duration get difference => DateTime.now().difference(lastMessageTime!);

  Conversation copyWith({
    String? id,
    String? otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
    String? otherUserDepartment,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      otherUserDepartment: otherUserDepartment ?? this.otherUserDepartment,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    otherUserId,
    otherUserName,
    otherUserAvatar,
    otherUserDepartment,
    lastMessage,
    lastMessageSenderId,
    lastMessageTime,
    unreadCount,
    createdAt,
    updatedAt,
  ];
}