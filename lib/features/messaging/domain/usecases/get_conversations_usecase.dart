import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../repositories/messaging_repository.dart';

class GetConversationsUseCase{

  final MessagingRepository _repository;

  GetConversationsUseCase(this._repository);

  Future<Either<Failure, List<Conversation>>> call() async {
    return await _repository.getConversations();
  }

  Future<Either<Failure, List<Message>>> getMessages(String conversationId) async {
    return await _repository.getMessages(conversationId);

  }

  Future<Either<Failure, Conversation>> getOrCreateConversation(String otherUserId) async {
    return await _repository.getOrCreateConversation(otherUserId);
  }

  Future<Either<Failure, int>> getUnreadCount() async {
    return await _repository.getUnreadCount();
  }





}