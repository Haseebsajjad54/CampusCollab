import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    final result = await repository.markAsRead(notificationId);
    return result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
    );
  }

  Future<Either<Failure, void>> markAllAsRead() async {
    final result = await repository.markAllAsRead();
    return result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
    );
  }

  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    final result = await repository.deleteNotification(notificationId);
    return result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
    );
  }

  Future<Either<Failure, void>> clearAll() async {
    final result = await repository.clearAllNotifications();
    return result.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
    );
  }
}