import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock sent applications
  final List<Map<String, dynamic>> _sentApplications = [
    {
      'id': '1',
      'postTitle': 'AI-Powered Health Monitoring System',
      'postAuthor': 'Sarah Chen',
      'authorImage': 'https://i.pravatar.cc/150?img=1',
      'status': 'pending',
      'appliedDate': '2024-02-10',
      'message': 'I have strong experience in computer vision...',
      'postType': 'FYP Group',
    },
    {
      'id': '2',
      'postTitle': 'Blockchain Supply Chain Platform',
      'postAuthor': 'Ahmed Khan',
      'authorImage': 'https://i.pravatar.cc/150?img=33',
      'status': 'accepted',
      'appliedDate': '2024-02-08',
      'message': 'My blockchain expertise would be valuable...',
      'postType': 'Project Partner',
      'responseMessage': 'Welcome to the team! Let\'s schedule a meeting.',
    },
    {
      'id': '3',
      'postTitle': 'Smart Campus AR Navigation',
      'postAuthor': 'Lisa Park',
      'authorImage': 'https://i.pravatar.cc/150?img=45',
      'status': 'rejected',
      'appliedDate': '2024-02-05',
      'message': 'I can contribute to the Unity development...',
      'postType': 'FYP Group',
      'responseMessage': 'Thanks for applying. We found someone with more AR experience.',
    },
  ];

  // Mock received applications
  final List<Map<String, dynamic>> _receivedApplications = [
    {
      'id': '1',
      'postTitle': 'My E-Commerce Analytics Dashboard',
      'applicantName': 'Michael Zhang',
      'applicantImage': 'https://i.pravatar.cc/150?img=60',
      'applicantDepartment': 'Software Engineering',
      'applicantYear': 3,
      'status': 'pending',
      'appliedDate': '2024-02-12',
      'message': 'I have 2 years of React experience and have built similar dashboards...',
      'skills': ['React', 'Node.js', 'Data Visualization'],
      'matchScore': 88,
    },
    {
      'id': '2',
      'postTitle': 'My E-Commerce Analytics Dashboard',
      'applicantName': 'Emily Rodriguez',
      'applicantImage': 'https://i.pravatar.cc/150?img=47',
      'applicantDepartment': 'Computer Science',
      'applicantYear': 4,
      'status': 'accepted',
      'appliedDate': '2024-02-11',
      'message': 'Passionate about data analytics and have experience with real-time systems...',
      'skills': ['Python', 'React', 'PostgreSQL'],
      'matchScore': 92,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(theme),

            // Tab Bar
            _buildTabBar(theme),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSentApplicationsList(theme),
                  _buildReceivedApplicationsList(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Applications',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'Manage your applications',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
                const Text('Sent'),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_sentApplications.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Received'),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_receivedApplications.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentApplicationsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      itemCount: _sentApplications.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SentApplicationCard(
            application: _sentApplications[index],
            onWithdraw: () => _handleWithdraw(_sentApplications[index]),
          ),
        );
      },
    );
  }

  Widget _buildReceivedApplicationsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      itemCount: _receivedApplications.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ReceivedApplicationCard(
            application: _receivedApplications[index],
            onAccept: () => _handleAccept(_receivedApplications[index]),
            onReject: () => _handleReject(_receivedApplications[index]),
          ),
        );
      },
    );
  }

  void _handleWithdraw(Map<String, dynamic> application) {
    setState(() {
      _sentApplications.remove(application);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Application withdrawn'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleAccept(Map<String, dynamic> application) {
    setState(() {
      application['status'] = 'accepted';
    });
  }

  void _handleReject(Map<String, dynamic> application) {
    setState(() {
      application['status'] = 'rejected';
    });
  }
}

// Sent Application Card
class SentApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onWithdraw;

  const SentApplicationCard({
    super.key,
    required this.application,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = application['status'] as String;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(status).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(application['authorImage']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['postAuthor'],
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        application['appliedDate'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),

            const SizedBox(height: 16),

            // Post Title
            Text(
              application['postTitle'],
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            // Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                application['postType'],
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                application['message'],
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Response (if any)
            if (application['responseMessage'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(status).withOpacity(0.1),
                      _getStatusColor(status).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(status).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.reply,
                      color: _getStatusColor(status),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        application['responseMessage'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onWithdraw,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Withdraw Application',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    IconData icon;
    String label;

    switch (status) {
      case 'accepted':
        icon = Icons.check_circle;
        label = 'Accepted';
        break;
      case 'rejected':
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      default:
        icon = Icons.schedule;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _getStatusColor(status)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }
}

// Received Application Card
class ReceivedApplicationCard extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ReceivedApplicationCard({
    super.key,
    required this.application,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = application['status'] as String;
    final isPending = status == 'pending';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(application['applicantImage']),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: AppColors.background,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['applicantName'],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${application['applicantDepartment']} • Year ${application['applicantYear']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Match Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    AppColors.accent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: AppColors.accent, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${application['matchScore']}% Match',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Skills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (application['skills'] as List<String>)
                  .map((skill) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APPLICATION MESSAGE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    application['message'],
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Actions
            if (isPending) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: status == 'accepted'
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: status == 'accepted'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      status == 'accepted'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: status == 'accepted'
                          ? AppColors.success
                          : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status == 'accepted'
                          ? 'Application Accepted'
                          : 'Application Rejected',
                      style: TextStyle(
                        color: status == 'accepted'
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}