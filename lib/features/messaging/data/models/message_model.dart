import '../../domain/entities/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.content,
    super.isRead,
    required super.createdAt,
  });

  /// Convert JSON → Model
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;

    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      senderName: sender?['full_name'] ?? 'Unknown User',
      senderAvatar: sender?['profile_picture_url'],
      content: json['content'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert Entity → Model
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      senderName: message.senderName,
      senderAvatar: message.senderAvatar,
      content: message.content,
      isRead: message.isRead,
      createdAt: message.createdAt,
    );
  }
}