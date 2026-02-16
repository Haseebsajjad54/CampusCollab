import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification.dart' as domain;

abstract class NotificationRepository{

  Future<Either<Failure, List<domain.Notification>>> getUnreadNotifications();

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(String notificationId);

  Future<Either<Failure, void>> clearAllNotifications();

  Stream<domain.Notification> listenToNotifications();

}