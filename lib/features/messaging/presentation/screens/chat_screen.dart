// chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/conversation.dart';
import '../providers/messaging_provider.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _isConnected = true; // Default to true, will check in initState

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    final provider = context.read<MessagingProvider>();
    final currentUserId = provider.currentUser.id;
    final otherUserId = widget.conversation.otherUserId;

    final isConnected = await provider.areUsersConnected(currentUserId, otherUserId);

    setState(() {
      _isConnected = isConnected;
    });

    if (_isConnected) {
      _loadMessages();
      _setupRealtimeListener();
      _markAsRead();
    }
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    final provider = context.read<MessagingProvider>();
    await provider.loadMessages(widget.conversation.id);
    _scrollToBottom();
  }

  void _setupRealtimeListener() {
    if (!mounted) return;
    final provider = context.read<MessagingProvider>();
    provider.listenToMessages(widget.conversation.id);
  }

  Future<void> _markAsRead() async {
    if (!mounted) return;
    final provider = context.read<MessagingProvider>();
    await provider.markAsRead(widget.conversation.id);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isConnected
          ? Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          Consumer<MessagingProvider>(
            builder: (context, provider, _) {
              return ChatInput(
                onSend: _handleSend,
                isLoading: _isSending,
              );
            },
          ),
        ],
      )
          : _buildNotConnectedView(),
    );
  }

  Widget _buildNotConnectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            size: 80,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Not Connected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can only message users you are connected with.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _sendConnectionRequest(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Send Connection Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendConnectionRequest() async {
    // Navigate to profile or send request
    // This would typically call your connection provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connection request feature coming soon'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                image: widget.conversation.otherUserAvatar != null
                    ? DecorationImage(
                  image: NetworkImage(widget.conversation.otherUserAvatar!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: widget.conversation.otherUserAvatar == null
                  ? Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 20,
              )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.otherUserName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.conversation.otherUserDepartment != null)
                  Text(
                    widget.conversation.otherUserDepartment!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.border,
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return Consumer<MessagingProvider>(
      builder: (context, provider, _) {
        final currentUserId = provider.currentUser.id ?? '';

        if (provider.isLoadingMessages) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.messagesStatus == MessagingStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load messages',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadMessages,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final messages = provider.getMessages(widget.conversation.id);

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: AppColors.textTertiary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send a message to start the conversation!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.isFromMe(currentUserId);

            final showAvatar = index == messages.length - 1 ||
                messages[index + 1].senderId != message.senderId;

            return MessageBubble(
              message: message,
              isMe: isMe,
              showAvatar: showAvatar,
            );
          },
        );
      },
    );
  }

  Future<void> _handleSend(String content) async {
    if (content.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    final provider = context.read<MessagingProvider>();
    final success = await provider.sendMessage(
      conversationId: widget.conversation.id,
      content: content,
    );

    setState(() {
      _isSending = false;
    });

    if (success) {
      _scrollToBottom();
    } else {
      if (mounted) {
        print('Error sending message: ${provider.messagesError}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.messagesError ?? 'Failed to send message',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}