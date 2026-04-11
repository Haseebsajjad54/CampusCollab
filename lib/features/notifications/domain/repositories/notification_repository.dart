import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification.dart' as domain;

abstract class NotificationRepository {
  // Get all notifications
  Future<Either<Failure, List<domain.Notification>>> getNotifications({
    int limit = 50,
    int offset = 0,
  });

  // Get unread notifications
  Future<Either<Failure, List<domain.Notification>>> getUnreadNotifications();

  // Get unread count
  Future<Either<Failure, int>> getUnreadCount();

  // Mark as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  // Mark all as read
  Future<Either<Failure, void>> markAllAsRead();

  // Delete notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  // Clear all notifications
  Future<Either<Failure, void>> clearAllNotifications();

  // Listen to real-time notifications
  Stream<domain.Notification> listenToNotifications();
}