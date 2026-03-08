import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/messaging_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

/// Messaging State Status
enum MessagingStatus {
  initial,
  loading,
  success,
  error,
}

/// Messaging Provider
///
/// Manages conversations and messages with real-time updates
class MessagingProvider extends ChangeNotifier {
  late final GetConversationsUseCase _getConversationsUseCase;
  late final SendMessageUseCase _sendMessageUseCase;
  late final MarkAsReadUseCase _markAsReadUseCase;
  late final MessagingRepositoryImpl _repository;

  // Conversations state
  MessagingStatus _conversationsStatus = MessagingStatus.initial;
  List<Conversation> _conversations = [];
  String? _conversationsError;
  int _totalUnreadCount = 0;

  // Messages state
  MessagingStatus _messagesStatus = MessagingStatus.initial;
  Map<String, List<Message>> _messagesCache = {};
  String? _messagesError;

  // Real-time subscriptions
  StreamSubscription<Message>? _messagesSubscription;
  StreamSubscription<Conversation>? _conversationsSubscription;

  // Getters
  MessagingStatus get conversationsStatus => _conversationsStatus;
  List<Conversation> get conversations => _conversations;
  String? get conversationsError => _conversationsError;
  int get totalUnreadCount => _totalUnreadCount;

  MessagingStatus get messagesStatus => _messagesStatus;
  String? get messagesError => _messagesError;

  bool get isLoadingConversations => _conversationsStatus == MessagingStatus.loading;
  bool get isLoadingMessages => _messagesStatus == MessagingStatus.loading;

  User get currentUser => _repository.supabaseClient.auth.currentUser!;


  MessagingProvider() {
    _initializeUseCases();
  }

  void _initializeUseCases() {
    final supabase = Supabase.instance.client;
    _repository = MessagingRepositoryImpl(supabaseClient: supabase);
    _getConversationsUseCase = GetConversationsUseCase(_repository);
    _sendMessageUseCase = SendMessageUseCase(_repository, content: '', conversationId: '');
    _markAsReadUseCase = MarkAsReadUseCase(_repository);
  }

  /// Load conversations
  Future<void> loadConversations() async {
    _conversationsStatus = MessagingStatus.loading;
    notifyListeners();

    final result = await _getConversationsUseCase();

    result.fold(
          (failure) {
        _conversationsStatus = MessagingStatus.error;
        _conversationsError = failure.message;
        _conversations = [];
      },
          (conversations) async {
        _conversations = conversations;
        _conversationsStatus = MessagingStatus.success;
        _conversationsError = null;

        // Also load unread count
        await _loadUnreadCount();
      },
    );
    notifyListeners();
  }

  /// Load messages for conversation
  Future<void> loadMessages(String conversationId) async {
    _messagesStatus = MessagingStatus.loading;
    notifyListeners();

    final result = await _getConversationsUseCase.getMessages(conversationId);

    result.fold(
          (failure) {
        _messagesStatus = MessagingStatus.error;
        _messagesError = failure.message;
      },
          (messages) {
        _messagesCache[conversationId] = messages;
        _messagesStatus = MessagingStatus.success;
        _messagesError = null;
      },
    );
    notifyListeners();
  }

  /// Get messages for conversation
  List<Message> getMessages(String conversationId) {
    return _messagesCache[conversationId] ?? [];
  }

  /// Send message
  Future<bool> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final result = await _sendMessageUseCase(
      conversationId: conversationId,
      content: content,
    );

    return result.fold(
          (failure) {
        _messagesError = failure.message;
        notifyListeners();
        return false;
      },
          (message) {
        // Add message to cache
        final messages = _messagesCache[conversationId] ?? [];
        _messagesCache[conversationId] = [...messages, message];
        notifyListeners();
        return true;
      },
    );
  }

  /// Mark conversation as read
  Future<void> markAsRead(String conversationId) async {
    final result = await _markAsReadUseCase(conversationId);

    result.fold(
          (failure) {
        debugPrint('Failed to mark as read: ${failure.message}');
      },
          (_) {
        // Update local state
        final index = _conversations.indexWhere((c) => c.id == conversationId);
        if (index != -1) {
          _conversations[index] = _conversations[index].copyWith(
            unreadCount: 0,
          );
          _loadUnreadCount();
          notifyListeners();
        }

        // Mark messages as read in cache
        final messages = _messagesCache[conversationId];
        if (messages != null) {
          _messagesCache[conversationId] = messages.map((m) {
            return m.copyWith(isRead: true);
          }).toList();
        }
      },
    );
  }

  /// Get or create conversation with user
  Future<Conversation?> getOrCreateConversation(String otherUserId) async {
    final result = await _getConversationsUseCase.getOrCreateConversation(
      otherUserId,
    );

    return result.fold(
          (failure) {
        _conversationsError = failure.message;
        notifyListeners();
        return null;
      },
          (conversation) {
        // Add to conversations if not exists
        final exists = _conversations.any((c) => c.id == conversation.id);
        if (!exists) {
          _conversations.insert(0, conversation);
          notifyListeners();
        }
        return conversation;
      },
    );
  }

  /// Start listening to messages for conversation
  void listenToMessages(String conversationId) {
    _messagesSubscription?.cancel();

    final stream = _repository.listenToMessages(conversationId);
    _messagesSubscription = stream.listen(
          (message) {
        // Add message to cache
        final messages = _messagesCache[conversationId] ?? [];
        _messagesCache[conversationId] = [...messages, message];
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Messages stream error: $error');
      },
    );
  }

  /// Start listening to conversations
  void listenToConversations() {
    _conversationsSubscription?.cancel();

    final stream = _repository.listenToConversations();
    _conversationsSubscription = stream.listen(
          (conversation) {
        // Update or add conversation
        final index = _conversations.indexWhere((c) => c.id == conversation.id);
        if (index != -1) {
          _conversations[index] = conversation;
          // Move to top
          final conv = _conversations.removeAt(index);
          _conversations.insert(0, conv);
        } else {
          _conversations.insert(0, conversation);
        }
        _loadUnreadCount();
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Conversations stream error: $error');
      },
    );
  }

  /// Stop listening to messages
  void stopListeningToMessages() {
    _messagesSubscription?.cancel();
  }

  /// Load unread count
  Future<void> _loadUnreadCount() async {
    final result = await _getConversationsUseCase.getUnreadCount();
    result.fold(
          (_) {},
          (count) {
        _totalUnreadCount = count;
      },
    );
  }

  /// Clear messages cache for conversation
  void clearMessagesCache(String conversationId) {
    _messagesCache.remove(conversationId);
    notifyListeners();
  }

  /// Clear all caches
  void clearAllCaches() {
    _messagesCache.clear();
    _conversations = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _conversationsSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}