import 'package:campus_collab/features/auth/presentation/providers/auth_provider.dart';
import 'package:campus_collab/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:campus_collab/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../../core/config/theme/app_colors.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _meshController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _meshController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        final size = MediaQuery.of(context).size;
        final theme = Theme.of(context);

        return Scaffold(
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _meshController,
                builder: (context, child) {
                  return CustomPaint(
                    size: size,
                    painter: MeshGradientPainter(_meshController.value),
                  );
                },
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/noise.png',
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.12),
                        _buildHeader(theme),
                        const SizedBox(height: 60),
                        _buildLoginCard(theme, provider),
                        const SizedBox(height: 32),
                        _buildForgotPassword(theme),
                        const SizedBox(height: 40),
                        _buildSignUpLink(theme),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.glowShadow,
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  size: 40,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
          child: Text(
            'PartnerFind',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect. Collaborate. Create.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(ThemeData theme, AuthProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glass,
            AppColors.glass.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your journey',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: provider.loginEmailController,
                  label: 'University Email',
                  hint: 'your.email@university.edu',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: provider.loginPasswordController,
                  label: 'Password',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: provider.obscureLoginPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      provider.obscureLoginPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: provider.toggleLoginPasswordVisibility,
                  ),
                ),
                const SizedBox(height: 32),
                _buildLoginButton(theme, provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
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
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: AppColors.textSecondary),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(ThemeData theme, AuthProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: provider.isLoading ? null : AppColors.primaryGradient,
          color: provider.isLoading ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: provider.isLoading ? null : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: provider.isLoading
                ? null
                : () async {
              final success = await provider.signIn();
              if (success && mounted) {
                Navigator.of(context).pushReplacementNamed('/home');
              } else if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Login failed'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: provider.isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation(AppColors.textSecondary),
                ),
              )
                  : Text(
                'SIGN IN',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
        },
        child: Text(
          'Forgot your password?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.accent,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: theme.textTheme.bodyMedium,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
            },
            child: Text(
              'Sign Up',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final double animation;

  MeshGradientPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final offset = animation * 2 * math.pi + (i * 2 * math.pi / 3);
      final center = Offset(
        size.width * 0.5 + math.cos(offset) * size.width * 0.3,
        size.height * 0.5 + math.sin(offset) * size.height * 0.3,
      );

      paint.shader = RadialGradient(
        center: Alignment.center,
        radius: 1.5,
        colors: [
          AppColors.primary.withOpacity(0.3 - i * 0.1),
          AppColors.primaryDark.withOpacity(0.2 - i * 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.6));

      canvas.drawCircle(center, size.width * 0.6, paint);
    }

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.background,
        AppColors.background.withOpacity(0.8),
        AppColors.background,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(MeshGradientPainter oldDelegate) => true;
}