import 'dart:ui';
import 'package:campus_collab/features/posts/presentation/widgets/customs_text_field.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../providers/post_provider.dart';
import 'package:provider/provider.dart';

/// Show Create Post Bottom Sheet
/// Call this function when FAB is pressed
void showCreatePostSheet(BuildContext context) {
  // Reset provider state
  context.read<PostProvider>().resetForm();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => const CreatePostBottomSheet(),
  );
}


class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Stack(
            children: [
              // Animated Background
              _buildAnimatedBackground(),

              // Main Content
              Column(
                children: [
                  // Drag Handle
                  _buildDragHandle(),

                  // Header
                  _buildHeader(context, provider),

                  // Progress Indicator
                  _buildProgressIndicator(provider),

                  // Steps Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        // Sync page with provider step
                      },
                      children: [
                        _buildBasicInfoStep(context, provider),
                        _buildDetailsStep(context, provider),
                        _buildSkillsStep(context, provider),
                        _buildLookingForStep(context, provider),
                        _buildReviewStep(context, provider),
                      ],
                    ),
                  ),

                  // Navigation Buttons
                  _buildNavigationButtons(context, provider),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================================
  // DRAG HANDLE
  // ============================================================================

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // ANIMATED BACKGROUND
  // ============================================================================

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) {
            return CustomPaint(
              painter: WavePainter(value),
            );
          },
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader(BuildContext context, PostProvider provider) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          // Close Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 16),

          // Title & Step Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Post',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Step ${provider.currentStep + 1} of ${provider.totalSteps}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PROGRESS INDICATOR
  // ============================================================================

  Widget _buildProgressIndicator(PostProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(provider.totalSteps, (index) {
          final isCompleted = index < provider.currentStep;
          final isCurrent = index == provider.currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                right: index < provider.totalSteps - 1 ? 8 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: isCompleted || isCurrent
                    ? AppColors.accentGradient
                    : null,
                color: isCompleted || isCurrent ? null : AppColors.surface,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================================
  // STEP 1: BASIC INFO
  // ============================================================================

  Widget _buildBasicInfoStep(BuildContext context, PostProvider provider) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            theme: theme,
            title: 'Basic Information',
            subtitle: 'Let\'s start with the fundamentals',
          ),
          const SizedBox(height: 24),

          // Post Type
          Text(
            'POST TYPE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTypeCard(
                  theme: theme,
                  type: 'FYP Group',
                  icon: Icons.groups_outlined,
                  isSelected: provider.postType == 'FYP Group',
                  onTap: () => provider.setPostType('FYP Group'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeCard(
                  theme: theme,
                  type: 'Project Partner',
                  icon: Icons.handshake_outlined,
                  isSelected: provider.postType == 'academic_project',
                  onTap: () => provider.setPostType('academic_project'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Project Title
          CustomTextField(
              label: 'PROJECT TITLE',
              hint: 'e.g., AI-Powered Health Monitoring System',
              onChanged: provider.setTitle
          ),


          const SizedBox(height: 20),

          // Description
          CustomTextField(
              label: 'DESCRIPTION',
              hint: 'Describe your project idea, goals, and what you\'re looking for',
              onChanged: provider.setDescription
          ),
          // _buildTextField(
          //   label: 'DESCRIPTION',
          //   hint: 'Describe your project idea, goals, and what you\'re looking for...',
          //   maxLines: 5,
          //   initialValue: provider.description,
          //   onChanged: provider.setDescription,
          // ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================================
  // STEP 2: DETAILS
  // ============================================================================

  Widget _buildDetailsStep(BuildContext context, PostProvider provider) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            theme: theme,
            title: 'Project Details',
            subtitle: 'Configure team size and timeline',
          ),
          const SizedBox(height: 24),

          // Team Size
          Text(
            'TEAM SIZE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surface,
                  AppColors.surface.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Looking for ${provider.teamSize} members',
                      style: theme.textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${provider.teamSize}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: provider.teamSize.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.background,
                  onChanged: (val) => provider.setTeamSize(val.toInt()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Deadline
          Text(
            'DEADLINE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) provider.setDeadline(picked);
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      provider.deadline != null
                          ? '${provider.deadline!.day}/${provider.deadline!.month}/${provider.deadline!.year}'
                          : 'Select deadline',
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================================
  // STEP 3: SKILLS
  // ============================================================================

  Widget _buildSkillsStep(BuildContext context, PostProvider provider) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            theme: theme,
            title: 'Required Skills',
            subtitle: 'What skills are you looking for?',
          ),
          const SizedBox(height: 24),

          Text(
            'SKILLS (${provider.selectedSkills.length} selected)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),

          // Use FutureBuilder to handle async skills data
          FutureBuilder<List<String>>(
            future: provider.getSkills(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load skills',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => provider.getSkills(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final skills = snapshot.data ?? [];

              if (skills.isEmpty) {
                return Center(
                  child: Text(
                    'No skills available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: skills.map((skill) {
                  final selected = provider.selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: selected,
                    onSelected: (_) => _handleSkillSelection(context, provider, skill, selected),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

// Add this method to handle skill selection with mandatory/optional dialog
  void _handleSkillSelection(BuildContext context, PostProvider provider, String skill, bool isCurrentlySelected) async {
    if (isCurrentlySelected) {
      provider.toggleSkill(skill);
    } else {
      final isMandatory = await _showSkillRequirementDialog(context, skill);
      if (isMandatory != null) {
        provider.addSkillWithRequirement(skill, isMandatory);
      }
    }
  }

  Future<bool?> _showSkillRequirementDialog(BuildContext context, String skill) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.code,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                skill,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Is this skill required for the project?',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildRequirementOption(
                    context: context,
                    title: 'Required',
                    description: 'Team members must have this skill',
                    icon: Icons.star,
                    isMandatory: true,
                  ),
                  const Divider(color: AppColors.border),
                  _buildRequirementOption(
                    context: context,
                    title: 'Optional',
                    description: 'Nice to have, but not required',
                    icon: Icons.star_border,
                    isMandatory: false,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool isMandatory,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, isMandatory),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isMandatory
                    ? AppColors.primaryGradient
                    : AppColors.accentGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STEP 4: REVIEW
  // ============================================================================

  Widget _buildReviewStep(BuildContext context, PostProvider provider) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            theme: theme,
            title: 'Review & Publish',
            subtitle: 'Make sure everything looks good',
          ),
          const SizedBox(height: 24),

          // Preview Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surface,
                  AppColors.surface.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    provider.postType ?? 'FYP Group',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  provider.title ?? 'Untitled Project',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  provider.description ?? 'No description',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Team Size & Deadline
                Row(
                  children: [
                    Icon(
                      Icons.group,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.teamSize} members',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.deadline != null
                          ? '${provider.deadline!.day}/${provider.deadline!.month}/${provider.deadline!.year}'
                          : 'No deadline',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),

                // Skills
                if (provider.selectedSkills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.selectedSkills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (provider.lookingFor.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Looking For:',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.lookingFor.map((role) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================================
  // COMMON WIDGETS
  // ============================================================================

  Widget _buildStepTitle({
    required ThemeData theme,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required ThemeData theme,
    required String type,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              type,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? initialValue,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            maxLines: maxLines,
            onChanged: onChanged,
            controller: initialValue != null
                ? TextEditingController(text: initialValue)
                : null,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
  // Add this method to _CreatePostBottomSheetState

  Widget _buildLookingForStep(BuildContext context, PostProvider provider) {
    final theme = Theme.of(context);
    final TextEditingController _roleController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            theme: theme,
            title: 'Looking For',
            subtitle: 'What roles are you trying to fill?',
          ),
          const SizedBox(height: 24),

          Text(
            'ADD ROLES (${provider.lookingFor.length} added)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Add role input
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _roleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'e.g., Machine Learning Engineer',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.textPrimary),
                  onPressed: () {
                    if (_roleController.text.isNotEmpty) {
                      provider.addLookingFor(_roleController.text);
                      _roleController.clear();
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Display added roles
          if (provider.lookingFor.isNotEmpty) ...[
            Text(
              'SELECTED ROLES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: provider.lookingFor.map((role) {
                return Chip(
                  label: Text(role),
                  onDeleted: () => provider.removeLookingFor(role),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, PostProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back Button
            if (provider.currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.previousStep();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('BACK'),
                ),
              ),

            if (provider.currentStep > 0) const SizedBox(width: 12),

            // Next/Publish Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () async {
                  if (provider.currentStep < provider.totalSteps - 1) {
                    provider.nextStep();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // Publish post
                    print('Publishing post');
                    await provider.createPost();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Post created successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  provider.currentStep < provider.totalSteps - 1
                      ? 'NEXT'
                      : 'PUBLISH POST',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WAVE PAINTER
// ============================================================================

class WavePainter extends CustomPainter {
  final double animation;
  WavePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.1),
          AppColors.background,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}