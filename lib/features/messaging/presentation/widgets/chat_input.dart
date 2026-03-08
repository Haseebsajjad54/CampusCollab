import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';

/// Chat Input Widget
///
/// Text field and send button for chat
class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend(text);
      _controller.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isLoading,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Send button
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: _hasText ? 1.0 : 0.8),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _hasText && !widget.isLoading
                      ? AppColors.primaryGradient
                      : null,
                  color: _hasText && !widget.isLoading
                      ? null
                      : AppColors.border,
                  shape: BoxShape.circle,
                  boxShadow: _hasText && !widget.isLoading
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _hasText && !widget.isLoading ? _handleSend : null,
                    borderRadius: BorderRadius.circular(24),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textSecondary,
                          ),
                        ),
                      )
                          : Icon(
                        Icons.send,
                        color: _hasText
                            ? Colors.white
                            : AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
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