import 'package:campus_collab/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message.dart';

class SendMessageUseCase{
  final MessagingRepository _repository;
  final String conversationId;
  final String content;

  SendMessageUseCase( this._repository,{required this.content,required this.conversationId});

  Future<Either<Failure, Message>> call({
    required String conversationId,
    required String content,}) async {
     return await _repository.sendMessage(conversationId: conversationId, content: content);

  }
}
