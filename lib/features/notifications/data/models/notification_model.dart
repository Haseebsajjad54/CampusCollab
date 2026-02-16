import '../../domain/entities/notification.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? actionId;
  final String? actionType;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
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

  /// Convert model to domain entity
  Notification toEntity() {
    return Notification(
      id: id,
      userId: userId,
      type: _mapType(type),
      title: title,
      body: body,
      actionId: actionId,
      actionType: actionType,
      metadata: metadata,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  /// Create model from entity
  factory NotificationModel.fromEntity(Notification notification) {
    return NotificationModel(
      id: notification.id,
      userId: notification.userId,
      type: notification.type.name,
      title: notification.title,
      body: notification.body,
      actionId: notification.actionId,
      actionType: notification.actionType,
      metadata: notification.metadata,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
    );
  }

  /// JSON serialization
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      actionId: json['action_id'] as String?,
      actionType: json['action_type'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'action_id': actionId,
      'action_type': actionType,
      'metadata': metadata,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper to map string to NotificationType enum
  static NotificationType _mapType(String type) {
    switch (type.toLowerCase()) {
      case 'application':
        return NotificationType.application;
      case 'applicationupdate':
      case 'application_update':
        return NotificationType.applicationUpdate;
      case 'message':
        return NotificationType.message;
      case 'postinterest':
      case 'post_interest':
        return NotificationType.postInterest;
      case 'teaminvite':
      case 'team_invite':
        return NotificationType.teamInvite;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}
