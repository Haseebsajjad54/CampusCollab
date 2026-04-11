import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        final isEmailSent = provider.isEmailSent;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              _buildGradientBackground(),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          IconButton(
                            onPressed: () {
                              provider.setEmailSent(false);
                              provider.forgotEmailController.clear();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 40),
                          if (!isEmailSent) ...[
                            _buildResetForm(theme, provider),
                          ] else ...[
                            _buildSuccessView(theme, provider),
                          ],
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                provider.setEmailSent(false);
                                provider.forgotEmailController.clear();
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_back,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.8),
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

  Widget _buildResetForm(ThemeData theme, AuthProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 50,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Forgot Password?',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 42,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No worries! Enter your email address and we\'ll send you a link to reset your password.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        _buildTextField(
          controller: provider.forgotEmailController,
          label: 'EMAIL ADDRESS',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 32),
        _buildResetButton(theme, provider),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(ThemeData theme, AuthProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () async {
          if (provider.forgotEmailController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter your email address'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          await provider.sendPasswordResetEmail();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: provider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'SEND RESET LINK',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme, AuthProvider provider) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 60,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Check Your Email',
          style: theme.textTheme.displaySmall?.copyWith(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent a password reset link to:',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          provider.forgotEmailController.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accentBlue, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Next Steps',
                    style: TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInstructionItem('1. Check your inbox (and spam folder)'),
              const SizedBox(height: 8),
              _buildInstructionItem('2. Click the reset link in the email'),
              const SizedBox(height: 8),
              _buildInstructionItem('3. Create a new password'),
              const SizedBox(height: 8),
              _buildInstructionItem('4. Sign in with your new password'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () async {
            await provider.sendPasswordResetEmail();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Resend Email',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}