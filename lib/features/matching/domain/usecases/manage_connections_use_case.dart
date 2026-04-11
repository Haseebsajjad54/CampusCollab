import 'package:campus_collab/features/matching/domain/repositories/matching_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

class ManageConnectionUseCase{
  final MatchingRepository _matchingRepository;

  ManageConnectionUseCase(this._matchingRepository);

  /// Send connection request to specific user
  ///
  /// [userId] - ID of user to send connection request
  Future<Either<Failure, bool>> sendConnectionRequest(String senderId, String receiverId){
    return _matchingRepository.sendConnectionRequest(senderId, receiverId);
  }

  ///Accept Connection Request

  Future<Either<Failure, bool>> acceptConnectionRequest(String userId, String requesterId) {
    return _matchingRepository.acceptConnectionRequest(userId, requesterId);
  }


}


