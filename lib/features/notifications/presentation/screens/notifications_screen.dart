import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/config/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'application',
      'title': 'New Application',
      'message': 'Sarah Chen applied to your AI Health Monitoring project',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'time': '5 min ago',
      'isRead': false,
      'category': 'applications',
    },
    {
      'id': '2',
      'type': 'match',
      'title': 'Perfect Match!',
      'message': 'We found 3 new projects that match your skills',
      'icon': Icons.auto_awesome,
      'time': '1 hour ago',
      'isRead': false,
      'category': 'matches',
    },
    {
      'id': '3',
      'type': 'message',
      'title': 'New Message',
      'message': 'Marcus Chen: "When can we schedule a meeting?"',
      'avatar': 'https://i.pravatar.cc/150?img=15',
      'time': '2 hours ago',
      'isRead': false,
      'category': 'messages',
    },
    {
      'id': '4',
      'type': 'application_accepted',
      'title': 'Application Accepted! 🎉',
      'message': 'Your application to Smart Campus IoT Network was accepted',
      'icon': Icons.check_circle,
      'time': '3 hours ago',
      'isRead': true,
      'category': 'applications',
    },
    {
      'id': '5',
      'type': 'team_invite',
      'title': 'Team Invitation',
      'message': 'Emma Watson invited you to join E-Commerce Analytics team',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'time': '5 hours ago',
      'isRead': true,
      'category': 'invitations',
    },
    {
      'id': '6',
      'type': 'deadline',
      'title': 'Deadline Reminder',
      'message': 'Application deadline for Blockchain Platform is tomorrow',
      'icon': Icons.event,
      'time': '1 day ago',
      'isRead': true,
      'category': 'reminders',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _unreadNotifications =>
      _notifications.where((n) => !n['isRead']).toList();

  List<Map<String, dynamic>> get _allNotifications => _notifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gradient Background
          _buildGradientBackground(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(theme),

                // Tab Bar
                _buildTabBar(theme),

                // Notifications List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotificationsList(_unreadNotifications, theme),
                      _buildNotificationsList(_allNotifications, theme),
                    ],
                  ),
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
            center: const Alignment(0.8, -0.9),
            radius: 1.0,
            colors: [
              AppColors.accentBlue.withOpacity(0.1),
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final unreadCount = _unreadNotifications.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount > 0
                      ? '$unreadCount new notification${unreadCount > 1 ? 's' : ''}'
                      : 'You\'re all caught up!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Mark all as read button
          if (unreadCount > 0)
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _markAllAsRead,
                  borderRadius: BorderRadius.circular(14),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.done_all,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unread'),
                if (_unreadNotifications.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_unreadNotifications.length}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'All'),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
      List<Map<String, dynamic>> notifications,
      ThemeData theme,
      ) {
    if (notifications.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 50)),
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
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationCard(
              notification: notifications[index],
              onTap: () => _handleNotificationTap(notifications[index]),
              onDismiss: () => _dismissNotification(notifications[index]['id']),
              onMarkAsRead: () => _markAsRead(notifications[index]['id']),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Navigate based on notification type
    _markAsRead(notification['id']);
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }
}

// Notification Card Widget
class NotificationCard extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
    required this.onMarkAsRead,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isDismissing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = widget.notification['isRead'] as bool;
    final type = widget.notification['type'] as String;

    return Dismissible(
      key: Key(widget.notification['id']),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (_) => widget.onDismiss(),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isDismissing ? 0.0 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isRead
                    ? AppColors.surface.withOpacity(0.6)
                    : AppColors.surface,
                isRead
                    ? AppColors.surface.withOpacity(0.4)
                    : AppColors.surface.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isRead
                  ? AppColors.border
                  : _getTypeColor(type).withOpacity(0.3),
              width: isRead ? 1 : 1.5,
            ),
            boxShadow: isRead
                ? null
                : [
              BoxShadow(
                color: _getTypeColor(type).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar or Icon
                    _buildLeadingWidget(type),

                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.notification['title'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: isRead
                                        ? FontWeight.w600
                                        : FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.notification['message'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isRead
                                  ? AppColors.textTertiary
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.notification['time'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    const SizedBox(width: 12),

                    if (!isRead)
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => _showNotificationOptions(context),
                        iconSize: 20,
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

  Widget _buildLeadingWidget(String type) {
    final avatar = widget.notification['avatar'];
    final icon = widget.notification['icon'];

    if (avatar != null) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _getTypeColor(type),
            width: 2,
          ),
          image: DecorationImage(
            image: NetworkImage(avatar),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getTypeColor(type).withOpacity(0.2),
              _getTypeColor(type).withOpacity(0.1),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getTypeColor(type).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon ?? Icons.notifications,
          color: _getTypeColor(type),
          size: 24,
        ),
      );
    }
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.8),
            AppColors.error,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  void _showNotificationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionButton(
              icon: Icons.done,
              label: 'Mark as read',
              onTap: () {
                Navigator.pop(context);
                widget.onMarkAsRead();
              },
            ),
            const SizedBox(height: 12),
            _buildOptionButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                widget.onDismiss();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (color ?? AppColors.primary).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'application':
      case 'application_accepted':
        return AppColors.accentBlue;
      case 'match':
        return AppColors.accent;
      case 'message':
        return AppColors.primary;
      case 'team_invite':
        return AppColors.success;
      case 'deadline':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}