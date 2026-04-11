import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../providers/notification_provider.dart';
import '../providers/connection_provider.dart'; // You'll need to create this
import '../widgets/application_card.dart';
import '../widgets/connection_card.dart';

class RequestAlertScreen extends StatefulWidget {
  const RequestAlertScreen({super.key});

  @override
  State<RequestAlertScreen> createState() => _RequestAlertScreenState();
}

class _RequestAlertScreenState extends State<RequestAlertScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final notificationProvider = context.read<NotificationProvider>();
    final connectionProvider = context.read<ConnectionProvider>();

    await Future.wait([
      notificationProvider.loadNotifications(),
      connectionProvider.loadPendingConnectionRequests(),
      connectionProvider.loadPendingApplicationRequests(),
    ]);
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
                _buildTabBar(theme),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildApplicationRequestsTab(),
                      _buildConnectionRequestsTab(),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requests',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer2<ConnectionProvider, NotificationProvider>(
                  builder: (context, connectionProvider, notificationProvider, _) {
                    final totalRequests = connectionProvider.pendingConnectionRequests.length +
                        connectionProvider.pendingApplicationRequests.length;
                    return Text(
                      totalRequests > 0
                          ? '$totalRequests pending request${totalRequests > 1 ? 's' : ''}'
                          : 'No pending requests',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: totalRequests > 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: totalRequests > 0 ? FontWeight.w600 : FontWeight.w400,
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
        tabs: const [
          Tab(text: 'Applications'),
          Tab(text: 'Connections'),
        ],
      ),
    );
  }

  // Tab 1: Application Requests
  Widget _buildApplicationRequestsTab() {
    return Consumer<ConnectionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingApplications) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.hasError && provider.pendingApplicationRequests.isEmpty) {
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
                  'Failed to load applications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Unknown error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.pendingApplicationRequests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No application requests',
            subtitle: 'When someone applies to your posts, they\'ll appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadPendingApplicationRequests(),
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: provider.pendingApplicationRequests.length,
            itemBuilder: (context, index) {
              final application = provider.pendingApplicationRequests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ApplicationRequestCard(
                  application: application,
                  onAccept: () => _acceptApplication(application['id']),
                  onReject: () => _rejectApplication(application['id']),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Tab 2: Connection Requests
  Widget _buildConnectionRequestsTab() {
    return Consumer<ConnectionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingConnections) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.hasError && provider.pendingConnectionRequests.isEmpty) {
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
                  'Failed to load connection requests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Unknown error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.pendingConnectionRequests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No connection requests',
            subtitle: 'When someone wants to connect, they\'ll appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadPendingConnectionRequests(),
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: provider.pendingConnectionRequests.length,
            itemBuilder: (context, index) {
              final requester = provider.pendingConnectionRequests[index];
              // print('Requester: $requester');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ConnectionRequestCard(
                  user: requester,
                  onAccept: () => _acceptConnectionRequest(requester['id']),
                  onReject: () => _rejectConnectionRequest(requester['id']),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
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
            child: Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Action Methods
  Future<void> _acceptConnectionRequest(String requesterId) async {
    //print('Accepting connection request from $requesterId');
    final provider = context.read<ConnectionProvider>();
    final success = await provider.acceptConnectionRequest(requesterId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request accepted!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!success && mounted) {
      print('Failed to accept connection request ${provider.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to accept request'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectConnectionRequest(String requesterId) async {
    final provider = context.read<ConnectionProvider>();
    final success = await provider.rejectConnectionRequest(requesterId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request rejected'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _acceptApplication(String applicationId) async {
    final provider = context.read<ConnectionProvider>();
    final success = await provider.acceptApplication(applicationId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application accepted!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectApplication(String applicationId) async {
    final provider = context.read<ConnectionProvider>();
    final success = await provider.rejectApplication(applicationId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application rejected'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}