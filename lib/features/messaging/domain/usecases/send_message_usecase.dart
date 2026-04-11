import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../repositories/messaging_repository.dart';

class SendMessageUseCase {
  final MessagingRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, Message>> call({
    required String conversationId,
    required String content,
    String? attachmentUrl,
  }) async {
    try {
      // ✅ Validate inputs
      if (conversationId.isEmpty) {
        return const Left(
          ValidationFailure('Conversation ID cannot be empty'),
        );
      }

      if (content.trim().isEmpty && attachmentUrl == null) {
        return const Left(
          ValidationFailure('Message must have content or attachment'),
        );
      }

      // Call repository to send message
      return await repository.sendMessage(
        conversationId: conversationId,
        content: content.trim(),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to send message: $e'));
    }
  }
}
