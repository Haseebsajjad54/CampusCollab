import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/application_model.dart';
import '../../domain/entities/application.dart';

/// Application Status Badge Widget
///
/// Displays a colored badge showing the application status
class ApplicationStatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final bool isLarge;

  const ApplicationStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 12,
        vertical: isLarge ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
        border: Border.all(
          color: config.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: isLarge ? 18 : 14,
            color: config.color,
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: isLarge ? 14 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return _StatusConfig(
          label: 'Pending',
          icon: Icons.schedule,
          color: AppColors.warning,
        );
      case ApplicationStatus.accepted:
        return _StatusConfig(
          label: 'Accepted',
          icon: Icons.check_circle,
          color: AppColors.success,
        );
      case ApplicationStatus.rejected:
        return _StatusConfig(
          label: 'Rejected',
          icon: Icons.cancel,
          color: AppColors.error,
        );
      case ApplicationStatus.withdrawn:
        return _StatusConfig(
          label: 'Withdrawn',
          icon: Icons.remove_circle,
          color: AppColors.textTertiary,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;

  _StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}