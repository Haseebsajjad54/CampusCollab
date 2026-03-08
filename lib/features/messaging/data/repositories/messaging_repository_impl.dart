import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Messaging Repository Implementation
///
/// Complete Supabase integration with real-time messaging
///
class MessagingRepositoryImpl implements MessagingRepository {
  final SupabaseClient supabaseClient;
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _conversationsChannel;

  final _messagesController = StreamController<Message>.broadcast();
  final _conversationsController = StreamController<Conversation>.broadcast();

  MessagingRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure( 'User not authenticated'),
        );
      }

      final response = await supabaseClient
          .from('conversations')
          .select('''
            *,
            participant1:profiles!conversations_participant1_id_fkey(
              full_name,
              profile_picture_url,
              department
            ),
            participant2:profiles!conversations_participant2_id_fkey(
              full_name,
              profile_picture_url,
              department
            )
          ''')
          .or('participant1_id.eq.${currentUser.id},participant2_id.eq.${currentUser.id}')
          .order('updated_at', ascending: false);

      final conversations = (response as List)
          .map((json) => ConversationModel.fromJson(json,))
          .toList();

      return Right(conversations);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(
            'Failed to get conversations: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Conversation>> getOrCreateConversation(
      String otherUserId,
      ) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure( 'User not authenticated'),
        );
      }

      // Check if conversation already exists
      final existing = await supabaseClient
          .from('conversations')
          .select('''
            *,
            participant1:profiles!conversations_participant1_id_fkey(
              full_name,
              profile_picture_url,
              department
            ),
            participant2:profiles!conversations_participant2_id_fkey(
              full_name,
              profile_picture_url,
              department
            )
          ''')
          .or(
        'and(participant1_id.eq.${currentUser.id},participant2_id.eq.$otherUserId),'
            'and(participant1_id.eq.$otherUserId,participant2_id.eq.${currentUser.id})',
      )
          .maybeSingle();

      if (existing != null) {
        final conversation = ConversationModel.fromJson(
          existing,
        );
        return Right(conversation);
      }

      // Create new conversation
      final newConversation = await supabaseClient
          .from('conversations')
          .insert({
        'participant1_id': currentUser.id,
        'participant2_id': otherUserId,
      })
          .select('''
            *,
            participant1:profiles!conversations_participant1_id_fkey(
              full_name,
              profile_picture_url,
              department
            ),
            participant2:profiles!conversations_participant2_id_fkey(
              full_name,
              profile_picture_url,
              department
            )
          ''')
          .single();

      final conversation = ConversationModel.fromJson(
        newConversation,

      );

      return Right(conversation);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(
            'Failed to get/create conversation: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(
      String conversationId,
      ) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      final response = await supabaseClient
          .from('messages')
          .select('''
            *,
            sender:profiles!messages_sender_id_fkey(
              full_name,
              profile_picture_url
            )
          ''')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();

      return Right(messages);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(
            'Failed to get messages: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      // Insert message
      final messageResponse = await supabaseClient
          .from('messages')
          .insert({
        'conversation_id': conversationId,
        'sender_id': currentUser.id,
        'content': content,
      })
          .select('''
            *,
            sender:profiles!messages_sender_id_fkey(
              full_name,
              profile_picture_url
            )
          ''')
          .single();

      final message = MessageModel.fromJson(messageResponse);

      // Update conversation's last message
      await supabaseClient.from('conversations').update({
        'last_message': content,
        'last_message_sender_id': currentUser.id,
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);

      // Increment unread count for the other participant
      final conversation = await supabaseClient
          .from('conversations')
          .select('participant1_id, participant2_id')
          .eq('id', conversationId)
          .single();

      final isParticipant1 = conversation['participant1_id'] == currentUser.id;
      final unreadField = isParticipant1
          ? 'unread_count_participant2'
          : 'unread_count_participant1';

      await supabaseClient.rpc('increment_unread', params: {
        'conversation_id': conversationId,
        'field_name': unreadField,
      });

      return Right(message);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(
            'Failed to send   ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      // Mark messages as read
      await supabaseClient
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', currentUser.id)
          .eq('is_read', false);

      // Reset unread count
      final conversation = await supabaseClient
          .from('conversations')
          .select('participant1_id')
          .eq('id', conversationId)
          .single();

      final isParticipant1 = conversation['participant1_id'] == currentUser.id;
      final unreadField = isParticipant1
          ? 'unread_count_participant1'
          : 'unread_count_participant2';

      await supabaseClient
          .from('conversations')
          .update({unreadField: 0})
          .eq('id', conversationId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(
            'Failed to mark as read: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        return const Left(
          AuthenticationFailure(  'User not authenticated'),
        );
      }

      final conversations = await supabaseClient
          .from('conversations')
          .select('participant1_id, unread_count_participant1, unread_count_participant2')
          .or('participant1_id.eq.${currentUser.id},participant2_id.eq.${currentUser.id}');

      int totalUnread = 0;
      for (final conv in conversations as List) {
        final isParticipant1 = conv['participant1_id'] == currentUser.id;
        final unread = isParticipant1
            ? (conv['unread_count_participant1'] as int? ?? 0)
            : (conv['unread_count_participant2'] as int? ?? 0);
        totalUnread += unread;
      }

      return Right(totalUnread);
    } on PostgrestException catch (e) {
      return Left(
        ServerFailure(  'Database error: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure(
            'Failed to get unread count: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Message> listenToMessages(String conversationId) {
    final currentUser = supabaseClient.auth.currentUser;

    if (currentUser == null) {
      _messagesController.addError('User not authenticated');
      return _messagesController.stream;
    }

    // Remove existing subscription
    _messagesChannel?.unsubscribe();

    // Create new real-time channel
    _messagesChannel = supabaseClient
        .channel('messages:$conversationId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (payload) async {
        try {
          // Fetch complete message with sender info
          final messageData = await supabaseClient
              .from('messages')
              .select('''
                    *,
                    sender:profiles!messages_sender_id_fkey(
                      full_name,
                      profile_picture_url
                    )
                  ''')
              .eq('id', payload.newRecord['id'])
              .single();

          final message = MessageModel.fromJson(messageData);
          _messagesController.add(message);
        } catch (e) {
          _messagesController.addError(e);
        }
      },
    )
        .subscribe();

    return _messagesController.stream;
  }

  @override
  Stream<Conversation> listenToConversations() {
    final currentUser = supabaseClient.auth.currentUser;

    if (currentUser == null) {
      _conversationsController.addError('User not authenticated');
      return _conversationsController.stream;
    }

    // Remove existing subscription
    _conversationsChannel?.unsubscribe();

    // Create new real-time channel
    _conversationsChannel = supabaseClient
        .channel('conversations:${currentUser.id}')
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'conversations',
      callback: (payload) async {
        try {
          // Check if this conversation involves current user
          final participant1 = payload.newRecord['participant1_id'];
          final participant2 = payload.newRecord['participant2_id'];

          if (participant1 == currentUser.id || participant2 == currentUser.id) {
            // Fetch complete conversation with profile info
            final convData = await supabaseClient
                .from('conversations')
                .select('''
                      *,
                      participant1:profiles!conversations_participant1_id_fkey(
                        full_name,
                        profile_picture_url,
                        department
                      ),
                      participant2:profiles!conversations_participant2_id_fkey(
                        full_name,
                        profile_picture_url,
                        department
                      )
                    ''')
                .eq('id', payload.newRecord['id'])
                .single();

            final conversation = ConversationModel.fromJson(
              convData,

            );

            _conversationsController.add(conversation);
          }
        } catch (e) {
          _conversationsController.addError(e);
        }
      },
    )
        .subscribe();

    return _conversationsController.stream;
  }

  /// Dispose resources
  void dispose() {
    _messagesChannel?.unsubscribe();
    _conversationsChannel?.unsubscribe();
    _messagesController.close();
    _conversationsController.close();
  }
}