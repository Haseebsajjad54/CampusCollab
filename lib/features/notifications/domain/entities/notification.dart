import 'package:equatable/equatable.dart';

/// Notification Type Enum
enum NotificationType {
  application,      // New application received
  applicationUpdate, // Application status changed
  message,          // New message
  postInterest,     // Someone interested in post
  teamInvite,       // Team invitation
  system,
  applicationRejected,
  applicationReceived,
  applicationAccepted,
  newMatch,
  newMessage,
  deadlineReminder,
  projectUpdate,// System notification
}

/// Notification Entity
///
/// Represents a user notification
class Notification extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? actionId; // Post ID, Application ID, etc.
  final String? actionType; // 'post', 'application', 'profile'
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.actionId,
    this.actionType,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
  });

  /// Get icon based on type
  String get icon {
    switch (type) {
      case NotificationType.application:
        return '📝';
      case NotificationType.applicationUpdate:
        return '✅';
      case NotificationType.message:
        return '💬';
      case NotificationType.postInterest:
        return '👀';
      case NotificationType.teamInvite:
        return '🤝';
      case NotificationType.system:
        return '🔔';
      case NotificationType.applicationRejected:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.applicationReceived:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.applicationAccepted:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.newMatch:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.newMessage:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.deadlineReminder:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NotificationType.projectUpdate:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Check if notification is today
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// Check if notification is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 7;
  }

  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? actionId,
    String? actionType,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      actionId: actionId ?? this.actionId,
      actionType: actionType ?? this.actionType,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    body,
    actionId,
    actionType,
    metadata,
    isRead,
    createdAt,
  ];

}