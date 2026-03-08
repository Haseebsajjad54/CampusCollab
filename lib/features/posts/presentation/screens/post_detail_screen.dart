import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/theme/app_colors.dart';


class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isBookmarked = false;
  bool _hasApplied = false;

  // Mock post data
  final Map<String, dynamic> _post = {
    'id': '1',
    'type': 'FYP Group',
    'title': 'AI-Powered Health Monitoring System',
    'author': 'Sarah Chen',
    'authorId': 'user_1',
    'authorImage': 'https://i.pravatar.cc/150?img=1',
    'authorBio': 'Final year CS student passionate about AI and healthcare',
    'department': 'Computer Science',
    'year': 4,
    'cgpa': 3.85,
    'description': '''We're building an innovative health monitoring system that uses computer vision and machine learning to track vital signs in real-time.

The system will analyze video feeds to detect heart rate, respiratory rate, and stress levels without requiring any physical contact with sensors. This could revolutionize healthcare accessibility in remote areas.

We're looking for passionate developers who want to make a real impact in healthcare technology.''',
    'requiredSkills': [
      {'name': 'Python', 'mandatory': true},
      {'name': 'TensorFlow', 'mandatory': true},
      {'name': 'Computer Vision', 'mandatory': true},
      {'name': 'Flutter', 'mandatory': false},
      {'name': 'Firebase', 'mandatory': false},
    ],
    'lookingFor': [
      'Machine Learning Engineer',
      'Computer Vision Specialist',
      'Mobile App Developer',
    ],
    'teamSize': 4,
    'currentMembers': 2,
    'deadline': '2024-03-15',
    'duration': '6 months',
    'matchScore': 92,
    'timePosted': '2 hours ago',
    'viewCount': 156,
    'applicationCount': 12,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient Background
          _buildGradientBackground(),

          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              _buildSliverAppBar(theme),

              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Match Score Badge
                          _buildMatchScoreBadge(theme),

                          const SizedBox(height: 24),

                          // Title
                          Text(
                            _post['title'],
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontSize: 32,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Meta Info
                          _buildMetaInfo(theme),

                          const SizedBox(height: 32),

                          // Author Card
                          _buildAuthorCard(theme),

                          const SizedBox(height: 32),

                          // Description
                          _buildSection(
                            theme: theme,
                            title: 'About The Project',
                            child: Text(
                              _post['description'],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.8,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Required Skills
                          _buildSection(
                            theme: theme,
                            title: 'Required Skills',
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: (_post['requiredSkills'] as List)
                                  .map((skill) => _buildSkillChip(
                                skill['name'],
                                isMandatory: skill['mandatory'],
                              ))
                                  .toList(),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Looking For
                          _buildSection(
                            theme: theme,
                            title: 'Looking For',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (_post['lookingFor'] as List)
                                  .map((role) => _buildRoleItem(theme, role))
                                  .toList(),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Project Details
                          _buildProjectDetails(theme),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          _buildBottomActionBar(theme),
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

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
          iconSize: 20,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.accent : AppColors.textPrimary,
            ),
            onPressed: () => setState(() => _isBookmarked = !_isBookmarked),
            iconSize: 20,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () => _showShareOptions(context),
            iconSize: 20,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMatchScoreBadge(ThemeData theme) {
    final score = _post['matchScore'] as int;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.accent,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$score% Perfect Match',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Based on your skills & interests',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.accent.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildMetaChip(
          icon: Icons.category_outlined,
          text: _post['type'],
          color: AppColors.primary,
        ),
        _buildMetaChip(
          icon: Icons.people_outline,
          text: '${_post['currentMembers']}/${_post['teamSize']} Members',
          color: AppColors.accentBlue,
        ),
        _buildMetaChip(
          icon: Icons.access_time,
          text: _post['timePosted'],
          color: AppColors.textSecondary,
        ),
        _buildMetaChip(
          icon: Icons.visibility_outlined,
          text: '${_post['viewCount']} views',
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                    image: DecorationImage(
                      image: NetworkImage(_post['authorImage']),
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
                      _post['author'],
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_post['department']} • Year ${_post['year']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'CGPA ${_post['cgpa']}',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                    onTap: () {
                      // Open chat
                    },
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

          const SizedBox(height: 16),

          Text(
            _post['authorBio'],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
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

  Widget _buildSkillChip(String skill, {required bool isMandatory}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: isMandatory ? AppColors.primaryGradient : null,
        color: isMandatory ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMandatory
              ? AppColors.primary
              : AppColors.border,
          width: isMandatory ? 2 : 1,
        ),
        boxShadow: isMandatory
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMandatory)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(
                Icons.star,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ),
          Text(
            skill,
            style: TextStyle(
              color: isMandatory
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isMandatory)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleItem(ThemeData theme, String role) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              role,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Details',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Application Deadline',
            value: _post['deadline'],
            color: AppColors.warning,
          ),

          const SizedBox(height: 16),

          _buildDetailRow(
            icon: Icons.schedule_outlined,
            label: 'Project Duration',
            value: _post['duration'],
            color: AppColors.accentBlue,
          ),

          const SizedBox(height: 16),

          _buildDetailRow(
            icon: Icons.description_outlined,
            label: 'Total Applications',
            value: '${_post['applicationCount']} students',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Secondary Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Save for later
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isBookmarked ? 'Saved' : 'Save',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Primary Button
              Expanded(
                flex: 2,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _hasApplied
                        ? null
                        : AppColors.accentGradient,
                    color: _hasApplied ? AppColors.success : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _hasApplied
                        ? null
                        : [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _hasApplied ? null : _showApplySheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasApplied ? Icons.check_circle : Icons.send_rounded,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _hasApplied ? 'APPLICATION SENT' : 'APPLY NOW',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
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
    );
  }

  void _showApplySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationBottomSheet(
        postTitle: _post['title'],
        onApply: (message) {
          setState(() => _hasApplied = true);
          Navigator.pop(context);
          _showSuccessSnackbar();
        },
      ),
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Application sent successfully!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    // Share functionality
  }
}

// Application Bottom Sheet
class ApplicationBottomSheet extends StatefulWidget {
  final String postTitle;
  final Function(String) onApply;

  const ApplicationBottomSheet({
    super.key,
    required this.postTitle,
    required this.onApply,
  });

  @override
  State<ApplicationBottomSheet> createState() => _ApplicationBottomSheetState();
}

class _ApplicationBottomSheetState extends State<ApplicationBottomSheet> {
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Apply to Project',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.postTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // Message Input
            Text(
              'WHY DO YOU WANT TO JOIN?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 5,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tell the team why you\'re a great fit...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.glowShadow,
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.textPrimary,
                      ),
                    ),
                  )
                      : const Text(
                    'SEND APPLICATION',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write a message'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    widget.onApply(_messageController.text);
  }
}