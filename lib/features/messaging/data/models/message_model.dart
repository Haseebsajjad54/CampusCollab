
import '../../domain/entities/message.dart';

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
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      content: json['content'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
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

  // Model -> Entity




}