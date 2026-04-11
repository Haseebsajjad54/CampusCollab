import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  // Get all notifications
  Future<Either<Failure, List<Notification>>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await repository.getNotifications(limit: limit, offset: offset);
    return result.fold(
          (failure) => Left(failure),
          (notifications) => Right(notifications),
    );
  }

  // Get unread notifications
  Future<Either<Failure, List<Notification>>> getUnreadNotifications() async {
    final result = await repository.getUnreadNotifications();
    return result.fold(
          (failure) => Left(failure),
          (notifications) => Right(notifications),
    );
  }

  // Get unread count
  Future<Either<Failure, int>> getUnreadCount() async {
    final result = await repository.getUnreadCount();
    return result.fold(
          (failure) => Left(failure),
          (count) => Right(count),
    );
  }
}