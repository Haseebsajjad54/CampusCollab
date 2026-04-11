import '../../domain/entities/conversation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

    // Determine the other participant
    final isParticipant1 = json['participant1_id'] == currentUserId;
    final otherUser = isParticipant1
        ? json['participant2']
        : json['participant1'];

    final unreadCount = isParticipant1
        ? (json['unread_count_participant1'] as int? ?? 0)
        : (json['unread_count_participant2'] as int? ?? 0);

    return ConversationModel(
      id: json['id'],
      otherUserId: isParticipant1
          ? json['participant2_id']
          : json['participant1_id'],
      otherUserName: otherUser?['full_name'] ?? 'Unknown User',
      otherUserAvatar: otherUser?['profile_picture_url'],
      otherUserDepartment: otherUser?['department'],
      lastMessage: json['last_message'],
      lastMessageSenderId: json['last_message_sender_id'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: unreadCount,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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