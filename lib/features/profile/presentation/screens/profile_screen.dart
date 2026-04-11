import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/screens/post_detail_screen.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final Map<String, dynamic> profile = {
    'name': 'Alex Morgan',
    'studentId': 'CS-2021-042',
    'department': 'Computer Science',
    'year': 4,
    'cgpa': 3.85,
    'bio': 'Passionate full-stack developer with a keen interest in AI/ML and cloud computing. Always looking for innovative projects to collaborate on.',
    'profileImage': 'https://i.pravatar.cc/300?img=12',
    'linkedin': '@alexmorgan',
    'github': '@alexmorgan',
    'availability': 'Available',
    'stats': {
      'projects': 12,
      'collaborations': 8,
      'skills': 15,
    },
    'skills': [
      {'name': 'Flutter', 'level': 'Expert'},
      {'name': 'Python', 'level': 'Advanced'},
      {'name': 'React', 'level': 'Advanced'},
      {'name': 'Node.js', 'level': 'Intermediate'},
      {'name': 'TensorFlow', 'level': 'Intermediate'},
      {'name': 'AWS', 'level': 'Intermediate'},
    ],
    'interests': ['AI/ML', 'Web Development', 'Mobile Apps', 'Cloud Computing'],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final profileProvider=Provider.of<ProfileProvider>(context);

    return ValueListenableBuilder<ProfileState>(
        valueListenable: profileProvider.stateNotifier,
        builder: (context, state, child) {
          final showLoading = state.status == ProfileStatus.loading;

          return Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Gradient Background
              _buildBackgroundGradient(),

              // Main Content
             showLoading?const Center(child: CircularProgressIndicator(),) : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar with Floating Actions
                  _buildSliverAppBar(theme,profileProvider: profileProvider),

                  // Profile Header
                  SliverToBoxAdapter(
                    child: _buildProfileHeader(theme,profileProvider: profileProvider),
                  ),

                  // Stats Cards
                  SliverToBoxAdapter(
                    child: _buildStatsCards(theme),
                  ),

                  // Tab Bar
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                        tabs: const [
                          Tab(text: 'SKILLS'),
                          Tab(text: 'POSTS'),
                          Tab(text: 'ACTIVITY'),
                        ],
                      ),
                    ),
                  ),

                  // Tab Content
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSkillsTab(theme),
                        _buildPostsTab(theme,profileProvider: profileProvider),
                        _buildActivityTab(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.8),
            radius: 1.2,
            colors: [
              AppColors.primary.withOpacity(0.2),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme,{required ProfileProvider profileProvider}) {
    final provider = context.watch<AuthProvider>();


    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      //   onPressed: () => Navigator.pop(context),
      // ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
          onPressed: () {
            // Navigate to settings
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.logout_outlined, color: AppColors.textPrimary),
          onPressed: () {
            // Navigate to settings
            setState(() {
            provider.signOut();
            // profileProvider.authLocalDataSource.clearUser();
            });

          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ThemeData theme, {required ProfileProvider profileProvider}) {
    final ImagePicker picker = ImagePicker();

    // Get profile with null safety
    final profile = profileProvider.profile;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
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
        padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
        child: Column(
          children: [
            // Profile Picture with Glow Effect
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final XFile? pickedImage = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 85,
                        );

                        if (pickedImage != null) {
                          final File imageFile = File(pickedImage.path);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          final bool success = await profileProvider.uploadProfilePicture(imageFile);

                          if (context.mounted) {
                            Navigator.pop(context);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile picture updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(profileProvider.errorMessage ?? 'Failed to upload image'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          // FIXED: Safe null check for profile picture URL
                          image: (profile?.profilePictureUrl != null && profile!.profilePictureUrl!.isNotEmpty)
                              ? NetworkImage(profile.profilePictureUrl!)
                              : const AssetImage('assets/default_avatar.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: AppColors.background,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),

                // Availability Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    profile?.availabilityStatus ?? 'Available',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Name
            Text(
              profile?.fullName ?? "Full Name",
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 32,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Student Info
            Text(
              '${profile?.studentId ?? ""} • ${profile?.department ?? ""}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Year & CGPA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoPill(
                  icon: Icons.school_outlined,
                  text: 'Year ${profile?.yearOfStudy ?? ""}',
                ),
                const SizedBox(width: 12),
                _buildInfoPill(
                  icon: Icons.star_outline,
                  text: 'CGPA ${profile?.cgpa ?? ""}',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bio
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface.withOpacity(0.6),
                    AppColors.surface.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile?.bio ?? "",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Social Links
            SizedBox(
              height: 50,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  if (profile?.linkedinUrl != null && profile!.linkedinUrl!.isNotEmpty)
                    _buildSocialLink(
                      icon: Icons.work_outline,
                      label: profile.linkedinUrl!,
                      onTap: () {},
                    ),
                  if (profile?.githubUrl != null && profile!.githubUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: _buildSocialLink(
                        icon: Icons.code,
                        label: profile.githubUrl!,
                        onTap: () {},
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final stats = profileProvider.stats ?? {};

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  icon: Icons.post_add_outlined,
                  value: stats['posts']?.toString() ?? '0',
                  label: 'Posts',
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  icon: Icons.people_outline,
                  value: stats['applications_sent']?.toString() ?? '0',
                  label: 'Application Sent',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  icon: Icons.bolt_outlined,
                  value: stats['applications_received']?.toString() ?? '0',
                  label: 'Application Received',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(ThemeData theme) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;

        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final skills = profile.skills ?? [];
        final interests = profile.interests ?? [];

        if (skills.isEmpty && interests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No skills or interests added yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (skills.isNotEmpty) ...[
                Text(
                  'Technical Skills',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                ...skills.map((skill) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSkillItem(
                      theme: theme,
                      name: skill,
                      level:  'Intermediate',
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],

              if (interests.isNotEmpty) ...[
                Text(
                  'Interests',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: interests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillItem({
    required ThemeData theme,
    required String name,
    required String level,
  }) {
    final proficiency = {
      'Expert': 1.0,
      'Advanced': 0.8,
      'Intermediate': 0.6,
      'Beginner': 0.4,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium,
            ),
            Text(
              level,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: proficiency[level] ?? 0.5),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation(AppColors.accent),
                minHeight: 8,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab(ThemeData theme, {required ProfileProvider profileProvider}) {
    final posts = profileProvider.userPosts ?? [];

    return Center(
      child: posts.isNotEmpty
          ? ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  post.title.substring(0, 1).toUpperCase() ?? 'P',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                post.title ?? 'Untitled',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                post.description ?? 'No description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                _formatDate(post.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              onTap: () {
                // Navigate to post detail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(postId: post.id),
                  ),
                );
              },
            ),
          );
        },
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first post to share your ideas!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildActivityTab(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Tab Bar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}