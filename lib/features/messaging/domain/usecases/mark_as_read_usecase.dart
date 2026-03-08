import 'package:campus_collab/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

class MarkAsReadUseCase{
  final MessagingRepository _repository;
  MarkAsReadUseCase(this._repository);

  Future<Either<Failure, void>> call(String conversationId) async {
    return await _repository.markAsRead(conversationId);
  }



  }

