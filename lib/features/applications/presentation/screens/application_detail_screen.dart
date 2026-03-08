import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/application_model.dart';
import '../providers/application_provider.dart';
import '../widgets/application_status_badge.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';

/// Application Detail Screen
///
/// Shows complete details of a single application
class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
  });

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Application? _application;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadApplication();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadApplication() async {
    setState(() => _isLoading = true);

    // In a real implementation, you would call:
    // final provider = context.read<ApplicationProvider>();
    // final result = await provider.getApplicationById(widget.applicationId);

    // For now, we'll check the provider's loaded applications
    final provider = context.read<ApplicationProvider>();

    // Try to find in sent applications
    var app = provider.state.sentApplications
        .where((a) => a.id == widget.applicationId)
        .firstOrNull;

    // If not found, try received applications
    app ??= provider.state.receivedApplications
        .where((a) => a.id == widget.applicationId)
        .firstOrNull;

    setState(() {
      _application = app;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gradient Background
          _buildGradientBackground(),

          // Content
          if (_isLoading)
            const LoadingIndicator(message: 'Loading application...')
          else if (_application == null)
            _buildErrorState()
          else
            _buildContent(theme),

          // App Bar
          _buildAppBar(),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.5,
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

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Spacer(),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(Icons.share, size: 20),
                color: AppColors.textPrimary,
                onPressed: _shareApplication,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: EmptyState(
        icon: Icons.error_outline,
        title: 'Application Not Found',
        subtitle: 'The application you\'re looking for doesn\'t exist.',
        actionText: 'Go Back',
        onAction: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Spacing for app bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    ApplicationStatusBadge(
                      status: _application!.status,
                      isLarge: true,
                    ),

                    const SizedBox(height: 24),

                    // Post Title
                    if (_application!.postTitle != null) ...[
                      Text(
                        _application!.postTitle!,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontSize: 32,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Post Type
                    if (_application!.postType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _application!.postType!,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Applicant/Author Info Card
                    _buildInfoCard(theme),

                    const SizedBox(height: 32),

                    // Application Message
                    _buildSection(
                      theme: theme,
                      title: 'Application Message',
                      child: Text(
                        _application!.message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Response Message (if any)
                    if (_application!.responseMessage != null) ...[
                      const SizedBox(height: 32),
                      _buildSection(
                        theme: theme,
                        title: 'Response',
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(_application!.status)
                                    .withOpacity(0.1),
                                _getStatusColor(_application!.status)
                                    .withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getStatusColor(_application!.status)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply,
                                color: _getStatusColor(_application!.status),
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _application!.responseMessage!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: _getStatusColor(
                                      _application!.status,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Timeline
                    _buildTimeline(theme),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    final isSentApp = _isSentApplication();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSentApp ? 'Post Author' : 'Applicant',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    image: _getPersonImage() != null
                        ? DecorationImage(
                      image: NetworkImage(_getPersonImage()!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _getPersonImage() == null
                      ? const Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 32,
                  )
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPersonName(),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    if (_application!.applicantDepartment != null)
                      Text(
                        '${_application!.applicantDepartment}'
                            '${_application!.applicantYear != null ? ' • Year ${_application!.applicantYear}' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              // Message Button
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _startConversation,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildTimeline(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          icon: Icons.send,
          title: 'Application Submitted',
          time: _formatDateTime(_application!.createdAt),
          isFirst: true,
          color: AppColors.primary,
        ),
        if (_application!.status != ApplicationStatus.pending)
          _buildTimelineItem(
            icon: _getStatusIcon(_application!.status),
            title: _getStatusTitle(_application!.status),
            time: _formatDateTime(_application!.updatedAt),
            isLast: true,
            color: _getStatusColor(_application!.status),
          ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String time,
    bool isFirst = false,
    bool isLast = false,
    required Color color,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and icon
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: isLast ? 0 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isSentApplication() {
    final provider = context.read<ApplicationProvider>();
    return provider.state.sentApplications
        .any((a) => a.id == widget.applicationId);
  }

  String _getPersonName() {
    if (_isSentApplication()) {
      return _application!.postTitle ?? 'Unknown';
    } else {
      return _application!.applicantName ?? 'Unknown';
    }
  }

  String? _getPersonImage() {
    if (_isSentApplication()) {
      return null; // We don't have author image for sent applications
    } else {
      return _application!.applicantImage;
    }
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.withdrawn:
        return AppColors.textTertiary;
      default:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
      case ApplicationStatus.withdrawn:
        return Icons.remove_circle;
      default:
        return Icons.schedule;
    }
  }

  String _getStatusTitle(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return 'Application Accepted';
      case ApplicationStatus.rejected:
        return 'Application Rejected';
      case ApplicationStatus.withdrawn:
        return 'Application Withdrawn';
      default:
        return 'Pending Review';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _startConversation() {
    // Navigate to chat
    Navigator.pushNamed(context, '/chat');
  }

  void _shareApplication() {
    // Share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}