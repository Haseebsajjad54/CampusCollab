import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/config/theme/app_colors.dart';

/// Match Score Indicator Widget
///
/// Displays match percentage with animated circular progress
class MatchScoreIndicator extends StatefulWidget {
  final double score; // 0.0 to 1.0
  final double size;
  final bool showLabel;
  final bool animate;

  const MatchScoreIndicator({
    super.key,
    required this.score,
    this.size = 80,
    this.showLabel = true,
    this.animate = true,
  });

  @override
  State<MatchScoreIndicator> createState() => _MatchScoreIndicatorState();
}

class _MatchScoreIndicatorState extends State<MatchScoreIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score * 100).round();
    final color = _getScoreColor(widget.score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _ScoreCirclePainter(
                  progress: _animation.value,
                  color: color,
                  strokeWidth: widget.size * 0.08,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_animation.value * 100).round()}%',
                        style: TextStyle(
                          fontSize: widget.size * 0.28,
                          fontWeight: FontWeight.w700,
                          color: color,
                          height: 1,
                        ),
                      ),
                      if (widget.showLabel)
                        Text(
                          _getScoreLabel(widget.score),
                          style: TextStyle(
                            fontSize: widget.size * 0.12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.accentBlue;
    if (score >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.6) return 'Good';
    if (score >= 0.4) return 'Fair';
    return 'Low';
  }
}

/// Custom painter for circular score indicator
class _ScoreCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ScoreCirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color,
          color.withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Glow effect
    if (progress > 0.8) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}