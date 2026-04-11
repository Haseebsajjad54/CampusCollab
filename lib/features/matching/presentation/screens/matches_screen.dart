import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../messaging/presentation/providers/messaging_provider.dart';
import '../../../messaging/presentation/screens/chat_screen.dart';
import '../../domain/entities/match_suggestion.dart';
import '../providers/matching_provider.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  Future<void> _loadMatches() async {
    if (!mounted) return;
    final provider = context.read<MatchingProvider>();
    await provider.loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Consumer<MatchingProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: [
                    _buildHeader(theme, provider),
                    _buildFilterChips(provider),
                    if (provider.matches.isNotEmpty)
                      _buildStatisticsBar(provider),
                    Expanded(
                      child: _buildMatchesList(provider, theme),
                    ),
                  ],
                );
              },
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
              AppColors.accent.withOpacity(0.15),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, MatchingProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Finder',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.matches.isEmpty
                      ? 'Finding your perfect teammates...'
                      : '${provider.matches.length} potential matches',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: provider.isLoading ? null : () => _refreshMatches(provider),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: provider.isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textPrimary,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.refresh,
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

  Widget _buildFilterChips(MatchingProvider provider) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All Matches', 'all', provider.matches.length),
          const SizedBox(width: 8),
          _buildFilterChip('High Match', 'high', provider.getHighMatches().length),
          const SizedBox(width: 8),
          _buildFilterChip('Available', 'available', provider.filterByAvailability().length),
          const SizedBox(width: 8),
          _buildFilterChip('Same Department', 'department', 0),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textPrimary.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? AppColors.textPrimary : AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }

  Widget _buildStatisticsBar(MatchingProvider provider) {
    final stats = provider.getStatistics();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.stars,
            label: 'High',
            value: '${stats['high']}',
            color: AppColors.accent,
          ),
          Container(width: 1, height: 30, color: AppColors.border),
          _buildStatItem(
            icon: Icons.trending_up,
            label: 'Avg Score',
            value: '${(stats['averageScore'] * 100).toStringAsFixed(0)}%',
            color: AppColors.primary,
          ),
          Container(width: 1, height: 30, color: AppColors.border),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Available',
            value: '${stats['available']}',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesList(MatchingProvider provider, ThemeData theme) {
    if (provider.isLoading && provider.matches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.hasError) {
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
              'Failed to load matches',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Unknown error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadMatches,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.isEmpty || provider.matches.isEmpty) {
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
                    AppColors.accent.withOpacity(0.2),
                    AppColors.accent.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 64,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No matches found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adding more skills and interests to your profile!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      );
    }

    final filteredMatches = _getFilteredMatches(provider);

    return RefreshIndicator(
      onRefresh: () => provider.refreshMatches(),
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: filteredMatches.length,
        itemBuilder: (context, index) {
          final match = filteredMatches[index];
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MatchCard(
                match: match,
                currentUserId: provider.currentUserId,
                onTap: () => _viewMatchProfile(match),
                onConnect: () => _sendConnectionRequest(provider, match.userId),
                onMessage: () => _startChat(match),
              ),
            ),
          );
        },
      ),
    );
  }

  List<MatchSuggestion> _getFilteredMatches(MatchingProvider provider) {
    switch (_selectedFilter) {
      case 'high':
        return provider.getHighMatches();
      case 'available':
        return provider.filterByAvailability();
      case 'department':
        return provider.matches;
      default:
        return provider.matches;
    }
  }

  Future<void> _sendConnectionRequest(MatchingProvider provider, String receiverId) async {
    // Call the provider's sendConnectionRequest method
    await provider.sendConnectionRequest(provider.currentUserId, receiverId);

    if (!mounted) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request sent!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _startChat(MatchSuggestion match) async {
    final messagingProvider = context.read<MessagingProvider>();
    final currentUserId = messagingProvider.currentUser.id;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Check if users are connected
      final areConnected = await messagingProvider.areUsersConnected(
        currentUserId,
        match.userId,
      );

      Navigator.pop(context); // Close loading dialog

      if (!areConnected) {
        _showNotConnectedDialog(match);
        return;
      }

      // Get or create conversation
      final conversation = await messagingProvider.getOrCreateConversation(match.userId);

      if (conversation != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(conversation: conversation),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start chat: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showNotConnectedDialog(MatchSuggestion match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Not Connected',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'You need to be connected with ${match.fullName} to send messages.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final matchingProvider = context.read<MatchingProvider>();
              await matchingProvider.sendConnectionRequest(
                matchingProvider.currentUserId,
                match.userId,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connection request sent!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshMatches(MatchingProvider provider) async {
    await provider.refreshMatches();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Matches refreshed!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _viewMatchProfile(MatchSuggestion match) {
    showDialog(
      context: context,
      builder: (context) => MatchDetailsDialog(match: match),
    );
  }
}

// Match Card Widget
class MatchCard extends StatelessWidget {
  final MatchSuggestion match;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onConnect;
  final VoidCallback? onMessage;

  const MatchCard({
    super.key,
    required this.match,
    required this.currentUserId,
    required this.onTap,
    this.onConnect,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getScoreColor(match.matchScore).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(match.matchScore).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (match.department != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.school,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${match.department} • Year ${match.yearOfStudy ?? "?"}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    _buildScoreBadge(),
                  ],
                ),
                const SizedBox(height: 16),
                if (match.bio != null && match.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      match.bio!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (match.sharedSkills.isNotEmpty)
                  _buildSharedItems(
                    icon: Icons.code,
                    label: 'Skills',
                    items: match.sharedSkills,
                    color: AppColors.accentBlue,
                  ),
                if (match.sharedSkills.isNotEmpty && match.sharedInterests.isNotEmpty)
                  const SizedBox(height: 8),
                if (match.sharedInterests.isNotEmpty)
                  _buildSharedItems(
                    icon: Icons.favorite,
                    label: 'Interests',
                    items: match.sharedInterests,
                    color: AppColors.accent,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (match.cgpa != null)
                      _buildInfoChip(
                        icon: Icons.school,
                        label: 'CGPA ${match.cgpa!.toStringAsFixed(2)}',
                      ),
                    const SizedBox(width: 8),
                    if (match.isAvailable)
                      _buildInfoChip(
                        icon: Icons.check_circle,
                        label: 'Available',
                        color: AppColors.success,
                      ),
                    const Spacer(),
                    Text(
                      '${match.totalPosts} posts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        onPressed: onConnect,
                        icon: Icons.person_add_outlined,
                        label: 'Connect',
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent,
                            AppColors.accent.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        onPressed: onMessage,
                        icon: Icons.message_outlined,
                        label: 'Message',
                        isOutlined: true,
                      ),
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

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    Gradient? gradient,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? AppColors.accent).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            _getScoreColor(match.matchScore),
            _getScoreColor(match.matchScore).withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: _getScoreColor(match.matchScore),
          width: 2,
        ),
        image: match.profilePictureUrl != null
            ? DecorationImage(
          image: NetworkImage(match.profilePictureUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: match.profilePictureUrl == null
          ? Icon(
        Icons.person,
        color: AppColors.textPrimary,
        size: 28,
      )
          : null,
    );
  }

  Widget _buildScoreBadge() {
    final percentage = (match.matchScore * 100).toInt();
    final color = _getScoreColor(match.matchScore);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            match.isHighMatch ? Icons.stars : Icons.star,
            color: AppColors.textPrimary,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedItems({
    required IconData icon,
    required String label,
    required List<String> items,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.take(3).map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (items.length > 3)
          Text(
            '+${items.length - 3}',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.textTertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.80) return AppColors.accent;
    if (score >= 0.60) return AppColors.primary;
    if (score >= 0.40) return AppColors.warning;
    return AppColors.textTertiary;
  }
}

class MatchDetailsDialog extends StatelessWidget {
  final MatchSuggestion match;

  const MatchDetailsDialog({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      match.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Score: ${(match.matchScore * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Full profile details coming soon!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}