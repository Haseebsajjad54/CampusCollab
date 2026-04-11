import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.initialValue,
    this.maxLines = 1,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);

    // Add listener to notify parent of changes
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if initialValue changes externally
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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
            controller: _controller,
            maxLines: widget.maxLines,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}