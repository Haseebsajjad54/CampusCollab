// lib/features/notifications/presentation/providers/notification_provider.dart
import 'dart:async';
import 'package:flutter/material.dart' hide Notification;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

enum NotificationStatus {
  initial,
  loading,
  success,
  error,
}

class NotificationState {
  final NotificationStatus status;
  final List<Notification> notifications;
  final int unreadCount;
  final String? errorMessage;
  final bool showNotificationMenu;

  NotificationState({
    required this.status,
    required this.notifications,
    this.unreadCount = 0,
    this.errorMessage,
    this.showNotificationMenu = false,
  });

  factory NotificationState.initial() {
    return NotificationState(
      status: NotificationStatus.initial,
      notifications: [],
      unreadCount: 0,
      showNotificationMenu: false,
    );
  }

  NotificationState copyWith({
    NotificationStatus? status,
    List<Notification>? notifications,
    int? unreadCount,
    String? errorMessage,
    bool? showNotificationMenu,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
      showNotificationMenu: showNotificationMenu ?? this.showNotificationMenu,
    );
  }

  bool get isLoading => status == NotificationStatus.loading;
  bool get hasError => status == NotificationStatus.error;
  bool get hasUnread => unreadCount > 0;
}

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
  bool get showNotificationMenu => _state.showNotificationMenu;

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

  void _setupRealtimeListener() {
    try {
      final stream = _repository.listenToNotifications();
      _realtimeSubscription = stream.listen(
            (notification) {
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

  Future<void> loadNotifications() async {
    if (_state.isLoading) return;

    _state = _state.copyWith(status: NotificationStatus.loading);
    notifyListeners();

    final result = await _getNotificationsUseCase.getUnreadNotifications();

    await result.fold(
          (failure) async {
        _state = _state.copyWith(
          status: NotificationStatus.error,
          errorMessage: failure.message,
        );
      },
          (notifications) async {
        final countResult = await _getNotificationsUseCase.getUnreadCount();
        int count = 0;
        countResult.fold(
              (failure) {},
              (c) => count = c,
        );

        _state = NotificationState(
          status: NotificationStatus.success,
          notifications: notifications,
          unreadCount: count,
        );
      },
    );
    notifyListeners();
  }

  Future<void> loadAllNotifications() async {
    if (_state.isLoading) return;

    _state = _state.copyWith(status: NotificationStatus.loading);
    notifyListeners();

    final result = await _getNotificationsUseCase.getNotifications();

    result.fold(
          (failure) {
        _state = _state.copyWith(
          status: NotificationStatus.error,
          errorMessage: failure.message,
        );
      },
          (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        _state = NotificationState(
          status: NotificationStatus.success,
          notifications: notifications,
          unreadCount: unreadCount,
        );
      },
    );
    notifyListeners();
  }

  Future<bool> markAsRead(String notificationId) async {
    final result = await _markReadUseCase(notificationId);

    return result.fold(
          (failure) {
        _state = _state.copyWith(errorMessage: failure.message);
        notifyListeners();
        return false;
      },
          (_) {
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

  Future<bool> markAllAsRead() async {
    final result = await _markReadUseCase.markAllAsRead();

    return result.fold(
          (failure) {
        _state = _state.copyWith(errorMessage: failure.message);
        notifyListeners();
        return false;
      },
          (_) {
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

  List<Notification> getUnreadNotifications() {
    return _state.notifications.where((n) => !n.isRead).toList();
  }

  List<Notification> getRecentNotifications({int limit = 3}) {
    return _state.notifications.take(limit).toList();
  }

  void toggleNotificationMenu() {
    _state = _state.copyWith(
      showNotificationMenu: !_state.showNotificationMenu,
    );
    notifyListeners();
  }

  void closeNotificationMenu() {
    if (_state.showNotificationMenu) {
      _state = _state.copyWith(showNotificationMenu: false);
      notifyListeners();
    }
  }

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