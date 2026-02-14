import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../../../core/config/theme/app_colors.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _suggestedPosts = [
    {
      'id': '1',
      'title': 'Smart Campus IoT Network',
      'author': 'Marcus Chen',
      'authorImage': 'https://i.pravatar.cc/150?img=15',
      'department': 'Computer Science',
      'matchScore': 94,
      'commonSkills': ['Python', 'IoT', 'Machine Learning'],
      'description': 'Building an intelligent campus network with automated systems...',
      'teamSize': '2/4',
      'type': 'FYP Group',
    },
    {
      'id': '2',
      'title': 'E-Commerce Analytics Platform',
      'author': 'Sophia Rodriguez',
      'authorImage': 'https://i.pravatar.cc/150?img=23',
      'department': 'Software Engineering',
      'matchScore': 89,
      'commonSkills': ['React', 'Node.js', 'Data Analysis'],
      'description': 'Real-time analytics dashboard for e-commerce businesses...',
      'teamSize': '3/5',
      'type': 'Project Partner',
    },
    {
      'id': '3',
      'title': 'Mental Health Chatbot',
      'author': 'David Kim',
      'authorImage': 'https://i.pravatar.cc/150?img=52',
      'department': 'Computer Science',
      'matchScore': 87,
      'commonSkills': ['NLP', 'TensorFlow', 'Python'],
      'description': 'AI-powered mental health support chatbot for students...',
      'teamSize': '1/3',
      'type': 'FYP Group',
    },
  ];

  final List<Map<String, dynamic>> _suggestedStudents = [
    {
      'id': '1',
      'name': 'Emma Watson',
      'image': 'https://i.pravatar.cc/150?img=5',
      'department': 'Computer Science',
      'year': 4,
      'matchScore': 92,
      'commonSkills': ['Flutter', 'Firebase', 'UI/UX'],
      'commonInterests': ['Mobile Development', 'Startups'],
      'bio': 'Full-stack mobile developer passionate about creating beautiful user experiences',
    },
    {
      'id': '2',
      'name': 'James Wilson',
      'image': 'https://i.pravatar.cc/150?img=14',
      'department': 'Software Engineering',
      'year': 3,
      'matchScore': 88,
      'commonSkills': ['Python', 'Django', 'PostgreSQL'],
      'commonInterests': ['Backend Development', 'Cloud Computing'],
      'bio': 'Backend specialist with experience in scalable systems',
    },
    {
      'id': '3',
      'name': 'Olivia Brown',
      'image': 'https://i.pravatar.cc/150?img=29',
      'department': 'Computer Science',
      'year': 4,
      'matchScore': 85,
      'commonSkills': ['Machine Learning', 'Python', 'TensorFlow'],
      'commonInterests': ['AI/ML', 'Data Science'],
      'bio': 'AI enthusiast working on computer vision projects',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(theme),

                // Tab Bar
                _buildTabBar(theme),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostsTab(theme),
                      _buildStudentsTab(theme),
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

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return CustomPaint(
            painter: PulsingCirclesPainter(_pulseController.value),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perfect Matches',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-powered recommendations just for you',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Match Quality Indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(24),
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
          Tab(text: 'Projects'),
          Tab(text: 'Students'),
        ],
      ),
    );
  }

  Widget _buildPostsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _suggestedPosts.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: MatchPostCard(
              post: _suggestedPosts[index],
              onLike: () => _handleLike(index),
              onDismiss: () => _handleDismiss(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _suggestedStudents.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: MatchStudentCard(
              student: _suggestedStudents[index],
              onConnect: () => _handleConnect(index),
            ),
          ),
        );
      },
    );
  }

  void _handleLike(int index) {
    // Handle liking a post
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post saved to favorites!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleDismiss(int index) {
    setState(() {
      _suggestedPosts.removeAt(index);
    });
  }

  void _handleConnect(int index) {
    // Handle connecting with a student
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Connection request sent!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Match Post Card
class MatchPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final VoidCallback onDismiss;

  const MatchPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onDismiss,
  });

  @override
  State<MatchPostCard> createState() => _MatchPostCardState();
}

class _MatchPostCardState extends State<MatchPostCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchScore = widget.post['matchScore'] as int;

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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _getScoreColor(matchScore).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(matchScore).withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match Score Badge
                  Row(
                    children: [
                      Expanded(
                        child: _buildScoreBadge(matchScore),
                      ),
                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.post['type'],
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Author Info
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getScoreColor(matchScore),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(widget.post['authorImage']),
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
                              widget.post['author'],
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              widget.post['department'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.post['title'],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    widget.post['description'],
                    style: theme.textTheme.bodyMedium,
                    maxLines: _isExpanded ? null : 2,
                    overflow: _isExpanded ? null : TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Common Skills
                  Text(
                    'MATCHING SKILLS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (widget.post['commonSkills'] as List<String>)
                        .map((skill) => _buildSkillChip(skill))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.close_rounded,
                          label: 'Pass',
                          color: AppColors.textTertiary,
                          onTap: widget.onDismiss,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildActionButton(
                          icon: Icons.favorite_rounded,
                          label: 'Interested',
                          gradient: AppColors.accentGradient,
                          onTap: widget.onLike,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor(score).withOpacity(0.2),
            _getScoreColor(score).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getScoreColor(score).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            color: _getScoreColor(score),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$score% Match',
            style: TextStyle(
              color: _getScoreColor(score),
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    Gradient? gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        color: color != null ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: gradient != null ? AppColors.textPrimary : color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: gradient != null ? AppColors.textPrimary : color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.accent;
    if (score >= 80) return AppColors.success;
    if (score >= 70) return AppColors.accentBlue;
    return AppColors.warning;
  }
}

// Match Student Card
class MatchStudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onConnect;

  const MatchStudentCard({
    super.key,
    required this.student,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchScore = student['matchScore'] as int;

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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    // Profile Picture
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(student['image']),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: AppColors.background,
                            width: 3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'],
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${student['department']} • Year ${student['year']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildScoreBadge(matchScore),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bio
                Text(
                  student['bio'],
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Common Skills & Interests
                _buildCommonSection(
                  'Common Skills',
                  student['commonSkills'],
                  AppColors.primary,
                ),

                const SizedBox(height: 12),

                _buildCommonSection(
                  'Common Interests',
                  student['commonInterests'],
                  AppColors.accentBlue,
                ),

                const SizedBox(height: 20),

                // Connect Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onConnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'CONNECT',
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.accent, size: 14),
          const SizedBox(width: 4),
          Text(
            '$score% Match',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Pulsing Circles Painter
class PulsingCirclesPainter extends CustomPainter {
  final double animation;

  PulsingCirclesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create pulsing circles
    final positions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.8),
    ];

    for (int i = 0; i < positions.length; i++) {
      final offset = (animation + (i * 0.33)) % 1.0;

      paint.shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.15 * (1 - offset)),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: positions[i],
          radius: size.width * 0.4 * (0.5 + offset),
        ),
      );

      canvas.drawCircle(
        positions[i],
        size.width * 0.4 * (0.5 + offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PulsingCirclesPainter oldDelegate) => true;
}