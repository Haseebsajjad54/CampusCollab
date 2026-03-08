import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class MessagingRepository{


  Future<Either<Failure, List<Conversation>>> getConversations();

  Future<Either<Failure, Conversation>> getOrCreateConversation(String otherUserId,);

  Future<Either<Failure, List<Message>>> getMessages(String conversationId,);

  Future<Either<Failure, Message>> sendMessage({required String conversationId, required String content,});

  Future<Either<Failure, void>> markAsRead(String conversationId,);

  Future<Either<Failure, int>> getUnreadCount();

  Stream<Message> listenToMessages(String conversationId,);

  Stream<Conversation> listenToConversations();




















}