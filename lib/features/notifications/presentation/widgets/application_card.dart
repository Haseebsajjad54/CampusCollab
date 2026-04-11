// lib/features/applications/presentation/widgets/application_request_card.dart
import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';

class ApplicationRequestCard extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ApplicationRequestCard({
    super.key,
    required this.application,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applicant = application['profiles'] as Map<String, dynamic>?;
    final post = application['posts'] as Map<String, dynamic>?;

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
          color: AppColors.accentBlue.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  _buildAvatar(applicant),
                  const SizedBox(width: 16),

                  // Name and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant?['full_name'] ?? 'Unknown User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (applicant?['department'] != null)
                          Row(
                            children: [
                              Icon(
                                Icons.school,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${applicant?['department']} • Year ${applicant?['year_of_study'] ?? "?"}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Application Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description,
                          color: AppColors.textPrimary,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Applied',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Post Title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applied to:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application['posts']?['title'] ?? 'Unknown Project',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Application Message
              if (application['message'] != null && application['message'].toString().isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.message_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Message:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        application['message'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Skills Section
              if (applicant?['skills'] != null && (applicant?['skills'] as List).isNotEmpty)
                _buildSkillsSection(applicant?['skills']),

              const SizedBox(height: 16),

              // Footer Info
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.star,
                    label: 'CGPA ${applicant?['cgpa']?.toStringAsFixed(2) ?? "N/A"}',
                  ),
                  const SizedBox(width: 8),
                  if (applicant?['availability_status'] == 'available')
                    _buildInfoChip(
                      icon: Icons.check_circle,
                      label: 'Available',
                      color: AppColors.success,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  // Accept Button
                  Expanded(
                    child: _buildActionButton(
                      onPressed: onAccept,
                      icon: Icons.check,
                      label: 'Accept',
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success,
                          AppColors.success.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Reject Button
                  Expanded(
                    child: _buildActionButton(
                      onPressed: onReject,
                      icon: Icons.close,
                      label: 'Reject',
                      isOutlined: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic>? applicant) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue,
            AppColors.accentBlue.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: AppColors.accentBlue,
          width: 2,
        ),
        image: applicant?['profile_picture_url'] != null
            ? DecorationImage(
          image: NetworkImage(applicant!['profile_picture_url']!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: applicant?['profile_picture_url'] == null
          ? Icon(
        Icons.person,
        color: AppColors.textPrimary,
        size: 28,
      )
          : null,
    );
  }

  Widget _buildSkillsSection(List<dynamic>? skills) {
    if (skills == null || skills.isEmpty) return const SizedBox();

    return Row(
      children: [
        Icon(
          Icons.code,
          size: 14,
          color: AppColors.accentBlue,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills.take(3).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  skill.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (skills.length > 3)
          Text(
            '+${skills.length - 3}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.accentBlue,
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

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    Gradient? gradient,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
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
            color: (gradient?.colors.first ?? AppColors.success).withOpacity(0.3),
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
}