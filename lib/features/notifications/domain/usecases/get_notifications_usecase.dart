import 'package:campus_collab/features/notifications/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';

class GetNotificationsUseCase{
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<Notification>>> call() async {
    try {
      return Right(await repository.getUnreadNotifications() as List<Notification>);
    } catch (e) {
      return Left(ServerFailure(e.toString()));

    }

  }

  // Unread Notifications Count
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      return Right((await repository.getUnreadCount()) as int);
    }catch(e){
      return Left(ServerFailure(e.toString()));
    }

  }

}