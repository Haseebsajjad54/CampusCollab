import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification.dart' as domain;
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient supabaseClient;
  RealtimeChannel? _realtimeChannel;
  final _notificationController = StreamController<domain.Notification>.broadcast();

  NotificationRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, List<domain.Notification>>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      final response = await supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json).toEntity())
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Notification>>> getUnreadNotifications() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      final response = await supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', currentUser.id)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json).toEntity())
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get unread notifications: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      final response = await supabaseClient
          .from('notifications')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('is_read', false);

      return Right(response.length);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get unread count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', currentUser.id);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to mark as read: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      await supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', currentUser.id)
          .eq('is_read', false);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to mark all as read: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      await supabaseClient
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', currentUser.id);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to delete notification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      await supabaseClient
          .from('notifications')
          .delete()
          .eq('user_id', currentUser.id);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to clear notifications: ${e.toString()}'));
    }
  }

  @override
  Stream<domain.Notification> listenToNotifications() {
    final currentUser = supabaseClient.auth.currentUser;
    if (currentUser == null) {
      _notificationController.addError('User not authenticated');
      return _notificationController.stream;
    }

    _realtimeChannel?.unsubscribe();

    _realtimeChannel = supabaseClient
        .channel('notifications:${currentUser.id}')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: currentUser.id,
      ),
      callback: (payload) {
        try {
          final notification = NotificationModel.fromJson(
            payload.newRecord,
          ).toEntity();
          _notificationController.add(notification);
        } catch (e) {
          _notificationController.addError(e);
        }
      },
    )
        .subscribe();

    return _notificationController.stream;
  }

  void dispose() {
    _realtimeChannel?.unsubscribe();
    _notificationController.close();
  }
}