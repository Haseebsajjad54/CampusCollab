import 'package:campus_collab/features/posts/presentation/screens/create_post_screen.dart';
import 'package:campus_collab/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../../core/config/theme/app_colors.dart';
import '../../../notifications/domain/entities/notification.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/presentation/screens/requests_alert_screen.dart';
import '../providers/post_provider.dart';

class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({super.key});

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> with SingleTickerProviderStateMixin {

  late AnimationController _headerController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // Load posts and notifications when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

      if (postProvider.posts.isEmpty) {
        postProvider.getPosts();
      }

      notificationProvider.loadNotifications();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading && provider.posts.isEmpty;
        final hasError = provider.error != null;

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              _buildBackgroundGradient(),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                  ? _buildErrorWidget(theme, provider.error!)
                  : CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(theme),
                  SliverToBoxAdapter(
                    child: _buildFilterChips(theme, provider),
                  ),
                  if (provider.posts.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(theme),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final post = provider.posts[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: PostCard(post: post),
                              ),
                            );
                          },
                          childCount: provider.posts.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
              _buildFAB(),
              // ✅ Add notification menu here - at the top of the stack
              _buildNotificationMenu(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<PostProvider>(context, listen: false);
              provider.getPosts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.post_add_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to create a post!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showCreatePostSheet(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.7),
            radius: 1.0,
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background.withOpacity(opacity),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10 * opacity, sigmaY: 10 * opacity),
          child: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: opacity > 0.5
                ? Text(
              'Discover',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 24,
              ),
            )
                : null,
            background: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find your perfect project partner',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 26),
          onPressed: () {},
        ),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, size: 26),
                  onPressed: notificationProvider.toggleNotificationMenu,
                ),
                if (notificationProvider.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${notificationProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  Widget _buildNotificationMenu() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (!provider.showNotificationMenu) return const SizedBox();

        final recentNotifications = provider.getRecentNotifications(limit: 3);

        return Positioned(
          top: 100,
          right: 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: AppColors.surface,
            child: Container(
              width: 320,
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        Text(
                          'Recent Notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  // Notifications list
                  if (recentNotifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No new notifications',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: recentNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = recentNotifications[index];
                        return _buildMenuItem(
                          context,
                          notification,
                          provider,
                        );
                      },
                    ),

                  const Divider(color: AppColors.border, height: 1),

                  // View all button
                  InkWell(
                    onTap: () {
                      provider.toggleNotificationMenu();
                      _showAllNotifications(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Center(
                        child: Text(
                          'View All Notifications',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildMenuItem(
      BuildContext context,
      Notification notification,
      NotificationProvider provider,
      ) {
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          provider.markAsRead(notification.id);
        }
        provider.toggleNotificationMenu();
        _handleNotificationTap(context, notification);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: !notification.isRead
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAllNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RequestAlertScreen(),
    );
  }

  // Widget _buildNotificationItemSheet(
  //     BuildContext context,
  //     Notification notification,
  //     NotificationProvider provider,
  //     StateSetter setState,
  //     ) {
  //   return InkWell(
  //     onTap: () {
  //       if (!notification.isRead) {
  //         provider.markAsRead(notification.id);
  //        // setState(() {});
  //       }
  //       _handleNotificationTap(context, notification);
  //       Navigator.pop(context);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       decoration: BoxDecoration(
  //         color: !notification.isRead
  //             ? AppColors.primary.withOpacity(0.05)
  //             : Colors.transparent,
  //       ),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Icon
  //           Container(
  //             width: 44,
  //             height: 44,
  //             decoration: BoxDecoration(
  //               color: _getNotificationColor(notification.type).withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Icon(
  //               _getNotificationIcon(notification.type),
  //               color: _getNotificationColor(notification.type),
  //               size: 22,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //
  //           // Content
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   notification.title,
  //                   style: const TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600,
  //                     color: AppColors.textPrimary,
  //                   ),
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   notification.body,
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: AppColors.textSecondary,
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   notification.timeAgo,
  //                   style: TextStyle(
  //                     fontSize: 10,
  //                     color: AppColors.textTertiary,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           // Unread indicator
  //           if (!notification.isRead)
  //             Container(
  //               width: 8,
  //               height: 8,
  //               decoration: const BoxDecoration(
  //                 color: AppColors.primary,
  //                 shape: BoxShape.circle,
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _handleNotificationTap(BuildContext context, notification) {
    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.application:
      case NotificationType.applicationUpdate:
      // Navigate to applications screen
        break;
      case NotificationType.message:
      // Navigate to chat screen
        break;
      case NotificationType.teamInvite:
      // Navigate to team invite screen
        break;
      case NotificationType.postInterest:
      // Navigate to post
        break;
      default:
        break;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.application:
      case NotificationType.applicationUpdate:
        return Icons.description;
      case NotificationType.message:
        return Icons.chat_bubble;
      case NotificationType.teamInvite:
        return Icons.group_add;
      case NotificationType.postInterest:
        return Icons.favorite;
      case NotificationType.system:
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.application:
      case NotificationType.applicationUpdate:
        return AppColors.accentBlue;
      case NotificationType.message:
        return AppColors.primary;
      case NotificationType.teamInvite:
        return AppColors.success;
      case NotificationType.postInterest:
        return AppColors.accent;
      case NotificationType.system:
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildFilterChips(ThemeData theme, PostProvider provider) {
    final filters = ['All Posts', 'FYP Groups', 'Projects', 'My Department', 'Matched'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedIndex = index;
                });
                // Filter posts based on selection
                if (index == 0) {
                  provider.getPosts();
                } else if (index == 1) {
                  provider.filterPosts('fyp_group');
                } else if (index == 2) {
                  provider.filterPosts('project');
                }
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withOpacity(0.2),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAB() {
    return Positioned(
      bottom: 80,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.glowShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showCreatePostSheet(context);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Create Post',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}

// Post Card Widget
class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // 🔹 Scaling factors
    double scale(double value) => value * (width / 375);

    final postId = widget.post['id'] as String? ?? '';
    final title = widget.post['title'] as String? ?? '';
    final description = widget.post['description'] as String? ?? '';
    final postType = widget.post['post_type'] as String? ?? 'project';
    final teamSize = widget.post['team_size'] as int? ?? 3;
    final currentTeamSize = widget.post['current_team_size'] as int? ?? 1;
    final requiredTeamSize = widget.post['required_team_size'] as int? ?? 5;
    final matchScore = widget.post['match_score'] as int? ?? 0;
    final deadline = widget.post['deadline'] as String? ?? '';

    List<String> selectedSkills = [];
    final skillsData = widget.post['selected_skills'];
    if (skillsData != null && skillsData is List) {
      selectedSkills = skillsData.map((skill) => skill.toString()).toList();
    }

    final authorName = widget.post['author_name'] as String? ?? 'Unknown User';
    final authorImage = widget.post['author_image'] as String? ?? '';
    final authorDepartment = widget.post['department'] as String? ?? 'Computer Science';
    final authorYear = widget.post['year'] as int? ?? widget.post['year_of_study'] as int? ?? 2026;

    final timePosted = _formatTimePosted(widget.post['created_at'] as String?);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(scale(24)),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: scale(20),
            offset: Offset(0, scale(10)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: postId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(scale(24)),
          child: Padding(
            padding: EdgeInsets.all(scale(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: scale(44),
                      height: scale(44),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        image: authorImage.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(authorImage),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: authorImage.isEmpty
                          ? Icon(
                        Icons.person,
                        color: AppColors.textSecondary,
                        size: scale(24),
                      )
                          : null,
                    ),
                    SizedBox(width: scale(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: scale(14),
                            ),
                          ),
                          SizedBox(height: scale(2)),
                          Text(
                            '$authorDepartment • Year $authorYear • $timePosted',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: scale(11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? AppColors.accent : AppColors.textSecondary,
                        size: scale(22),
                      ),
                      onPressed: () {
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: scale(16)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scale(12),
                    vertical: scale(6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(scale(8)),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    postType == 'fyp_group' ? 'FYP Group' : 'Project',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: scale(11),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: scale(12)),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: scale(18),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: scale(10)),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: scale(13),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: scale(16)),
                if (selectedSkills.isNotEmpty) ...[
                  Wrap(
                    spacing: scale(8),
                    runSpacing: scale(8),
                    children: selectedSkills
                        .take(4)
                        .map((skill) => SkillChip(skill: skill))
                        .toList(),
                  ),
                  SizedBox(height: scale(20)),
                ],
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: scale(12),
                        vertical: scale(8),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withOpacity(0.2),
                            AppColors.accent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(scale(12)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: AppColors.accent,
                            size: scale(18),
                          ),
                          SizedBox(width: scale(6)),
                          Text(
                            '$matchScore% Match',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: scale(13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: scale(12)),
                    _buildInfoChip(scale, Icons.people_outline,
                        '$currentTeamSize/$requiredTeamSize'),
                    const Spacer(),
                    if (deadline.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColors.textTertiary,
                            size: scale(16),
                          ),
                          SizedBox(width: scale(4)),
                          Text(
                            _formatDeadline(deadline),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: scale(11),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      double Function(double) scale, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale(12),
        vertical: scale(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(scale(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: scale(16)),
          SizedBox(width: scale(6)),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: scale(13),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Your existing methods unchanged
  String _formatTimePosted(String? createdAt) {
    if (createdAt == null) return 'Just now';
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  String _formatDeadline(String deadline) {
    try {
      final deadlineDate = DateTime.parse(deadline);
      final now = DateTime.now();
      final daysLeft = deadlineDate.difference(now).inDays;
      if (daysLeft < 0) {
        return 'Expired';
      } else if (daysLeft == 0) {
        return 'Today';
      } else if (daysLeft == 1) {
        return '1 day left';
      } else {
        return '$daysLeft days left';
      }
    } catch (e) {
      return deadline;
    }
  }
}

class SkillChip extends StatelessWidget {
  final String skill;

  const SkillChip({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

