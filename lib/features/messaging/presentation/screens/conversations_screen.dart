// conversations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../providers/messaging_provider.dart';
import '../widgets/conversation_tile.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _loadConversations();
    _setupRealtimeListeners();
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;
    final provider = context.read<MessagingProvider>();
    await provider.loadConversations();
  }

  void _setupRealtimeListeners() {
    final provider = context.read<MessagingProvider>();
    provider.listenToConversations();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(theme),
                Expanded(
                  child: _buildConversationsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.8),
            radius: 1.2,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Consumer<MessagingProvider>(
                  builder: (context, provider, _) {
                    if (provider.totalUnreadCount > 0) {
                      return Text(
                        '${provider.totalUnreadCount} unread',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }
                    return Text(
                      'All caught up!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return Consumer<MessagingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingConversations) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.conversationsStatus == MessagingStatus.error) {
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
                  'Failed to load conversations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.conversationsError ?? 'Unknown error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadConversations,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.conversations.isEmpty) {
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
                  'No conversations yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start by connecting with others!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        final currentUserId = provider.currentUser.id ;

        return RefreshIndicator(
          onRefresh: _loadConversations,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: provider.conversations.length,
            itemBuilder: (context, index) {
              final conversation = provider.conversations[index];

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                // child: Container(
                //   margin: const EdgeInsets.only(bottom: 16),
                //   decoration: BoxDecoration(
                //     color: AppColors.surface,
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   width: 100,
                //   height: 100,
                //
                // ),
                child: ConversationTile(
                  conversation: conversation,
                  currentUserId: currentUserId,
                  onTap: () => _openChat(conversation),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openChat(conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(conversation: conversation),
      ),
    );
  }
}