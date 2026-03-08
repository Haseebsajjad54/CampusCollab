import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.otherUserId,
    required super.otherUserName,
    super.otherUserAvatar,
    super.otherUserDepartment,
    super.lastMessage,
    super.lastMessageSenderId,
    super.lastMessageTime,
    super.unreadCount,
    required super.createdAt,
    required super.updatedAt,
  });

  /// JSON → Model
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      otherUserId: json['otherUserId'],
      otherUserName: json['otherUserName'],
      otherUserAvatar: json['otherUserAvatar'],
      otherUserDepartment: json['otherUserDepartment'],
      lastMessage: json['lastMessage'],
      lastMessageSenderId: json['lastMessageSenderId'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserAvatar': otherUserAvatar,
      'otherUserDepartment': otherUserDepartment,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Entity → Model
  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      otherUserId: conversation.otherUserId,
      otherUserName: conversation.otherUserName,
      otherUserAvatar: conversation.otherUserAvatar,
      otherUserDepartment: conversation.otherUserDepartment,
      lastMessage: conversation.lastMessage,
      lastMessageSenderId: conversation.lastMessageSenderId,
      lastMessageTime: conversation.lastMessageTime,
      unreadCount: conversation.unreadCount,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
    );
  }
}