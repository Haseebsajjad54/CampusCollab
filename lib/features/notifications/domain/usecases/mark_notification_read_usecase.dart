import 'package:campus_collab/features/notifications/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

class MarkNotificationReadUseCase{
  final NotificationRepository repository;
  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    try {
       Right(await repository.markAsRead(notificationId));
       return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      Right(await repository.markAllAsRead());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }

  }
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      Right(await repository.deleteNotification(notificationId));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }

  }
  Future<Either<Failure, void>> clearAll() async {
    try {
      Right(await repository.clearAllNotifications());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

}
