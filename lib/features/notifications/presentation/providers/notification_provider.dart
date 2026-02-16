import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

/// Notification State Status
enum NotificationStatus {
  initial,
  loading,
  success,
  error,
}

/// Notification State
class NotificationState {
  final NotificationStatus status;
  final List<Notification> notifications;
  final int unreadCount;
  final String? errorMessage;

  NotificationState({
    required this.status,
    required this.notifications,
    this.unreadCount = 0,
    this.errorMessage,
  });

  factory NotificationState.initial() {
    return NotificationState(
      status: NotificationStatus.initial,
      notifications: [],
      unreadCount: 0,
    );
  }

  NotificationState copyWith({
    NotificationStatus? status,
    List<Notification>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == NotificationStatus.loading;
  bool get hasError => status == NotificationStatus.error;
  bool get hasUnread => unreadCount > 0;
}

/// Notification Provider
///
/// Manages notifications with real-time updates
class NotificationProvider extends ChangeNotifier {
  late final GetNotificationsUseCase _getNotificationsUseCase;
  late final MarkNotificationReadUseCase _markReadUseCase;
  late final NotificationRepositoryImpl _repository;

  NotificationState _state = NotificationState.initial();
  NotificationState get state => _state;

  List<Notification> get notifications => _state.notifications;
  int get unreadCount => _state.unreadCount;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  String? get errorMessage => _state.errorMessage;

  StreamSubscription<Notification>? _realtimeSubscription;

  NotificationProvider() {
    _initializeUseCases();
    _setupRealtimeListener();
  }

  void _initializeUseCases() {
    final supabase = Supabase.instance.client;
    _repository = NotificationRepositoryImpl(supabaseClient: supabase);
    _getNotificationsUseCase = GetNotificationsUseCase(_repository);
    _markReadUseCase = MarkNotificationReadUseCase(_repository);
  }

  /// Setup real-time listener
  void _setupRealtimeListener() {
    try {
      final stream = _repository.listenToNotifications();

      _realtimeSubscription = stream.listen(
            (notification) {
          // Add new notification to list
          _state = _state.copyWith(
            notifications: [notification, ..._state.notifications],
            unreadCount: _state.unreadCount + 1,
          );
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Notification stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to setup realtime listener: $e');
    }
  }

  /// Load notifications
  Future<void> loadNotifications({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    _state = _state.copyWith(status: NotificationStatus.loading);
    notifyListeners();

    final result = await _getNotificationsUseCase.call();

    result.fold(
          (failure) {
        _state = NotificationState(
          status: NotificationStatus.error,
          notifications: [],
          errorMessage: failure.message,
        );
      },
          (notifications) async {
        // Also load unread count
        final countResult = await _getNotificationsUseCase.getUnreadCount();
        final count = countResult.getOrElse(() => 0);

        _state = NotificationState(
          status: NotificationStatus.success,
          notifications: notifications,
          unreadCount: count,
        );
      },
    );
    notifyListeners();
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    final result = await _markReadUseCase(notificationId);

    return result.fold(
          (failure) {
        _state = _state.copyWith(errorMessage: failure.message);
        notifyListeners();
        return false;
      },
          (_) {
        // Update local state
        final updatedNotifications = _state.notifications.map((n) {
          if (n.id == notificationId && !n.isRead) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        _state = _state.copyWith(
          notifications: updatedNotifications,
          unreadCount: _state.unreadCount > 0 ? _state.unreadCount - 1 : 0,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Mark all as read
  Future<bool> markAllAsRead() async {
    final result = await _markReadUseCase.markAllAsRead();

    return result.fold(
          (failure) {
        _state = _state.copyWith(errorMessage: failure.message);
        notifyListeners();
        return false;
      },
          (_) {
        // Update local state
        final updatedNotifications = _state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();

        _state = _state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    final result = await _markReadUseCase.deleteNotification(notificationId);

    return result.fold(
          (failure) {
        _state = _state.copyWith(errorMessage: failure.message);
        notifyListeners();
        return false;
      },
          (_) {
        // Remove from local state
        final wasUnread = _state.notifications
            .firstWhere((n) => n.id == notificationId)
            .isRead == false;

        final updatedNotifications = _state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        _state = _state.copyWith(
          notifications: updatedNotifications,
          unreadCount: wasUnread ? _state.unreadCount - 1 : _state.unreadCount,
        );
        notifyListeners();
        return true;
      },
    );
  }

  /// Clear all notifications
  Future<bool> clearAll() async {
    final result = await _markReadUseCase.clearAll();

    return result.fold(
          (failure) {
        _state = _state.copyWith(errorMessage: failure.message);
        notifyListeners();
        return false;
      },
          (_) {
        _state = NotificationState.initial();
        notifyListeners();
        return true;
      },
    );
  }

  /// Get unread notifications
  List<Notification> getUnreadNotifications() {
    return _state.notifications.where((n) => !n.isRead).toList();
  }

  /// Get notifications by type
  List<Notification> getNotificationsByType(NotificationType type) {
    return _state.notifications.where((n) => n.type == type).toList();
  }

  /// Get today's notifications
  List<Notification> getTodaysNotifications() {
    return _state.notifications.where((n) => n.isToday).toList();
  }

  /// Clear error
  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}